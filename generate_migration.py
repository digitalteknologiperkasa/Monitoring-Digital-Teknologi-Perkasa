import openpyxl
import re
import sys
import os

# Ensure UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

excel_path = r"d:\Vue\Monitoring Digitek (Log Error,Bug,Access Control and Version Control)\src\database\Dokument LIMS Access Control __ Matriks Hak Akses Web Pesantren Smart Digital (1).xlsx"
output_sql_path = r"d:\Vue\Monitoring Digitek (Log Error,Bug,Access Control and Version Control)\src\database\migration_access_control.sql"

def parse_permissions(perm_str):
    if not perm_str:
        return {'C': 'false', 'R': 'false', 'U': 'false', 'D': 'false', 'V': 'false'}
    perm_str = str(perm_str).upper()
    return {
        'C': 'true' if 'C' in perm_str else 'false',
        'R': 'true' if 'R' in perm_str else 'false',
        'U': 'true' if 'U' in perm_str else 'false',
        'D': 'true' if 'D' in perm_str else 'false',
        'V': 'true' if ('V' in perm_str or 'A' in perm_str) else 'false'
    }

def slugify(text):
    if not text: return "UNKNOWN"
    return re.sub(r'[^A-Z0-9]+', '_', str(text).upper()).strip('_')

print(f"Loading Excel: {excel_path}")
try:
    if not os.path.exists(excel_path):
        print(f"File not found: {excel_path}")
        sys.exit(1)

    wb = openpyxl.load_workbook(excel_path, data_only=True)
    sheet = wb.active
    rows = list(sheet.iter_rows(values_only=True))
    
    # Find header row
    header_row_idx = -1
    role_map = {}
    
    # Heuristic: Look for "YAYASAN" or "SUPER" (for Super Admin)
    for i, row in enumerate(rows[:20]):
        row_str = [str(c) for c in row if c]
        if any("YAYASAN" in s.upper() or "SUPER" in s.upper() for s in row_str):
            header_row_idx = i
            break
            
    if header_row_idx == -1:
        # Fallback: Row with most non-empty strings
        max_cols = 0
        for i, row in enumerate(rows[:10]):
            cols = len([c for c in row if c and isinstance(c, str) and len(c) > 2])
            if cols > max_cols:
                max_cols = cols
                header_row_idx = i
    
    print(f"Header row index: {header_row_idx}")
    if header_row_idx == -1:
         print("Could not find header row.")
         sys.exit(1)

    header_row = rows[header_row_idx]
    
    # Map roles
    for idx, cell in enumerate(header_row):
        if idx == 0: continue # Skip Component Name col
        if cell and isinstance(cell, str) and len(cell.strip()) > 1 and cell.strip() != '--':
            clean_name = cell.replace('\n', ' ').replace('\r', '').strip()
            role_map[idx] = clean_name
            
    print(f"Roles found: {role_map}")
    
    sql = ["DO $$", "DECLARE", "    v_project_id bigint;", "    v_role_id uuid;", "    v_comp_id uuid;", "BEGIN"]
    sql.append("    -- Get Project ID")
    sql.append("    SELECT id INTO v_project_id FROM projects WHERE name ILIKE '%Pesantren%' LIMIT 1;")
    sql.append("    IF v_project_id IS NULL THEN SELECT id INTO v_project_id FROM projects LIMIT 1; END IF;")
    sql.append("    IF v_project_id IS NULL THEN INSERT INTO projects (name, description) VALUES ('Default Project', 'Auto-generated') RETURNING id INTO v_project_id; END IF;")
    sql.append("")
    
    # Roles
    for idx, name in role_map.items():
        code = slugify(name)
        sql.append(f"    -- Role: {name}")
        sql.append(f"    INSERT INTO access_roles (project_id, role_code, role_name) VALUES (v_project_id, '{code}', '{name.replace('\'', '\'\'')}') ON CONFLICT (role_code) DO NOTHING;")
    sql.append("")
    
    # Components & Permissions
    for i in range(header_row_idx + 1, len(rows)):
        row = rows[i]
        comp_name = row[0]
        if not comp_name or not isinstance(comp_name, str) or not comp_name.strip(): continue
        comp_name = comp_name.strip().replace("'", "''")
        
        sql.append(f"    -- Component: {comp_name}")
        sql.append(f"    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = '{comp_name}';")
        sql.append(f"    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, '{comp_name}') RETURNING id INTO v_comp_id; END IF;")
        
        for col_idx, role_name in role_map.items():
            if col_idx < len(row):
                perms = parse_permissions(row[col_idx])
                role_code = slugify(role_name)
                sql.append(f"    SELECT id INTO v_role_id FROM access_roles WHERE role_code = '{role_code}';")
                sql.append(f"    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN")
                sql.append(f"        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, {perms['C']}, {perms['R']}, {perms['U']}, {perms['D']}, {perms['V']});")
                sql.append(f"    ELSE")
                sql.append(f"        UPDATE access_permissions SET can_create={perms['C']}, can_read={perms['R']}, can_update={perms['U']}, can_delete={perms['D']}, can_verify={perms['V']} WHERE role_id = v_role_id AND component_id = v_comp_id;")
                sql.append(f"    END IF;")
                
    sql.append("END $$;")
    
    with open(output_sql_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(sql))
        
    print(f"Generated: {output_sql_path}")

except Exception as e:
    print(f"Error: {e}")

DO $$
DECLARE
    v_project_id bigint;
    v_role_id uuid;
    v_comp_id uuid;
BEGIN
    -- Get Project ID
    SELECT id INTO v_project_id FROM projects WHERE name ILIKE '%Pesantren%' LIMIT 1;
    IF v_project_id IS NULL THEN SELECT id INTO v_project_id FROM projects LIMIT 1; END IF;
    IF v_project_id IS NULL THEN INSERT INTO projects (name, description) VALUES ('Default Project', 'Auto-generated') RETURNING id INTO v_project_id; END IF;

    -- Role: R1: Admin Yayasan
    INSERT INTO access_roles (project_id, role_code, role_name) VALUES (v_project_id, 'R1_ADMIN_YAYASAN', 'R1: Admin Yayasan') ON CONFLICT (role_code) DO NOTHING;
    -- Role: R2: Admin Unit Pendidikan
    INSERT INTO access_roles (project_id, role_code, role_name) VALUES (v_project_id, 'R2_ADMIN_UNIT_PENDIDIKAN', 'R2: Admin Unit Pendidikan') ON CONFLICT (role_code) DO NOTHING;
    -- Role: R3: Bendahara Yayasan
    INSERT INTO access_roles (project_id, role_code, role_name) VALUES (v_project_id, 'R3_BENDAHARA_YAYASAN', 'R3: Bendahara Yayasan') ON CONFLICT (role_code) DO NOTHING;
    -- Role: R4: Bendahara Unit
    INSERT INTO access_roles (project_id, role_code, role_name) VALUES (v_project_id, 'R4_BENDAHARA_UNIT', 'R4: Bendahara Unit') ON CONFLICT (role_code) DO NOTHING;
    -- Role: R5: Pengawas Belanja Khusus
    INSERT INTO access_roles (project_id, role_code, role_name) VALUES (v_project_id, 'R5_PENGAWAS_BELANJA_KHUSUS', 'R5: Pengawas Belanja Khusus') ON CONFLICT (role_code) DO NOTHING;
    -- Role: R6: Presensi Santri Tap
    INSERT INTO access_roles (project_id, role_code, role_name) VALUES (v_project_id, 'R6_PRESENSI_SANTRI_TAP', 'R6: Presensi Santri Tap') ON CONFLICT (role_code) DO NOTHING;
    -- Role: R7: Pendaftaran Baru PPDB
    INSERT INTO access_roles (project_id, role_code, role_name) VALUES (v_project_id, 'R7_PENDAFTARAN_BARU_PPDB', 'R7: Pendaftaran Baru PPDB') ON CONFLICT (role_code) DO NOTHING;

    -- Component: Jurnalku
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Jurnalku';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Jurnalku') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Monitoring Pengajar
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Monitoring Pengajar';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Monitoring Pengajar') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Basis Data: Tahun Ajaran
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Basis Data: Tahun Ajaran';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Basis Data: Tahun Ajaran') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Basis Data: Unit Pendidikan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Basis Data: Unit Pendidikan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Basis Data: Unit Pendidikan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Basis Data: Santri
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Basis Data: Santri';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Basis Data: Santri') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Basis Data: Kamar
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Basis Data: Kamar';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Basis Data: Kamar') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Basis Data: Pegawai
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Basis Data: Pegawai';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Basis Data: Pegawai') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Basis Data: Jadwal PSB
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Basis Data: Jadwal PSB';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Basis Data: Jadwal PSB') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: PPDB: Pendaftaran
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'PPDB: Pendaftaran';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'PPDB: Pendaftaran') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: PPDB: Info Grafis
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'PPDB: Info Grafis';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'PPDB: Info Grafis') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: PPDB: Rekap Formulir
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'PPDB: Rekap Formulir';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'PPDB: Rekap Formulir') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: PPDB: Tampilan Web
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'PPDB: Tampilan Web';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'PPDB: Tampilan Web') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Penerimaan: Terverifikasi
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Penerimaan: Terverifikasi';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Penerimaan: Terverifikasi') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Penerimaan: Diterima
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Penerimaan: Diterima';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Penerimaan: Diterima') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Kelas: Daftar Kelas
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Kelas: Daftar Kelas';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Kelas: Daftar Kelas') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Kelas: Mutasi Kelas
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Kelas: Mutasi Kelas';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Kelas: Mutasi Kelas') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Kelas: Riwayat
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Kelas: Riwayat';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Kelas: Riwayat') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Basis Data: Alumni
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Basis Data: Alumni';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Basis Data: Alumni') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Layanan: Perangkat
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Layanan: Perangkat';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Layanan: Perangkat') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Perangkat Tap: Akses Presensi
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Perangkat Tap: Akses Presensi';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Perangkat Tap: Akses Presensi') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Perangkat Tap: Kegiatan Presesnsi
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Perangkat Tap: Kegiatan Presesnsi';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Perangkat Tap: Kegiatan Presesnsi') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Perangkat Tap: Verifikasi Kegiatan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Perangkat Tap: Verifikasi Kegiatan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Perangkat Tap: Verifikasi Kegiatan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Keuangan: Pos Akun
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Keuangan: Pos Akun';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Keuangan: Pos Akun') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Keuangan: Bank
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Keuangan: Bank';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Keuangan: Bank') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Keuangan: Transaksi Kas
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Keuangan: Transaksi Kas';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Keuangan: Transaksi Kas') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Keuangan: Transaksi Bank
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Keuangan: Transaksi Bank';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Keuangan: Transaksi Bank') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Keuangan: Cek Transfer
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Keuangan: Cek Transfer';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Keuangan: Cek Transfer') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: SPP: Konfigurasi SPP
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'SPP: Konfigurasi SPP';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'SPP: Konfigurasi SPP') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: SPP: Konfigurasi NON SPP
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'SPP: Konfigurasi NON SPP';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'SPP: Konfigurasi NON SPP') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: SPP: Transaksi SPP
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'SPP: Transaksi SPP';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'SPP: Transaksi SPP') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: SPP: Transaksi SPP Kolektif
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'SPP: Transaksi SPP Kolektif';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'SPP: Transaksi SPP Kolektif') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: SPP: Transaksi NON SPP
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'SPP: Transaksi NON SPP';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'SPP: Transaksi NON SPP') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Tabungan: Santri
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Tabungan: Santri';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Tabungan: Santri') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Tabungan: Pegawai
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Tabungan: Pegawai';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Tabungan: Pegawai') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Mitra Usaha: Merchant
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Mitra Usaha: Merchant';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Mitra Usaha: Merchant') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Mitra Usaha: Penagihan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Mitra Usaha: Penagihan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Mitra Usaha: Penagihan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Mitra Usaha: Konfigurasi
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Mitra Usaha: Konfigurasi';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Mitra Usaha: Konfigurasi') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Mitra Usaha: Ijin Belanja Khusus
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Mitra Usaha: Ijin Belanja Khusus';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Mitra Usaha: Ijin Belanja Khusus') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Mitra Usaha: Rekap Ijin Khusus
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Mitra Usaha: Rekap Ijin Khusus';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Mitra Usaha: Rekap Ijin Khusus') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Kepegawaian Versi 2.0: Area Absensi
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Kepegawaian Versi 2.0: Area Absensi';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Kepegawaian Versi 2.0: Area Absensi') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Kepegawaian Versi 2.0: Libur Pegawai
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Kepegawaian Versi 2.0: Libur Pegawai';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Kepegawaian Versi 2.0: Libur Pegawai') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Kepegawaian Versi 2.0: Pengajuan Ijin
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Kepegawaian Versi 2.0: Pengajuan Ijin';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Kepegawaian Versi 2.0: Pengajuan Ijin') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Kepegawaian Versi 2.0: Absesnsi Manual
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Kepegawaian Versi 2.0: Absesnsi Manual';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Kepegawaian Versi 2.0: Absesnsi Manual') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Kepegawaian Versi 2.0: 
Presensi Mengajar Manual Kolektif
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Kepegawaian Versi 2.0: 
Presensi Mengajar Manual Kolektif';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Kepegawaian Versi 2.0: 
Presensi Mengajar Manual Kolektif') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Penggajian: Pengaturan Penggajian V.1
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Penggajian: Pengaturan Penggajian V.1';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Penggajian: Pengaturan Penggajian V.1') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Penggajian: Pembayaran Gaji V.1
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Penggajian: Pembayaran Gaji V.1';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Penggajian: Pembayaran Gaji V.1') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Penggajian: Pengaturan Penggajian V.2
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Penggajian: Pengaturan Penggajian V.2';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Penggajian: Pengaturan Penggajian V.2') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Penggajian: Pembayaran Gaji V.2
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Penggajian: Pembayaran Gaji V.2';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Penggajian: Pembayaran Gaji V.2') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Publikasi: Tanya Ustadz
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Publikasi: Tanya Ustadz';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Publikasi: Tanya Ustadz') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Publikasi: Artikel/Berita
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Publikasi: Artikel/Berita';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Publikasi: Artikel/Berita') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Publikasi: Link You Tube
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Publikasi: Link You Tube';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Publikasi: Link You Tube') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Publikasi: Pesan Siaran
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Publikasi: Pesan Siaran';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Publikasi: Pesan Siaran') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Poin Pelanggaran
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Poin Pelanggaran';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Poin Pelanggaran') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Pelanggaran
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Pelanggaran';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Pelanggaran') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Perijinan Santri
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Perijinan Santri';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Perijinan Santri') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, false);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Mata Pelajaran
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Mata Pelajaran';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Mata Pelajaran') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Jadwal Pelajaran
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Jadwal Pelajaran';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Jadwal Pelajaran') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Kitab
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Kitab';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Kitab') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Presensi Santri
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Presensi Santri';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Presensi Santri') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Tahfidz
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Tahfidz';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Tahfidz') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Materi Kitab
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Materi Kitab';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Materi Kitab') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Akademik: Keluhan Kesehatan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Akademik: Keluhan Kesehatan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Akademik: Keluhan Kesehatan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Laporan: Keuangan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Laporan: Keuangan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Laporan: Keuangan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Laporan: Kepegawaian
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Laporan: Kepegawaian';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Laporan: Kepegawaian') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Laporan: Pendanaan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Laporan: Pendanaan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Laporan: Pendanaan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Laporan: Kesantrian
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Laporan: Kesantrian';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Laporan: Kesantrian') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Laporan: Mitra Usaha
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Laporan: Mitra Usaha';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Laporan: Mitra Usaha') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Laporan: Tabungan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Laporan: Tabungan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Laporan: Tabungan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Laporan: Pembayaran Santri
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Laporan: Pembayaran Santri';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Laporan: Pembayaran Santri') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Virtual Account: Riwayat
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Virtual Account: Riwayat';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Virtual Account: Riwayat') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Virtual Account: Pencairan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Virtual Account: Pencairan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Virtual Account: Pencairan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Pengaturan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Pengaturan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Pengaturan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: WhatsApp: Konfigurasi
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'WhatsApp: Konfigurasi';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'WhatsApp: Konfigurasi') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: WhatsApp: Tagihan SPP
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'WhatsApp: Tagihan SPP';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'WhatsApp: Tagihan SPP') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: WhatsApp: Tagihan Khusus
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'WhatsApp: Tagihan Khusus';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'WhatsApp: Tagihan Khusus') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Hak Akses
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Hak Akses';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Hak Akses') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Surat: Template Surat
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Surat: Template Surat';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Surat: Template Surat') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Surat: Agenda Surat Masuk & Keluar
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Surat: Agenda Surat Masuk & Keluar';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Surat: Agenda Surat Masuk & Keluar') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, true, true, true, true, true);
    ELSE
        UPDATE access_permissions SET can_create=true, can_read=true, can_update=true, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Panduan
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Panduan';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Panduan') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, true, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=true, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, true);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=true WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    -- Component: Log Out
    SELECT id INTO v_comp_id FROM app_components WHERE project_id = v_project_id AND name = 'Log Out';
    IF v_comp_id IS NULL THEN INSERT INTO app_components (project_id, name) VALUES (v_project_id, 'Log Out') RETURNING id INTO v_comp_id; END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R1_ADMIN_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R2_ADMIN_UNIT_PENDIDIKAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R3_BENDAHARA_YAYASAN';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R4_BENDAHARA_UNIT';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R5_PENGAWAS_BELANJA_KHUSUS';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R6_PRESENSI_SANTRI_TAP';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
    SELECT id INTO v_role_id FROM access_roles WHERE role_code = 'R7_PENDAFTARAN_BARU_PPDB';
    IF NOT EXISTS (SELECT 1 FROM access_permissions WHERE role_id = v_role_id AND component_id = v_comp_id) THEN
        INSERT INTO access_permissions (role_id, component_id, can_create, can_read, can_update, can_delete, can_verify) VALUES (v_role_id, v_comp_id, false, false, false, false, false);
    ELSE
        UPDATE access_permissions SET can_create=false, can_read=false, can_update=false, can_delete=false, can_verify=false WHERE role_id = v_role_id AND component_id = v_comp_id;
    END IF;
END $$;
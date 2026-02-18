
import os

file_path = r'd:\Vue\Monitoring Digitek (Log Error,Bug,Access Control and Version Control)\src\views\FeatureManagement.vue'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"Total lines read: {len(lines)}")

# Find start of Lampiran
start_idx = -1
for i, line in enumerate(lines):
    if '<!-- Lampiran Pendukung -->' in line:
        start_idx = i
        break

print(f"Start index: {start_idx}")

# Find start of Sidebar
sidebar_idx = -1
for i, line in enumerate(lines):
    if '<!-- Sidebar Content (Right) -->' in line:
        sidebar_idx = i
        break

print(f"Sidebar index: {sidebar_idx}")

if start_idx == -1 or sidebar_idx == -1:
    print("Markers not found")
    exit(1)

# The line before sidebar_idx should be the closing div of col-span-8
closing_div_idx = sidebar_idx - 1
while closing_div_idx > start_idx and '</div>' not in lines[closing_div_idx]:
    closing_div_idx -= 1

print(f"Closing div index: {closing_div_idx}")
print(f"Content at closing div: {lines[closing_div_idx].strip()}")

content_to_move = lines[start_idx:closing_div_idx]
print(f"Lines to move: {len(content_to_move)}")

remaining_lines = lines[:start_idx] + lines[closing_div_idx:]
print(f"Remaining lines count: {len(remaining_lines)}")

# Find insertion point
footer_idx = -1
for i, line in enumerate(remaining_lines):
    if '<!-- Modal Footer -->' in line:
        footer_idx = i
        break

print(f"Footer index in remaining: {footer_idx}")

# Find insertion point (3rd closing div before footer)
div_count = 0
insert_idx = -1
for i in range(footer_idx - 1, -1, -1):
    if '</div>' in remaining_lines[i]:
        div_count += 1
        if div_count == 3:
            insert_idx = i
            break

print(f"Insert index: {insert_idx}")
print(f"Content at insert index: {remaining_lines[insert_idx].strip()}")

wrapper_start = '              <!-- Full Width Content (Moved) -->\n              <div class="col-span-12 space-y-6">\n'
wrapper_end = '              </div>\n'

final_lines = remaining_lines[:insert_idx] + [wrapper_start] + content_to_move + [wrapper_end] + remaining_lines[insert_idx:]

print(f"Final lines count: {len(final_lines)}")

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(final_lines)

print("Write complete.")

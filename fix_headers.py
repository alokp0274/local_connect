"""
Fix dangling library doc comments by converting /// to // for file headers.
"""
import os
import re

LIB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'lib')

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    changed = False
    new_lines = []
    in_header = True  # We're in the file header region
    
    for line in lines:
        if in_header:
            # Convert /// to // in the header (before first import/class/etc)
            stripped = line.strip()
            if stripped.startswith('///'):
                new_line = line.replace('///', '//', 1)
                new_lines.append(new_line)
                changed = True
                continue
            elif stripped == '' or stripped.startswith('//'):
                new_lines.append(line)
                continue
            else:
                in_header = False
        new_lines.append(line)
    
    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
    return changed

def main():
    count = 0
    for root, dirs, files in os.walk(LIB_DIR):
        for f in sorted(files):
            if not f.endswith('.dart'):
                continue
            filepath = os.path.join(root, f)
            if fix_file(filepath):
                count += 1
    print(f"Fixed {count} files.")

if __name__ == '__main__':
    main()

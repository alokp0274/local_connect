"""
Fix all broken relative imports by converting to package-absolute imports.
Uses filename-based resolution since all .dart filenames in the project are unique.
"""
import os
import re

LIB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'lib')
PACKAGE = 'local_connect'

def collect_dart_files():
    """Build a map of basename -> lib-relative path for all dart files."""
    basename_map = {}
    duplicates = []
    for root, dirs, files in os.walk(LIB_DIR):
        for f in files:
            if f.endswith('.dart'):
                full = os.path.join(root, f)
                rel = os.path.relpath(full, LIB_DIR).replace('\\', '/')
                if f in basename_map:
                    duplicates.append((f, basename_map[f], rel))
                basename_map[f] = rel
    if duplicates:
        print("WARNING: Duplicate basenames found:")
        for name, p1, p2 in duplicates:
            print(f"  {name}: {p1} vs {p2}")
    return basename_map

def fix_file_imports(filepath, basename_map):
    """Fix all relative imports in a single dart file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    changed = False
    new_lines = []
    
    for line in lines:
        # Match relative imports: import '...' or import "..."
        m = re.match(r"""^(\s*import\s+['"])(\.\.[^'"]+|\.\/[^'"]+)(['"];?\s*)$""", line)
        if m:
            prefix = m.group(1)
            rel_path = m.group(2)
            suffix = m.group(3)
            
            # Extract basename from the relative import
            basename = os.path.basename(rel_path)
            
            if basename in basename_map:
                new_path = f'package:{PACKAGE}/{basename_map[basename]}'
                new_line = f"{prefix}{new_path}{suffix}"
                if new_line != line:
                    new_lines.append(new_line)
                    changed = True
                    continue
                else:
                    new_lines.append(line)
                    continue
            else:
                print(f"  WARNING: Could not resolve '{rel_path}' (basename '{basename}') in {os.path.relpath(filepath, LIB_DIR)}")
                new_lines.append(line)
                continue
        
        # Also match part/export with relative paths
        m2 = re.match(r"""^(\s*(?:part|export)\s+['"])(\.\.[^'"]+|\.\/[^'"]+)(['"];?\s*)$""", line)
        if m2:
            prefix = m2.group(1)
            rel_path = m2.group(2)
            suffix = m2.group(3)
            basename = os.path.basename(rel_path)
            if basename in basename_map:
                new_path = f'package:{PACKAGE}/{basename_map[basename]}'
                new_line = f"{prefix}{new_path}{suffix}"
                if new_line != line:
                    new_lines.append(new_line)
                    changed = True
                    continue
        
        new_lines.append(line)
    
    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(new_lines))
    
    return changed

def main():
    print("=== Import Fixer: Converting relative imports to package imports ===\n")
    
    # Step 1: Build basename map
    basename_map = collect_dart_files()
    print(f"Found {len(basename_map)} dart files\n")
    
    # Step 2: Fix imports in all files
    fixed_count = 0
    for root, dirs, files in os.walk(LIB_DIR):
        for f in files:
            if f.endswith('.dart'):
                filepath = os.path.join(root, f)
                rel = os.path.relpath(filepath, LIB_DIR).replace('\\', '/')
                if fix_file_imports(filepath, basename_map):
                    fixed_count += 1
                    print(f"  Fixed: {rel}")
    
    print(f"\nDone! Fixed imports in {fixed_count} files.")

if __name__ == '__main__':
    main()

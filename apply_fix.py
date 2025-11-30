import subprocess
import re

def apply_fix():
    # Run cleanup script to get duplicates
    result = subprocess.run(['python3', 'cleanup_project.py'], capture_output=True, text=True)
    output = result.stdout.splitlines()
    
    project_path = 'TBDApp.xcodeproj/project.pbxproj'
    with open(project_path, 'r') as f:
        project_lines = f.readlines()
        
    lines_to_remove = set()
    
    # Regex to parse script output
    pattern = re.compile(r'Line (\d+): Duplicate BuildFile ([0-9A-F]{24})')
    
    for line in output:
        match = pattern.match(line)
        if match:
            line_num = int(match.group(1))
            bid = match.group(2)
            
            # Mark line_num for removal (PBXBuildFile definition)
            # line_num is 1-based from the script output
            lines_to_remove.add(line_num - 1)
            
            # Find usage in SourcesBuildPhase
            for i, pline in enumerate(project_lines):
                if bid in pline and 'in Sources' in pline and '=' not in pline:
                    lines_to_remove.add(i)
    
    if not lines_to_remove:
        print("No duplicates found to remove.")
        return

    print(f"Removing {len(lines_to_remove)} lines...")
    
    # Write back preserving order, skipping removed lines
    with open(project_path, 'w') as f:
        for i, line in enumerate(project_lines):
            if i not in lines_to_remove:
                f.write(line)
                
    print("Project file updated.")

if __name__ == '__main__':
    apply_fix()

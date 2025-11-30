import subprocess
import re
import json

def generate_fix():
    # Run cleanup script to get duplicates
    result = subprocess.run(['python3', 'cleanup_project.py'], capture_output=True, text=True)
    output = result.stdout.splitlines()
    
    removals = []
    
    # Regex to parse script output
    # Line 42: Duplicate BuildFile 1E42BD09F047A68A90A40599 for FileRef A8D493834C7333FC98BE2BC7
    pattern = re.compile(r'Line (\d+): Duplicate BuildFile ([0-9A-F]{24})')
    
    project_path = 'TBDApp.xcodeproj/project.pbxproj'
    with open(project_path, 'r') as f:
        project_lines = f.readlines()
        
    for line in output:
        match = pattern.match(line)
        if match:
            line_num = int(match.group(1))
            bid = match.group(2)
            
            # Add removal for PBXBuildFile definition
            # We use the exact content of the line to be safe
            target_content = project_lines[line_num - 1] # 1-based to 0-based
            removals.append({
                "StartLine": line_num,
                "EndLine": line_num,
                "TargetContent": target_content,
                "ReplacementContent": "",
                "AllowMultiple": False
            })
            
            # Find usage in SourcesBuildPhase
            # We look for the BID in the file
            for i, pline in enumerate(project_lines):
                if bid in pline and 'in Sources' in pline and '=' not in pline:
                    # This is likely the SourcesBuildPhase entry
                    # It should look like: BID /* Name in Sources */,
                    removals.append({
                        "StartLine": i + 1,
                        "EndLine": i + 1,
                        "TargetContent": pline,
                        "ReplacementContent": "",
                        "AllowMultiple": False
                    })
    
    print(json.dumps(removals, indent=2))

if __name__ == '__main__':
    generate_fix()

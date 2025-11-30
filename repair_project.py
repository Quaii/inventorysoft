import re
import uuid

def generate_id():
    return uuid.uuid4().hex[:24].upper()

def repair_project():
    project_path = 'TBDApp.xcodeproj/project.pbxproj'
    with open(project_path, 'r') as f:
        lines = f.readlines()

    # Target Sources Phase ID for TBDApp_macOS
    target_phase_id = 'BC0FA6301BFA2AFD38D4CF8E'
    
    # Regex to find FileRefs
    # 315: 		F87521AFE6A1657599BD9C32 /* ImportProfile.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ImportProfile.swift; sourceTree = "<group>"; };
    file_ref_pattern = re.compile(r'^\s*([0-9A-F]{24}) /\* (.*) \*/ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = (.*); sourceTree = .*; };')
    
    # Regex to find BuildFiles
    # 98: 		6BA648E445F155ABE785E303 /* ImportProfile.swift in Sources */ = {isa = PBXBuildFile; fileRef = F87521AFE6A157C6E9553DB1 /* ImportProfile.swift */; };
    build_file_pattern = re.compile(r'^\s*([0-9A-F]{24}) /\* (.*) in Sources \*/ = {isa = PBXBuildFile; fileRef = ([0-9A-F]{24}) .*; };')

    all_swift_files = {} # fileRef -> name
    existing_build_files = {} # fileRef -> [buildFileID]
    
    # Parse FileRefs
    for line in lines:
        match = file_ref_pattern.match(line)
        if match:
            fid, name, path = match.groups()
            # We only care about files in Core or Features (roughly)
            # But path is just filename usually.
            # We'll assume all swift files should be in the target for now.
            all_swift_files[fid] = name

    # Parse BuildFiles
    for line in lines:
        match = build_file_pattern.match(line)
        if match:
            bid, name, fid = match.groups()
            if fid not in existing_build_files:
                existing_build_files[fid] = []
            existing_build_files[fid].append(bid)

    # Find the Sources Build Phase content
    phase_start_index = -1
    phase_end_index = -1
    files_list_start = -1
    
    for i, line in enumerate(lines):
        if f'{target_phase_id} /* Sources */ = {{' in line:
            phase_start_index = i
        if phase_start_index != -1 and 'files = (' in line and i > phase_start_index:
            files_list_start = i
        if phase_start_index != -1 and '};' in line and i > phase_start_index:
            # This might be end of files list or end of phase object
            # We look for end of phase object
            if lines[i-1].strip() == ');' or lines[i-2].strip() == ');':
                 phase_end_index = i
                 break
    
    if phase_start_index == -1:
        print("Could not find target build phase")
        return

    # Collect BIDs currently in the target phase
    current_phase_bids = set()
    for i in range(files_list_start + 1, phase_end_index):
        line = lines[i].strip()
        if line == ');':
            break
        # Extract BID
        # 				C05C8CE4E8EAAF31AD87A85F /* AnalyticsConfigRepository.swift in Sources */,
        if not line:
            continue
        bid = line.split()[0]
        current_phase_bids.add(bid)

    # Identify missing files
    files_to_add = [] # (fid, name)
    
    for fid, name in all_swift_files.items():
        # Check if this file is linked in the target phase
        is_linked = False
        if fid in existing_build_files:
            for bid in existing_build_files[fid]:
                if bid in current_phase_bids:
                    is_linked = True
                    break
        
        if not is_linked:
            files_to_add.append((fid, name))

    if not files_to_add:
        print("No missing files found.")
        return

    print(f"Found {len(files_to_add)} missing files to add to target.")
    
    # Generate new BuildFiles
    new_build_files = []
    new_phase_entries = []
    
    for fid, name in files_to_add:
        bid = generate_id()
        # 		6BA648E445F155ABE785E303 /* ImportProfile.swift in Sources */ = {isa = PBXBuildFile; fileRef = F87521AFE6A157C6E9553DB1 /* ImportProfile.swift */; };
        build_file_entry = f'\t\t{bid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};\n'
        new_build_files.append(build_file_entry)
        
        # 				6BA648E445F155ABE785E303 /* ImportProfile.swift in Sources */,
        phase_entry = f'\t\t\t\t{bid} /* {name} in Sources */,\n'
        new_phase_entries.append(phase_entry)

    # Insert new BuildFiles at the end of PBXBuildFile section
    # Find End PBXBuildFile section
    build_file_section_end = -1
    for i, line in enumerate(lines):
        if 'End PBXBuildFile section' in line:
            build_file_section_end = i
            break
            
    if build_file_section_end != -1:
        lines.insert(build_file_section_end, "".join(new_build_files))
        
        # Adjust indices
        files_list_start += 1 # We inserted one block
        # Actually indices shift by len(new_build_files)
        # But we need to find files_list_start again or just use the content match
    
    # Re-find phase list start because lines shifted
    for i, line in enumerate(lines):
        if f'{target_phase_id} /* Sources */ = {{' in line:
            # search forward for files = (
            for j in range(i, len(lines)):
                if 'files = (' in lines[j]:
                    files_list_start = j
                    break
            break

    # Insert new phase entries
    lines.insert(files_list_start + 1, "".join(new_phase_entries))

    with open(project_path, 'w') as f:
        f.writelines(lines)
        
    print("Project file repaired.")

if __name__ == '__main__':
    repair_project()

import re
import sys

def parse_project(path):
    with open(path, 'r') as f:
        lines = f.readlines()

    # Regex patterns
    # 98: 		6BA648E445F155ABE785E303 /* ImportProfile.swift in Sources */ = {isa = PBXBuildFile; fileRef = F87521AFE6A157C6E9553DB1 /* ImportProfile.swift */; };
    build_file_pattern = re.compile(r'^\s*([0-9A-F]{24}) /\* (.*) in Sources \*/ = {isa = PBXBuildFile; fileRef = ([0-9A-F]{24}) /\* (.*) \*/; };')
    
    # 315: 		F87521AFE6A1657599BD9C32 /* ImportProfile.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ImportProfile.swift; sourceTree = "<group>"; };
    file_ref_pattern = re.compile(r'^\s*([0-9A-F]{24}) /\* (.*) \*/ = {isa = PBXFileReference;.*; path = (.*); sourceTree = .*; };')

    file_refs = {} # id -> {path, name, line_num}
    path_to_refs = {} # path -> [ids]
    
    build_files = {} # id -> {fileRef, name, line_num}
    ref_to_builds = {} # fileRef -> [ids]

    # First pass: find FileRefs
    in_refs = False
    for i, line in enumerate(lines):
        if 'Begin PBXFileReference section' in line:
            in_refs = True
            continue
        if 'End PBXFileReference section' in line:
            in_refs = False
            continue
        
        if in_refs:
            match = file_ref_pattern.match(line)
            if match:
                fid, name, path = match.groups()
                # Remove quotes from path if present
                path = path.strip('"')
                file_refs[fid] = {'path': path, 'name': name, 'line': i + 1}
                if path not in path_to_refs:
                    path_to_refs[path] = []
                path_to_refs[path].append(fid)

    # Second pass: find BuildFiles
    in_builds = False
    for i, line in enumerate(lines):
        if 'Begin PBXBuildFile section' in line:
            in_builds = True
            continue
        if 'End PBXBuildFile section' in line:
            in_builds = False
            continue
            
        if in_builds:
            match = build_file_pattern.match(line)
            if match:
                bid, name, fid, fname = match.groups()
                build_files[bid] = {'fileRef': fid, 'name': name, 'line': i + 1}
                if fid not in ref_to_builds:
                    ref_to_builds[fid] = []
                ref_to_builds[fid].append(bid)

    # Identify duplicates
    duplicates_to_remove = [] # list of (line_num, description)

    # 1. Duplicate FileRefs (same path)
    for path, fids in path_to_refs.items():
        if len(fids) > 1:
            print(f"Duplicate FileRefs for path '{path}': {fids}")
            # Keep the first one, remove others?
            # Or keep the one that is used?
            # We need to check usage in BuildFiles.
            
            # Strategy: Keep the one that has the most BuildFiles, or the first one.
            # But if we remove a FileRef, we must also remove its BuildFiles.
            
            # Let's see which ones are used.
            used_fids = [fid for fid in fids if fid in ref_to_builds]
            
            if not used_fids:
                # None used? Keep first, remove others.
                keep = fids[0]
            else:
                # Keep the first used one.
                keep = used_fids[0]
            
            for fid in fids:
                if fid != keep:
                    duplicates_to_remove.append((file_refs[fid]['line'], f"Duplicate FileRef for {path} ({fid})"))
                    # Also mark its BuildFiles for removal
                    if fid in ref_to_builds:
                        for bid in ref_to_builds[fid]:
                            duplicates_to_remove.append((build_files[bid]['line'], f"BuildFile for duplicate FileRef {fid}"))

    # 2. Duplicate BuildFiles (same FileRef)
    for fid, bids in ref_to_builds.items():
        if len(bids) > 1:
            print(f"Duplicate BuildFiles for FileRef {fid}: {bids}")
            # Keep first, remove others
            keep = bids[0]
            for bid in bids[1:]:
                duplicates_to_remove.append((build_files[bid]['line'], f"Duplicate BuildFile {bid} for FileRef {fid}"))

    # 3. Find SourcesBuildPhase entries for removed BuildFiles
    # We need to scan SourcesBuildPhase for the removed BIDs.
    removed_bids = set()
    for line_num, desc in duplicates_to_remove:
        # Find the BID associated with this line if it's a BuildFile line
        # This is tricky without reverse lookup or parsing the line again.
        # But we know the line number.
        pass

    # Actually, simpler approach:
    # Just output the line numbers to remove from PBXBuildFile and PBXFileReference sections.
    # And then we need to grep for the BIDs in PBXSourcesBuildPhase.
    
    return duplicates_to_remove

if __name__ == '__main__':
    dupes = parse_project('TBDApp.xcodeproj/project.pbxproj')
    for line, desc in sorted(dupes):
        print(f"Line {line}: {desc}")

# Script Migration Plan

## Current State
- **Total scripts in /scripts root**: 50 files
- **Already organized**: 15 files (in subfolders)
- **To migrate**: 35 files to deprecated/

## Scripts to Keep (Already Organized)
These are already in the correct location:
- `/scripts/core/` (3 files): start.sh, stop.sh, rebuild.sh
- `/scripts/desktop/` (3 files): launch-desktop.sh, launch-app.sh, configure-menu.sh
- `/scripts/tools/` (3 files): install-core.sh, install-full.sh, install-malware.sh
- `/scripts/malware/` (2 files): analyze.sh, setup-lab.sh
- `/scripts/utils/` (5 files): backup-config.sh, debug-menu.sh, ensure-panel-tools.sh, configure-panel-icons.sh, setup-claude.sh

## Critical Scripts Referenced by Other Files
These scripts are referenced and need special handling:
1. **kali-desktop.sh** - Referenced by multiple scripts
   - Action: Keep as symlink to desktop/launch-desktop.sh
2. **kali-gui-app.sh** - Referenced in start-kali.sh
   - Action: Keep as symlink to desktop/launch-app.sh
3. **stop-kali.sh** - Referenced in start-kali.sh
   - Action: Keep as symlink to core/stop.sh
4. **start-kali.sh** - Base start script
   - Action: Keep as symlink to core/start.sh

## Migration Groups

### Group 1: Menu/Panel Fix Scripts (26 files)
All superseded by `/scripts/desktop/configure-menu.sh`:
- clean-malware-menu.sh
- debug-kali-menu.sh
- final-panel-fix.sh
- fix-applications-menu.sh
- fix-kali-menu.sh
- fix-kali-tools-menu.sh
- fix-kali-whisker-categories.sh
- fix-kali-whisker-menu.sh
- fix-malware-menu-categories.sh
- fix-malware-panel.sh
- fix-panel-complete.sh
- fix-panel-menu.sh
- fix-panel-now.sh
- fix-panel-properly.sh
- fix-root-desktop-menu.sh
- fix-vertical-panel.sh
- fix-whisker-menu.sh
- force-kali-menu-fix.sh
- force-vertical-panel.sh
- quick-menu-fix.sh
- rebuild-xfce-menu.sh
- replace-directory-menu.sh
- reset-panel.sh
- restore-kali-panel.sh
- restore-panel-ux.sh
- restore-panel.sh
- setup-whisker-menu.sh
- simple-panel-fix.sh

### Group 2: Installation Scripts (5 files)
All superseded by scripts in `/scripts/tools/`:
- install-all-kali-tools.sh → tools/install-full.sh
- install-applications-menu.sh → part of desktop/configure-menu.sh
- install-kali-metapackages.sh → tools/install-full.sh
- install-kali-tools-direct.sh → tools/install-full.sh
- setup-tools.sh → tools/install-core.sh

### Group 3: Malware Scripts (4 files)
Superseded by `/scripts/malware/`:
- kali-malware-analysis.sh → malware/setup-lab.sh
- safe-analyze.sh → malware/analyze.sh
- setup-malware-analysis.sh → malware/setup-lab.sh
- start-malware-lab.sh → core/start.sh --malware
- start-secure-malware-lab.sh → core/start.sh --isolated

### Group 4: Launch Scripts (3 files)
Superseded by unified launchers:
- start-proper-desktop.sh → core/start.sh + desktop/launch-desktop.sh
- run-gui.sh → desktop/launch-app.sh
- x11-docker.sh → handled by launch-desktop.sh

### Group 5: Other Scripts (3 files)
- setup-claude.sh → utils/setup-claude.sh (duplicate)
- setup-x11.sh → handled by launch-desktop.sh
- test-kali-menu-install.sh → deprecated/testing/
- test-kali-packages.sh → deprecated/testing/
- test-whisker-menu.sh → deprecated/testing/

## Implementation Steps

### Step 1: Create Symlinks for Compatibility
```bash
# Create backwards-compatible symlinks
ln -sf core/start.sh scripts/start-kali.sh
ln -sf core/stop.sh scripts/stop-kali.sh
ln -sf desktop/launch-desktop.sh scripts/kali-desktop.sh
ln -sf desktop/launch-app.sh scripts/kali-gui-app.sh
```

### Step 2: Create Deprecated Structure
```bash
mkdir -p scripts/deprecated/{menu-fixes,installation,malware,launch,testing,other}
```

### Step 3: Move Scripts
```bash
# Move menu/panel scripts
mv scripts/{clean-malware-menu.sh,debug-kali-menu.sh,final-panel-fix.sh,...} scripts/deprecated/menu-fixes/

# Move installation scripts
mv scripts/{install-all-kali-tools.sh,install-applications-menu.sh,...} scripts/deprecated/installation/

# Move old malware scripts
mv scripts/{kali-malware-analysis.sh,safe-analyze.sh,...} scripts/deprecated/malware/

# Move old launch scripts
mv scripts/{start-proper-desktop.sh,run-gui.sh,x11-docker.sh} scripts/deprecated/launch/

# Move test scripts
mv scripts/{test-kali-menu-install.sh,test-kali-packages.sh,test-whisker-menu.sh} scripts/deprecated/testing/

# Move other scripts
mv scripts/{setup-claude.sh,setup-x11.sh} scripts/deprecated/other/
```

### Step 4: Update References
Files that need updating:
1. None - all references point to scripts we're keeping as symlinks

### Step 5: Create Migration Log
Document what was moved and why for future reference.

## Success Criteria
- ✅ All functionality preserved through symlinks
- ✅ No broken references
- ✅ Clean /scripts directory with only organized subfolders
- ✅ Deprecated scripts preserved for reference
- ✅ Clear documentation of changes

## Rollback Plan
If issues occur:
```bash
# Move everything back from deprecated
mv scripts/deprecated/*/*.sh scripts/
# Remove symlinks
rm scripts/{start-kali.sh,stop-kali.sh,kali-desktop.sh,kali-gui-app.sh}
```
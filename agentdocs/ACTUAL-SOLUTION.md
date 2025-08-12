# The Actual Solution to Kali Whisker Menu

## Root Cause
1. kali-menu IS installed when we install it
2. It creates `/etc/xdg/menus/applications-merged/kali-applications.menu`
3. BUT the whisker menu doesn't automatically show merged menus
4. The key line needed is: `<MergeFile type="parent">/etc/xdg/menus/applications-merged/kali-applications.menu</MergeFile>`

## The Fix
The solution is to explicitly tell XFCE to merge the Kali menu file. This is done by:

1. Creating an xfce-applications.menu that includes:
   ```xml
   <MergeFile type="parent">/etc/xdg/menus/applications-merged/kali-applications.menu</MergeFile>
   ```

2. This makes the Kali categories appear:
   - Reconnaissance
   - Persistence  
   - Discovery
   - Collection
   - Impact
   - Forensics
   - And all other MITRE ATT&CK based categories

## Current Kali Menu Format
The new Kali uses MITRE ATT&CK categories, not numbered categories (01-20).
To use numbered categories would require creating a custom menu structure.

## Working With Current Format
The malware analysis tools are now categorized as:
- `kali-forensics` - For forensics tools
- `kali-reverse-engineering` - For RE tools
- `kali-network-sniffing` - For network analysis

These will appear under the appropriate Kali menu categories.
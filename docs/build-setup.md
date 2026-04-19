# Build Setup Notes

## Windows Path Space Issue

Flutter and Dart SDK cannot handle paths with spaces internally (unquoted invocations break).

## Required Junctions (created once, persist across reboots)

Both junctions must exist before running any `flutter build web` command:

```powershell
# Flutter SDK junction (avoids "C:\Users\Fred Chu\flutter" spaces)
New-Item -ItemType Junction -Path 'C:\flutter' -Target 'C:\Users\Fred Chu\flutter'

# Project junction (avoids spaces in project path)
New-Item -ItemType Junction -Path 'C:\at' -Target 'C:\Users\Fred Chu\app\claude\test everything claude code\asset_tracker\.worktrees\phase1-foundation'
```

## Build Command

Always build from the junction path using the junction flutter:

```bash
cd /c/at
/c/flutter/bin/flutter.bat build web --no-tree-shake-icons
```

## Dev Server (flutter run)

```bash
cd /c/at
/c/flutter/bin/flutter.bat run -d chrome
```

## Note

The junctions point to the **worktree** (`phase1-foundation`). When switching to a different branch/worktree, update the `C:\at` junction target accordingly.

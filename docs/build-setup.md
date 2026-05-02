# Build Setup Notes

## Windows Path Space Issue

Flutter and Dart SDK cannot handle paths with spaces internally (unquoted invocations break).

## Required Junctions (created once, persist across reboots)

Both junctions should exist before running any `flutter build web` command:

```powershell
# Flutter SDK junction (avoids "C:\Users\Fred Chu\flutter" spaces)
New-Item -ItemType Junction -Path 'C:\flutter' -Target 'C:\Users\Fred Chu\flutter'

# Project junction (avoids spaces in project path)
New-Item -ItemType Junction -Path 'C:\at' -Target 'C:\App_Test\asset_tracker'
```

For feature worktrees, update the project junction target to the active worktree:

```powershell
Remove-Item 'C:\at'
New-Item -ItemType Junction -Path 'C:\at' -Target 'C:\App_Test\asset_tracker\.worktrees\supabase-cloud-storage'
```

## Build Command

Always build from the junction path using the junction flutter:

```powershell
Set-Location C:\at
C:\flutter\bin\flutter.bat build web --no-tree-shake-icons
```

## Dev Server (flutter run)

```powershell
Set-Location C:\at
C:\flutter\bin\flutter.bat run -d chrome
```

## Supabase Cloud Mode

Cloud mode requires build-time dart defines:

```powershell
Set-Location C:\at
C:\flutter\bin\flutter.bat run -d chrome `
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" `
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```

Use the same defines for web builds and mobile runs:

```powershell
C:\flutter\bin\flutter.bat build web --release `
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" `
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"

C:\flutter\bin\flutter.bat run -d <device-id> `
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" `
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```

Without these defines, the app runs in local Drift mode.

# Run this script AFTER closing Cursor/IDE to clear locked build folders.
# If it still fails, pause OneDrive sync or move the project out of OneDrive.

$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot

Write-Host "Removing build and .dart_tool (may fail if OneDrive/IDE has lock)..." -ForegroundColor Yellow
Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ".dart_tool" -ErrorAction SilentlyContinue

Write-Host "Running flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "Done. You can reopen the project and run flutter run." -ForegroundColor Green

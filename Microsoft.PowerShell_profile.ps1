. "$PSScriptRoot\Set-Window.ps1"

# Load all scripts
Get-ChildItem (Join-Path $PSScriptRoot \Library\) | Where `
{ $_.Name -notlike '__*' -and $_.Name -like '*.ps1' } | ForEach `
{ . $_.FullName }

# Dracula readline configuration. Requires version 2.0, if you have 1.2 convert to `Set-PSReadlineOption -TokenType`
Set-PSReadlineOption -Color @{
    "Command"   = [ConsoleColor]::Green
    "Parameter" = [ConsoleColor]::Gray
    "Operator"  = [ConsoleColor]::Magenta
    "Variable"  = [ConsoleColor]::White
    "String"    = [ConsoleColor]::Yellow
    "Number"    = [ConsoleColor]::Blue
    "Type"      = [ConsoleColor]::Cyan
    "Comment"   = [ConsoleColor]::DarkCyan
}
# Dracula Prompt Configuration
Import-Module posh-git
$GitPromptSettings.DefaultPromptPrefix.Text = "$([char]0x2192) " # arrow unicode symbol
$GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::Green
$GitPromptSettings.DefaultPromptPath.ForegroundColor = [ConsoleColor]::Cyan
$GitPromptSettings.DefaultPromptSuffix.Text = "$([char]0x203A) " # chevron unicode symbol
$GitPromptSettings.DefaultPromptSuffix.ForegroundColor = [ConsoleColor]::Magenta
# Dracula Git Status Configuration
$GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BranchColor.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.AfterStatus.ForegroundColor = [ConsoleColor]::Blue

# Function Definitions
function Open-CodeProjects {
    Push-Location "F:\Code Projects"
}
function Open-CodingDrive {
    Push-Location "G:\"
}
function Open-StorageDrive {
    Push-Location "G:\"
}
$YoutubeFilepath = "G:\Downloads\YouTube"
function Download-YoutubeVideo([string]$URL) {
    Clear-Host
    $data = yt-dlp --get-filename --playlist-items 1 -o "%(uploader)s\%(title)s" $URL
    $channel = $data.Substring(0, $data.IndexOf('\'))
    $title = $data.Substring($data.IndexOf('\') + 1)
    Write-Host -ForegroundColor Red "Downloading: $channel - $title"
    Write-Host
    yt-dlp  --sponsorblock-remove sponsor --no-playlist --console-title -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --embed-sub --embed-thumbnail --add-metadata -o "$YoutubeFilepath\%(uploader)s\%(title)s.%(ext)s" $URL
}
function Download-YoutubePlaylist([string]$URL) {
    Clear-Host
    $data = yt-dlp --get-filename --playlist-items 1 -o "%(uploader)s\%(playlist_title)s" $URL
    $channel = $data.Substring(0, $data.IndexOf('\'))
    $playlist = $data.Substring($data.IndexOf('\') + 1)
    Write-Host -ForegroundColor Red "Downloading: $channel - $playlist"
    Write-Host
    yt-dlp  --sponsorblock-remove sponsor --yes-playlist --console-title -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --embed-sub --embed-thumbnail --add-metadata -o "$YoutubeFilepath\%(uploader)s\%(playlist_title)s\%(playlist_index)03d - %(title)s.%(ext)s" $URL
    $videoFiles = Get-ChildItem -Path "$YoutubeFilepath\$channel\$playlist\*.mp4"
    foreach ($video in $videoFiles) {
        Add-Content "$YoutubeFilepath\$channel\$playlist\$playlist.m3u" "$YoutubeFilepath\$channel\$playlist\$($video.Name)"
    }
}
function Force-DeleteItems([string]$Item) {
    Remove-Item $Item -Force -Recurse
}
function Force-Rename([string]$OldName, [string]$NewName) {
    Rename-Item $OldName $NewName -Force
}
function New-DirAndFileExt([string]$NewDirAndFile, [string]$NewExt) {
    New-Item $NewDirAndFile -ItemType Directory
    New-Item $NewDirAndFile\index.$NewExt -Type File
}
function New-ListOfDirsAndFiles([string[]]$DirsAndFiles, [string]$NewExt) {
    foreach ($DirAndFile in $DirsAndFiles) {
        New-DirAndFileExt $DirAndFile $NewExt
    }
}
function Setup-Windows {
    Set-Window -ProcessName firefox -X 2553 -Y 500 -Width 1453 -Height 1500 -Passthru
    Set-Window -ProcessName youtube -X 2560 -Y -527 -Width 1440 -Height 1028 -Passthru
}

Set-Alias windows Setup-Windows
Set-Alias projects Open-CodeProjects
Set-Alias coding Open-CodingDrive
Set-Alias storage Open-StorageDrive
Set-Alias video Download-YoutubeVideo
Set-Alias playlist Download-YoutubePlaylist
Set-Alias fdel Force-DeleteItems
Set-Alias fren Force-Rename
Set-Alias touch New-Item
Set-Alias ndfe New-DirAndFileExt
Set-Alias nld New-ListOfDirsAndFiles
Set-Alias forcebind "C:\Program Files (x86)\ForceBindIP\ForceBindIP.exe"

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

oh-my-posh init pwsh --config "https://raw.githubusercontent.com/Anti049/NewComputerSetup/main/.mytheme.omp.json" | Invoke-Expression
$env:POSH_GIT_ENABLED = $true

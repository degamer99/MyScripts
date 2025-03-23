<#
.SYNOPSIS
    Downloads video(s) using yt-dlp with custom filename formatting.

.DESCRIPTION
    This script accepts two arguments:
      1. DownloadLocation - The folder where videos will be saved.
      2. Link - The URL of the video or playlist.
    
    It checks if the folder exists and creates it if not. It then checks if the link is a playlist 
    (by looking for "list=" in the URL) and sets the output template accordingly:
      - If a playlist: it prepends the video’s playlist index.
      - If not: it uses just the title.
    
    Finally, it builds and executes the yt-dlp command.
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$DownloadLocation,
    
    [Parameter(Mandatory=$true)]
    [string]$Link
)

# 1. Check if the download directory exists; if not, create it.
if (-Not (Test-Path $DownloadLocation)) {
    New-Item -ItemType Directory -Path $DownloadLocation | Out-Null
    Write-Host "Created download location: $DownloadLocation"
} else {
    Write-Host "Download location exists: $DownloadLocation"
}

# 2. Determine if the link is a playlist.
# We'll assume that if the URL contains "list=", it's a playlist.
if ($Link -match "list=") {
    $OutputTemplate = "$DownloadLocation\%(playlist_index)s. %(title)s.%(ext)s"
    Write-Host "Link appears to be a playlist. Using output template with playlist index."
} else {
    $OutputTemplate = "$DownloadLocation\%(title)s.%(ext)s"
    Write-Host "Link appears to be a single video. Using output template with title only."
}

# 3. Build the yt-dlp command string.
# We wrap the output template and the link in quotes.
$Command = "yt-dlp -o `"$OutputTemplate`" `"$Link`""

Write-Host "Executing command:"
Write-Host $Command

# 4. Execute the command.
try {
    Invoke-Expression $Command
    Write-Host "Download initiated successfully."
}
catch {
    Write-Error "Error executing yt-dlp: $_"
}

function Invoke-YtDownload {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$DownloadLocation,

        [Parameter(Mandatory = $true)]
        [string]$Link,

        [Parameter(Mandatory = $false)]
        [ValidateSet("720p", "480p", "360p", "240p", "low_audio", "high_audio")]
        [string]$Quality = "480p"
    )

    # 1. Check if the download directory exists; if not, create it.
    if (-Not (Test-Path $DownloadLocation)) {
        New-Item -ItemType Directory -Path $DownloadLocation | Out-Null
        Write-Host "Created download location: $DownloadLocation"
    }
    else {
        Write-Host "Download location exists: $DownloadLocation"
    }

    # 2. Determine if the link is a playlist.
    if ($Link -match "list=") {
        $OutputTemplate = "$DownloadLocation\%(playlist_index)s. %(title)s.%(ext)s"
        Write-Host "Link appears to be a playlist. Using output template with playlist index."
    }
    else {
        $OutputTemplate = "$DownloadLocation\%(title)s.%(ext)s"
        Write-Host "Link appears to be a single video. Using output template with title only."
    }

    # 3. Map the Quality parameter to a yt-dlp format string.
    switch ($Quality) {
        "720p"       { $FormatOption = "bestvideo[height<=720]+worstaudio/best[height<=720]" }
        "480p"       { $FormatOption = "bestvideo[height<=480]+worstaudio/best[height<=480]" }
        "360p"       { $FormatOption = "bestvideo[height<=360]+worstaudio/best[height<=360]" }
        "240p"       { $FormatOption = "bestvideo[height<=240]+worstaudio/best[height<=240]" }
        "high_audio" { $FormatOption = "bestaudio" }
        "low_audio"  { $FormatOption = "worstaudio" }
        Default      { $FormatOption = "" }
    }

    # 4. Build the yt-dlp command string.
    if ($FormatOption -ne "") {
        $Command = "yt-dlp -f `"$FormatOption`" -o `"$OutputTemplate`" `"$Link`""
    }
    else {
        $Command = "yt-dlp -o `"$OutputTemplate`" `"$Link`""
    }

    Write-Host "Executing command:"
    Write-Host $Command

    # 5. Execute the command.
    try {
        Invoke-Expression $Command
        Write-Host "Download initiated successfully."
    }
    catch {
        Write-Error "Error executing yt-dlp: $_"
    }
}

# Export the function so that it is available when the module is imported.
Export-ModuleMember -Function Invoke-YtDownload

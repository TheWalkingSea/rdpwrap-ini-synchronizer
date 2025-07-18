# Set up constants
$rdpWrapDir = "C:\Program Files\RDP Wrapper"
$iniPath = Join-Path $rdpWrapDir "rdpwrap.ini"
$taskName = "Update-RDPWrap-INI"
$logPath = "$env:ProgramData\rdpwrap_update.log"

# Function: Download INI from S3
function Download-INIDef {
    param (
        [string]$version
    )

    # Customize your base URL and file pattern
    $baseUrl = "https://rdpwrap-config.s3.us-east-2.amazonaws.com"
    $fileName = "$version"
    $downloadUrl = "$baseUrl/$fileName"

    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $iniPath -UseBasicParsing
        Write-Output "Downloaded $fileName to $iniPath"
    } catch {
        Write-Error "Failed to download $fileName from $downloadUrl"
    }
}

# Main logic
$version = Get-CimInstance CIM_DataFile -Filter "Name='C:\\Windows\\System32\\termsrv.dll'" | Select-Object -ExpandProperty Version
if ($version) {
    Write-Output "Detected RDPWrap version: $version"
    Download-INIDef -version $version
}

# Create scheduled task for auto-start
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if (-not $taskExists) {
    $scriptPath = $MyInvocation.MyCommand.Definition

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal

    Write-Output "Scheduled task '$taskName' created to run at startup."
}

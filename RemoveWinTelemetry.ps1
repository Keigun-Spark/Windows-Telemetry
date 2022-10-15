param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # Elevating didn't work or wasn't accepted, aborting.
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack\" -Name Start -Value 4 
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener\" -Name Start -Value 0 
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\" -Name AllowTelemetry -Value 0 
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\" -Name MaxTelemetryAllowed -Value 0 
Remove-Item -Path "C:\Windows\System32\LogFiles\WMI\*" -Include "Diagtrack-Listener.etl.*" -Force 
New-NetFirewallRule -DisplayName "BlockDiagTrackService" -Name "BlockDiagTrackService" -Direction Outbound -Service "DiagTrack" -Action Block 
New-NetFirewallRule -DisplayName "BlockDiagTrackServicePort" -Name "BlockDiagTrackServicePort" -Direction Outbound -LocalPort 443 -Protocol TCP -Program "%SystemRoot%\system32\svchost.exe" -Service "DiagTrack" -Action Block 
New-NetFirewallRule -DisplayName "BlockDiagTrack" -Name "BlockDiagTrack" -Direction Outbound -Program "%SystemRoot%\System32\utc_myhost.exe -k utcsvc -p" -Action Block 
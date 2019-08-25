$host.UI.RawUI.WindowTitle = 'Modify RDP Port'

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    echo 'UAC Promotion Required'
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$port = 3344

echo 'Modifying RDP Port'
$rdp = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\'
Set-ItemProperty ($rdp + 'WinStations\RDP-Tcp') -Name 'PortNumber' -Value $port
Set-ItemProperty ($rdp + 'Wds\rdpwd\Tds\tcp') -Name 'PortNumber' -Value $port

echo 'Modifying Firewall Rules'
Set-NetFirewallRule -Name RemoteDesktop-UserMode-In-TCP -LocalPort $port
Set-NetFirewallRule -Name RemoteDesktop-UserMode-In-UDP -LocalPort $port

echo 'Restarting RDP Services'
if ((Get-Service -Name SessionEnv).Status -eq 'Running') {
    Write-Host -NoNewline '- Remote Desktop Configuration (SessionEnv)...'
    Restart-Service -Name SessionEnv -Force
    echo ' success'
}
if ((Get-Service -Name TermService).Status -eq 'Running') {
    Write-Host -NoNewline '- Remote Desktop Services (TermService)...'
    Restart-Service -Name TermService -Force
    echo ' success'
}

echo ('RDP port has been successfully modified to ' + $port)

Write-Host -NoNewline 'Press any key to continue...'
$null = [Console]::ReadKey()

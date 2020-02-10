try {
    "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)\twilio-powershell-module\twilio-powershell-module.psd1" | Test-ModuleManifest -ErrorAction STOP -Verbose
}
catch {
    Write-Error -Message $Error[0]
}
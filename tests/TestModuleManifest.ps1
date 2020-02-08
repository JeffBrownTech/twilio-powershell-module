try {
    Test-ModuleManifest -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY\twilio-powershell-module.psd1 -ErrorAction STOP
}
catch {
    Write-Error -Message $Error[0]
}
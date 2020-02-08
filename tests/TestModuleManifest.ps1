try {
    Test-ModuleManifest -Path ..\twilio-powershell-module.psd1 -ErrorAction STOP
}
catch {
    Write-Error -Message $Error[0]
}
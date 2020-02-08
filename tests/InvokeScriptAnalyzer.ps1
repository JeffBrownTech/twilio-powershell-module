$analyzerErrors = Invoke-ScriptAnalyzer -Path "$($env:SYSTEM_DEFAULTWORKINGDIRECTORY)twilio-powershell-module.psm1" -Severity Error

if ($analyzerErrors.Count -gt 0)
{
    exit 1
}
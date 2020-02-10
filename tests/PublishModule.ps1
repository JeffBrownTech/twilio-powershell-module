Write-Host $env:SYSTEM_DEFAULTWORKINGDIRECTORY
Publish-Module -Path .\ -NuGetApiKey $env:PowerShellGalleryAPI -WhatIf -Verbose -ErrorAction STOP
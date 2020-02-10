#Publish-Module -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -NuGetApiKey $($PowerShellGalleryAPI) -WhatIf -Verbose -ErrorAction STOP

Write-Host "Try 1: " -NoNewline
Write-Host $PowerShellGalleryAPI

Write-Host "Try 2: " -NoNewline
Write-Host $(PowerShellGalleryAPI)

Write-Host "Try 3: " -NoNewline
Write-Host $($PowerShellGalleryAPI)

Write-Host "Try 4: " -NoNewline
Write-Host $env:PowerShellGalleryAPI

Write-Host "Try 5: " -NoNewline
Write-Host $($env:PowerShellGalleryAPI)
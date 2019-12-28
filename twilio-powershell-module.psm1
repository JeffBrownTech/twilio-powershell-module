function Get-TwilioAccountSID {
    return $Script:TWILIO_ACCOUNT_SID
}

function Set-TwilioAccountSID {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $SID
    )

    $Script:TWILIO_ACCOUNT_SID = $SID

    # If auth token is available, go ahead and create the full cred object
    if ($null -ne $Script:TWILIO_AUTH_TOKEN) {
        Set-TwilioCredentials -SID $Script:TWILIO_ACCOUNT_SID -AuthToken $Script:TWILIO_AUTH_TOKEN
    }
}

function Set-TwilioAuthToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $AuthToken
    )

    $Script:TWILIO_AUTH_TOKEN = $AuthToken
    
    # If auth token is available, go ahead and create the full cred object
    if ($null -ne $Script:TWILIO_ACCOUNT_SID) {
        Set-TwilioCredentials -SID $Script:TWILIO_ACCOUNT_SID -AuthToken $Script:TWILIO_AUTH_TOKEN
    }
}

function Set-TwilioCredentials {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $SID,

        [Parameter(Mandatory)]
        [string]
        $AuthToken
    )

    # Reference: https://www.twilio.com/docs/usage/tutorials/how-to-make-http-basic-request-twilio-powershell
    $Script:TWILIO_CREDS = New-Object System.Management.Automation.PSCredential($SID, ($AuthToken | ConvertTo-SecureString -AsPlainText -Force))
}

function Get-TwilioPhoneNumber {
    return $Script:TWILIO_PHONE_NUMBER
}

function Set-TwilioPhoneNumber {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $PhoneNumber
    )

    $Script:TWILIO_PHONE_NUMBER = $PhoneNumber
}

function Send-TwilioSMS {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ToPhoneNumber,

        [Parameter()]
        [string]
        $FromPhoneNumber = $Script:TWILIO_PHONE_NUMBER,

        [Parameter(Mandatory)]
        [string]
        $Message
    )

    if ($PSBoundParameters.ContainsKey('FromPhoneNumber')) {
        $body = @{
            From = $FromPhoneNumber
            To = $ToPhoneNumber
            Body = $Message
        }
    }
    else {
        $body = @{
            From = $Script:TWILIO_PHONE_NUMBER
            To = $ToPhoneNumber
            Body = $Message
        }
    }    
    
    Invoke-RestMethod -Method POST -Uri "https://api.twilio.com/2010-04-01/Accounts/$Script:TWILIO_ACCOUNT_SID/Messages.json" -Credential $Script:TWILIO_CREDS -Body $body
}
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

    # Set API URI
    Set-TwilioApiUri -SID $SID
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

function Set-TwilioCredentials2 {
    $Script:TWILIO_CREDS2 = Get-Credential -Message "User name = Account SID, Password = Auth Token"
}

function Get-TwilioApiUri {
    return $Script:TWILIO_API_URI
}

function Set-TwilioApiUri {
    param(
        [Parameter(Mandatory)]
        [string]
        $SID,

        [Parameter()]
        [string]
        $ApiVersion = "2010-04-01"
    )

    $Script:TWILIO_API_URI = "https://api.twilio.com/$ApiVersion/Accounts/$SID"
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
            To   = $ToPhoneNumber
            Body = $Message
        }
    }
    else {
        $body = @{
            From = $Script:TWILIO_PHONE_NUMBER
            To   = $ToPhoneNumber
            Body = $Message
        }
    }    
    
    Invoke-RestMethod -Method POST -Uri "$Script:TWILIO_API_URI/Messages.json" -Credential $Script:TWILIO_CREDS -Body $body
}

function Get-TwilioSMSHistory {
    Invoke-RestMethod -Method GET -Uri "$Script:TWILIO_API_URI/Messages.json" -Credential $Script:TWILIO_CREDS2
}

#https://lookups.twilio.com/v1/PhoneNumbers/{number}

function Search-TwilioPhoneNumber {
    param(
        [Parameter(Mandatory)]
        [string]
        $PhoneNumber
    )

    Invoke-RestMethod -Method GET -Uri "https://lookups.twilio.com/v1/PhoneNumbers/$PhoneNumber" -Credential $Script:TWILIO_CREDS
}
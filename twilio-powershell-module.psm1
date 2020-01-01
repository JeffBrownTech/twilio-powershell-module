function Set-TwilioCredential {
    param(
        [Parameter()]
        [PSCredential]
        $Credential
    )
    
    if ($PSBoundParameters.ContainsKey('Credential')) {
        $Script:TWILIO_CREDS = $Credential
    }
    else {
        $Script:TWILIO_CREDS = Get-Credential -Message "User name = Account SID, Password = Auth Token"
    }    
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

function Get-TwilioAccountPhoneNumber {
    return $Script:TWILIO_PHONE_NUMBER
}

function Set-TwilioAccountPhoneNumber {
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
        $Message,

        [Parameter()]
        [PSCredential]
        $Credential = $Script:TWILIO_CREDS
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
    
    Invoke-RestMethod -Method POST -Uri "$Script:TWILIO_API_URI/Messages.json" -Credential $Credential -Body $body
}

function Get-TwilioSMSHistory {
    param(
        [Parameter()]
        [PSCredential]
        $Credential = $Script:TWILIO_CREDS
    )

    Invoke-RestMethod -Method GET -Uri "$Script:TWILIO_API_URI/Messages.json" -Credential $Credential
}

function Search-TwilioPhoneNumber {
    param(
        [Parameter(Mandatory)]
        [string]
        $PhoneNumber,

        [Parameter()]
        [PSCredential]
        $Credential = $Script:TWILIO_CREDS
    )

    Invoke-RestMethod -Method GET -Uri "https://lookups.twilio.com/v1/PhoneNumbers/$PhoneNumber" -Credential $Credential
}
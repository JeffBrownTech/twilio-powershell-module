function Connect-TwilioApi {
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

    Set-TwilioApiUri -SID $Script:TWILIO_CREDS.UserName
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
        [ValidatePattern("^\+[1-9]\d{1,14}$")]  # Regex taken from: https://www.twilio.com/docs/glossary/what-e164
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

    if ($Null -eq $Script:TWILIO_CREDS) {
        Write-Error -Message "The Twilio API credentials have not been configured. Please run Connect-TwilioApi and use the account SID and Auth Token to configure credentials."
    }
    elseif ($NULL -eq $Script:TWILIO_API_URI) {
        Write-Error -Message "The Twilio API URI has not been configured with the Account SID. Please run Set-TwilioApiUri with the Account SID before running this command again."
    }
    elseif ($NULL -eq $Script:TWILIO_PHONE_NUMBER) {
        Write-Error -Message "The Twilio Account Phone Number has not been specified. Use the Set-TwilioAccountPhoneNumber cmdlet or use the -FromPhoneNumber parameter to specify the Twilio account phone number."
    }
    else {
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
        [ValidatePattern("^\+[1-9]\d{1,14}$")]  # Regex taken from: https://www.twilio.com/docs/glossary/what-e164
        [string]
        $PhoneNumber,

        [Parameter(ParameterSetName="verify")]
        [switch]
        $NumberVerification,

        [Parameter(ParameterSetName="carrier")]
        [switch]
        $CarrierLookup,

        [Parameter(ParameterSetName="caller")]
        [switch]
        $CallerLookup,
        
        [Parameter()]
        [PSCredential]
        $Credential = $Script:TWILIO_CREDS
    )
    # Reference: https://www.twilio.com/docs/lookup/api?code-sample=code-carrier-lookup-with-e164-formatted-number&code-language=curl&code-sdk-version=json

    if ($Null -eq $Script:TWILIO_CREDS) {
        Write-Error -Message "The Twilio API credentials have not been configured. Please run Connect-TwilioApi and use the account SID and Auth Token to configure credentials."
    }
    elseif ($PSBoundParameters.ContainsKey("CarrierLookup")) {
        Invoke-RestMethod -Method GET -Uri "https://lookups.twilio.com/v1/PhoneNumbers/$($PhoneNumber)?Type=carrier" -Credential $Credential
    }
    elseif ($PSBoundParameters.ContainsKey("CallerLookup")) {
        Invoke-RestMethod -Method GET -Uri "https://lookups.twilio.com/v1/PhoneNumbers/$($PhoneNumber)?Type=caller-name" -Credential $Credential
    }
    elseif ($PSBoundParameters.ContainsKey("NumberVerification")) {
        Invoke-RestMethod -Method GET -Uri "https://lookups.twilio.com/v1/PhoneNumbers/$PhoneNumber" -Credential $Credential
    }
}
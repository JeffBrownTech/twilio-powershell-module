function Connect-TwilioService {
    <#
    .SYNOPSIS
    Configures Twilio API credentials (Account SID and Auth Token) and set thes API URI with the Account SID.

    .DESCRIPTION
    Configures Twilio API credentials (Account SID and Auth Token) and set thes API URI with the Account SID.
    This requires a Twilio account with a configured Account SID and Auth Token.
    Can also optionally set the Twilio account phone number for sending SMS messages.

    .PARAMETER PhoneNumber
    Allows option to set the Twilio account phone number for sending SMS messages. Must be in E.164 format and a valid telephone number.
    This parameter is optional; however, if omitted, requires running Set-TwilioAccountPhoneNumber.

    .PARAMETER Credential
    Takes a PSCredential object saved in a PowerShell variable. This is the Account SID and Auth Token for your Twilio account.

    .PARAMETER SID
    A twilio credential can be composed of an API Id and token or a SID and a token; if your credential uses an API ID, enter your account's SID here
    
    .EXAMPLE
    PS C:\> Connect-TwilioService

    This example will prompt for the Account SID and Auth Token to configure the API connection.

    .EXAMPLE
    $creds = Get-Credential
    PS C:\> Connect-TwilioService -Credential $creds

    This example saves the Account SID and Auth Token to a PowerShell variable and then configures the API connection.

    .EXAMPLE
    PS C:\> Connect-TwilioService -PhoneNumber +15551234567

    This example will set the from phone number to +15551234567 and prompt for the Account SID and Auth Token to configure the API connection.

    .LINK
    https://www.twilio.com/docs/iam/credentials/api#authentication
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidatePattern("^\+[1-9]\d{1,14}$")]  # Regex taken from: https://www.twilio.com/docs/glossary/what-e164
        [string]
        $PhoneNumber,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [string]
        $SID
    )

    if ($PSBoundParameters.ContainsKey('Credential')) {
        $Script:TWILIO_CREDS = $Credential
    }
    else {
        $Script:TWILIO_CREDS = Get-Credential -Message "User name = Account SID, Password = Auth Token"
    }

    if ($PSBoundParameters.ContainsKey('SID')) {
        Set-TwilioApiUri -SID $SID
    } else
    {
        Set-TwilioApiUri -SID $Script:TWILIO_CREDS.UserName
    }
 
    if ((Test-TwilioCredentials -Credential $Script:TWILIO_CREDS) -eq $true) {
        if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
            Set-TwilioAccountPhoneNumber -PhoneNumber $PhoneNumber
        }
    }
} # End of Connect-TwilioService

function Test-TwilioCredentials {
    <#
    .SYNOPSIS
    Tests that the Account SID and Auth Token are valid.

    .DESCRIPTION
    Takes a PSCredential object and verifies the Account SID and Auth Token are valid by making a simple GET request against the Twilio API URI.
    This function is called from the Connect-TwilioService cmdlet to verify the credentials are valid.

    .PARAMETER Credential
    Takes a PSCredential object saved in a PowerShell variable. This is the Account SID and Auth Token for your Twilio account.

    .EXAMPLE
    $creds = Get-Credential
    PS C:\> Test-TwilioCredentials -Credential $creds

    This example prompts for and saves the Account SID and Auth Token to a PowerShell variable and then verifies they are valid.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCredential]
        $Credential
    )
 
    $validCreds = $true
    $uri = "$Script:TWILIO_API_URI/Usage/Records/LastMonth.json"

    try {
        Invoke-RestMethod -Method GET -Uri $uri -Credential $Credential | Out-Null
    }
    catch {
        Write-Error -Message "Error validating Twilio credentials. Verify the correct Account SID and Auth Token are being used."
        $validCreds = $false
    }

    return $validCreds
}

function Get-TwilioApiUri {
    <#
    .SYNOPSIS
    Returns the Twilio API URI configured with the module.

    .DESCRIPTION
    If the Connect-TwilioService has been ran, this will return the API URI being used by the module with the Account SID.
    This command does not require any named parameters.

    .EXAMPLE
    PS C:\> Get-TwilioApiUri

    This example returns the configure Twilio API URI being used by the module.

    .LINK
    https://www.twilio.com/docs/iam/credentials/api#api-base-url
    #>

    [CmdletBinding()]
    param()

    return $Script:TWILIO_API_URI
} # End of Get-TwilioApiUri

function Set-TwilioApiUri {
    <#
    .SYNOPSIS
    Sets the Twilio API URI using an Account SID.

    .DESCRIPTION
    Sets the Twilio API URI using an Account SID. This allows changing the API URI using a new API version or Account SID.

    .PARAMETER SID
    Specify the Account SID for your Twilio account.
    This is a required parameter.

    .PARAMETER ApiVersion
    Specify the Twilio API version to use. The default is "2010-04-01".

    .EXAMPLE
    PS C:\> Set-TwilioApiUri -SID AC90asd989df800w9gf90d9f8g

    This will change the API URI in the module to use the value in the SID parameter.

    .EXAMPLE
    PS C:\> Set-TwilioApiUri -SID AC90asd989df800w9gf90d9f8g -ApiVersion 2010-04-01

    This example changes the API URI in the module to use the values set in the SID and ApiVersion.

    .NOTES
    The Twilio API URI format is:
    https://api.twilio.com/<API_Version>/Accounts/<Account_SID>
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $SID,

        [Parameter()]
        [string]
        $ApiVersion = "2010-04-01"
    )

    $Script:TWILIO_API_URI = "https://api.twilio.com/$ApiVersion/Accounts/$SID"
} # End of Set-TwilioApiUri

function Get-TwilioAccountPhoneNumber {
    <#
    .SYNOPSIS
    Returns the Twilio Account Phone Number if it has been configured.

    .DESCRIPTION
    Returns the Twilio Account Phone Number if it has been configured.
    This command does not require any named parameters.

    .EXAMPLE
    PS C:/> Get-TwilioAccountPhoneNumber

    This example will return the Twilio Account Phone Number (if configured) or prompt to run Set-TwilioAccountPhoneNumber if it has not been configure.
    #>

    [CmdletBinding()]
    param()

    if ($null -ne $Script:TWILIO_PHONE_NUMBER) {
        return $Script:TWILIO_PHONE_NUMBER
    }
    else {
        return "Twilio Account Phone Number not set. Run Set-TwilioAccountPhoneNumber to configure the sending phone number for your Twilio account."
    }
} # End of Get-TwilioAccountPhoneNumber

function Set-TwilioAccountPhoneNumber {
    <#
    .SYNOPSIS
    Sets the Twilio account phone number to use for SMS messages.

    .DESCRIPTION
    In order to send SMS messages with this module, a sending phone number must be configured. This cmdlet sets a default from phone number that is configured in your Twilio account.

    .PARAMETER PhoneNumber
    Accepts an E.164 formatted phone number starting with a plus (+) sign. The phone number is then validated using the Get-TwilioPhoneNumberInformation cmdlet.
    This is a required parameter.

    .EXAMPLE
    PS C:\> Set-TwilioAccountPhoneNumber -PhoneNumber +15551234567

    This example sets the default sending phone number for the module to +15551234567.

    .LINK
    https://www.twilio.com/docs/sms/tutorials/send-sms-during-phone-call-ruby#sign-up-for-a-twilio-account-and-get-a-phone-number
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern("^\+[1-9]\d{1,14}$")]  # Regex taken from: https://www.twilio.com/docs/glossary/what-e164
        [string]
        $PhoneNumber
    )

    try {
        Get-TwilioPhoneNumberInformation -PhoneNumber $PhoneNumber -VerifyNumber -ErrorAction STOP | Out-Null
    }
    catch {
        Write-Error -Message "An error occurred while verifying the phone number: $($Error[0].ErrorDetails.Message)"
    }

    $Script:TWILIO_PHONE_NUMBER = $PhoneNumber
}

function Send-TwilioSMS {
    <#
    .SYNOPSIS
    Sends an SMS message using the Twilio API.

    .DESCRIPTION
    Uses the Twilio API to send an SMS message. This requires a Twilio account along with a configured sending phone number.

    .PARAMETER ToPhoneNumber
    This is the receiving phone number for the message. The phone number should be E.164 formatted.
    This is a required parameter.

    .PARAMETER Message
    This is the text body of the SMS message.
    Thi sis a required parameter.

    .PARAMETER FromPhoneNumber
    This is the sending phone number configured in your Twilio account. If the phone number hasn't been configured using the Set-TwilioAccountPhoneNumber, this parameter should be used.

    .PARAMETER Credential
    If the API URI credentials have not been specified using the Connect-TwilioService cmdlet, you can specify them here with a PSCredential object.

    .EXAMPLE
    PS C:\> Send-TwilioSMS -ToPhoneNumber +15551234567 -Message "Hello World!"

    This example sends a message to the phone number +15551234567 using the already configured Account SID and Auth Token.

    .EXAMPLE
    PS C:\> Send-TwilioSMS -ToPhoneNumber +15551234567 -Message "Hello World!" -FromPhoneNumber +15559876543

    This example sends a message to the phone number +15551234567 using the already configured Account SID and Auth Token.
    It also specifies the from phone number if it has not been configured using the Set-TwilioAccountPhoneNumber.

    .EXAMPLE
    $creds = Get-Credential
    PS C:\> Send-TwilioSMS -ToPhoneNumber +15551234567 -Message "Hello World!" -FromPhoneNumber +15559876543 -Credential $creds

    This example sends a message to the phone number +15551234567 using the already configured Account SID and Auth Token.
    It also specifies the from phone number if it has not been configured using the Set-TwilioAccountPhoneNumber and uses a PSCredential object saved to $creds with the
    Account SID and Auth Token.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        [ValidatePattern("^\+[1-9]\d{1,14}$")]  # Regex taken from: https://www.twilio.com/docs/glossary/what-e164
        $ToPhoneNumber,

        [Parameter(Mandatory)]
        [string]
        $Message,

        [Parameter()]
        [string]
        [ValidatePattern("^\+[1-9]\d{1,14}$")]  # Regex taken from: https://www.twilio.com/docs/glossary/what-e164
        $FromPhoneNumber = $Script:TWILIO_PHONE_NUMBER,

        [Parameter()]
        [PSCredential]
        $Credential = $Script:TWILIO_CREDS
    )

    if ($Null -eq $Credential) {
        Write-Error -Message "The Twilio API credentials have not been configured. Please run Connect-TwilioService and use the account SID and Auth Token to configure credentials."
    }
    elseif ($NULL -eq $Script:TWILIO_API_URI) {
        Write-Error -Message "The Twilio API URI has not been configured with the Account SID. Please run Set-TwilioApiUri with the Account SID before running this command again."
    }
    elseif ($NULL -eq $FromPhoneNumber) {
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
    <#
    .SYNOPSIS
    Gets the SMS history from your Twilio account.

    .DESCRIPTIOn
    Makes an API call to return all the SMS messages in your account history in JSON.

    .PARAMETER Credential
    If the API URI credentials have not been specified using the Connect-TwilioService cmdlet, you can specify them here with a PSCredential object.

    .EXAMPLE
    PS C:\> Get-TwilioSMSHistory

    This example will return the SMS history in your Twilio account.
    This assumes Connect-TwilioService has already been configured.

    .EXAMPLE
    $creds = Get-Credential
    PS C:\> Get-TwilioSMSHistory -Credential $creds

    This example will return the SMS history in your Twilio account and uses a PSCredential object saved to $creds with the
    Account SID and Auth Token.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [PSCredential]
        $Credential = $Script:TWILIO_CREDS
    )

    Invoke-RestMethod -Method GET -Uri "$Script:TWILIO_API_URI/Messages.json" -Credential $Credential
}

function Get-TwilioPhoneNumberInformation {
    <#
    .SYNOPSIS
    Returns information about a phone number using Twilio lookup service.

    .DESCRIPTION
    This cmdlet returns information about a phone number in JSON. There are three options:

    1. Verify number (-VerifyNumber)
    2. Lookup carrier information (-LookupCarrier)
    3. Lookup owner (-LookupCallerID)

    Each option is made available through switch parameters as part of parameter sets, meaning only only lookup option can be specified each time the command is ran.

    .PARAMETER PhoneNumber
    This is the phone number in to verify in E.164 format.
    This is a required parameter.

    .PARAMETER VerifyNumber
    This switch parameter confirms the phone number is valid.

    .PARAMETER LookupCarrier
    This switch parameter returns information such as the carrier name and phone number type (landline, mobile, or voip).

    .PARAMETER LookupCallerID
    This switch paramter performs a lookup on the phone number and returns the name of the individual or business associated with it.
    Only available for U.S. numbers.

    .PARAMETER Credential
    If the API URI credentials have not been specified using the Connect-TwilioService cmdlet, you can specify them here with a PSCredential object.

    .EXAMPLE
    PS C:\> Get-TwilioPhoneNumberInformation -PhoneNumber +15551234567 -VerifyNumber

    This example verifies the supplied phone number is a valid phone number.

    .EXAMPLE
    PS C:\> Get-TwilioPhoneNumberInformation -PhoneNumber +15551234567 -LookupCarrier

    This example returns information for the supplied phone number, such as landline, mobile, or voip and the mobile carrier name.

    .EXAMPLE
    PS C:\> Get-TwilioPhoneNumberInformation -PhoneNumber +15551234567 -LookupCallerID

    This example returns the name of the individual or business associated with the phone number.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern("^\+[1-9]\d{1,14}$")]  # Regex taken from: https://www.twilio.com/docs/glossary/what-e164
        [string]
        $PhoneNumber,

        [Parameter(ParameterSetName="verify")]
        [switch]
        $VerifyNumber,

        [Parameter(ParameterSetName="carrier")]
        [switch]
        $LookupCarrier,

        [Parameter(ParameterSetName="caller")]
        [switch]
        $LookupCallerID,
        
        [Parameter()]
        [PSCredential]
        $Credential = $Script:TWILIO_CREDS
    )
    # Reference: https://www.twilio.com/docs/lookup/api?code-sample=code-carrier-lookup-with-e164-formatted-number&code-language=curl&code-sdk-version=json

    if ($Null -eq $Credential) {
        Write-Error -Message "The Twilio API credentials have not been configured. Please run Connect-TwilioService and use the account SID and Auth Token to configure credentials."
        RETURN
    }
    else {
        switch ($PSBoundParameters) {
            {$_.Keys -eq "VerifyNumber"} { Invoke-RestMethod -Method GET -Uri "https://lookups.twilio.com/v1/PhoneNumbers/$PhoneNumber" -Credential $Credential; break }
            {$_.Keys -eq "LookupCarrier"} { Invoke-RestMethod -Method GET -Uri "https://lookups.twilio.com/v1/PhoneNumbers/$($PhoneNumber)?Type=carrier" -Credential $Credential; break }
            {$_.Keys -eq "LookupCallerID"} { Invoke-RestMethod -Method GET -Uri "https://lookups.twilio.com/v1/PhoneNumbers/$($PhoneNumber)?Type=caller-name" -Credential $Credential; break }
        }
    }
}

#Export-ModuleMember -Function Connect-TwilioService, Test-TwilioCredentials, Get-TwilioApiUri, Set-TwilioApiUri, Get-TwilioAccountPhoneNumber, Set-TwilioAccountPhoneNumber, `
#                                Send-TwilioSMS, Get-TwilioSMSHistory, Get-TwilioPhoneNumberInformation
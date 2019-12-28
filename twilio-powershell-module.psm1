function Get-TwilioAccountSID {
    return $Script:TWILIO_ACCOUNT_SID
}

function Set-TwilioAccountSID {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $SID
    )

    $Script:TWILIO_ACCOUNT_SID = $SID
}

function Set-TwilioAuthToken {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $AuthToken
    )

    $Script:TWILIO_AUTH_TOKEN = $AuthToken
}

function Set-TwilioPhoneNumber {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $PhoneNumber
    )

    $Script:TWILIO_PHONE_NUMBER = $PhoneNumber
}

function Send-TwilioSMS {

}
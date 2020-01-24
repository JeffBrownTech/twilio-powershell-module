# twilio-powershell-module
This is a PowerShell module that utilizes Twilio's API for different functions. This requires a Twilio account to run most of the commands. To get started with a free trial to configure an Account SID, Auth Token, and Phone Number, check out the link below:

[How to Use Your Free Trial Account](https://www.twilio.com/docs/usage/tutorials/how-to-use-your-free-trial-account)

# Command Overview

## Connect-TwilioService
Configures Twilio API credentials (Account SID and Auth Token) and set thes API URI with the Account SID. This requires a Twilio account with a configured Account SID and Auth Token. Can also optionally set the Twilio account phone number for sending SMS messages.

## Test-TwilioCredentials
Takes a PSCredential object and verifies the Account SID and Auth Token are valid by making a simple GET request against the Twilio API URI. This function is called from the Connect-TwilioService cmdlet to verify the credentials are valid.

## Get-TwilioApiUri
If the Connect-TwilioService has been ran, this will return the API URI being used by the module with the Account SID. This command does not require any named parameters.

## Set-TwilioApiUri
Sets the Twilio API URI using an Account SID. This allows changing the API URI using a new API version or Account SID.

## Get-TwilioAccountPhoneNumber
Returns the Twilio Account Phone Number if it has been configured. This command does not require any named parameters.

## Set-TwilioAccountPhoneNumber
In order to send SMS messages with this module, a sending phone number must be configured. This cmdlet sets a default from phone number that is configured in your Twilio account.

## Send-TwilioSMS
Uses the Twilio API to send an SMS message. This requires a Twilio account along with a configured sending phone number.

## Get-TwilioSMSHistory
Makes an API call to return all the SMS messages in your account history in JSON.

## Get-TwilioPhoneNumberInformation
This cmdlet returns information about a phone number in JSON. There are three options:
    
1. Verify number (-VerifyNumber)
2. Lookup carrier information (-LookupCarrier)
3. Lookup owner (-LookupCallerID)

Each option is made available through switch parameters as part of parameter sets, meaning only only lookup option can be specified each time the command is ran.

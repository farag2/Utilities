#Requires -Version 7.4

# Add personal data
# https://support.mts.ru/mts_biznes_api/personalnie-dannie-polzovatelya-nomera/kak-vnesti-personalnie-dannie-polzovatelya-nomera-s-pomoschyu-mts-biznes-api

# Get you secrets on https://lk-b2b.mts.ru/mts_business_web/mobile-api
$consumerKey    = ''
$consumerSecret = ''

$pair      = "{0}:{1}" -f $consumerKey, $consumerSecret
$bytes     = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64    = [System.Convert]::ToBase64String($bytes)
$authValue = "Basic $base64"

$Headers = @{
    "Authorization" = $authValue
    "Content-Type"  = "application/x-www-form-urlencoded"
    "Accept"        = "application/json"
}
$Body = @{
    grant_type = "client_credentials"
}
$Parameters = @{
    Uri             = "https://api.mts.ru/token"
    Method          = "POST"
    Headers         = $Headers
    Body            = $Body
    UseBasicParsing = $true
    Verbose         = $true
}
$Token = Invoke-RestMethod @Parameters

$Body = @"
{
    "request": {
        "Items": [
            {
                "Msisdn": "7XXXXXXXXXX",
                "UserData": {
                    "Action": "Create",
                    "Addresses": [
                        {
                            "Country": "",
                            "City": "",
                            "Home": "",
                            "Region": "",
                            "Street": "",
                            "Zip": "",
                            "Apartment": "",
                            "Estate": "",
                            "AddressTypes": "RegAddress"
                        }
                    ],
                    "LegalCategory": {
                        "Code": "1"
                    },
                    "Birthday": "",
                    "BirthPlace": "",
                    "Gender": "",
                    "Identifications": [
                        {
                            "Action": "Create",
                            "DocumentType": {
                                "Code": "21"
                            },
                            "Country": {
                                "Code": "RU"
                            },
                            "DocumentSeries": "",
                            "DocumentNumber": "",
                            "DateIssued": "",
                            "Issuer": "",
                            "IssuerCode": "" // IssuerCode uses "-"
                        }
                    ],
                    "IsEntrepreneur": false,
                    "Names": [
                        {
                            "Action": "Create",
                            "FirstName": "",
                            "SecondName": "",
                            "SurName": "",
                            "Language": {
                                "Code": "1"
                            }
                        }
                    ]
                }
            }
        ]
    },
    "SubscriberInformation": {
        "MessageId": "NewGuid",
        "ReplyToURL": "DB:",
        "SubscriberName": "MobileAPI",
        "OperatorType": "MTSBusinessAPI"
    }
}
"@

$Headers = @{
	# Double quote x-soap-action x-soap-action
	"x-soap-action"          = '"http://schemas.sitels.ru/FORIS/IL/JsonApi/IResourceOperations%ChangeUserPhysicalResourceBulk"'
	# If only one MSISDN
	"X-MTS-MSISDN"           = "7XXXXXXXXXX"
	"Content-Type"           = "application/json"
	# If more than one MSISDN
	#"X-MTS-AGREEMENT_NUMBER" = "XXXXXXXXXXXX"
	"Authorization"          = "Bearer $($Token.access_token)"
	"Accept"                 = "application/json"
}

$Parameters = @{
	Uri             = "https://api.mts.ru/b2b/v1/PersonalData/ChangePersonalData"
	Method          = "Post"
	Headers         = $Headers
	Body            = $Body
	UseBasicParsing = $true
	Verbose         = $true
}
Invoke-RestMethod @Parameters

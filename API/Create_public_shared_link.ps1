# https://oauth.yandex.ru
# Open https://oauth.yandex.ru/authorize?response_type=token&client_id=<Your_ClientID> and obtain your Token
# https://yandex.ru/dev/disk-api/doc/ru/concepts/quickstart

# Rights needed
# cloud_api:disk.app_folder
# cloud_api:disk.read
# cloud_api:disk.info
# cloud_api:disk.write
# yadisk:disk

$encodedPath = [System.Uri]::EscapeDataString("disk:/test/1.txt")

$Headers = @{
	Authorization = "OAuth $Token"
	Accept        = "application/json"
}
$Parameters = @{
	Uri     = "https://cloud-api.yandex.net/v1/disk/resources/publish?path=$encodedPath"
	Headers = $Headers
	Method  = "Put"
}
$publishResponse = Invoke-RestMethod @Parameters

$Parameters = @{
	Uri     = $publishResponse.href
	Headers = $Headers
}
$resourceInfo = Invoke-RestMethod @Parameters
$resourceInfo.public_url

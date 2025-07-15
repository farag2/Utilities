# https://github.com/GoogleChromeLabs/chrome-for-testing/blob/main/data/last-known-good-versions-with-downloads.json
# https://www.nuget.org/packages/selenium.webdriver
# https://www.nuget.org/packages/selenium.support
# https://developer.microsoft.com/microsoft-edge/tools/webdriver/

Import-Module "D:\Desktop\lib\net8.0\WebDriver.dll"
Import-Module "D:\Desktop\lib\net8.0\WebDriver.Support.dll"

$edgeOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions

$edgeOptions.AddArgument("--headless=new")
$edgeOptions.AddArgument("--ignore-certificate-errors")
$edgeOptions.AddArgument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0")
$edgeOptions.AddArgument("--window-size=1920,1080")
$edgeOptions.AddArgument("--disable-blink-features=AutomationControlled")
$edgeOptions.AddArgument("--disable-features=IsolateOrigins,site-per-process")
$edgeOptions.AddArgument("--disable-site-isolation-trials")

$edgeOptions.AcceptInsecureCertificates = $true
$edgeOptions.AddUserProfilePreference("download.default_directory", "D:\Desktop\lib")

$driver = New-Object OpenQA.Selenium.Edge.EdgeDriver("D:\Desktop\lib", $edgeOptions)

$driver.ExecuteScript("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
$driver.ExecuteScript("return navigator.language")

$driver.Navigate().GoToUrl("URL")

function Test-ADCredentials
{
	param
	(
		[string]
		$User,

		[string]
		$Password,

		[string]
		$DomainController = ""
	)

	Add-Type -AssemblyName System.DirectoryServices.AccountManagement

	if ($DomainController)
	{
		$PrincipalContext = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $DomainController)
		$PrincipalContext.ValidateCredentials($User, $Password, [System.DirectoryServices.AccountManagement.ContextOptions]::Negotiate)
		$PrincipalContext.Dispose()
	}
	else
	{
		New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine, $env:COMPUTERNAME).ValidateCredentials($User, $Password)
	}
}
Test-ADCredentials -User "" -Password ""
Test-ADCredentials -User "" -Password ""

(Get-ADDomainController -Discover -NextClosestSite).HostName
$env:LOGONSERVER

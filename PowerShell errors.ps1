# https://gist.github.com/techthoughts2/0945276362aeebb4926a11b848844926

function Reset-Errors
{
    $Global:Error.Clear()
    $psISE.Options.ErrorForegroundColor = '#FFFF0000'
    $Global:ErrorView = 'NormalView'
}
Reset-Errors

#generate an error
function Show-Error
{
    Get-Item c:\doesnotexist.txt
}
Show-Error

#all errors are stored in:
$Error

#lets make it less overwhelming (and prioritized and actionable)
$Error | Group-Object | Sort-Object -Property Count -Descending | Format-Table -Property Count,Name -AutoSize

#what about speific error details?
$Error[0] | Format-List *

#PS is dumb somtimes and this doesn't provide the date we are looking for.
#use the force, luke!
$Error[0] | Format-List * -Force

#when the top level information inst' clear, go deeper
$Error[0].Exception
$Error[0].Exception | Format-List * -Force
$Error[0].Exception.InnerException | Format-List * -Force

#leverage the stack traces
$Error[0].ScriptStackTrace #for locations in PowerShell functions/scripts
$Error[0].Exception.StackTrace #for locations in compiled cmdlets/dlls

#don't forget to clean up behind yourself as you deal with errors
$Error.Remove($Error[0]) #remove a specific error
$Error.RemoveAt(0) #remove by index
$Error.RemoveRange(0,10) #remove by index + count
$Error.Clear() #clear the error collection

#-------------------------------------------
#consider ussing ThrowTerminating error
1/0
Write-Host 'Will this run?' -ForegroundColor Cyan

function Test-1
{
    [CmdletBinding()]
    param()
    try
    {
        1/0; Write-Host 'Will this run?' -ForegroundColor Cyan
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}
function Test-2
{
    [CmdletBinding()]
    param()
    try{
        1/0; Write-Host 'Will this run?' -ForegroundColor Cyan
    }
    catch
    {
        throw
    }
}
#compare Test-1 (clean error identifying the source line where it happened in the calling script
Test-1
#to Test-2 (error showing internals that don't identify the source line at all)
Test-2

#-------------------------------------------------------------------------------
#crafting a custom ErrorRecord for the purposes of properly mocking failures
Mock Invoke-RestMethod
{
    [System.Exception]$exception = "The remote server returned an error: (400) Bad Request."
    [System.String]$errorId = 'BadRequest'
    [Management.Automation.ErrorCategory]$errorCategory = [Management.Automation.ErrorCategory]::InvalidOperation
    [System.Object]$target = 'Whatevs'
    $errorRecord = New-Object Management.Automation.ErrorRecord ($exception, $errorID,$errorCategory, $target)
    [System.Management.Automation.ErrorDetails]$errorDetails = '{"message":"Database could not be reached"}'
    $errorRecord.ErrorDetails = $errorDetails
    throw $errorRecord
}
#-------------------------------------------------------------------------------
$formatstring = "{0} : {1}`n{2}`n" +
                "    + CategoryInfo          : {3}`n" +
                "    + FullyQualifiedErrorId : {4}`n"
$fields = $_.InvocationInfo.MyCommand.Name,
          $_.ErrorDetails.Message,
          $_.InvocationInfo.PositionMessage,
          $_.CategoryInfo.ToString(),
          $_.FullyQualifiedErrorId

$formatstring -f $fields
#-------------------------------------------------------------------------------

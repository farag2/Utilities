# Send a file for scanning and create a collection

#Requires -Version 7

$Reports = foreach ($File in @(Get-ChildItem -Path D:\Folder -File))
{
	$Headers = @{
		"x-apikey" = ""
	}
	$Parameters = @{
		Uri             = "https://www.virustotal.com/api/v3/files"
		Method          = "Post"
		Headers         = $Headers
		Form            = @{file = $File}
		UseBasicParsing = $true
		Verbose         = $true
	}
	$Response = Invoke-RestMethod @Parameters

	Write-Verbose -Message "Uploading $($File)..." -Verbose

	do
	{
		Start-Sleep -Seconds 20

		$Headers = @{
			"x-apikey" = ""
		}
		$Parameters = @{
			Uri             = "https://www.virustotal.com/api/v3/analyses/$($Response.data.id)"
			Headers         = $Headers
			UseBasicParsing = $true
			Verbose         = $true
		}
		$Analysis = Invoke-RestMethod @Parameters
	}
	until ($Analysis.data.attributes.status -eq "completed")

	[PSCustomObject]@{
		Name  = $File.Name
		Hash  = (Get-FileHash -Path $File.FullName -Algorithm SHA256).Hash.ToLower()
		Stats = $Analysis.data.attributes.stats
	}
}

$Body = @{
	data = @{
		type          = "collection"
		attributes    = @{
			name        = "Name"
			description = "testtest"
		}
		relationships = @{
			files = @{
				data = @($Reports | ForEach-Object -Process {@{type = "file"; id = $_.Hash}})
			}
		}
	}
} | ConvertTo-Json -Depth 10

$Headers = @{
	"x-apikey" = ""
}
$Parameters = @{
	Uri         = "https://www.virustotal.com/api/v3/collections"
	Method      = "Post"
	Headers     = $Headers
	ContentType = "application/json"
	Body        = $Body
	Verbose     = $true
}
$Collection = Invoke-RestMethod @Parameters

$Malicious = @{
	Name = "Malicious"
	Expression = {$_.Stats.malicious}
}
$Suspicious = @{
	Name = "Suspicious"
	Expression = {$_.Stats.suspicious}
}
$Reports | Select-Object -Property Name, $Malicious, $Suspicious, Hash | Format-Table -AutoSize

"Collection: https://www.virustotal.com/gui/collection/$($Collection.data.id)"

$Headers = @{
	"x-apikey" = ""
}
$Parameters = @{
	Uri     = "https://www.virustotal.com/api/v3/collections/c8b8b2e4e2420889678c7ebfe20859af7374548505baf1004b4c65a1bcc44a44"
	Headers = $Headers
}
(Invoke-RestMethod @Parameters).data.attributes

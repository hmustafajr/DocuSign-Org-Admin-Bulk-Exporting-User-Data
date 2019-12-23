# Construct your API header
$accessToken = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$orgId = "0da0a9c0-xxxx-xxxx-xxxx-05a0fe6aa5c4"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.add("Authorization","Bearer $accessToken")
$headers.add("Content-Type","application/json")

# Create the Bulk Export
$body = @"
{
	"type": "organization_memberships_export"
}
"@

$uri1 = "https://api-d.docusign.net/management/v2/organizations/$orgId/exports/user_list"
$result1 = Invoke-WebRequest -headers $headers -Uri $uri1 -body $body -Method POST
$result1.Content
$results = $result1 | convertfrom-json
$requestId = $results.id
$resultId = "To be set"
Write-Output "The request is being created. Waiting 5 seconds to get the request status."
Start-Sleep -Second 5

# Check the Request Status
Write-Output "Checking Bulk Action Status"
$uri2 = "https://api-d.docusign.net/management/v2/organizations/$orgId/exports/user_list/$requestId"
$result2 = Invoke-WebRequest -headers $headers -Uri $uri2 -Method GET
$result2.Content
$results = $result2 | convertfrom-json
$retrycount = 0
Do{
	Write-Output "The Bulk Action has not been completed. Retrying in 5 seconds. To abort, Press Control+C"
	Start-Sleep 5
	$result2 = Invoke-WebRequest -headers $headers -Uri $uri2 -Method Get
	$retrycount++
	if($retrycount -eq 5){
		break
	}
} While ($results.status -ne "completed")
if($results.status -eq "completed"){
	Write-Output $results.results.id
	$resultId = $results.results.id
}
else{
	Write-Output "An error has occurred, the Bulk Action has not been completed."
}

# Download the exported CSV user list
if($results.status -eq "completed"){
	$uri3 = "https://demo.docusign.net/restapi/v2/organization_exports/$orgId/user_list/$resultId"
	$result3 = Invoke-WebRequest -headers $headers -Uri $uri3 -Method GET
	$result3.Content
}

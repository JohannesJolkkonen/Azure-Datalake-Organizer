param(
    [Parameter (Mandatory=$false)]
    [object] $WebhookData,
    [Parameter()]
    [string]$resgroup = "DatalakeDemoRG",
    [Parameter()]
    [string]$automacc = "myautomation",
    [Parameter()]
    [string]$runbookname = "dl-automation-MIdentity"
)

if ($WebHookData) {
    Write-Output "PS-Script Started from Webhook"
    $WebhookName = $WebHookData.WebHookName
    $WebhookHeaders = $WebHookData.RequestHeader
    $Body = $WebHookData.RequestBody
}

# Connect to Azure
$conn = Get-AutomationConnection -Name "AzureRunAsConnection"

Connect-AzAccount -ServicePrincipal `
    -ApplicationId $conn.ApplicationId `
    -Tenant $conn.TenantId `
    -CertificateThumbprint $conn.CertificateThumbprint

$job = Start-AzAutomationRunbook -ResourceGroupName $resgroup `
  -AutomationAccountName $automacc -Name $runbookname -Parameters @{"RunbookInput"=$Body}

if (!$job) {
    Write-Output "Failed to start Blob-control runbook."
    exit
    }else {
        Write-Output "Job started successfully"
        }

$doLoop = $true 
While ($doLoop) {
    $job = Get-AzAutomationJob -ResourceGroupName $resgroup `
        -AutomationAccountName $automacc `
        -Id $job.JobId
    $status = $job.status
    $doLoop = (($status -ne "Completed")) -and ($status -ne "Failed") -and ($status -ne "Suspended") -and ($status -ne "Stopped")
}

$joboutput = (Get-AzAutomationJobOutput -ResourceGroupName $resgroup `
    -AutomationAccountName $automacc `
    -Id $job.JobId `
    -Stream Error).Summary

$teamsWebhook = Get-AutomationVariable -Name "teams-incoming-webhook"
$body = [PSCustomObject][Ordered]@{
    "summmary"="Alert from Datalake Organizer"
    "title"="Alert from Datalake Organizer"
    "text"="<pre>Errors from runbook: $joboutput<br><br>Request body: $body</pre>"}

$teamMessageBody = ConvertTo-Json $body 

Invoke-RestMethod -Uri $teamsWebhook -Method Post -Body $teamMessageBody -ContentType 'application/json'



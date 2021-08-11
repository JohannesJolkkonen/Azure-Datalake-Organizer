param(
    [Parameter (Mandatory=$false)]
    [object] $RunbookInput
)

if ($RunbookInput) {
    Write-Output "PS-Script Started with ErrorHandling"
    $WebhookName = $WebHookData.WebHookName
    $WebhookHeaders = $WebHookData.RequestHeader
    $MyInput = (ConvertFrom-Json -InputObject $RunbookInput)
}

# $azAccount = Connect-AzAccount -Identity
# $mykey = Get-AzStorageAccountKey -ResourceGroupName "DatalakeDemoRG" -AccountName "datalake01storage" | Where-Object {$_.KeyName -eq "key1"}

$conn = Get-AutomationConnection -Name "AzureRunAsConnection"
Connect-AzAccount -ServicePrincipal `
    -ApplicationId $conn.ApplicationId `
    -Tenant $conn.TenantId `
    -CertificateThumbprint $conn.CertificateThumbprint

$mykey = (Get-AutomationVariable -Name "datalake-storage-account-key")

$storacc = "datalake01storage"
$filesys = $MyInput.fsystem
$inputpath = $MyInput.fpath
if ($filesys -like '*production*') {
    $destpath = 'production'
    }
    else {
    $destpath = $inputpath
    }

$destfilesys = "raw-d829dfbb-1516-4957-805b-2a3c1e8573eb"

$mystorcontext = New-AzStorageContext -StorageAccountName $storacc -StorageAccountKey $mykey


try {
    Move-AzDataLakeGen2Item -FileSystem $filesys -Path $inputpath -DestFileSystem $destfilesys -DestPath $destpath -Context $mystorcontext -Force
    }
    catch {
        Write-Error $Error[0]
        # Write-Error "Sample Error 100344"
        }


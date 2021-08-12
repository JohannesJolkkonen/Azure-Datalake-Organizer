# Azure Datalake Gen2 Organizer

## Purpose
Support for high volumes and numerous formats of data is one of the best features of Data Lakes. However, this can also lead to their deprecation into Data Swamps, where data is not properly curated and it becomes very difficult for users to find the data they need and in the right format.

This setup uses BlobTrigger Functions to detect new blobs of data within the Data Lake that are not compliant with rules of organization, and Azure Automate Runbooks for moving the blobs to their correct zone. By dealing with offending blobs as they occur, we prevent the system's usability from gradually deprecating.


## Notes

-BlobTrigger Functions are triggered retroactively, so when you set the functions to track an existing container/filesystem for uploads, **all existing blobs are also checked** for compliance and moved as necessary.

- Azure Automation was used to move the blobs mostly for learning purposes, but implementing all the scripts with Azure Functions would probably be better due to faster startup. 

- In case of error(s) moving a blob, the runbook sends an alert Message to a Teams-channel using a webhook connector. The webhook address is stored and retrieved with AzAutomate Variables.


## Services Used

- ADLGen2
- Key Vault
- Azure Function App
- Azure Automation
- Teams

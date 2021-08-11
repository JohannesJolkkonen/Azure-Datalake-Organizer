##

import os, uuid, sys

from azure.storage.filedatalake import DataLakeServiceClient
from azure.core.match_conditions import MatchConditions
from azure.storage.filedatalake._models import ContentSettings


def initialize_storage_account(stor_acc_name, stor_acc_key):
    try:
        global service_client

        service_client = DataLakeServiceClient(account_url=f"https://{stor_acc_name}.dfs.core.windows.net", credential=stor_acc_key)
    
    except Exception as e:
        print(e)



import logging
import requests
import azure.functions as func

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient


def get_autom_webhook(secret_name):
    keyVaultName = "my-secretchamber"
    KVUri = f"https://{keyVaultName}.vault.azure.net"
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=KVUri, credential=credential)
    webhook = client.get_secret(secret_name).value
    logging.info(f'Secret Retrieved Successfully')

    return webhook

def webhook_request(url, data):
    logging.info(f'Calling webhook at: {url}')
    r = requests.post(url=url, json=data)
    logging.info(f'Status code: {r.status_code}')

def main(myadl: func.InputStream):
    logging.info(f"Python blob trigger function processed blob \n"
                 f"Name: {myadl.name}\n"
                 f"Blob Size: {myadl.length} bytes\n")   

    if myadl.name.split('.')[-1] in ["parquet"]:
        logging.info('No actions required.')
        return
    
    else:
        webhook = get_autom_webhook("autom-webhook")
        body = {'fsystem': myadl.name.split('/')[0],
                    'fpath': "/".join(myadl.name.strip("/").split('/')[1:]),
                    'fname': myadl.name.split('/')[-1]
                }
        webhook_request(webhook, body)
        

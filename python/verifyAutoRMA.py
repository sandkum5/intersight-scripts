#!/usr/bin/env python3
"""
Script to verify Intersight AutoRMA configuration
Does the following:
 - Checks if AutoRMA is configured at Account/Org/Asset/Device Level
 - Lists Active Faults with AutoRMA fault codes
 - List contracts associated with claimed devices in Intersight
 - Allows AutoRMA configuration at Account/Org level
Update Line 286 with the Intersight FQDN. If SAAS, no changes are needed.
Add ApiKey.txt and SecretKey.txt files with the API keys in the same directory before script execution.
"""
import json
import requests
from intersight_auth import IntersightAuth
import urllib3
from tabulate import tabulate
from pprint import pprint

urllib3.disable_warnings()

def read_keys(apikeyfile, secretkeyfile):
    try:
        with open(apikeyfile) as f:
            ApiKey = f.read()
        with open(secretkeyfile) as s:
            cert = s.read()
    except Exception as e:
        print("Issue with Intersight API Keys")
    return (ApiKey,secretkeyfile)

def get_data(AUTH, base_url, path):
    url = f"{base_url}{path}"
    try:
        response = requests.get(url, auth=AUTH, verify=False)
    except Exception as e:
        print(e)
    else:
        if response.status_code == 200:
            return response
        else:
            return response.text

def put_data(AUTH, base_url, path, payload):
    url = f"{base_url}{path}"
    headers = {"Content-Type": "application/json"}
    try:
        response = requests.post(url, auth=AUTH, headers=headers, json=json.dumps(payload), verify=False)
    except Exception as e:
        print(e)
    else:
        # return response.json()
        return response

def parse_tags(data):
    autorma_config = {"AutoRMA": "", "AutoRMAEmail": "", "NotConfigured": ""}
    if data:
        for x in data:
            if x["Key"] == "AutoRMA":
                if x["Value"] == "True":
                    # print("AutoRMA Enabled")
                    autorma_config["AutoRMA"] = "True"
                if x["Value"] == "False":
                    # print("AutoRMA Disabled")
                    autorma_config["AutoRMA"] = "False"
            if x["Key"] == "AutoRMAEmail":
                emails = x["Value"]
                autorma_config["AutoRMAEmail"] = emails
                # print(f"Configured Emails: {emails}")
    else:
        autorma_config["NotConfigured"] = "True"
        # print("AutoRMA Not Configured")
    return autorma_config

def verify_account_autorma(AUTH, base_url):
    path = "iam/Accounts?$select=Name,Tags"
    response = get_data(AUTH, base_url, path)
    data = response.json()["Results"][0]
    acc_name = data["Name"]
    tags_data = data["Tags"]
    rma_table = [["Account_Name", "AutoRMA_Config", "Emails"]]
    autorma_config = parse_tags(tags_data)
    filtered_table = []
    account_table = []
    account_table.append(acc_name)
    if autorma_config["AutoRMA"] == "True":
        emails = autorma_config["AutoRMAEmail"]
        account_table.append("True")
        account_table.append(emails)
        # print(f"Org Name: {org_name}: AutoRMA Enabled")
        # print(f"Configured Emails: {emails}")
    if autorma_config["AutoRMA"] == "False":
        account_table.append("False")
        account_table.append("")
        # print(f"Org Name: {org_name}: AutoRMA Disabled")
    if autorma_config["AutoRMA"] == "":
        account_table.append("Not Configured")
        account_table.append("")
    rma_table.append(account_table)
    # print("-" * 75)
    # print("Account Level AutoRMA Config")
    # print(tabulate(rma_table, headers="firstrow"))
    for account in rma_table:
        if account[1] in ("True", "False", "AutoRMA_Config"):
            filtered_table.append(account)
    if len(filtered_table) > 1:
        print("")
        print("-" * 75)
        print("Account Level AutoRMA Config")
        print(tabulate(filtered_table, headers="firstrow"))
        print("")
        account_config = True
        return account_config
    if len(filtered_table) <= 1:
        print("-" * 75)
        print("AutoRMA is not configured at Account Level")
        account_config = False
        return account_config

def verify_org_autorma(AUTH, base_url):
    path = "organization/Organizations?$select=Name,Tags"
    response = get_data(AUTH, base_url, path)
    filtered_table = []
    rma_table = [["Org_Name", "AutoRMA_Config", "Emails"]]
    for org in response.json()["Results"]:
        org_table = []
        org_name = org["Name"]
        org_table.append(org_name)
        org_tags = org["Tags"]
        autorma_config = parse_tags(org_tags)
        if autorma_config["AutoRMA"] == "True":
            emails = autorma_config["AutoRMAEmail"]
            org_table.append("True")
            org_table.append(emails)
            # print(f"Org Name: {org_name}: AutoRMA Enabled")
            # print(f"Configured Emails: {emails}")
        if autorma_config["AutoRMA"] == "False":
            org_table.append("False")
            org_table.append("")
            # print(f"Org Name: {org_name}: AutoRMA Disabled")
        if autorma_config["AutoRMA"] == "":
            org_table.append("Not Configured")
            org_table.append("")
            # print(f"Org Name: {org_name}: AutoRMA Not Configured")
        rma_table.append(org_table)
    for org in rma_table:
        if org[1] in ("True", "False", "AutoRMA_Config"):
            filtered_table.append(org)
    if len(filtered_table) > 1:
        print("")
        print("-" * 75)
        print("Organization Level AutoRMA Config")
        print(tabulate(filtered_table, headers="firstrow"))
        print("")
        org_config = True
        return org_config
    if len(filtered_table) <= 1:
        print("-" * 75)
        print("AutoRMA is not configured at Org Level")
        org_config = False
        return org_config
    # return filtered_table
    # print(tabulate(rma_table, headers="firstrow"))

def verify_device_autorma(AUTH, base_url):
    path = "asset/DeviceRegistrations?$select=DeviceHostname,Serial,Tags"
    response = get_data(AUTH, base_url, path)
    filtered_table = []
    rma_table = [["DeviceHostName", "AutoRMA_Config", "Emails"]]
    for data in response.json()["Results"]:
        device_name = data["DeviceHostname"]
        tags_data = data["Tags"]
        autorma_config = parse_tags(tags_data)
        device_table = []
        device_table.append(device_name)
        if autorma_config["AutoRMA"] == "True":
            emails = autorma_config["AutoRMAEmail"]
            device_table.append("True")
            device_table.append(emails)
            # print(f"Org Name: {org_name}: AutoRMA Enabled")
            # print(f"Configured Emails: {emails}")
        if autorma_config["AutoRMA"] == "False":
            device_table.append("False")
            device_table.append("")
            # print(f"Org Name: {org_name}: AutoRMA Disabled")
        if autorma_config["AutoRMA"] == "":
            device_table.append("Not Configured")
            device_table.append("")
        rma_table.append(device_table)
    for device in rma_table:
        if device[1] in ("True", "False", "AutoRMA_Config"):
            filtered_table.append(device)
    if len(filtered_table) > 1:
        print("")
        print("-" * 75)
        print("Asset/Device Level AutoRMA Config")
        print(tabulate(filtered_table, headers="firstrow"))
        print("")
    if len(filtered_table) <= 1:
        print("-" * 75)
        print("AutoRMA is not configured at Asset/Device Level")
    # print(tabulate(rma_table, headers="firstrow"))
    # return filtered_table

def get_active_faults(AUTH, base_url):
    path = "cond/Alarms?$filter=Code in ('F0185','F1732','F0181','F0484','F0397','F0794')&$expand=RegisteredDevice($select=DeviceHostname,Pid,Serial,PlatformType,DeviceIpAddress,ConnectorVersion,ConnectionStatus,ConnectionReason,ConnectionStatusLastChangeTime)&$select=MsAffectedObject,Description,CreationTime,Severity,RegisteredDevice,AffectedMoType,AffectedMoDisplayName"
    response = get_data(AUTH, base_url, path)
    active_faults = response.json()["Results"]
    active_faults_count = len(response.json()["Results"])
    return (active_faults_count, active_faults)

def get_cleared_faults(AUTH, base_url):
    path = "cond/Alarms?$filter=Severity eq 'Cleared' and Code in ('F0185','F1732','F0181','F0484','F0397','F0794')&$select=LastTransitionTime&$orderby=LastTransitionTime Asc"
    response = get_data(AUTH, base_url, path)
    cleared_faults = response.json()["Results"]
    cleared_fault_count = len(response.json()["Results"])
    return (cleared_fault_count, cleared_faults)

def add_account_tags(AUTH, base_url, enable_autorma, email_ids):
    path = "iam/Accounts"
    get_response = get_data(AUTH, base_url, path)
    account_moid = get_response.json()["Results"][0]["Moid"]
    payload = [
        {"op": "add", "path": "/Tags/-", "value": {"Key": "AutoRMA", "Value": enable_autorma}},
        {"op": "add", "path": "/Tags/-", "value": {"Key": "AutoRMAEmail", "Value": email_ids}}
    ]
    post_path = f"iam/Accounts/{account_moid}"
    url = f"{base_url}{post_path}"
    headers = {"Content-Type": "application/json-patch+json"}
    response = requests.patch(url, auth=AUTH, headers=headers, data=json.dumps(payload), verify=False)
    # print(response.json())
    if response.status_code == 200:
        print("Account Tags Updated Successfully")

def del_account_tags(AUTH, base_url):
    path = "iam/Accounts"
    get_response = get_data(AUTH, base_url, path)
    account_moid = get_response.json()["Results"][0]["Moid"]
    # Below Payload syntax fails. Issue with API. Still Checking
    # payload = [
    #     { "op": "remove",  "path": "/Tags[Key='AutoRMA']" },
    #     { "op": "remove",  "path": "/Tags[Key='AutoRMAEmail']" }
    # ]
    # If the AutoRMA and AutoRMAEmail are the first 2 Tags
    payload = [
        {"op": "remove", "path": "/Tags/0"},
        {"op": "remove", "path": "/Tags/1"}
    ]
    post_path = f"iam/Accounts/{account_moid}"
    url = f"{base_url}{post_path}"
    headers = {"Content-Type": "application/json-patch+json"}
    response = requests.patch(url, auth=AUTH, headers=headers, data=json.dumps(payload), verify=False)
    # print(response.json())
    if response.status_code == 200:
        print("Account Tags Deleted Successfully")

def add_org_tags(AUTH, base_url, enable_autorma, email_ids, org_list):
    path = "organization/Organizations"
    response = get_data(AUTH, base_url, path)
    for org in response.json()["Results"]:
        org_moid = org["Moid"]
        org_name = org["Name"]
        if org_name in org_list:
            payload = [
                {"op": "add", "path": "/Tags/-", "value": {"Key": "AutoRMA", "Value": enable_autorma}},
                {"op": "add", "path": "/Tags/-", "value": {"Key": "AutoRMAEmail", "Value": email_ids}}
            ]
            post_path = f"organization/Organizations/{org_moid}"
            url = f"{base_url}{post_path}"
            headers = {"Content-Type": "application/json-patch+json"}
            response = requests.patch(url, auth=AUTH, headers=headers, data=json.dumps(payload), verify=False)
            # print(response.json())
            if response.status_code == 200:
                print(f"Organization: {org_name} Tags Updated Successfully")

def get_contracts(AUTH, base_url):
    path = "asset/DeviceContractInformations?$select=Contract,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId"
    response = get_data(AUTH, base_url, path)
    contracts = response.json()
    contract_list = []
    for contract in contracts["Results"]:
        ContractNumber = contract["Contract"]["ContractNumber"]
        contract_list.append(ContractNumber)
    unique_contracts = list(set(contract_list))
    pprint(unique_contracts)

if __name__ == '__main__':
    # hostname = input("Enter Intersight Hostname: ")
    hostname = "intersight.com"
    base_url = f"https://{hostname}/api/v1/"
    api_key, secret_key = read_keys('ApiKey.txt', 'SecretKey.txt')
    AUTH = IntersightAuth(api_key, secret_key)

    # AutoRMA Config at Account Level
    account_config = verify_account_autorma(AUTH, base_url)
    org_config = verify_org_autorma(AUTH, base_url)
    verify_device_autorma(AUTH, base_url)
    print("-" * 75)
    active_fault_count, active_faults = get_active_faults(AUTH, base_url)
    print(f"Active Fault Count with AutoRMA Fault Codes: {active_fault_count}")
    print("-" * 75)
    cleared_fault_count, cleared_faults = get_cleared_faults(AUTH, base_url)
    print(f"Cleared Fault Count with AutoRMA Fault Codes: {cleared_fault_count}")
    print("-" * 75)
    print("List of contracts associated with claimed devices in Intersight:")
    get_contracts(AUTH, base_url)
    print("-" * 75)
    enable_account = input("Configure AutoRMA at Account Level, y/n: ")
    if enable_account.lower() == "y":
        # if not account_config:
        enable_autorma = "True"
        email_ids = "sample@demo-email.com,demo@home.lab"
        print(f"Enable Auto RMA with Emails: {email_ids}")
        add_account_tags(AUTH, base_url, enable_autorma, email_ids)
        verify_account_autorma(AUTH, base_url)
        print("-" * 75)
    if enable_account.lower() == "n":
        print("-" * 75)
    enable_org = input("Configure AutoRMA at Organization Level, y/n: ")
    if enable_org.lower() == "y":
        orgs = input("Enter Comma separated Org Names! E.g. prod,dev: ")
    # if not org_config:
        # org_list = ["default", "prod"]
        org_list = orgs.split(",")
        enable_autorma = "True"
        email_ids = input("Enter Comma separated Email Ids: ")
        # email_ids = "sandkum5@cisco.com,demo@home.lab"
        print(f"Enable Auto RMA with Emails: {email_ids}")
        add_org_tags(AUTH, base_url, enable_autorma, email_ids, org_list)
        verify_org_autorma(AUTH, base_url)
        print("-" * 75)
    if enable_org == "n":
        print("-" * 75)
  

#!/usr/bin/env python3
# Pending: Add Pagination

import requests
from intersight_auth import IntersightAuth
import csv

url = "https://intersight.com/api/v1/asset/DeviceContractInformations?$select=Contract,Contract.ContractNumber,Contract.LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId"

# Create an AUTH object
AUTH = IntersightAuth(
    secret_key_filename="./SecretKey.txt",
    api_key_id="xxxxxxxxxxx",
)

payload = {}
headers = {}

response = requests.request("GET", url, auth=AUTH, headers=headers, data=payload)

# print(response.text)
jsonData = response.json()

columns = [
    "DeviceId",
    "DeviceType",
    "PlatformType",
    "ContractNumber",
    "ContractStatus",
    "ContractStatusReason",
    "LineStatus",
    "SalesOrderNumber",
    "PurchaseOrderNumber",
    "ServiceLevel",
    "ServiceDescription",
    "ServiceStartDate",
    "ServiceEndDate",
]

# Output file
filename = "contract_info.csv"

with open(filename, "w") as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(columns)
    for device in range(len(jsonData["Results"])):
        data_dict = {}
        data_dict["DeviceId"] = jsonData["Results"][device]["DeviceId"]
        data_dict["DeviceType"] = jsonData["Results"][device]["DeviceType"]
        data_dict["PlatformType"] = jsonData["Results"][device]["PlatformType"]
        data_dict["ContractNumber"] = jsonData["Results"][device]["Contract"][
            "ContractNumber"
        ]
        data_dict["ContractStatus"] = jsonData["Results"][device]["ContractStatus"]
        data_dict["ContractStatusReason"] = jsonData["Results"][device][
            "ContractStatusReason"
        ]
        data_dict["LineStatus"] = jsonData["Results"][device]["Contract"]["LineStatus"]
        data_dict["SalesOrderNumber"] = jsonData["Results"][device]["SalesOrderNumber"]
        data_dict["PurchaseOrderNumber"] = jsonData["Results"][device][
            "PurchaseOrderNumber"
        ]
        data_dict["ServiceLevel"] = jsonData["Results"][device]["ServiceLevel"]
        data_dict["ServiceDescription"] = jsonData["Results"][device][
            "ServiceDescription"
        ]
        data_dict["ServiceStartDate"] = jsonData["Results"][device]["ServiceStartDate"]
        data_dict["ServiceEndDate"] = jsonData["Results"][device]["ServiceEndDate"]
        row = list(data_dict.values())
        # Write Device info as a csv row
        csvwriter.writerow(row)

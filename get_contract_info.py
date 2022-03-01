#!/usr/bin/env python3
#
# Get Device Contract Status Info from Intersight.
#

import requests
from intersight_auth import IntersightAuth
import csv


def getCount(AUTH):
    url = "https://intersight.com/api/v1/asset/DeviceContractInformations?$count=True"
    response = requests.request("GET", url, auth=AUTH)
    countData = response.json()
    return countData


def getData(AUTH, count):
    """
    Get Contract Status for all the servers
    """
    loop_count = (count // 100) + 1
    for x in range(loop_count):
        skip_value = x * 100
        url = f"https://intersight.com/api/v1/asset/DeviceContractInformations?$skip={skip_value}&$top=100&$select=Contract,Contract.ContractNumber,Contract.LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId"
        response = requests.request("GET", url, auth=AUTH)
        contractData = response.json()
        return contractData


def main():
    # Create an AUTH object
    AUTH = IntersightAuth(
        secret_key_filename="./SecretKey.txt",
        api_key_id="xxxxxxxxxxxxx",
    )

    # Get Object Count
    countData = getCount(AUTH)
    count = countData["Count"]

    # Get Contract Data
    contractData = getData(AUTH, count)

    # Write to a CSV File
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

    # Output File
    filename = "contract_info.csv"

    with open(filename, "w") as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(columns)
        for device in range(len(contractData["Results"])):
            data_dict = {}
            data_dict["DeviceId"] = contractData["Results"][device]["DeviceId"]
            data_dict["DeviceType"] = contractData["Results"][device]["DeviceType"]
            data_dict["PlatformType"] = contractData["Results"][device]["PlatformType"]
            data_dict["ContractNumber"] = contractData["Results"][device]["Contract"][
                "ContractNumber"
            ]
            data_dict["ContractStatus"] = contractData["Results"][device][
                "ContractStatus"
            ]
            data_dict["ContractStatusReason"] = contractData["Results"][device][
                "ContractStatusReason"
            ]
            data_dict["LineStatus"] = contractData["Results"][device]["Contract"][
                "LineStatus"
            ]
            data_dict["SalesOrderNumber"] = contractData["Results"][device][
                "SalesOrderNumber"
            ]
            data_dict["PurchaseOrderNumber"] = contractData["Results"][device][
                "PurchaseOrderNumber"
            ]
            data_dict["ServiceLevel"] = contractData["Results"][device]["ServiceLevel"]
            data_dict["ServiceDescription"] = contractData["Results"][device][
                "ServiceDescription"
            ]
            data_dict["ServiceStartDate"] = contractData["Results"][device][
                "ServiceStartDate"
            ]
            data_dict["ServiceEndDate"] = contractData["Results"][device][
                "ServiceEndDate"
            ]
            row = list(data_dict.values())
            # Write Device info as a csv row
            csvwriter.writerow(row)

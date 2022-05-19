#!/usr/bin/env python3

import requests
from intersight_auth import IntersightAuth
import csv
from pprint import pprint
import os
from dotenv import load_dotenv

load_dotenv()


def get_server_license_info(AUTH):
    """Get's all the server info"""
    url = "https://intersight.com/api/v1/compute/PhysicalSummaries?$select=Serial,Tags"
    payload = {}
    headers = {}
    response = requests.request("GET", url, auth=AUTH, headers=headers, data=payload)
    server_info = response.json()["Results"]
    return server_info


def parse_license_info(server_info):
    license_dict = {}
    for server in server_info:
        for tag in server["Tags"]:
            if "Intersight.LicenseTier" in tag["Key"]:
                license = tag["Value"]
        moid = server["Moid"]
        serial = server["Serial"]
        object_type = server["ObjectType"]
        if license != "Base":
            license_dict[moid] = {
                "Serial": serial,
                "ObjectType": object_type,
                "License": license,
            }
        # print("")
        # print(f"Server Serial: {serial}\nServer Moid: {moid}\nServer ObjectType: {object_type}\nServer License: {license}")
        # print(100 * "-")
    return license_dict


def get_server_info(AUTH, server_moid_tuple):
    """Get's all the server info"""
    base_url = f"https://intersight.com/api/v1/cond/HclStatuses?"
    filter_url = f"$filter=(ManagedObject.Moid in {server_moid_tuple})"
    expand_filter = f"&$expand=ManagedObject($select=Tags),RegisteredDevice($select=Moid,Serial,DeviceHostname,DeviceIpAddress)&$select=ManagedObject,ComponentStatus,HardwareStatus,HclFirmwareVersion,HclModel,HclOsVendor,HclOsVersion,HclProcessor,InvFirmwareVersion,InvModel,InvOsVendor,InvOsVersion,InvProcessor,ServerReason,SoftwareStatus,Status,Details,RegisteredDevice"
    url = f"{base_url}{filter_url}{expand_filter}"
    payload = {}
    headers = {}
    response = requests.request("GET", url, auth=AUTH, headers=headers, data=payload)
    server_info = response.json()["Results"]
    return server_info


def get_hcl_info(moid_tuple, AUTH):
    """Get's HCL info for the components"""
    filter_url = f"?$filter=Moid in {moid_tuple}&$select=Moid,HardwareStatus,HclCimcVersion,HclDriverName,HclDriverVersion,HclFirmwareVersion,HclModel,InvCimcVersion,InvDriverName,InvDriverVersion,InvFirmwareVersion,InvModel,Reason,SoftwareStatus,Status,Component,HclStatus"
    base_url = "https://www.intersight.com/api/v1/cond/HclStatusDetails"
    url = f"{base_url}{filter_url}"
    payload = {}
    headers = {}
    response = requests.request("GET", url, auth=AUTH, headers=headers, data=payload)
    hcl_info = response.json()["Results"]
    return hcl_info


def get_component_moid_dict(component_info):
    component_dict = {"storage.Controller": {}, "adapter.Unit": {}}
    for i in range(len(component_info)):
        if component_info[i]["Component"]["ObjectType"] == "storage.Controller":
            hcl_status_moid = component_info[i]["Moid"]
            component_moid = component_info[i]["Component"]["Moid"]
            component_dict["storage.Controller"][hcl_status_moid] = component_moid
        if component_info[i]["Component"]["ObjectType"] == "adapter.Unit":
            hcl_status_moid = component_info[i]["Moid"]
            component_moid = component_info[i]["Component"]["Moid"]
            component_dict["adapter.Unit"][hcl_status_moid] = component_moid
    return component_dict


def get_component_info(component_type, component_tuple, AUTH):
    """Get Component related info"""
    base_url = "https://www.intersight.com/api/v1/"
    base_path = f"{component_type}s"
    filter_path = (
        f"?$filter=Moid in {component_tuple}&$select=Serial,Model,Vendor,InterfaceType"
    )
    url = f"{base_url}{base_path}{filter_path}"
    payload = {}
    headers = {}
    response = requests.request("GET", url, auth=AUTH, headers=headers, data=payload)
    component_info = response.json()["Results"]
    return component_info


def parse_server_info(server_info):
    server_dict = {}
    for x in range(len(server_info)):
        Serial = server_info[x]["RegisteredDevice"]["Serial"][0]
        DeviceHostname = server_info[x]["RegisteredDevice"]["DeviceHostname"]
        DeviceIpAddress = server_info[x]["RegisteredDevice"]["DeviceIpAddress"]
        DeviceMoid = server_info[x]["RegisteredDevice"]["Moid"]
        ConnectorVersion = ""
        ConnectionStatus = ""
        ConnectionReason = ""
        InvModel = server_info[x]["InvModel"]
        InvProcessor = server_info[0]["InvProcessor"]
        InvFirmwareVersion = server_info[x]["InvFirmwareVersion"]
        InvOsVendor = server_info[x]["InvOsVendor"]
        InvOsVersion = server_info[x]["InvOsVersion"]
        HardwareStatus = server_info[x]["HardwareStatus"]
        SoftwareStatus = server_info[x]["SoftwareStatus"]
        ComponentStatus = server_info[x]["ComponentStatus"]
        ServerReason = server_info[x]["ServerReason"]
        Status = server_info[x]["Status"]
        hcl_moids = []
        for y in range(len(server_info[x]["Details"])):
            hcl_moids.append(server_info[x]["Details"][y]["Moid"])
        server_dict[Serial] = {
            "DeviceHostname": DeviceHostname,
            "DeviceIpAddress": DeviceIpAddress,
            "DeviceMoid": DeviceMoid,
            "ConnectorVersion": ConnectorVersion,
            "ConnectionStatus": ConnectionStatus,
            "ConnectionReason": ConnectionReason,
            "InvModel": InvModel,
            "InvProcessor": InvProcessor,
            "InvFirmwareVersion": InvFirmwareVersion,
            "InvOsVendor": InvOsVendor,
            "InvOsVersion": InvOsVersion,
            "HardwareStatus": HardwareStatus,
            "SoftwareStatus": SoftwareStatus,
            "ComponentStatus": ComponentStatus,
            "ServerReason": ServerReason,
            "Status": Status,
            "hcl_moid": hcl_moids,
        }
    return server_dict


def parse_hcl_info(hcl_info):
    hcl_dict = {}
    for x in range(len(hcl_info)):
        Moid = hcl_info[x]["Moid"]
        ObjectType = hcl_info[x]["Component"]["ObjectType"]

        InvModel = hcl_info[x]["InvModel"]
        InvCimcVersion = hcl_info[x]["InvCimcVersion"]
        InvDriverName = hcl_info[x]["InvDriverName"]
        InvDriverVersion = hcl_info[x]["InvDriverVersion"]
        InvFirmwareVersion = hcl_info[x]["InvFirmwareVersion"]

        HardwareStatus = hcl_info[x]["HardwareStatus"]
        HclCimcVersion = hcl_info[x]["HclCimcVersion"]
        HclDriverName = hcl_info[x]["HclDriverName"]
        HclDriverVersion = hcl_info[x]["HclDriverVersion"]
        HclFirmwareVersion = hcl_info[x]["HclFirmwareVersion"]
        HclModel = hcl_info[x]["HclModel"]

        HardwareStatus = hcl_info[x]["HardwareStatus"]
        SoftwareStatus = hcl_info[x]["SoftwareStatus"]
        Status = hcl_info[x]["Status"]
        Reason = hcl_info[x]["Reason"]

        hcl_dict[Moid] = {
            "ObjectType": ObjectType,
            "InvModel": InvModel,
            "InvCimcVersion": InvCimcVersion,
            "InvDriverName": InvDriverName,
            "InvDriverVersion": InvDriverVersion,
            "InvFirmwareVersion": InvFirmwareVersion,
            "HardwareStatus": HardwareStatus,
            "HclCimcVersion": HclCimcVersion,
            "HclDriverName": HclDriverName,
            "HclDriverVersion": HclDriverVersion,
            "HclFirmwareVersion": HclFirmwareVersion,
            "HclModel": HclModel,
            "HardwareStatus": HardwareStatus,
            "SoftwareStatus": SoftwareStatus,
            "Status": Status,
            "Reason": Reason,
        }
    return hcl_dict


def parse_component_moid_dict(component_moid_dict, AUTH):
    component_dict = {}
    for key in component_moid_dict.keys():
        component_type = "/".join(key.split("."))
        for hcl_status_moid in component_moid_dict[key].keys():
            component_moid = component_moid_dict[key][hcl_status_moid]
            component_list = [component_moid]
            component_tuple = tuple(
                component_list,
            )
            component_dict[hcl_status_moid] = {}
            component_dict[hcl_status_moid][component_moid] = {}
            component_dict[hcl_status_moid][component_moid] = get_component_info(
                component_type, component_tuple, AUTH
            )
    return component_dict


def write_to_csv(server_dict, component_moid_dict, hcl_dict, component_dict):
    columns = [
        "Serial",
        "DeviceHostname",
        "DeviceIpAddress",
        "DeviceMoid",
        "ConnectorVersion",
        "ConnectionStatus",
        "ConnectionReason",
        "InvModel",
        "InvProcessor",
        "InvFirmwareVersion",
        "InvOsVendor",
        "InvOsVersion",
        "HardwareStatus",
        "SoftwareStatus",
        "ComponentStatus",
        "ServerReason",
        "Status",
        "storage_ObjectType",
        "storage_InvModel",
        "storage_InvCimcVersion",
        "storage_InvDriverName",
        "storage_InvDriverVersion",
        "storage_InvFirmwareVersion",
        "storage_HclModel",
        "storage_HclCimcVersion",
        "storage_HclDriverName",
        "storage_HclDriverVersion",
        "storage_HclFirmwareVersion",
        "storage_SoftwareStatus",
        "storage_HardwareStatus",
        "storage_Status",
        "storage_Reason",
        "storage_Serial",
        "storage_Model",
        "storage_Vendor",
        "adapter_ObjectType",
        "adapter_InvModel",
        "adapter_InvCimcVersion",
        "adapter_InvDriverName",
        "adapter_InvDriverVersion",
        "adapter_InvFirmwareVersion",
        "adapter_HclModel",
        "adapter_HclCimcVersion",
        "adapter_HclDriverName",
        "adapter_HclDriverVersion",
        "adapter_HclFirmwareVersion",
        "adapter_SoftwareStatus",
        "adapter_HardwareStatus",
        "adapter_Status",
        "adapter_Reason",
        "adapter_Serial",
        "adapter_Model",
        "adapter_Vendor",
    ]
    # Output file
    filename = "hcl_status_info.csv"

    with open(filename, "w") as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(columns)
        for serial in server_dict.keys():
            data_dict = {}
            data_dict["Serial"] = serial
            data_dict["DeviceHostname"] = server_dict[serial]["DeviceHostname"][0]
            data_dict["DeviceIpAddress"] = server_dict[serial]["DeviceIpAddress"]
            data_dict["DeviceMoid"] = server_dict[serial]["DeviceMoid"]
            data_dict["ConnectorVersion"] = server_dict[serial]["ConnectorVersion"]
            data_dict["ConnectionStatus"] = server_dict[serial]["ConnectionStatus"]
            data_dict["ConnectionReason"] = server_dict[serial]["ConnectionReason"]
            data_dict["InvModel"] = server_dict[serial]["InvModel"]
            data_dict["InvProcessor"] = server_dict[serial]["InvProcessor"]
            data_dict["InvFirmwareVersion"] = server_dict[serial]["InvFirmwareVersion"]
            data_dict["InvOsVendor"] = server_dict[serial]["InvOsVendor"]
            data_dict["InvOsVersion"] = server_dict[serial]["InvOsVersion"]
            data_dict["HardwareStatus"] = server_dict[serial]["HardwareStatus"]
            data_dict["SoftwareStatus"] = server_dict[serial]["SoftwareStatus"]
            data_dict["ComponentStatus"] = server_dict[serial]["ComponentStatus"]
            data_dict["ServerReason"] = server_dict[serial]["ServerReason"]
            data_dict["Status"] = server_dict[serial]["Status"]
            hcl_moid = server_dict[serial]["hcl_moid"]
            for moid in hcl_moid:
                if hcl_dict[moid]["ObjectType"] == "storage.Controller":
                    data_dict["storage_ObjectType"] = hcl_dict[moid]["ObjectType"]
                    data_dict["storage_InvModel"] = hcl_dict[moid]["InvModel"]
                    data_dict["storage_InvCimcVersion"] = hcl_dict[moid][
                        "InvCimcVersion"
                    ]
                    data_dict["storage_InvDriverName"] = hcl_dict[moid]["InvDriverName"]
                    data_dict["storage_InvDriverVersion"] = hcl_dict[moid][
                        "InvDriverVersion"
                    ]
                    data_dict["storage_InvFirmwareVersion"] = hcl_dict[moid][
                        "InvFirmwareVersion"
                    ]
                    data_dict["storage_HclModel"] = hcl_dict[moid]["HclModel"]
                    data_dict["storage_HclCimcVersion"] = hcl_dict[moid][
                        "HclCimcVersion"
                    ]
                    data_dict["storage_HclDriverName"] = hcl_dict[moid]["HclDriverName"]
                    data_dict["storage_HclDriverVersion"] = hcl_dict[moid][
                        "HclDriverVersion"
                    ]
                    data_dict["storage_HclFirmwareVersion"] = hcl_dict[moid][
                        "HclFirmwareVersion"
                    ]
                    data_dict["storage_SoftwareStatus"] = hcl_dict[moid][
                        "SoftwareStatus"
                    ]
                    data_dict["storage_HardwareStatus"] = hcl_dict[moid][
                        "HardwareStatus"
                    ]
                    data_dict["storage_Status"] = hcl_dict[moid]["Status"]
                    data_dict["storage_Reason"] = hcl_dict[moid]["Reason"]
                    if moid in component_moid_dict["storage.Controller"].keys():
                        component_moid = component_moid_dict["storage.Controller"][moid]
                        data_dict["storage_Serial"] = component_dict[moid][
                            component_moid
                        ][0]["Serial"]
                        data_dict["storage_Model"] = component_dict[moid][
                            component_moid
                        ][0]["Model"]
                        data_dict["storage_Vendor"] = component_dict[moid][
                            component_moid
                        ][0]["Vendor"]
                if hcl_dict[moid]["ObjectType"] == "adapter.Unit":
                    data_dict["adapter_ObjectType"] = hcl_dict[moid]["ObjectType"]
                    data_dict["adapter_component_InvModel"] = hcl_dict[moid]["InvModel"]
                    data_dict["adapter_InvCimcVersion"] = hcl_dict[moid][
                        "InvCimcVersion"
                    ]
                    data_dict["adapter_InvDriverName"] = hcl_dict[moid]["InvDriverName"]
                    data_dict["adapter_InvDriverVersion"] = hcl_dict[moid][
                        "InvDriverVersion"
                    ]
                    data_dict["adapter_InvFirmwareVersion"] = hcl_dict[moid][
                        "InvFirmwareVersion"
                    ]
                    data_dict["adapter_HclModel"] = hcl_dict[moid]["HclModel"]
                    data_dict["adapter_HclCimcVersion"] = hcl_dict[moid][
                        "HclCimcVersion"
                    ]
                    data_dict["adapter_HclDriverName"] = hcl_dict[moid]["HclDriverName"]
                    data_dict["adapter_HclDriverVersion"] = hcl_dict[moid][
                        "HclDriverVersion"
                    ]
                    data_dict["adapter_HclFirmwareVersion"] = hcl_dict[moid][
                        "HclFirmwareVersion"
                    ]
                    data_dict["adapter_SoftwareStatus"] = hcl_dict[moid][
                        "SoftwareStatus"
                    ]
                    data_dict["adapter_HardwareStatus"] = hcl_dict[moid][
                        "HardwareStatus"
                    ]
                    data_dict["adapter_Status"] = hcl_dict[moid]["Status"]
                    data_dict["adapter_Reason"] = hcl_dict[moid]["Reason"]
                    if moid in component_moid_dict["adapter.Unit"].keys():
                        component_moid = component_moid_dict["adapter.Unit"][moid]
                        data_dict["adapter_Serial"] = component_dict[moid][
                            component_moid
                        ][0]["Serial"]
                        data_dict["adapter_Model"] = component_dict[moid][
                            component_moid
                        ][0]["Model"]
                        data_dict["adapter_Vendor"] = component_dict[moid][
                            component_moid
                        ][0]["Vendor"]
            row = list(data_dict.values())
            # Write Device info as a csv row
            csvwriter.writerow(row)


def main():
    # Create an AUTH object
    AUTH = IntersightAuth(
        secret_key_filename="./SecretKey.txt",
        api_key_id=os.getenv("api_key_id"),
    )

    # Get Server Moid's where the Server license is not Base.
    server_license_info = get_server_license_info(AUTH)
    license_dict = parse_license_info(server_license_info)
    # print(license_dict)
    server_moid_list = []
    for moid in license_dict.keys():
        server_moid_list.append(moid)

    server_moid_tuple = tuple(server_moid_list)
    # Server Info in server_info list
    server_info = get_server_info(AUTH, server_moid_tuple)
    # print(75 * "-")
    # print("Got Server Info")
    # pprint(server_info)
    # print(75 * "-")
    moid_list = []
    for server in range(len(server_info)):
        for moid in range(len(server_info[server]["Details"])):
            moid_list.append(server_info[server]["Details"][moid]["Moid"])

    moid_tuple = tuple(moid_list)
    # print(75 * "-")
    # print("Moid Tuple")
    # pprint(moid_tuple)
    # print(75 * "-")

    hcl_info = get_hcl_info(moid_tuple, AUTH)
    # print(75 * "-")
    # print("Got HCL Status Info")
    # pprint(hcl_info)
    # print(75 * "-")

    component_moid_dict = get_component_moid_dict(hcl_info)
    server_dict = parse_server_info(server_info)
    hcl_dict = parse_hcl_info(hcl_info)
    component_dict = parse_component_moid_dict(component_moid_dict, AUTH)
    # print(100 * "-")
    # print(100 * "-")
    # print("Server_Dict: ")
    # print(server_dict)
    # print(100 * "-")
    # print(100 * "-")
    # print("Component_Moid_Dict: ")
    # print(component_moid_dict)
    # print(100 * "-")
    # print(100 * "-")
    # print("HCL DICT")
    # print(hcl_dict)
    # print(100 * "-")
    # print(100 * "-")
    # print("COMPONENT DICT")
    # print(component_dict)
    # print(100 * "-")
    # print(100 * "-")

    # Write to CSV File
    write_to_csv(server_dict, component_moid_dict, hcl_dict, component_dict)


if __name__ == "__main__":
    main()

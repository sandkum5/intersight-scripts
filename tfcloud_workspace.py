#!/usr/bin/env python3

"""
Python program to create/list below objects in Terraform Cloud using Terraform Cloud API through Intersight Reverse Proxy APIs
    1. Create Workspaces
    2. List Workspace Names and ID's
    3. Create Workspace Variables
    4. List Workspace Variables
"""
import os
import json
import requests

from intersight_auth import IntersightAuth
from dotenv import load_dotenv

load_dotenv()


def create_workspace(auth, tfcloud_org, payload):
    """
    Function to create a workspace under the provided organization
    """
    headers = {"Content-Type": "application/json"}
    url = f"https://intersight.com/tfc/api/v2/organizations/{tfcloud_org}/workspaces"
    response = requests.post(
        url,
        headers=headers,
        data=json.dumps(payload),
        auth=auth,
    )
    print(f"Workspace Create Status: {response.status_code}")


def create_workspace_var(auth, workspace_id, payload):
    """
    Function to create variables under workspaces
    """
    headers = {"Content-Type": "application/json"}
    url = f"https://intersight.com/tfc/api/v2/workspaces/{workspace_id}/vars"
    response = requests.post(
        url,
        headers=headers,
        data=json.dumps(payload),
        auth=auth,
    )
    print(f"Workspace Variable Create Status: {response.status_code}")


def create_workspace_vars(auth, workspace_id, var_list):
    """
    Function to create multiple variables in a workspace
    """
    for var in var_list:
        payload = {
            "data": {
                "type": "vars",
                "attributes": {
                    "key": var["key"],
                    "value": var["value"],
                    "description": var["description"],
                    "category": var["category"],
                    "hcl": False,
                    "sensitive": False,
                },
            }
        }
        var_name = payload["data"]["attributes"]["key"]
        print(f"Creating WorkSpace Var: {var_name}")
        create_workspace_var(auth, workspace_id, payload)


def get_workspace(auth, tfcloud_org):
    """
    Function to list workspaces under an Organization
    """
    workspace_data = {}
    headers = {"Content-Type": "application/json"}
    url = f"https://intersight.com/tfc/api/v2/organizations/{tfcloud_org}/workspaces"
    response = requests.get(
        url,
        headers=headers,
        auth=auth,
    )
    response_data = response.json()
    for workspace in response_data["data"]:
        workspace_id = workspace["id"]
        workspace_data[workspace_id] = workspace["attributes"]["name"]
    return workspace_data


def get_workspace_vars(auth, workspace_id):
    """
    Function to get variables created in a workspace
    """
    headers = {"Content-Type": "application/json"}
    url = f"https://intersight.com/tfc/api/v2/workspaces/{workspace_id}/vars"
    response = requests.get(url, headers=headers, auth=auth)
    response_data = response.json()
    print(response_data)
    workspace_vars = {}
    for var in response_data["data"]:
        var_id = var["id"]
        workspace_vars[var_id] = {}
        workspace_vars[var_id]["var_name"] = var["attributes"]["key"]
        workspace_vars[var_id]["var_value"] = var["attributes"]["value"]
        workspace_vars[var_id]["sensitive"] = var["attributes"]["sensitive"]
        workspace_vars[var_id]["var_description"] = var["attributes"]["description"]
    return workspace_vars


def main():
    """
    Main Function to execute the code
    """
    auth = IntersightAuth(
        secret_key_filename="./SecretKey.txt",
        api_key_id=os.getenv("api_key_id"),
    )

    variable_file = "tfcloud_vars.json"
    with open(variable_file, "r") as file:
        data = json.load(file)

    # Set Organization Name
    tfcloud_org = data["organization"]

    # Set Workspace Payload
    payload_vcs = data["workspace"]["payload_vcs"]

    # Create Workspace
    workspace_name = payload_vcs["data"]["attributes"]["name"]
    print(f"Creating workspace: {workspace_name}")
    create_workspace(auth, tfcloud_org, payload_vcs)
    # List workspaces
    workspace_data = get_workspace(auth, tfcloud_org)

    # Set workspace ID for which we are creating variables
    for key, value in workspace_data.items():
        if value == payload_vcs["data"]["attributes"]["name"]:
            workspace_id = key

    # Set Variables Payload
    var_list = data["vars"]
    # Create variables defined in tfcloud_vars.json file
    create_workspace_vars(auth, workspace_id, var_list)
    
    # Print Workspace Variables
    # workspace_vars = get_workspace_vars(auth, workspace_id)
    # print("Workspace Variables: ", workspace_vars)


if __name__ == "__main__":
    main()

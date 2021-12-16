#!/usr/bin/env python3

"""
Python program to create/list below objects in Terraform Cloud using Terraform Cloud API through Intersight Reverse Proxy APIs
  1. Create Workspaces
  2. List Workspace Names and ID's
  3. Create Workspace Variables
  4. List Workspace Variables
"""
import json
import requests

from intersight_auth import IntersightAuth


def create_workspace(tfcloud_org, auth, payload):
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

    
def create_workspace_var(workspace_id, auth, payload):
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

    
def create_workspace_vars(variable_file, workspace_id, auth):
    with open(variable_file, "r") as file:
        var_list = json.load(file)

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
        create_workspace_var(workspace_id, auth, payload)


def get_workspace(tfcloud_org, auth):
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


def get_workspace_vars(workspace_id, auth):
    headers = {"Content-Type": "application/json"}
    url = f"https://intersight.com/tfc/api/v2/workspaces/{workspace_id}/vars"
    response = requests.get(url, headers=headers, auth=auth)
    response_data = response.json()
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

    auth = IntersightAuth(
        secret_key_filename="./SecretKey.txt",
        api_key_id="<add_api_key_id>",
    )

    # Set Organization Name
    tfcloud_org = "<tf_cloud_organization>"

    # Payload to create a Base workspace
    # payload_base = {
    #     "data": {
    #         "attributes": {
    #             "name": "TF-DEMO_2",
    #             "resource-count": 1,
    #             "terraform_version": "",
    #             "working-directory": "",
    #         },
    #         "type": "workspaces",
    #     }
    # }

    # Payload to create a workspace with vcs repo, exection mode, auto-apply, tf version settings
    payload_vcs = {
        "data": {
            "attributes": {
                "name": "tf-demo-cross-launch",
                "resource-count": 1,
                "terraform_version": "1.1.1",
                "working-directory": "",
                "execution-mode": "remote",
                "auto-apply": False,
                "vcs-repo": {
                    "identifier": "repo_name", # Sample: sandkum5/IST-DEMO"
                    "oauth-token-id": "<add_github_token>",
                    "branch": "",
                },
            },
            "type": "workspaces",
        }
    }
    # Create Workspace
    workspace_name = payload_vcs["data"]["attributes"]["name"]
    print(f"Creating workspace: {workspace_name}")
    create_workspace(tfcloud_org, auth, payload_vcs)

    # List workspaces
    workspace_data = get_workspace(tfcloud_org, auth)
    # print(workspace_data)

    # Create Workspace Vars or load from a json file
    # var_list = [
    #     {
    #         "key": "org_name",
    #         "value": "default",
    #         "description": "This is a API Created org variable",
    #         "category": "terraform",  # Possible Values: "terraform", "env"
    #     }
    # ]

    # Set workspace ID for which we are creating variables
    for key, value in workspace_data.items():
        if value == payload_vcs["data"]["attributes"]["name"]:
            workspace_id = key
    
    # Load workspace variables from a file
    variable_file = "tfcloud_vars.json"
    with open(variable_file, "r") as file:
        var_list = json.load(file)

    # Create workspace variables from the var_list
    create_workspace_vars(variable_file, workspace_id, auth)


if __name__ == "__main__":
    main()

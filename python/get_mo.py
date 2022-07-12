#!/usr/bin/env python3
# Install Modules
# pip install requests python-dotenv intersight-auth
"""
    Get JSON data from Intersight for provider path
"""
import os
import argparse
import requests
from dotenv import load_dotenv
from intersight_auth import IntersightAuth
from pprint import pprint


load_dotenv()


def get_mo(AUTH, url):
    """
    Get Managed Object from Intersight
    """
    headers = {"Accept": "application/json"}
    response = requests.request("GET", url, auth=AUTH, headers=headers)
    if response.status_code == 401:
        print(response.json()["message"])
        return None
    if response.status_code == 200:
        return response


def main():
    """
    Main function to run the script
    """
    # Create the parser
    parser = argparse.ArgumentParser()
    # Add an argument
    parser.add_argument('--path', type=str, required=True)
    # Parse the argument
    args = parser.parse_args()

    # Intersight REST API Base URL
    base_url = "https://intersight.com/api/v1/"

    # Sample Paths: ntp/Policies, kubernets/AddonPolicies
    url = f"{base_url}{args.path}"
    print(url)

    # Create an AUTH Object
    AUTH = IntersightAuth(
        secret_key_filename="./labv3secretkey.txt",
        api_key_id=os.getenv("labv3")
    )

    # Send Request
    response = get_mo(AUTH, url)
    api_data = response.json()['Results']

    # Print JSON output
    pprint(api_data)
    # for entry in api_data:
    #     print(f"Moid: {entry['Moid']}, ObjectType: {entry['ObjectType']}, Name: {entry['Name']}")


if __name__ == '__main__':
    main()

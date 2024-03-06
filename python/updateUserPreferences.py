#!/usr/bin/env python3
"""
    Intersight API calls to Update User Custom Views using userpreferences.json file generated using getUserPreferences.py script
    Note: User must be logged out from Intersight GUI before running this script
"""

import sys
import json
import requests

def get_token(client_id, client_secret):
    """ Get oAuth Token """
    token_url="https://intersight.com/iam/token"
    client_auth = requests.auth.HTTPBasicAuth(client_id, client_secret)
    post_data = {"grant_type": "client_credentials"}
    response = requests.post(url=token_url,
                            auth=client_auth,
                            data=post_data)
    if response.status_code != 200:
        print("Failed to obtain token from the OAuth 2.0 server", file=sys.stderr)
        sys.exit(1)
    print("Successfuly obtained a new token")
    token_json = response.json()
    return token_json["access_token"]

def get_api_data(token, client_id, client_secret, api_url):
    """ Get API Endpoint Data """
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(url=api_url, headers=headers)
    if	response.status_code == 401:
        print("Existing Token Expired. Generating a new one!")
        token = get_token(client_id, client_secret)
        get_api_data(token, client_id, client_secret, api_url)
    else:
        return response.json()

def patch_api_data(token, client_id, client_secret, api_url, data):
    """ Update API Endpoint Data """
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.patch(url=api_url, headers=headers, json=data)
    if	response.status_code == 401:
        print("Existing Token Expired. Generating a new one!")
        token = get_token(client_id, client_secret)
        patch_api_data(token, client_id, client_secret, api_url, data)
    else:
        return response.json()


if __name__ == '__main__':
    # Set variables - Destination User oAuth Info
    client_id = "Add Client ID"    # Update
    client_secret = "Add Client Secret" # Update
    api_url = "https://intersight.com/api/v1/iam/UserPreferences"

    # Get oAuth Token
    token = get_token(client_id, client_secret)

    # Get User Preference Moid
    response = get_api_data(token, client_id, client_secret, api_url)
    user_moid = response['Results'][0]['Moid']

    # Reading from user preference json file
    with open('userpreferences.json', 'r') as openfile:
        data = json.load(openfile)

    # Update Custom View Data
    patch_url = f"https://intersight.com/api/v1/iam/UserPreferences/{user_moid}"
    response = patch_api_data(token, client_id, client_secret, patch_url, data)
    if response:
        print("User Preferences updated Successfully!")

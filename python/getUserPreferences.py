#!/usr/bin/env python3
"""
    Intersight API calls to pull User Custom Views
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
        print("User Preferences gathered successfully!")
        return response.json()

if __name__ == '__main__':
    # Set variables - Source User oAuth Info
    client_id = "Add Client ID"    # Update
    client_secret = "Add Client Secret" # Update
    api_url = "https://intersight.com/api/v1/iam/UserPreferences"

    # Get oAuth Token
    token = get_token(client_id, client_secret)

    # Get API Endpoint Data
    response = get_api_data(token, client_id, client_secret, api_url)

    # Parse Custom View Data
    post_data = response['Results'][0]['Preference']['grid']
    user_data = { "Preference": { "grid": post_data } }
    json_object = json.dumps(user_data, indent=4)
    with open("userpreferences.json", "w") as outfile:
        outfile.write(json_object)


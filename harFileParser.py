#!/usr/bin/python3
"""
Script to parse Intersight HAR files
Returns:
    HTTP Method
    X-Startship-Token
    URL
"""
import json

filename = input("Please enter the HAR Filename: ")

with open(filename, "r") as f:
    har_data = f.read()
    json_data = json.loads(har_data)
    for i in range(len(json_data["log"]["entries"])):
        entry = json_data["log"]["entries"][i]
        http_method = entry["request"]["method"]
        http_url = entry["request"]["url"]
        for cookie in entry["request"]["cookies"]:
            if cookie["name"] == "X-Starship-Token":
                x_startship_token = cookie["value"]
        http_response_data = entry["response"]["content"]
        # print(f"{http_method} : {http_url} : {http_response_data}")
        print("")
        print(f"HTTP METHOD       : {http_method}")
        print(f"X-Startship-Token : {x_startship_token}")
        print(f"URL               : {http_url}")

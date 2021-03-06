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
    for entry in json_data["log"]["entries"]:
        http_method = entry["request"]["method"]
        http_url = entry["request"]["url"]
        for cookie in entry["request"]["cookies"]:
            if cookie["name"] == "X-Starship-Token":
                x_startship_token = cookie["value"]
        # http_response_data = entry["response"]["content"]["text"]
        print("")
        print("HTTP METHOD       : " + http_method)
        print("X-Startship-Token : " + x_startship_token)
        print("URL               : " + http_url)
        # Using F-string for Python 3.6+
        # print(f"HTTP METHOD       : {http_method}")
        # print(f"X-Startship-Token : {x_startship_token}")
        # print(f"URL               : {http_url}")
        
        # Write Output to a text file
        # with open("harFiltered.log", 'a') as f:
        #    f.write("\n")
        #    f.write("HTTP METHOD       : " + http_method + "\n")
        #    f.write("X-Startship-Token : " + x_startship_token + "\n")
        #    f.write("URL               : " + http_url + "\n")

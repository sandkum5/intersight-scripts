#!/usr/bin/python3
"""
Script to parse Intersight HAR files

Input:
    Har Filename
    URL Path E.g. fabric/UplinkPcRoles, ntp/Policies

Returns:
    Request:
        Method
        Url
        PostData

    Response:
        X-Startship-Token
        Status
        StatusText
        Response Data
        
Creates an output file: harFiltered.log
"""
import json

filename = input("Please enter the HAR Filename: ")
filter_path = input("Enter URL path to filter: ")
parse_response_header = 'X-Starship-TraceId'
print("")
with open(filename, "r") as f:
    har_data = f.read()
    json_data = json.loads(har_data)
    for entry in json_data["log"]["entries"]:
        if filter_path in entry['request']['url']:
            # Request Parsing
            http_method = entry["request"]["method"]
            http_url = entry["request"]["url"]

            # Request Post Data
            post_data = entry['request']['postData']['text']

            # Response Parsing
            for header in entry['response']['headers']:
                if header['name'] == parse_response_header:
                    response_TraceId = header['value']
            response_status = entry['response']['status']
            response_statustext = entry['response']['statusText']

            # Response Content Parsing
            response_data = entry["response"]["content"]["text"]

            # Print Output
            print("REQUEST INFO")
            print(f"HTTP METHOD         : {http_method}")
            print(f"URL                 : {http_url}")
            print(f"Post_Data           : {post_data}")
            print("")
            print("RESPONSE INFO")
            print(f"X-Startship-Token   : {response_TraceId}")
            print(f"Response Status     : {response_status}")
            print(f"Response StatusText : {response_statustext}")
            print(f"Response Data       : {response_data}")
            print("")
            print(150 * '*')
            print("")

            # Write Output to a text file
            with open("harFiltered.log", 'a') as f:
                f.write(" ** REQUEST INFO **\n")
                f.write(f"HTTP METHOD         : {http_method}\n")
                f.write(f"URL                 : {http_url}\n")
                f.write(f"Post_Data           : {post_data}\n")
                f.write("\n")
                f.write(" ** RESPONSE INFO **\n")
                f.write(f"X-Startship-Token   : {response_TraceId}\n")
                f.write(f"Response Status     : {response_status}\n")
                f.write(f"Response StatusText : {response_statustext}\n")
                f.write(f"Response Data       : {response_data}\n")
                f.write("\n")
                f.write(70 * '*' + '\n')
                f.write("\n")

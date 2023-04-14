#!/usr/bin/env python3
"""
Script to parse Intersight HAR files
Input:
    Har Filename
Returns a harFiltered.json file in format:
    [{
        Request:
            Method
            Url
            PostData
        Response:
            X-Startship-Token
            Status
            StatusText
            Response Data
    }]

Creates an output file: harFiltered.log
"""
import json
from pprint import pprint

filename = input("Please enter the HAR Filename: ")
parse_response_header = 'x-starship-traceid'
print("")
json_out = []

with open(filename, "r") as f:
    har_data = f.read()
    json_data = json.loads(har_data)
    for entry in json_data["log"]["entries"]:
        if 'api/v1' in entry['request']['url']:
            # Request Parsing
            http_method = entry["request"]["method"]
            http_url = entry["request"]["url"]

            # Request Post Data
            post_data = None
            if http_method == 'POST':
                post_data = entry['request']['postData']['text']

            # Response Parsing
            for header in entry['response']['headers']:
                if header['name'] == parse_response_header:
                    response_TraceId = header['value']
            response_status = entry['response']['status']
            response_statustext = entry['response']['statusText']

            # Response Content Parsing
            response_data = entry["response"]["content"]["text"]
            response_data.replace("\n", '')
            # Response in JSON
            json_in = {"request": {}, "response": {}}
            json_in["request"]["method"] = http_method
            json_in["request"]["url"] = http_url
            if post_data is not None:
                json_in["request"]["post_data"]

            json_in["response"]["intersight_traceid"] = response_TraceId
            json_in["response"]["status"] = response_status
            json_in["response"]["status_text"] = response_statustext
            json_in["response"]["data"] = json.loads(response_data)
            json_out.append(json_in)

            # Print Output
            # print("REQUEST INFO")
            # print(f"HTTP METHOD         : {http_method}")
            # print(f"URL                 : {http_url}")
            # if post_data is not None:
            #     print(f"Post_Data           : {post_data}")
            # print("")
            # print("RESPONSE INFO")
            # print(f"Intersight TraceId  : {response_TraceId}")
            # print(f"Response Status     : {response_status}")
            # print(f"Response StatusText : {response_statustext}")
            # pprint(f"Response Data       : {response_data}")
            # print("")
            # print(150 * '*')
            # print("")

            # Write Output to a text file
            # with open("harFiltered.log", 'a') as f:
            #     f.write(" ** REQUEST INFO **\n")
            #     f.write(f"HTTP METHOD         : {http_method}\n")
            #     f.write(f"URL                 : {http_url}\n")
            #     if post_data is not None:
            #         f.write(f"Post_Data           : {post_data}\n")
            #     f.write("\n")
            #     f.write(" ** RESPONSE INFO **\n")
            #     f.write(f"Intersight TraceId  : {response_TraceId}\n")
            #     f.write(f"Response Status     : {response_status}\n")
            #     f.write(f"Response StatusText : {response_statustext}\n")
            #     f.write(f"Response Data       : {response_data}\n")
            #     f.write("\n")
            #     f.write(70 * '*' + '\n')
            #     f.write("\n")

# Serializing json
json_object = json.dumps(json_out, indent=8)

with open("harFiltered.json", 'w') as f:
    f.write(json_object)

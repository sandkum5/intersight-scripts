# intersight-scripts
#### Random Intersight Scripts 

`Note`: I have copied the intersight_auth.py from github repo: https://github.com/movinalot/intersight-rest-api

--- 
**Script Name**: `get_contract_info.py` : 
Get following feilds for all the devices in the account and write to a CSV file: 
Contract,Contract.ContractNumber,Contract.LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId


**Output**: This script should generate a contract_info.csv file. 

--- 
**Script Name**: `get_hcl_status.py` : 
Get's Device related details including NIC/Storage drivers and other details. 

`Note`: 
- Use $top and $skip to return the output in batches if the server count exceeds 500 as the amount of data returned would be huge. 
- Update the .env with the api_key_id to use this script. 
- Refer `get_contract_info.py` for pagination example using $top, $skip.

**Output**: This script should generate a hcl_status_info.csv file.

---
**Script Name**: `intersight_tfcloud_proxy_api.py` :
Create/list below objects in Terraform Cloud using Terraform Cloud API through Intersight Reverse Proxy APIs
  1. Create Workspaces
  2. List Workspace Names and ID's
  3. Create Workspace Variables
  4. List Workspace Variables
 
`tfcloud_data.json` : Json file for tfcloud related data

`.env`: Add Intersight api_key_id in this file

---
**Script Name**: `harFileParser.py` :
Parse HAR Files generated for Intersight
Prints:
 - HTTP Method
 - X-Startship-Token
 - URL

```
Sample Output:

% ./har_parser.py                                   
Please enter the HAR Filename: intersight-export-servers.com.har

HTTP METHOD       : GET
X-Startship-Token : e479c24925fb4711555e7e6a7976ee797xxxxxxxxxxxxxe
URL               : https://intersight.com/api/v1/network/ElementSummaries?$filter=((tolower(AlarmSummary.Warning)%20gt%200)%20and%20(tolower(AlarmSummary.Critical)%20eq%200))&$count=true

HTTP METHOD       : GET
X-Startship-Token : e479c24925fb4711555e7e6a7976exxxxxxxxxxxxsssss
URL               : https://intersight.com/api/v1/network/ElementSummaries?$filter=((tolower(AlarmSummary.Critical)%20gt%200))&$count=true

```

--- 
### How to use the provided scripts: 
1. Clone this repo: git clone https://github.com/sandkum5/intersight-scripts.git
2. Change directory to intersight-scripts
3. Generate Intersight API keys. 
4. Copy the SecretKey.txt file to intersight-scripts. 
5. Update the "api_key_id" variable in the scripts. 
6. Change permissions: chmod 755 ./<script_name>.py
7. Run the scripts: ./<script_name>.py

# intersight-scripts
#### Random Intersight Scripts 

`Note`: I have copied the intersight_auth.py from github repo: https://github.com/movinalot/intersight-rest-api

--- 
**Script Name**: `get_contract_info.py` : 
Get following feilds for all the devices in the account and write to a CSV file: 
Contract,Contract.ContractNumber,Contract.LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId

`Note`: Use $top and $skip to return the output in batches if the server count exceeds 500. 

**Output**: This script should generate a contract_info.csv file. 

--- 
**Script Name**: `get_hcl_status.py` : 
Get's Device related details including NIC/Storage drivers and other details. 

`Note`: 
Use $top and $skip to return the output in batches if the server count exceeds 500 as the amount of data returned would be huge. 
Update the .env with the api_key_id to use this script. 

**Output**: This script should generate a hcl_status_info.csv file.

---
**Script Name**: `tfcloud_workspace.py` :
Create/list below objects in Terraform Cloud using Terraform Cloud API through Intersight Reverse Proxy APIs
  1. Create Workspaces
  2. List Workspace Names and ID's
  3. Create Workspace Variables
  4. List Workspace Variables
 
`tfcloud_data.json` : Json file for tfcloud related data

`.env`: Add Intersight api_key_id in this file

--- 
### How to use the provided scripts: 
1. Clone this repo: git clone https://github.com/sandkum5/intersight-scripts.git
2. Change directory to intersight-scripts
3. Generate Intersight API keys. 
4. Copy the SecretKey.txt file to intersight-scripts. 
5. Update the "api_key_id" variable in the scripts. 
6. Change permissions: chmod 755 ./<script_name>.py
7. Run the scripts: ./<script_name>.py

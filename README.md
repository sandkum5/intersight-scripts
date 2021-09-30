# intersight-scripts
Random Intersight Scripts 

`Note`: I have copied the intersight_auth.py from github repo: https://github.com/movinalot/intersight-rest-api

Script Name: `get_contract_info.py` : 
Get following feilds for all the devices in the account and write to a CSV file: 
Contract,Contract.ContractNumber,Contract.LineStatus,ContractStatus,ContractStatusReason,ServiceDescription,ServiceLevel,ServiceStartDate,ServiceEndDate,SalesOrderNumber,PurchaseOrderNumber,PlatformType,DeviceType,DeviceId

`Note`: Use $top and $skip to return the output in batches if the server count exceeds 500. 


### How to use the provided scripts: 
1. Clone this repo: git clone https://github.com/sandkum5/intersight-scripts.git
2. Change directory to intersight-scripts
3. Generate Intersight API keys. 
4. Copy the SecretKey.txt file to intersight-scripts. 
5. Update the "api_key_id" variable in the scripts. 
6. Change permissions: chmod 755 ./<script_name>.py
7. Run the scripts: ./<script_name>.py
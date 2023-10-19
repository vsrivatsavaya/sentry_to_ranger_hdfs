# sentry to ranger hdfs
Created to migrate sentry to Ranger HDFS policies
This is a two part process

**1) Extract**

The below script extracts Hive DB and Table level grants with their corresponding HDFS locations into two CSV files i.e. one for db level grants and another for table level grants
Please note this has been developed for MySQL backed Sentry and Metastore. Underlying Sql queries may need to be modified for other RDBMS like Oracle/Postgres

**sentry_to_ranger_hdfs_extract.sh**

Open the file and provide below details before running this script. Please note nameservice is case-sensitive

hdfs_nameservice="nameservice1"

db_user_name="root"

db_password="xxxxxx"

Run the script without any input arguments

./sentry_to_ranger_hdfs_extract.sh

The script generates two files. Samples below

Below are the different columns

POLICY_NAME - DB grants will have this as db=xxxxx and Table grants will have this as db=xxxx;tbl=xxxxx
RESOURCE_PATH - HDFS Path corresponding to Database or Table
PERMISSIONS - rwx (write) or rx (read)
ROLE - Sentry role (Assumption is Role Group mapping is already present as part of Sentry to Hive Migration performed by the Upgrade Wizard or the Authz migrator tool)

**db_hdfs_permissions_2023-10-19_02-31-47.csv**

POLICY_NAME,RESOURCE_PATH,PERMISSIONS,ROLE
db=test_database1,/user/hive/warehouse/test_database1.db,rwx,test_role1
db=test_database2,/user/hive/warehouse/test_database2.db,rwx,test_role2
db=test_database3,/user/hive/warehouse/test_database3.db,rwx,test_role3
db=test_database4,/user/hive/warehouse/test_database4.db,rwx,test_role4
db=test_database5,/user/hive/warehouse/test_database5.db,rwx,test_role5
db=test_database6,/user/hive/warehouse/test_database6.db,rx,test_role6
db=test_database7,/user/hive/warehouse/test_database7.db,rx,test_role7
db=test_database8,/user/hive/warehouse/test_database8.db,rx,test_role8
db=test_database9,/user/hive/warehouse/test_database9.db,rx,test_role9
db=test_database10,/user/hive/warehouse/test_database10.db,rx,test_role10
db=test_datalake,/datalake/db/schemas/test_datalake.db,rwx,test_role1
db=test_haas,/haas/aif/schemas/test_haas.db,rwx,test_role1
db=test_usrwrk,/usrwrk/aif/schemas/test_usrwrk.db,rwx,test_role1

**tbl_hdfs_permissions_2023-10-19_02-31-47.csv**

POLICY_NAME,RESOURCE_PATH,PERMISSIONS,ROLE
db=default;tbl=table1,/user/hive/warehouse/table1,rwx,test_role1
db=default;tbl=table1,/user/hive/warehouse/table1,rx,test_role2
db=default;tbl=table2,/user/hive/warehouse/table2,rwx,test_role1
db=default;tbl=table2,/user/hive/warehouse/table2,rx,test_role2
db=default;tbl=table3,/user/hive/warehouse/table3,rwx,test_role1
db=default;tbl=table3,/user/hive/warehouse/table3,rx,test_role2

**2) INGEST**
The below script takes one of the files generated above as input and loads policies into ranger
The script will go through the entries from the csv file and creates/updates policies via Ranger API calls. Time taken for the load depends on the number of grants in the CSV file
The API call will not remove any existing HDFS policies and will only create/update policies

Open the file and provide below details before running this script.

ranger_url="https://vvs-cdpchf15-ec2-4.vpc.cloudera.com:6182"

ranger_admin_username="admin"

ranger_admin_password="xxxxxxxx"

Run the script with input file name i.e. the previously extracted csv files

./sentry_to_ranger_hdfs_ingest.sh db_hdfs_permissions_2023-10-19_02-31-47.csv

./sentry_to_ranger_hdfs_ingest.sh tbl_hdfs_permissions_2023-10-19_02-31-47.csv

Sample output as below

Thu Oct 19 02:48:09 EDT 2023 - Sentry to Ranger HDFS policy ingest started


{"id":98,"guid":"7ada061f-a861-4532-bdfc-8215f21f821a","isEnabled":true,"createdBy":"Admin","updatedBy":"Admin","createTime":1697694452000,"updateTime":1697698092329,"version":5,"service":"cm_hdfs","name":"db=default;tbl=table1","policyType":0,"policyPriority":0,"description":"","resourceSignature":"4d389551cee1dbcf3655f3f392a4a0f7b6d88086366f149fb5c486ffe43fb9d3","isAuditEnabled":true,"resources":{"path":{"values":["/user/hive/warehouse/table1"],"isExcludes":false,"isRecursive":true}},"policyItems":[{"accesses":[{"type":"read","isAllowed":true},{"type":"write","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role1"],"conditions":[],"delegateAdmin":false},{"accesses":[{"type":"read","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role2"],"conditions":[],"delegateAdmin":false}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"serviceType":"hdfs","options":{},"validitySchedules":[],"policyLabels":[],"zoneName":"","isDenyAllElse":false}

{"id":98,"guid":"7ada061f-a861-4532-bdfc-8215f21f821a","isEnabled":true,"createdBy":"Admin","updatedBy":"Admin","createTime":1697694452000,"updateTime":1697698093874,"version":6,"service":"cm_hdfs","name":"db=default;tbl=table1","policyType":0,"policyPriority":0,"description":"","resourceSignature":"4d389551cee1dbcf3655f3f392a4a0f7b6d88086366f149fb5c486ffe43fb9d3","isAuditEnabled":true,"resources":{"path":{"values":["/user/hive/warehouse/table1"],"isExcludes":false,"isRecursive":true}},"policyItems":[{"accesses":[{"type":"read","isAllowed":true},{"type":"write","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role1"],"conditions":[],"delegateAdmin":false},{"accesses":[{"type":"read","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role2"],"conditions":[],"delegateAdmin":false}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"serviceType":"hdfs","options":{},"validitySchedules":[],"policyLabels":[],"zoneName":"","isDenyAllElse":false}

{"id":99,"guid":"0b3a5567-83f5-4552-92b7-40c527af056f","isEnabled":true,"createdBy":"Admin","updatedBy":"Admin","createTime":1697694456000,"updateTime":1697698095891,"version":5,"service":"cm_hdfs","name":"db=default;tbl=table2","policyType":0,"policyPriority":0,"description":"","resourceSignature":"5c0b55c8943c80d9782951a0d562eb475041732cf4ca648e0c8edf0ea313406c","isAuditEnabled":true,"resources":{"path":{"values":["/user/hive/warehouse/table2"],"isExcludes":false,"isRecursive":true}},"policyItems":[{"accesses":[{"type":"read","isAllowed":true},{"type":"write","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role1"],"conditions":[],"delegateAdmin":false},{"accesses":[{"type":"read","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role2"],"conditions":[],"delegateAdmin":false}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"serviceType":"hdfs","options":{},"validitySchedules":[],"policyLabels":[],"zoneName":"","isDenyAllElse":false}

{"id":99,"guid":"0b3a5567-83f5-4552-92b7-40c527af056f","isEnabled":true,"createdBy":"Admin","updatedBy":"Admin","createTime":1697694456000,"updateTime":1697698097846,"version":6,"service":"cm_hdfs","name":"db=default;tbl=table2","policyType":0,"policyPriority":0,"description":"","resourceSignature":"5c0b55c8943c80d9782951a0d562eb475041732cf4ca648e0c8edf0ea313406c","isAuditEnabled":true,"resources":{"path":{"values":["/user/hive/warehouse/table2"],"isExcludes":false,"isRecursive":true}},"policyItems":[{"accesses":[{"type":"read","isAllowed":true},{"type":"write","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role1"],"conditions":[],"delegateAdmin":false},{"accesses":[{"type":"read","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role2"],"conditions":[],"delegateAdmin":false}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"serviceType":"hdfs","options":{},"validitySchedules":[],"policyLabels":[],"zoneName":"","isDenyAllElse":false}

{"id":100,"guid":"b2103baf-fc97-4f3b-9e95-1ef35e0ac3e4","isEnabled":true,"createdBy":"Admin","updatedBy":"Admin","createTime":1697694460000,"updateTime":1697698099748,"version":5,"service":"cm_hdfs","name":"db=default;tbl=table3","policyType":0,"policyPriority":0,"description":"","resourceSignature":"35b9d08d611f2e6779e7342e3dfc482e2636ca8c432adde3fca154125f65faeb","isAuditEnabled":true,"resources":{"path":{"values":["/user/hive/warehouse/table3"],"isExcludes":false,"isRecursive":true}},"policyItems":[{"accesses":[{"type":"read","isAllowed":true},{"type":"write","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role1"],"conditions":[],"delegateAdmin":false},{"accesses":[{"type":"read","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role2"],"conditions":[],"delegateAdmin":false}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"serviceType":"hdfs","options":{},"validitySchedules":[],"policyLabels":[],"zoneName":"","isDenyAllElse":false}

{"id":100,"guid":"b2103baf-fc97-4f3b-9e95-1ef35e0ac3e4","isEnabled":true,"createdBy":"Admin","updatedBy":"Admin","createTime":1697694460000,"updateTime":1697698101918,"version":6,"service":"cm_hdfs","name":"db=default;tbl=table3","policyType":0,"policyPriority":0,"description":"","resourceSignature":"35b9d08d611f2e6779e7342e3dfc482e2636ca8c432adde3fca154125f65faeb","isAuditEnabled":true,"resources":{"path":{"values":["/user/hive/warehouse/table3"],"isExcludes":false,"isRecursive":true}},"policyItems":[{"accesses":[{"type":"read","isAllowed":true},{"type":"write","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role1"],"conditions":[],"delegateAdmin":false},{"accesses":[{"type":"read","isAllowed":true},{"type":"execute","isAllowed":true}],"users":[],"groups":[],"roles":["test_role2"],"conditions":[],"delegateAdmin":false}],"denyPolicyItems":[],"allowExceptions":[],"denyExceptions":[],"dataMaskPolicyItems":[],"rowFilterPolicyItems":[],"serviceType":"hdfs","options":{},"validitySchedules":[],"policyLabels":[],"zoneName":"","isDenyAllElse":false}

Thu Oct 19 02:48:21 EDT 2023 - Sentry to Ranger HDFS policy ingest completed


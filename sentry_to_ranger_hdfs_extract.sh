#! /bin/bash

hdfs_nameservice="nameservice1"
db_user_name="root"
db_password="Cl0uder@"
file_suffix=$(date '+%Y-%m-%d_%H-%M-%S')

# Create csv file for Database level grants
mysql -u$db_user_name -p$db_password -e "select concat('db=',b.DB_NAME,',',  SUBSTRING_INDEX(d.DB_LOCATION_URI,'$hdfs_nameservice',-1),',',  CASE WHEN b.ACTION IN ('*','all','insert') THEN 'rwx' WHEN b.ACTION = 'select' THEN 'rx' END ,',',  c.ROLE_NAME)  from sentry.SENTRY_ROLE_DB_PRIVILEGE_MAP a,  sentry.SENTRY_DB_PRIVILEGE b,  sentry.SENTRY_ROLE c,  metastore.DBS d  where a.ROLE_ID = c.ROLE_ID  and a.DB_PRIVILEGE_ID = b.DB_PRIVILEGE_ID  and b.DB_NAME = d.NAME  and b.PRIVILEGE_SCOPE = 'DATABASE'  and b.ACTION in ('*','all','insert','select') and d.DB_LOCATION_URI IS NOT NULL;" > db_hdfs_permissions_$file_suffix.csv

#Add header for csv
sed -i '1d' db_hdfs_permissions_$file_suffix.csv
sed -i '1iPOLICY_NAME,RESOURCE_PATH,PERMISSIONS,ROLE' db_hdfs_permissions_$file_suffix.csv

# Create csv file for Table level grants
mysql -u$db_user_name -p$db_password -e "select concat('db=',b.DB_NAME,';tbl=',b.TABLE_NAME,',',  SUBSTRING_INDEX(f.LOCATION,'$hdfs_nameservice',-1),',',  CASE WHEN b.ACTION IN ('*','all','insert') THEN 'rwx' WHEN b.ACTION = 'select' THEN 'rx' END ,',',  c.ROLE_NAME)  from sentry.SENTRY_ROLE_DB_PRIVILEGE_MAP a,  sentry.SENTRY_DB_PRIVILEGE b,  sentry.SENTRY_ROLE c,  metastore.DBS d, metastore.TBLS e, metastore.SDS f  where a.ROLE_ID = c.ROLE_ID  and a.DB_PRIVILEGE_ID = b.DB_PRIVILEGE_ID  and b.DB_NAME = d.NAME and b.TABLE_NAME = e.TBL_NAME and d.DB_ID = e.DB_ID and e.SD_ID = f.SD_ID and b.PRIVILEGE_SCOPE = 'TABLE' and b.ACTION in ('*','all','insert','select') and f.LOCATION IS NOT NULL;" > tbl_hdfs_permissions_$file_suffix.csv

#Add header for csv
sed -i '1d' tbl_hdfs_permissions_$file_suffix.csv
sed -i '1iPOLICY_NAME,RESOURCE_PATH,PERMISSIONS,ROLE' tbl_hdfs_permissions_$file_suffix.csv

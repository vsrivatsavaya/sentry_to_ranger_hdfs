#! /bin/bash

input_feed_file=$1
ranger_url="https://vvs-cdpchf15-ec2-4.vpc.cloudera.com:6182"
ranger_admin_username="admin"
ranger_admin_password="Cloudera123"

rm -f ranger_hdfs_policy.json
rm -f service_mapping_json

echo "$(date) - Sentry to Ranger HDFS policy ingest started"

policy_json='{"policies": ['
while IFS="," read -r policy_name resource permissions role
do
  if [ $permissions == 'rwx' ]; then
  policy_json+='{"policyType":"0","name":"'$policy_name'","isEnabled":true,"policyPriority":0,"policyLabels":[],"description":"","isAuditEnabled":true,"resources":{"path":{"values":["'$resource'"],"isRecursive":true}},"isDenyAllElse":false,"policyItems":[{"roles":["'$role'"],"accesses":[{"type":"read","isAllowed":true},{"type":"write","isAllowed":true},{"type":"execute","isAllowed":true}]}],"allowExceptions":[],"denyPolicyItems":[],"denyExceptions":[],"service":"cm_hdfs"},'
  fi
  if [ $permissions == 'rx' ]; then
  policy_json+='{"policyType":"0","name":"'$policy_name'","isEnabled":true,"policyPriority":0,"policyLabels":[],"description":"","isAuditEnabled":true,"resources":{"path":{"values":["'$resource'"],"isRecursive":true}},"isDenyAllElse":false,"policyItems":[{"roles":["'$role'"],"accesses":[{"type":"read","isAllowed":true},{"type":"execute","isAllowed":true}]}],"allowExceptions":[],"denyPolicyItems":[],"denyExceptions":[],"service":"cm_hdfs"},'
  fi
done < <(tail -n +2 $input_feed_file)

policy_json=${policy_json%?}
policy_json+=']}'
echo "$policy_json" > ranger_hdfs_policy.json
echo '{"cm_hdfs":"cm_hdfs"}' > service_mapping_json

curl --noproxy '*' -X POST -H "Content-Type: multipart/form-data" -F 'file=@ranger_hdfs_policy.json' -F "servicesMapJson=@service_mapping_json" -k -u $ranger_admin_username:$ranger_admin_password "$ranger_url/service/plugins/policies/importPoliciesFromFile?isOverride=false&mergeIfExists=true"

echo "$(date) - Sentry to Ranger HDFS policy ingest completed"

exit 0

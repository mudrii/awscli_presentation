#!/bin/sh -v

. ./aws_env.sh && \

## Delete ELBV2
#aws elbv2 describe-listeners --load-balancer-arn $aws_elbv2_arn  | jq .
#aws elbv2 delete-listener --listener-arn $aws_elbv2_list_https
#aws elbv2 delete-listener --listener-arn $aws_elbv2_list_http
#aws elbv2 describe-listeners --load-balancer-arn $aws_elbv2_arn  | jq .
#
#aws elbv2 describe-target-groups  | jq .
#aws elbv2 delete-target-group --target-group-arn $aws_elbv2_https_arn
#aws elbv2 delete-target-group --target-group-arn $aws_elbv2_http_arn
#aws elbv2 describe-target-groups  | jq .
#
#aws elbv2 describe-load-balancers  | jq .
#aws elbv2 delete-load-balancer --load-balancer-arn $aws_elbv2_arn
#aws elbv2 describe-load-balancers  | jq .

# Delete ElastiCash Reis cluster
#aws elasticache delete-cache-cluster  --cache-cluster-id  $aws_el_clust_id | jq .
#aws elasticache describe-cache-clusters | jq .CacheClusters[].CacheClusterStatus
#
#aws elasticache delete-cache-subnet-group  --cache-subnet-group-name  $aws_el_cash_subn
#aws elasticache describe-cache-subnet-groups | jq .
#
#aws rds delete-db-instance  --db-instance-identifier $aws_db_id --skip-final-snapshot | jq .
#aws rds describe-db-instances | jq .DBInstances[].DBInstanceStatus
#
#aws rds delete-db-subnet-group --db-subnet-group-name $aws_db_subn
#aws rds describe-db-subnet-groups | jq .

# Delete rules for Securety groups
aws ec2 revoke-security-group-ingress --group-id $aws_sec_cicd --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'$aws_my_ip'/32"}]},{"IpProtocol": "tcp", "FromPort": 8080, "ToPort": 8080, "IpRanges": [{"CidrIp": "'$aws_my_ip'/32"}]},{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]},{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]}]'

aws ec2 revoke-security-group-ingress --group-id $aws_sec_app --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]},{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_elb'"}]},{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]}]'

aws ec2 revoke-security-group-ingress --group-id $aws_sec_rds --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]},{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]},{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "IpRanges": [{"CidrIp": "'$aws_my_ip'/32"}]}]'

aws ec2 revoke-security-group-ingress --group-id $aws_sec_redi --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 6379, "ToPort": 6379, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]},{"IpProtocol": "tcp", "FromPort": 6379, "ToPort": 6379, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]},{"IpProtocol": "tcp", "FromPort": 6379, "ToPort": 6379, "IpRanges": [{"CidrIp": "'$aws_my_ip'/32"}]}]'

aws ec2 revoke-security-group-ingress --group-id $aws_sec_elb --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]},{"IpProtocol": "tcp", "FromPort": 443, "ToPort": 443, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]'

# Delete securety groups
aws ec2 describe-security-groups | jq .
aws ec2 delete-security-group --group-id $aws_sec_cicd
aws ec2 delete-security-group --group-id $aws_sec_app
aws ec2 delete-security-group --group-id $aws_sec_elb
aws ec2 delete-security-group --group-id $aws_sec_rds
aws ec2 delete-security-group --group-id $aws_sec_redi
aws ec2 describe-security-groups | jq .

# Delete Internet gateway
aws ec2 describe-internet-gateways | jq . && sleep 5
aws ec2 detach-internet-gateway  --internet-gateway-id $aws_int_gat --vpc-id $aws_vpc_id && \
aws ec2 delete-internet-gateway --internet-gateway-id $aws_int_gat
aws ec2 describe-internet-gateways | jq .

# Delete and disassociate routes
aws ec2 describe-route-tables | jq .
aws ec2 disassociate-route-table --association-id $aws_rout_ass1 && \
aws ec2 disassociate-route-table --association-id $aws_rout_ass2
#aws ec2 delete-route --route-table-id $aws_rout_tbl  --destination-cidr-block 0.0.0.0/0
aws ec2 describe-route-tables | jq .

# Delete subnets
aws ec2 describe-subnets | jq .
aws ec2 delete-subnet --subnet-id $aws_subn_1 && \
aws ec2 delete-subnet --subnet-id $aws_subn_2 && \
aws ec2 describe-subnets | jq .

# Delete VPC
aws ec2 delete-vpc --vpc-id $aws_vpc_id
aws ec2 describe-vpcs | jq .

# Delete DHCP option
aws ec2 delete-dhcp-options --dhcp-options-id  $aws_dhcp_id

# Delet3 S3 bucket
aws s3 rb s3://crash-course-logs --force

. ./aws_env.sh
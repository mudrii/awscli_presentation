#!/bin/sh -v

aws_vpc_id=$(aws ec2 describe-vpcs | jq .Vpcs[].VpcId -r)

aws_dhcp_id=$(aws ec2 describe-dhcp-options | jq .DhcpOptions[].DhcpOptionsId -r)

aws_subn_1=$(aws ec2 describe-subnets --filters Name=availabilityZone,Values=ap-southeast-1a | jq .Subnets[].SubnetId -r)

aws_subn_2=$(aws ec2 describe-subnets --filters Name=availabilityZone,Values=ap-southeast-1b | jq .Subnets[].SubnetId -r)

aws_rout_tbl=$(aws ec2 describe-route-tables | jq .RouteTables[0].RouteTableId -r)

aws_rout_ass1=$(aws ec2 describe-route-tables | jq .RouteTables[].Associations[0].RouteTableAssociationId -r)

aws_rout_ass2=$(aws ec2 describe-route-tables | jq .RouteTables[].Associations[1].RouteTableAssociationId -r)

aws_int_gat=$(aws ec2 describe-internet-gateways | jq .InternetGateways[].InternetGatewayId -r)

aws_sec_cicd=$(aws ec2 describe-security-groups --filters  Name=group-name,Values=cicd | jq .SecurityGroups[].GroupId -r)

aws_sec_rds=$(aws ec2 describe-security-groups --filters  Name=group-name,Values=rds | jq .SecurityGroups[].GroupId -r)

aws_sec_redi=$(aws ec2 describe-security-groups --filters  Name=group-name,Values=redis | jq .SecurityGroups[].GroupId -r)

aws_sec_app=$(aws ec2 describe-security-groups --filters  Name=group-name,Values=app | jq .SecurityGroups[].GroupId -r)

aws_sec_elb=$(aws ec2 describe-security-groups --filters  Name=group-name,Values=elb | jq .SecurityGroups[].GroupId -r)

aws_db_subn=$(aws rds describe-db-subnet-groups | jq .DBSubnetGroups[].DBSubnetGroupName -r)

aws_db_id=$(aws rds describe-db-instances | jq .DBInstances[].DBInstanceIdentifier -r)

aws_el_cash_subn=$(aws elasticache describe-cache-subnet-groups | jq .CacheSubnetGroups[].CacheSubnetGroupName -r)

aws_el_clust_id=$(aws elasticache describe-cache-clusters | jq .CacheClusters[].CacheClusterId -r)

aws_elbv2_arn=$(aws elbv2 describe-load-balancers | jq .LoadBalancers[].LoadBalancerArn -r)

aws_elbv2_http_arn=$(aws elbv2 describe-target-groups --names http | jq .TargetGroups[].TargetGroupArn -r)

aws_elbv2_https_arn=$(aws elbv2 describe-target-groups --names https | jq .TargetGroups[].TargetGroupArn -r)

aws_cert=$(aws acm list-certificates | jq .CertificateSummaryList[].CertificateArn -r)

aws_elbv2_list_http=$(aws elbv2 describe-listeners --load-balancer-arn $aws_elbv2_arn | jq .Listeners[0].ListenerArn -r)

aws_elbv2_list_https=$(aws elbv2 describe-listeners --load-balancer-arn $aws_elbv2_arn | jq .Listeners[1].ListenerArn -r)

aws_ec2_master=$(aws ec2 describe-instances)

aws_ec2_minion=$(aws ec2 describe-instances)

aws_my_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)

set | grep aws_

#aws_acc_id=$(aws ec2 describe-security-groups --group-names 'Default' --query 'SecurityGroups[0].OwnerId' --output text)
#shmod +x aws_env.sh

#source ./aws_env.sh
#or
#. ./aws_env.sh

# unset env var
# for i in $(set | grep aws_ | awk -F'=' '{print $1}') ; do unset $i ; done
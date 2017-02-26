#!/bin/sh

# Create VPC
aws ec2 describe-availability-zones --query AvailabilityZones[].ZoneName | jq .[]
aws ec2 describe-vpcs | jq .Vpcs[].VpcId
aws ec2 describe-dhcp-options | jq .DhcpOptions[].DhcpOptionsId

aws_vpc_id=$(aws ec2 create-vpc --cidr-block 172.30.0.0/16 --query Vpc.VpcId --output text)
aws ec2 modify-vpc-attribute --vpc-id $aws_vpc_id --enable-dns-support "{\"Value\":true}"
aws ec2 modify-vpc-attribute --vpc-id $aws_vpc_id --enable-dns-hostnames "{\"Value\":true}"
aws ec2 describe-vpcs | jq .


# Create Subnets
aws ec2 describe-subnets | jq .

aws_subn_1=$(aws ec2 create-subnet --vpc-id  $aws_vpc_id --cidr-block 172.30.0.0/24 --availability-zone ap-southeast-1a --query Subnet.SubnetId --output text)
aws_subn_2=$(aws ec2 create-subnet --vpc-id  $aws_vpc_id --cidr-block 172.30.1.0/24 --availability-zone ap-southeast-1b --query Subnet.SubnetId --output text)

aws ec2 modify-subnet-attribute --subnet-id $aws_subn_1 --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $aws_subn_2 --map-public-ip-on-launch

aws ec2 describe-subnets | jq .Subnets[]


# Create Routing Table
aws ec2 describe-route-tables | jq .RouteTables[]

aws_rout_tbl=$(aws ec2 create-route-table --vpc-id $aws_vpc_id --query RouteTable.RouteTableId --output text)
aws_rout_ass1=$(aws ec2 associate-route-table --route-table-id $aws_rout_tbl --subnet-id $aws_subn_1 | jq .AssociationId -r)
aws_rout_ass2=$(aws ec2 associate-route-table --route-table-id $aws_rout_tbl --subnet-id $aws_subn_2 | jq .AssociationId -r)

aws ec2 describe-route-tables | jq .RouteTables[]


# Create Internet Gateway
aws ec2 describe-internet-gateways | jq .

aws_int_gat=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
aws ec2 attach-internet-gateway --internet-gateway-id $aws_int_gat --vpc-id $aws_vpc_id
aws ec2 create-route --route-table-id $aws_rout_tbl --destination-cidr-block 0.0.0.0/0 --gateway-id $aws_int_gat | jq .

aws_dhcp_id=$(aws ec2 describe-dhcp-options | jq .DhcpOptions[].DhcpOptionsId -r)

aws ec2 describe-internet-gateways | jq .


# Create security Groups
aws ec2 describe-security-groups | jq .SecurityGroups[].GroupId

aws_sec_cicd=$(aws ec2 create-security-group --group-name cicd --description "CICD" --vpc-id $aws_vpc_id --query GroupId --output text)
aws_sec_rds=$(aws ec2 create-security-group --group-name rds --description "RDS" --vpc-id $aws_vpc_id --query GroupId --output text)
aws_sec_redi=$(aws ec2 create-security-group --group-name redis --description "REDIS" --vpc-id $aws_vpc_id --query GroupId --output text)
aws_sec_app=$(aws ec2 create-security-group --group-name app --description "APP" --vpc-id $aws_vpc_id --query GroupId --output text)
aws_sec_elb=$(aws ec2 create-security-group --group-name elb --description "ELB" --vpc-id $aws_vpc_id --query GroupId --output text)

aws ec2 describe-security-groups | jq .SecurityGroups[].GroupId


# Tag AWS resources
aws ec2 describe-tags | jq .

aws ec2 create-tags --resources $aws_vpc_id $aws_dhcp_id $aws_subn_1 $aws_subn_2 $aws_rout_tbl $aws_int_gat $aws_sec_cicd $aws_sec_app $aws_sec_elb $aws_sec_rds  $aws_sec_redi --tags Key=Name,Value=crash_course Key=Stack,Value=test

aws ec2 describe-tags | jq .


# Configure security groups

my_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)

aws ec2 authorize-security-group-ingress --group-id $aws_sec_cicd --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'$my_ip'/32"}]},{"IpProtocol": "tcp", "FromPort": 8080, "ToPort": 8080, "IpRanges": [{"CidrIp": "132.147.98.173/32"}]},{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]},{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]}]'

aws ec2 authorize-security-group-ingress --group-id $aws_sec_app --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]},{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_elb'"}]},{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]}]'

aws ec2 authorize-security-group-ingress --group-id $aws_sec_elb --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]},{"IpProtocol": "tcp", "FromPort": 443, "ToPort": 443, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]'

aws ec2 authorize-security-group-ingress --group-id $aws_sec_rds --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]},{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]},{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "IpRanges": [{"CidrIp": "'$my_ip'/32"}]}]'

aws ec2 authorize-security-group-ingress --group-id $aws_sec_redi --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 6379, "ToPort": 6379, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]},{"IpProtocol": "tcp", "FromPort": 6379, "ToPort": 6379, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]},{"IpProtocol": "tcp", "FromPort": 6379, "ToPort": 6379, "IpRanges": [{"CidrIp": "'$my_ip'/32"}]}]'

aws ec2 describe-security-groups --group-ids $aws_sec_cicd | jq .
aws ec2 describe-security-groups --group-ids $aws_sec_app | jq .
aws ec2 describe-security-groups --group-ids $aws_sec_elb | jq .
aws ec2 describe-security-groups --group-ids $aws_sec_redi | jq .


# Create RDS
aws rds describe-db-subnet-groups | jq .
aws rds describe-db-instances | jq .

aws_db_subn=$(aws rds create-db-subnet-group --db-subnet-group-name crash-course --subnet-ids $aws_subn_1 $aws_subn_2 --db-subnet-group-description crash-course-db --tags Key=Name,Value=crash_course Key=Stack,Value=Test --query DBSubnetGroup.DBSubnetGroupName --output text)

aws_db_id=$(aws rds create-db-instance --db-instance-identifier crash-course --allocated-storage 5 --db-instance-class db.t2.micro --storage-type gp2 --engine mariadb --engine-version 10.1.19 --master-username root --master-user-password crashcourse --db-subnet-group-name crash-course --vpc-security-group-ids $aws_sec_rds --no-multi-az --publicly-accessible --tags Key=Name,Value=crash_course Key=Stack,Value=Test --query DBInstance.DBInstanceIdentifier --output text)

aws rds describe-db-instances | jq .
aws rds describe-db-subnet-groups | jq .

# Create ElasticCashe
aws elasticache describe-cache-clusters | jq .
aws elasticache describe-cache-subnet-groups | jq .

aws_el_cash_subn=$(aws elasticache create-cache-subnet-group --cache-subnet-group-name crash-course --cache-subnet-group-description crash-course-cashe --subnet-ids $aws_subn_1 $aws_subn_2 --query CacheSubnetGroup.CacheSubnetGroupName --output text)

aws_el_clust_id=$(aws elasticache create-cache-cluster --cache-cluster-id crash-course --az-mode single-az --num-cache-nodes 1 --cache-node-type cache.t2.micro --engine redis --engine-version 3.2.4 --cache-subnet-group-name $aws_el_cash_subn --security-group-ids $aws_sec_redi --tags Key=Name,Value=crash_course Key=Stack,Value=Test --query CacheCluster.CacheClusterId --output text)

aws elasticache describe-cache-clusters | jq .
aws elasticache describe-cache-subnet-groups | jq .


# Creating ELBv2
aws elbv2 describe-load-balancers | jq .
aws elbv2 describe-target-groups | jq .

aws_elb2_name=$(aws elbv2 create-load-balancer --name crash-course --subnets $aws_subn_1 $aws_subn_2 --security-groups $aws_sec_elb --scheme internet-facing --tags Key=Name,Value=crash-course Key=Stack,Value=Test --query LoadBalancers[].LoadBalancerArn --output text)

aws_elb2_arn=$(aws elbv2 describe-load-balancers | jq .LoadBalancers[].LoadBalancerArn -r)

aws_elb2_http_arn=$(aws elbv2 create-target-group --name http --protocol HTTP --port 80 --vpc-id $aws_vpc_id --health-check-protocol HTTP --health-check-interval-seconds 30 --health-check-timeout-seconds 3 --healthy-threshold-count 2 --unhealthy-threshold-count 2 --query TargetGroups[].TargetGroupArn --output text)

aws_elb2_https_arn=$(aws elbv2 create-target-group --name https --protocol HTTP --port 443 --vpc-id $aws_vpc_id --health-check-protocol HTTPS --health-check-interval-seconds 30 --health-check-timeout-seconds 3 --healthy-threshold-count 2 --unhealthy-threshold-count 2 --query TargetGroups[].TargetGroupArn --output text)

aws elbv2 add-tags --resource-arns $aws_elb2_http_arn --tags Key=Name,Value=crash-course Key=Stack,Value=Test

aws elbv2 add-tags --resource-arns $aws_elb2_https_arn --tags Key=Name,Value=crash-course Key=Stack,Value=Test

aws_cert=$(aws acm list-certificates --query CertificateSummaryList[].CertificateArn --output text)

aws_elbv2_list_http=$(aws elbv2 create-listener --load-balancer-arn  $aws_elb2_arn --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$aws_elb2_http_arn | jq .Listeners[].ListenerArn -r)

aws_elbv2_list_https=$(aws elbv2 create-listener  --load-balancer-arn  $aws_elb2_arn --protocol HTTPS --port 443 --certificates CertificateArn=$aws_cert --default-actions Type=forward,TargetGroupArn=$aws_elb2_https_arn | jq .Listeners[].ListenerArn -r)

aws s3api list-buckets --query 'Buckets[].Name' | jq .

aws s3api create-bucket --bucket crash-course-logs1 --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1 | jq .

aws s3api list-objects --bucket crash-course-logs --query 'Contents[].{Key: Key
, Size: Size}' | jq .

#aws_account_id=$(aws ec2 describe-security-groups --group-names 'Default' --query 'SecurityGroups[0].OwnerId' --output text)

aws s3api put-bucket-policy --bucket crash-course-logs1 --policy file://aws_elbv2.json

aws s3api get-bucket-policy  --bucket crash-course-logs

aws elbv2 modify-load-balancer-attributes --load-balancer-arn $aws_elb2_arn --attributes Key=access_logs.s3.enabled,Value=true Key=access_logs.s3.bucket,Value=crash-course-logs1 Key=access_logs.s3.prefix,Value=crashcourse | jq .

# creating ec2

aws ec2 describe-key-pairs | jq .
aws ec2 describe-instance-status | jq .
aws ec2 describe-instances | jq .Reservations[].Instances[].State.Name
aws ec2 describe-instances | jq .Reservations[].Instances[].InstanceId
aws ec2 describe-instances | jq .Reservations[].Instances[].PrivateIpAddress
aws ec2 describe-instances | jq .Reservations[].Instances[].PublicIpAddress

. ./env.sh

#Find Local IP for securety group
# dig +short myip.opendns.com @resolver1.opendns.com

#aws ec2 delete-vpc --vpc-id $aws_vpc_id
#aws ec2 delete-dhcp-options --dhcp-options-id  $aws_dhcp_id

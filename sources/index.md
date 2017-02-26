% AWSCli Crash Course
% Ion Mudreac
% 28 Feb 2017

---

### About me

* SCB CDO Foundation Services DevOps Lead,
* Economist by training
* AWS Certified
* Leading EDMI, eOps, RPA and few other DevOps Teams

---

### About this Crash Course

* This Crash Course is NOT 100% tested !
* There might be mistakes (Feedback is Welcome)
* There might be missing or incomplete information
* Presentation available online at [awscli.mudrii.com]()
* Sources of this presentation is available online at
  [https://github.com/mudrii/awscli.git](https://github.com/mudrii/awscli.git)


---

### What is AWS (CLI)

* The AWS Command Line Interface (CLI) is a unified tool to manage AWS services.
* With just one tool
    * can control multiple AWS services
    * automate them through scripts
    * manage aws resources programmatically
    * ...

---

### Why use AWS (CLI)

* Easy to install
    - control AWS resources using AWS API
    - only python as dependency

* No other complicated setup is required
    - if you have AWS account and have aws_access_key and aws_secret_key you can run AWS cli against your AWS environment
    - make sure your AWS user have right access and right IAM policy

---

### AWS (CLI) Platforms, Components and Dependencies

* AWS (CLI)Supported Platforms
    - Windows, Linux, macOS, Unix
* AWS (CLI) Dependencies
    - Python 2 v2.6.5+ or Python 3 v3.3+
* AWS (CLI) Components
    - [aws-cli](https://github.com/aws/aws-cli)
    - [aws-shell](https://github.com/awslabs/aws-shell)


---

### Getting started with AWS (CLI)

* Dependencies
    * Check Python Version:
```
python --version
```
    * Check Pip Version :
```
pip --version
```
    * Check AWS Version :
```
aws --version
```

---

### Getting started with AWS (CLI)

* Install AWS (CLI)
    * With Python :
```
pip install --upgrade --user awscli aws-shell
```
    * macOS :
```
brew install awscli
```
    * Windows: can install [32](https://s3.amazonaws.com/aws-cli/AWSCLI64.msi) bit or [64](https://s3.amazonaws.com/aws-cli/AWSCLI64.msi) bit installer

---

### Configuring the AWS (CLI)

* Shell Command Completion
    * find your shell : _**echo $SHELL**_
    * find aws_completer : _**which aws_completer**_
    * enable command completion :
        * bash :
```
complete -C '/usr/local/bin/aws_completer' aws
```
        * zsh :
```
source /usr/local/bin/aws_zsh_completer.sh
```

---

### Configuring the AWS (CLI)

* Configure credentials
```
aws configure
AWS Access Key ID[None]:AKIAIOSFDN7EXAMPLE
AWS Secret Access Key[None]:wJalrXtnFEIENP/xRfiCYEXAMPLEKEY
Default region name[None]:ap-southeast-1
Default output format[None]:json
```

---

### Demo:

* Install and setup AWS (CLI)

```
pip install --upgrade --user awscli aws-shell

aws configure

aws ec2 describe-regions
```

* Note: nice tool to have [jq is sed for JSON](https://robots.thoughtbot.com/jq-is-sed-for-json)

---

### AWS (CLI) Syntax

* Syntax :
```
aws [options] <command> <subcommand> [parameters]
```
* Help : _**aws command help**_
* Universal Options:
    * _**--debug**_   Turn on debug logging
    * _-**-output**_  Output format json, text, table
    * _**--query**_   JMESPath query to use in filtering
    * _**--region**_  The region to use
    * _**...**_

---

### Demo:

* AWS (CLI) Synopsis

```
aws s3 ls

aws ec2 describe-regions help

aws ec2 describe-regions --output table

aws ec2 describe-regions --debug

aws ec2 describe-regions --filters "Name=endpoint,Values=*ap*"

aws ec2 describe-regions --query 'Regions[].{Name:RegionName}'

aws ec2 describe-regions --filters "Name=endpoint,Values=*ap*" \
--query 'Regions[].{Name:RegionName}' --output text
```

---

### Demo

* Check on available resource

```
aws ec2 describe-availability-zones

aws ec2 describe-vpcs

aws ec2 describe-vpcs --region us-east-2

aws ec2 describe-dhcp-options

aws ec2 describe-subnets

aws ec2 describe-subnets --region us-east-2
```

---

### Demo

* Create our 1st VPC

```
aws ec2 create-vpc --cidr-block 172.30.0.0/16

aws ec2 describe-vpcs

aws ec2 modify-vpc-attribute --vpc-id vpc-idxxxx \
--enable-dns-support "{\"Value\":true}"

aws ec2 modify-vpc-attribute --vpc-id vpc-idxxxx \
--enable-dns-hostnames "{\"Value\":true}"
```

---

### Demo

* Associate DHCP to VPC

```
aws ec2 describe-dhcp-options

aws ec2 associate-dhcp-options --dhcp-options-id dopt-idxxxx \
--vpc-id vpc-idxxxx

aws ec2 create-tags --resources vpc-idxxxx dopt-idxxxx \
--tags Key=Name,Value=crash_course Key=Stack,Value=test
```

---

### Demo

* Create Subnets for VPC

```
aws ec2 describe-subnets

ec2 create-subnet --vpc-id vpc-idxxxx --cidr-block 172.30.0.0/24 \
--availability-zone ap-southeast-1a

ec2 create-subnet --vpc-id vpc-idxxxx --cidr-block 172.30.1.0/24 \
--availability-zone ap-southeast-1b

aws ec2 describe-subnets

ec2 modify-subnet-attribute --subnet-id subnet-idxxaxa \
--map-public-ip-on-launch

ec2 modify-subnet-attribute --subnet-id subnet-idxxxxb \
--map-public-ip-on-launch
```

---

### Demo

* So Copy/Paste is not an option let's try in programmatic way pass as VAR

```
aws ec2 create-vpc --cidr-block 172.30.0.0/16 \
--generate-cli-skeleton output

aws ec2 create-vpc --cidr-block 172.30.0.0/16 \
--generate-cli-skeleton output --query Vpc.VpcId \
--output text

aws ec2 create-vpc --cidr-block 172.30.0.0/16 \
--generate-cli-skeleton output | jq .Vpc.VpcId -r
```

---

### Demo

* Let's try and create VPC and pass VpcId as Shell VAR

```
aws_vpc_id=$(aws ec2 create-vpc --cidr-block 172.30.0.0/16 \
--query Vpc.VpcId --output text)

echo $aws_vpc_id

aws ec2 modify-vpc-attribute --vpc-id $aws_vpc_id \
--enable-dns-support "{\"Value\":true}"

aws ec2 modify-vpc-attribute --vpc-id $aws_vpc_id \
--enable-dns-hostnames "{\"Value\":true}"

aws ec2 describe-vpcs | jq .
```

---

### Demo

* Create Subnets

```
aws ec2 create-subnet --vpc-id  $aws_vpc_id \
--cidr-block 172.30.0.0/24 --availability-zone ap-southeast-1a \
--generate-cli-skeleton output

aws_subn_1=$(aws ec2 create-subnet --vpc-id  $aws_vpc_id \
--cidr-block 172.30.0.0/24 --availability-zone ap-southeast-1a \
--query Subnet.SubnetId --output text)

aws_subn_2=$(aws ec2 create-subnet --vpc-id  $aws_vpc_id \
--cidr-block 172.30.1.0/24 --availability-zone ap-southeast-1b \
 | jq .Subnet.SubnetId -r)

aws ec2 modify-subnet-attribute --subnet-id $aws_subn_1 \
--map-public-ip-on-launch

aws ec2 modify-subnet-attribute --subnet-id $aws_subn_2 \
--map-public-ip-on-launch

set | grep aws
```

---

### Demo

* Route Table Subnet association

```
aws_rout_tbl=$(aws ec2 create-route-table --vpc-id $aws_vpc_id \
--query RouteTable.RouteTableId --output text)

aws_rout_ass1=$(aws ec2 associate-route-table --route-table-id \
$aws_rout_tbl --subnet-id $aws_subn_1 | jq .AssociationId -r)

aws_rout_ass2=$(aws ec2 associate-route-table --route-table-id \
$aws_rout_tbl --subnet-id $aws_subn_2 | jq .AssociationId -r)
```

---

### Demo

* Internet Gateway and internet route

```
aws_int_gat=$(aws ec2 create-internet-gateway --query \
InternetGateway.InternetGatewayId --output text)

aws ec2 attach-internet-gateway --internet-gateway-id $aws_int_gat \
--vpc-id $aws_vpc_id

aws ec2 create-route --route-table-id $aws_rout_tbl \
--destination-cidr-block 0.0.0.0/0 --gateway-id $aws_int_gat \
| jq .Return
```

---

### Demo

* Let's create some securely Groups

```
aws_sec_cicd=$(aws ec2 create-security-group --group-name cicd \
--description "CICD" --vpc-id $aws_vpc_id --query GroupId \
--output text)

aws_sec_rds=$(aws ec2 create-security-group --group-name rds \
--description "RDS" --vpc-id $aws_vpc_id --query GroupId \
--output text)

aws_sec_redi=$(aws ec2 create-security-group --group-name redis \
--description "REDIS" --vpc-id $aws_vpc_id --query GroupId \
--output text)

aws_sec_app=$(aws ec2 create-security-group --group-name app \
--description "APP" --vpc-id $aws_vpc_id --query GroupId \
--output text)

aws_sec_elb=$(aws ec2 create-security-group --group-name elb \
--description "ELB" --vpc-id $aws_vpc_id --query GroupId \
--output text)
```

---

### Demo

* Add access permissions to security Groups

```
ec2 authorize-security-group-ingress --group-id sg-xxxxxxx  \
--protocol tcp --port 22 --cidr 0.0.0.0/0
```

---

### Demo

* Add Ports to cicd group
```
aws ec2 authorize-security-group-ingress --group-id $aws_sec_cicd --ip-permissions \
'[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "132.147.98.173/32"}]},{"IpProtocol": "tcp", "FromPort": 8080, "ToPort": 8080, "IpRanges": [{"CidrIp": "132.147.98.173/32"}]},{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]},{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]}]'
```
* Add Ports to apps group
```
aws ec2 authorize-security-group-ingress --group-id $aws_sec_app --ip-permissions \
'[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]},{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_elb'"}]},{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]}]'
```
* Add Ports to elb Group
```
aws ec2 authorize-security-group-ingress --group-id $aws_sec_elb --ip-permissions \
'[{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]},{"IpProtocol": "tcp", "FromPort": 443, "ToPort": 443, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]'
```

---

### Demo

* Add Ports to rds group
```
aws ec2 authorize-security-group-ingress --group-id $aws_sec_rds --ip-permissions \
  '[{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]},{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]},{"IpProtocol": "tcp", "FromPort": 3306, "ToPort": 3306, "IpRanges": [{"CidrIp": "132.147.98.173/32"}]}]'
```
* Add Ports to redis group
```
aws ec2 authorize-security-group-ingress --group-id $aws_sec_redi --ip-permissions \
'[{"IpProtocol": "tcp", "FromPort": 6379, "ToPort": 6379, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_cicd'"}]},{"IpProtocol": "tcp", "FromPort": 6379, "ToPort": 6379, "UserIdGroupPairs": [{"GroupId": "'$aws_sec_app'"}]},{"IpProtocol": "tcp", "FromPort": 6379, "ToPort": 6379, "IpRanges": [{"CidrIp": "132.147.98.173/32"}]}]'
```

---

### Demo

* Assigning tags to AWS resources

```
aws ec2 create-tags --resources $aws_vpc_id $aws_dhcp_id \
$aws_subn_1 $aws_subn_2 $aws_rout_tbl $aws_int_gat $aws_sec_cicd \
$aws_sec_app $aws_sec_elb $aws_sec_rds $aws_sec_redi --tags \
Key=Name,Value=crash_cours
```

---

###

* Let's check our creation

```
aws ec2 describe-vpcs | jq .
aws ec2 describe-subnets | jq .
aws ec2 describe-internet-gateways | jq .
aws ec2 describe-network-acls | jq .
aws ec2 describe-route-tables | jq .
aws ec2 describe-security-groups | jq .
aws ec2 describe-dhcp-options | jq .
aws ec2 describe-tags | jq .

set | grep aws_
```

---

### Let's try to script it

* Gather env var from our aws account

```
cat env.sh

. ./env.sh
```

---

### Build complete infrastructure building script

* Let's make a builder script

```
less create_env.sh

./create_env.sh
```

---

### Questions ?

*

```

```

---

###

*

```

```

---

###

*

```

```

---

###

*

```

```

---

###

*

```

```

---



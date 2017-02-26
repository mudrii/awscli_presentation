% AWSCli Crash Course
% Ion Mudreac
% 28 Feb 2017

---

### About me

* SCB CDO Foundation Services DevOps Lead,
* Economist by training
* AWS Certified
* Leading EDMI, eOps, RPA DevOps Teams

---

### About this Crash Course

* This Crash Course is NOT 100% tested !
* There might be mistakes (Feedback is Welcome)
* There might be missing or incomplete information
* Presentation available online at [awscli.mudrii.com]()
* Sources of this presentation is available online at
  [https://mudrii.github.io/devops-AWS-CLI/](https://willthames.github.io/devops-singapore-2016/)


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
    - Python 2 version 2.6.5+ or Python 3 version 3.3+
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
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: ap-southeast-1
Default output format [None]: json
```

---

### Demo:

* Install and setup AWS (CLI)

```
pip install --upgrade --user awscli aws-shell

aws configure

aws ec2 describe-regions
```

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

aws ec2 describe-regions --filters \
"Name=endpoint,Values=*ap*"

aws ec2 describe-regions --query \
'Regions[].{Name:RegionName}' --output text

aws ec2 describe-regions --filters \
"Name=endpoint,Values=*ap*" --query \
'Regions[].{Name:RegionName}' --output text
```

---

###
---

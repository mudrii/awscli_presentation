#!/bin/bash

#Install common stuff
yum -y update && \
yum -y upgrade && \
yum -y distro-sync && \
yum -y install zip unzip device-mapper-libs device-mapper-event-libs python-setuptools python-setuptools-devel && \
curl -sSL https://get.docker.com/ | sh && \
usermod -aG docker ec2-user && \
mkdir /etc/systemd/system/docker.service.d && \
echo -e "[Service] \nExecStart= \nExecStart=/usr/bin/dockerd -D -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375"  > /etc/systemd/system/docker.service.d/docker.conf && \
systemctl daemon-reload && \
systemctl start docker.service && \
systemctl enable docker.service && \

sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo yum -y install gcc gcc-c++ kernel-devel make python-devel libxslt-devel libffi-devel openssl-devel git java vim wget bzip2 sysstat tmux tree lsof nc elinks htop

#AWS CLI installation
sudo easy_install pip
sudo pip install --upgrade pip
sudo pip install --upgrade awscli aws-shell

mkdir /home/ec2-user/.aws && echo -e "[default] \nregion = ap-southeast-1"  >> /home/ec2-user/.aws/config

#Ansible installtion
sudo pip install --upgrade paramiko PyYAML Jinja2 httplib2 six boto ansible

#Python dependancyes installations
sudo pip freeze --local | sudo grep -v '^\-e' | sudo cut -d = -f 1  | sudo xargs -n1 pip install -U

#Install JQ on master
wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod 555 jq
sudo mv jq /usr/local/bin

#Install metadata on Master
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod 555 ec2-metadata
sudo mv ec2-metadata /usr/local/bin

#Install awsping on master
wget https://github.com/ekalinin/awsping/releases/download/0.5.2/awsping.linux.amd64.tgz
tar xzvf awsping.linux.amd64.tgz
chmod +x awsping
sudo mv awsping /usr/local/bin

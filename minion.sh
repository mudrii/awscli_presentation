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
systemctl enable docker.service
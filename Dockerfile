#
#  Build docker image of db2 express-C v10.5 FP5 (64bit)
#
# # Authors:
#   * Leo (Zhong Yu) Wu       <leow@ca.ibm.com>
#
# Copyright 2015, IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Specify base OS with kernel 3.10.0
# Options:
#   centos:7


FROM    centos:7

MAINTAINER Leo Wu <leow@ca.ibm.com>

User root

###############################################################
#
#               System preparation for DB2
#
###############################################################

RUN  yum -y install wget

RUN  wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN  rpm -ivh epel-release-7-5.noarch.rpm

# Required pacakges
RUN yum install -y vi tar initscripts \
    system-config-language \
    sudo \
    passwd \
    pam \
    pam.i686 \
    ncurses-libs.i686 \
    file \
    rsyslog \
    e2fsprogs \
    libaio \
    libaio.i686 \
    compat-libstdc++-33 \
    libstdc++-devel \
    libstdc++-devel.i686 \
    dapl-devel \
    libibverbs-devel \
    sg3_utils \
    numactl \
    numactl.i686 \
    gcc-c++ \
    kernel-devel \
    openssh-server

RUN echo 'root:KNnTXEEc' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY install_db2.sh /tmp/install_db2.sh
RUN  /tmp/install_db2.sh

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 22 50000

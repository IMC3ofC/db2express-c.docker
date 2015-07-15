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


FROM centos:7

MAINTAINER Leo Wu <leow@ca.ibm.com>

###############################################################
#
#               System preparation for DB2
#
###############################################################

RUN groupadd db2iadm1 && useradd -G db2iadm1 db2inst1

# Required packages
RUN yum install -y \
    vi \
    sudo \
    passwd \
    pam \
    pam.i686 \
    ncurses-libs.i686 \
    file \
    libaio \
    libstdc++-devel.i686 \
    && yum clean all

ENV DB2EXPRESSC_DATADIR /home/db2inst1/data
ENV DB2EXPRESSC_SHA256 a5c9a3231054047f1f63e7144e4da49c4feaca25d8fce4ad97539d72abfc93d0
ENV DB2EXPRESSC_URL https://s3.amazonaws.com/db2-expc105-64bit-centos/v10.5fp5_linuxx64_expc.tar.gz

RUN curl -fSLo /tmp/expc.tar.gz $DB2EXPRESSC_URL \
    && echo "$DB2EXPRESSC_SHA256 /tmp/expc.tar.gz" | sha256sum -c - \
    && cd /tmp && tar xf expc.tar.gz \
    &&  su - db2inst1 -c "/tmp/expc/db2_install -b /home/db2inst1/sqllib" \
    && echo '. /home/db2inst1/sqllib/db2profile' >> /home/db2inst1/.bash_profile

RUN sed -ri  's/(ENABLE_OS_AUTHENTICATION=).*/\1YES/g' /home/db2inst1/sqllib/instance/db2rfe.cfg \
    && sed -ri  's/(RESERVE_REMOTE_CONNECTION=).*/\1YES/g' /home/db2inst1/sqllib/instance/db2rfe.cfg \
    && sed -ri 's/^\*(SVCENAME=db2c_db2inst1)/\1/g' /home/db2inst1/sqllib/instance/db2rfe.cfg \
    && sed -ri 's/^\*(SVCEPORT)=48000/\1=50000/g' /home/db2inst1/sqllib/instance/db2rfe.cfg

RUN mkdir $DB2EXPRESSC_DATADIR && chown db2inst1.db2iadm1 $DB2EXPRESSC_DATADIR

RUN su - db2inst1 -c "db2start && db2set DB2COMM=TCPIP && db2 UPDATE DBM CFG USING DFTDBPATH $DB2EXPRESSC_DATADIR IMMEDIATE" \
    && su - db2inst1 -c "db2stop force"

RUN cd /home/db2inst1/sqllib/instance \
    && ./db2rfe -f ./db2rfe.cfg \
    && rm -rf /tmp/db2* && rm -rf /tmp/expc*

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME $DB2EXPRESSC_DATADIR

EXPOSE 50000

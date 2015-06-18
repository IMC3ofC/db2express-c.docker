#!/bin/bash
set -e
#
#   Initialize DB2 instance in a Docker container
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


if [ -z "$DB2INST1_PASSWORD" ]; then
  echo ""
  echo >&2 'error: DB2INST1_PASSWORD not set'
  echo >&2 'Did you forget to add -e DB2INST1_PASSWORD=... ?'
  exit 1
else
  echo -e "$DB2INST1_PASSWORD\n$DB2INST1_PASSWORD" | passwd db2inst1
fi

if [ -z "$LICENSE" ];then
   echo ""
   echo >&2 'error: LICENSE not set'
   echo >&2 "Did you forget to add '-e LICENSE=accept' ?"
   exit 1
fi

if [ "${LICENSE}" != "accept" ];then
   echo ""
   echo >&2 "error: LICENSE not set to 'accept'"
   echo >&2 "Please set '-e LICENSE=accept' to accept License before use the DB2 software contained in this image."
   exit 1
fi

if [[ $1 = "-d" ]]; then
  su - db2inst1 -c "db2start"
  service sshd start
  while true; do sleep 1000; done
else
  exec "$1"
fi

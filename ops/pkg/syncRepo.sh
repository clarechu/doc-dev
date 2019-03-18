#!/bin/bash
export PATH

cd /data/yumdata
reposync
dirs=$(ls -d *)
for d in ${dirs};
do
 cd /data/yumdata/${d}
 createrepo ./
 done
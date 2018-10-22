#!/bin/bash
ENV_FILE=/Users/chenxi/BIM360/env_shell/dm/stg.sh
source $ENV_FILE
db_jqlist=$(aws rds describe-db-snapshots --profile stg)
if [[ $? != 0 ]];then exit 1;fi
numberOfSnapshots=$(echo $db_jqlist | jq ".DBSnapshots | length")
for i in $(seq 0 $(($numberOfSnapshots-1)))
do
    SnapshotType=$(echo $db_jqlist | jq .DBSnapshots[$i].SnapshotType)
    if [[ $SnapshotType == "\"manual\"" ]]
    then
        DBSnapshotIdentifier=$(echo $db_jqlist | jq .DBSnapshots[$i].DBSnapshotIdentifier)
        SnapshotCreateTime=$(echo $db_jqlist | jq .DBSnapshots[$i].SnapshotCreateTime)
        SnapshotCreateTime=$(date -d $SnapshotCreateTime +%s)
        oneMonthAgo=$(date -d '1 month ago' +%s)
        if [[ $SnapshotCreateTime -lt $oneMonthAgo ]]
        then
            aws rds describe-db-snapshot --db-snapshot-identifier=$DBSnapshotIdentifier --profile stg
            #aws rds delete-db-snapshot --db-snapshot-identifier $DBSnapshotIdentifier --profile stg
        fi
    fi
done
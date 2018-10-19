#!/bin/bash
aws rds describe-db-snapshots --profile stg > db_jqlist
numberOfSnapshots=$(cat db_jqlist | jq ".DBSnapshots | length")
for i in $(seq 0 $(($numberOfSnapshots-1)))
do
    SnapshotType=$(cat db_jqlist | jq .DBSnapshots[$i].SnapshotType)
    if [[ $SnapshotType == "\"manual\"" ]]
    then
        DBSnapshotIdentifier=$(cat db_jqlist | jq .DBSnapshots[$i].DBSnapshotIdentifier)
        SnapshotCreateTime=$(cat db_jqlist | jq .DBSnapshots[$i].SnapshotCreateTime)
        SnapshotCreateTime=$(date -d $SnapshotCreateTime +%s)
        oneMonthAgo=$(date -d '1 month ago' +%s)
        if [[ $SnapshotCreateTime -lt $oneMonthAgo ]]
        then
            aws rds delete-db-snapshot --db-snapshot-identifier $DBSnapshotIdentifier --profile stg
        fi
    fi
done
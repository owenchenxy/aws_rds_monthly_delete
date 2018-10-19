#!/bin/bash
##This script will delete the aws rds snapshots matches the blow conditions:
##  1) SnapshotType is manual
##  2) Create at more that 1 month ago
##Prequists for this scripts:
##  1) AWScli is installed
##  2) AWS credential is correctly configured.
aws rds describe-db-snapshots --profile stg > db_list
while read LINE
do
    if [[ $(echo $LINE|grep 'DBSnapshotIdentifier') != '' ]]
    then
        DBSnapshotIdentifier=$(echo $LINE | awk '{a=index($0,":");print substr($0,a+2,length($0)-a-2)}')
    fi
    if [[ $(echo $LINE|grep 'SnapshotCreateTime') != '' ]]
    then
        SnapshotCreateTime=$(date -d $(echo $LINE | awk '{a=index($0,":");print substr($0,a+2,length($0)-a-2)}') +%s)
        oneMonthAgo=$(date -d '1 month ago')  
    fi
    if [[ $(echo $LINE|grep 'SnapshotType') != '' ]]
    then
        SnapshotType=$(echo $LINE | awk '{a=index($0,":");print substr($0,a+2,length($0)-a-2)}')
        if [[ $SnapshotType == "\"manual\"" ]]
        then
            if [[ $SnapshotCreateTime -lt $oneMonthAgo ]]
            then
                aws rds delete-db-snapshot --db-snapshot-identifier $DBSnapshotIdentifier --profile stg
            fi
        fi
    fi
done < db_list
rm db_list


#!/bin/bash
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
                echo "$DBSnapshotIdentifier is to be deleted"
                #aws rds delete-db-snapshot --db-snapshot-identifier $DBSnapshotIdentifier --profile stg
            fi
        fi
    fi
done < db_list
rm db_list



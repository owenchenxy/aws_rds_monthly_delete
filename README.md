# aws_rds_monthly_delete
##This script will delete the aws rds snapshots matches the blow conditions:
##  1) SnapshotType is manual
##  2) Create at more that 1 month ago
##Prequists for this scripts:
##  1) AWScli is installed
##  2) AWS credential is correctly configured.
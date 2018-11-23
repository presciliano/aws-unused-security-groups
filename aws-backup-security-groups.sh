#!/bin/bash
#purpose: backup unused security groups
#author: prex, nov 2018
#version: 1.0a
#license: GPL3.0
#usage: aws-backup-security-groups <sg-unused-final.txt

#initialize backup file
true>sg-backup.txt

while IFS=$'\t' read -r region sg remainder
do
  aws ec2 describe-security-groups --region $region --group-ids $sg>>sg-backup.txt; 
  printf "-";
done
wc -l sg-backup.txt

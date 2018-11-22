#!/bin/bash
#purpose: list unused security groups
#author: prex, nov 2018
#version: 1.0l
#license: GPL3.0

#initialize files
true> sg-all.txt
true> sg-used-default.txt
true> sg-used-ec2.txt
true> sg-used-eni.txt
true> sg-used-elb.txt
true> sg-used-rds.txt
true> sg-used-lambda.txt
true> sg-unused-final.txt

printf "\nlist unused security groups in all regions of an AWS account\n"

printf "\nstep 1: list all security groups "
for region in $(aws ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
  printf "*";
  for sg in $(aws ec2 describe-security-groups --region $region | jq --raw-output '.SecurityGroups[].GroupId'); do
    printf "%s\t%s\n" "$region" "$sg">>sg-all.txt; printf ".";\
  done;
done
sort sg-all.txt | uniq >sg-all-sorted.txt
wc -l sg-all-sorted.txt

printf "\nstep 2: list default security groups (can't be deleted) "
for region in $(aws ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
  printf "*";	
  for sg in $(aws ec2 describe-security-groups --region $region --filters Name=group-name,Values=default | jq --raw-output '.SecurityGroups[].GroupId'); do
    printf "%s\t%s\n" "$region" "$sg">>sg-used-default.txt; printf ".";\
  done;
done
wc -l sg-used-default.txt

printf "\nstep 3: list security groups associated with instances "
for region in $(aws ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
  printf "*";		
  for sg in $(aws ec2 describe-instances --region $region | jq --raw-output '.Reservations[].Instances[].SecurityGroups[].GroupId'); do
    printf "%s\t%s\n" "$region" "$sg">>sg-used-ec2.txt; printf ".";\
  done;
done
wc -l sg-used-ec2.txt

printf "\nstep 4: list security groups associated with network interfaces "
for region in $(aws ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
  printf "*";	
  for sg in $(aws ec2 describe-network-interfaces --region $region | jq --raw-output '.NetworkInterfaces[].Groups[].GroupId'); do
    printf "%s\t%s\n" "$region" "$sg">>sg-used-eni.txt; printf ".";\
  done;
done
wc -l sg-used-eni.txt

printf "\nstep 5: list security groups associated with elbs "
for region in $(aws ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
  printf "*";	
  for sg in $(aws elb describe-load-balancers --region $region | jq --raw-output '.LoadBalancerDescriptions[].SecurityGroups[]'); do
    printf "%s\t%s\n" "$region" "$sg">>sg-used-elb.txt; printf ".";\
  done;
done
wc -l sg-used-elb.txt

printf "\nstep 6: list security groups associated with rds instances "
for region in $(aws ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
  printf "*";	
  for sg in $(aws rds describe-db-security-groups --region $region | jq --raw-output '.DBSecurityGroups[].EC2SecurityGroups[].EC2SecurityGroupId'); do
    printf "%s\t%s\n" "$region" "$sg">>sg-used-rds.txt; printf ".";
  done;
done
wc -l sg-used-rds.txt

printf "\nstep 7: list security groups associated with lambda functions "
for region in $(aws ec2 describe-regions | jq --raw-output '.Regions[].RegionName'); do
  printf "*";	
  for sg in $(aws lambda list-functions --region $region | jq --raw-output '.Functions[].VpcConfig.SecurityGroupIds[]?'); do
    printf "%s\t%s\n" "$region" "$sg">>sg-used-lambda.txt; printf ".";
  done;
done
wc -l sg-used-lambda.txt

printf "\nstep 8: generate a single list of unique used security groups "
sort sg-used-* | uniq >sg-used-sorted.txt
sort sg-all.txt | uniq >sg-all-sorted.txt
wc -l sg-used-sorted.txt

printf "\nstep 9: generate the list of unused security groups "
comm -23 sg-all-sorted.txt sg-used-sorted.txt >sg-unused.txt
wc -l sg-unused.txt

printf "\nstep 10. get the descriptions of the unused security groups "
while IFS=$'\t' read -r region sg
do
  description=$(aws ec2 describe-security-groups --region $region --group-ids $sg | jq --raw-output '.SecurityGroups[].Description'); 
  printf "%s\t%s\t%s\n" "$region" "$sg" "$description">>sg-unused-final.txt; printf ".";
done <sg-unused.txt

more sg-unused-final.txt

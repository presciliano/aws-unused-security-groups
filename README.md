# aws-unused-security-groups
Bash script to identify unused or orphaned AWS EC2 security groups in all regions and VPCs

# Prerequisites
1. Install and configure [awscli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
2. Make sure you have the accordingly IAM permissions

# Usage
1. run the script `aws-unused-security-groups.sh`
2. a file named `sg-unused-final.txt` will be created
3. review carefully the generated used list of security groups
4. (recommended) run the script `aws-backup-security-groups.sh <sg-unused-final.txt` to backup the security groups configurations
5. delete the unused security groups

## Authors
- Presciliano Neto

## To do
- List dependencies between used and unused security groups;

## License
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details

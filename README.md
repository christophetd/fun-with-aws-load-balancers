# Fun with AWS load balancers

This repository contains Terraform code to reproduce a common setup with an AWS Application Load Balancer (ALB).

* 2 public subnets
* 2 private subnets
* 1 NAT gateway that routes Internet traffic from the private subnet to the Internet

EC2 instances are in the private subnets and run nginx. 

## Usage

```
terraform init
terraform apply # optionally, add -var region=eu-west-1
```


This will output the DNS name of your load balancer. After creation, wait for a few minutes and it should be accessible.

The security group of the load balancer allows ingress traffic on port 80 from your public IP only.

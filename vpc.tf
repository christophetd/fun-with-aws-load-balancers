
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Enable public IP
  enable_nat_gateway    = true
  single_nat_gateway    = true
  create_igw            = true # default
  public_subnet_suffix  = "public-subnet"
  private_subnet_suffix = "private-subnet"

  tags = {
    Terraform = "true"
  }
}
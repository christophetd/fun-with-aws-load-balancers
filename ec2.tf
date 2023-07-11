resource "aws_security_group" "instance-sg" {
  name   = "instance-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_ami" "amazon-linux" {
 most_recent = true


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "aws_iam_role" "nginx-instance-role" {
  name = "nginx-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nginx-instance-role.name
}

resource "aws_iam_instance_profile" "nginx-instance-profile" {
  name = "nginx-instance-profile"
  role = aws_iam_role.nginx-instance-role.name
}

resource "aws_launch_template" "nginx-instance" {
  name_prefix   = "my-nginx"
  image_id      = data.aws_ami.amazon-linux.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance-sg.id ]
  iam_instance_profile {
    name = aws_iam_instance_profile.nginx-instance-profile.name
  }

  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 20
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash
touch /tmp/user-data
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx.service
sudo systemctl start nginx.service
echo "<h1>Hello World</h1><p>from $(hostname -f)</p>" | sudo tee /usr/share/nginx/html/index.html
EOF
  )
}

resource "aws_autoscaling_group" "nginx-instance" {
  desired_capacity = 2
  max_size         = 2
  min_size         = 1

  launch_template {
    id      = aws_launch_template.nginx-instance.id
    version = "$Latest"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.nginx-target-group.arn]
  tag {
    key                 = "Name"
    value               = "nginx-instance"
    propagate_at_launch = true
  }
}
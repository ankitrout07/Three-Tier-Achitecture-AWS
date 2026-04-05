# Get latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Web Tier Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_tier_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx curl git
              
              # Install NVM & Node 16
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
              export NVM_DIR="$HOME/.nvm"
              [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
              nvm install 16
              nvm use 16

              # Clone and Build Frontend (Simulated)
              # In a real scenario, we'd pull from S3 or Git
              # For this demo, we assume the code is deployed via some mechanism
              # or we'd add the git clone command here.
              
              # Update Nginx config to proxy to Internal ALB
              cat <<EOT > /etc/nginx/sites-available/default
              server {
                  listen 80;
                  location / {
                      root /var/www/html;
                      index index.html index.htm;
                      try_files \$uri \$uri/ /index.html;
                  }
                  location /api/ {
                      proxy_pass http://${aws_lb.internal_alb.dns_name}:4000/;
                      proxy_http_version 1.1;
                      proxy_set_header Upgrade \$http_upgrade;
                      proxy_set_header Connection 'upgrade';
                      proxy_set_header Host \$host;
                      proxy_cache_bypass \$http_upgrade;
                  }
              }
              EOT
              systemctl restart nginx
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web-server"
    }
  }
}

# Web Tier ASG
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.web_tg.arn]
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
}

# App Tier Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  network_interfaces {
    security_groups = [aws_security_group.app_tier_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y curl git
              
              # Install NVM & Node 16
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
              export NVM_DIR="$HOME/.nvm"
              [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
              nvm install 16
              nvm use 16
              npm install -g pm2

              # Environment variables for DB
              export DB_HOST=${aws_rds_cluster.aurora.endpoint}
              export DB_USER=admin
              export DB_PWD=${var.db_password}
              export DB_DATABASE=webappdb

              # In a real scenario, we'd clone the repo and run:
              # npm install && pm2 start index.js
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app-server"
    }
  }
}

# App Tier ASG
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  vpc_zone_identifier = aws_subnet.app[*].id

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

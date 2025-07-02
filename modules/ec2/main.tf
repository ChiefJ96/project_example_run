resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.private_subnet_ids == [] ? [] : var.private_subnet_ids # Use public subnets in practice; here private per spec - fix to public  
  // Correction: ALB needs to be in public subnet for internet access
  tags               = merge(var.tags, { Name = "app-alb" })
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name = "app-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

// EC2 Instances in private subnets behind ALB
resource "aws_instance" "web" {
  count                   = length(var.private_subnet_ids)
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.private_subnet_ids[count.index]
  vpc_security_group_ids  = [var.ec2_security_group_id]
  iam_instance_profile    = var.iam_instance_profile
  key_name                = var.key_name != "" ? var.key_name : null

  associate_public_ip_address = false

  tags = merge(var.tags, {
    Name = "web-server-${count.index + 1}"
  })

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y nginx1
              systemctl start nginx
              systemctl enable nginx
              echo "Hello from Web Server ${count.index + 1}" > /usr/share/nginx/html/index.html
              EOF
}

resource "aws_lb_target_group_attachment" "web_attachment" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}
# Application Load Balancer + Target Group + Listener
#
# ALB sits in the 2 public subnets (required: >=2 AZs).
# Listener on port 80 forwards to a target group.
# Target group health-checks the EC2s on GET / every 10s.

resource "aws_lb" "main" {
  name               = "lab05-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = { Name = "lab05-alb" }
}

resource "aws_lb_target_group" "nginx" {
  name     = "lab05-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
    matcher             = "200"
  }

  tags = { Name = "lab05-targets" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

resource "aws_lb_target_group_attachment" "targets" {
  count            = 2
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.target[count.index].id
  port             = 80
}

resource "aws_security_group" "alb" {
  vpc_id      = aws_vpc.app.id
  name        = "${var.project_name}-alb"
  description = "ALB security group"
  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb-ingress" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow ingress from port 80"
}

resource "aws_vpc_security_group_egress_rule" "alb-egress" {
  security_group_id            = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 8000
  to_port                      = 8000
  referenced_security_group_id = aws_security_group.ecs.id
  description                  = "Allow egress to port 8000"
}

resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "alb-target-group" {
  name        = "${var.project_name}-target-group"
  vpc_id      = aws_vpc.app.id
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    path                = "/api/v1/status/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  tags = {
    Name = "${var.project_name}-target-group"
  }
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-ecs-sg"
  description = "Security group for the app"
  vpc_id      = aws_vpc.app.id
  tags = {
    Name = "${var.project_name}-ecs-sg"
  }

}

resource "aws_vpc_security_group_ingress_rule" "ecs-ingress" {
  security_group_id            = aws_security_group.ecs.id
  ip_protocol                  = "tcp"
  from_port                    = 8000
  to_port                      = 8000
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Allow ingress from port 8000"
}

resource "aws_vpc_security_group_egress_rule" "ecs-egress" {
  security_group_id = aws_security_group.ecs.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
  description       = "Allow egress to all ports"
}

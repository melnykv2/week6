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

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for the db"
  vpc_id      = aws_vpc.app.id
  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow db to receive connections from app"
}

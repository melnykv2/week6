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

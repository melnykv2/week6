output "ecr_repository_url" {
  description = "ECR URL"
  value       = aws_ecr_repository.app.repository_url
}

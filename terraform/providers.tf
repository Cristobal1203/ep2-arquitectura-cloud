cat << 'EOF' > providers.tf
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Leemos el rol precreado en AWS Academy Learner Lab sin crear uno nuevo
data "aws_iam_role" "lab_role" {
  name = var.lab_role_name
}
EOF
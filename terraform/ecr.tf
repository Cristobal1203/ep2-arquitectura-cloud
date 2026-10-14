locals {
  ecr_repositories = [
    "freshbox/frontend",
    "freshbox/get-products",
    "freshbox/create-product",
    "freshbox/update-product",
    "freshbox/delete-product"
  ]
}

resource "aws_ecr_repository" "microservices" {
  for_each             = toset(local.ecr_repositories)
  name                 = each.value
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = each.value
  }
}
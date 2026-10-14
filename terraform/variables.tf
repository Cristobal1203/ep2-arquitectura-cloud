variable "aws_region" {
  description = "Region permitida en AWS Learner Lab"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo del proyecto FreshBox SpA"
  type        = string
  default     = "freshbox"
}

variable "vpc_cidr" {
  description = "CIDR /22 requerido por la arquitectura TO-BE"
  type        = string
  default     = "10.0.0.0/22"
}

variable "lab_role_name" {
  description = "Nombre del rol IAM precreado en Learner Lab (LabRole)"
  type        = string
  default     = "LabRole"
}

variable "db_name" {
  description = "Nombre de la base de datos MySQL para FreshBox"
  type        = string
  default     = "freshbox_db"
}

variable "db_username" {
  description = "Usuario administrador de RDS MySQL"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Contrasena maestra de RDS MySQL"
  type        = string
  default     = "FreshBox2025!"
  sensitive   = true
}
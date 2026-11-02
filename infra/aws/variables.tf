variable "region" {
  description = "AWS region for the cluster."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix for the VPC and cluster."
  type        = string
  default     = "secure-gitops"
}

variable "kubernetes_version" {
  description = "EKS control plane version. Upgrade one minor version at a time."
  type        = string
  default     = "1.31"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "admin_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint. Restrict to your office/VPN."
  type        = list(string)
  default     = []
}

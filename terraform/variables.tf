# ═══════════════════════════════════════════════════════════════
# variables.tf — GitOps Capstone: Input Variables
# Author  : Muathaf
# Purpose : Define all configurable inputs for the infrastructure.
#           Keeping variables here means you never hardcode values
#           in main.tf — change one file to redeploy to a new
#           region or rename the cluster.
#
# Override defaults at apply time with:
#   terraform apply -var="aws_region=eu-west-1"
# Or use a terraform.tfvars file for multiple overrides.
# ═══════════════════════════════════════════════════════════════


# ─────────────────────────────────────────
# AWS REGION
# ─────────────────────────────────────────

variable "aws_region" {
  description = "The AWS region where all resources will be deployed."
  type        = string
  default     = "us-east-1"   # N. Virginia — change to me-south-1 for Bahrain
                               # or me-central-1 for UAE when targeting GCC
}


# ─────────────────────────────────────────
# CLUSTER NAME
# ─────────────────────────────────────────

variable "cluster_name" {
  description = "The name for the EKS cluster and all associated resources (VPC, node groups, IAM roles). Used as a prefix throughout main.tf."
  type        = string
  default     = "muathaf-gitops-cluster"
}


# ─────────────────────────────────────────
# KUBERNETES VERSION
# ─────────────────────────────────────────

variable "kubernetes_version" {
  description = "The Kubernetes version to run on the EKS cluster. AWS supports the last 3 minor versions. Check: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html"
  type        = string
  default     = "1.29"
}


# ─────────────────────────────────────────
# NODE INSTANCE TYPE
# ─────────────────────────────────────────

variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes. t3.medium (2 vCPU / 4GB) is suitable for dev/staging. Use m5.large or c5.xlarge for production workloads."
  type        = string
  default     = "t3.medium"
}


# ─────────────────────────────────────────
# NODE GROUP SIZING
# ─────────────────────────────────────────

variable "node_min_size" {
  description = "Minimum number of worker nodes. The cluster will never scale below this number."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes. The cluster auto-scales up to this limit under heavy load."
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired number of worker nodes at startup. Auto-scaling adjusts from here."
  type        = number
  default     = 2
}

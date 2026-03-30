# ═══════════════════════════════════════════════════════════════
# outputs.tf — GitOps Capstone: Output Values
# Author  : Muathaf
# Purpose : Print useful information after 'terraform apply'
#           completes. These values are needed to connect to
#           the cluster and configure kubectl.
#
# View outputs any time with:
#   terraform output
#
# Use a specific output in a script:
#   terraform output -raw cluster_endpoint
# ═══════════════════════════════════════════════════════════════


# ─────────────────────────────────────────
# CLUSTER NAME
# ─────────────────────────────────────────

output "cluster_name" {
  description = "The name of the EKS cluster. Use this to configure kubectl and in CI/CD pipelines."
  value       = module.eks.cluster_name
}


# ─────────────────────────────────────────
# CLUSTER ENDPOINT
# ─────────────────────────────────────────

# The API server endpoint is the URL kubectl talks to.
# After applying, run:
#   aws eks update-kubeconfig --region us-east-1 --name muathaf-gitops-cluster
# to configure kubectl to use this cluster.
output "cluster_endpoint" {
  description = "The HTTPS endpoint of the EKS API server. Used by kubectl and CI/CD tools to communicate with the cluster."
  value       = module.eks.cluster_endpoint
}


# ─────────────────────────────────────────
# CLUSTER CERTIFICATE AUTHORITY
# ─────────────────────────────────────────

# The CA data is used by kubectl to verify the cluster's identity
# and establish a secure TLS connection.
output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the cluster. Required for secure kubectl authentication."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true   # marked sensitive — won't print in plain text logs
}


# ─────────────────────────────────────────
# CLUSTER SECURITY GROUP ID
# ─────────────────────────────────────────

output "cluster_security_group_id" {
  description = "The ID of the security group attached to the EKS cluster control plane. Useful for adding inbound rules if needed."
  value       = module.eks.cluster_security_group_id
}


# ─────────────────────────────────────────
# VPC ID
# ─────────────────────────────────────────

output "vpc_id" {
  description = "The ID of the VPC created for this cluster. Use this when adding other AWS services (RDS, ElastiCache) to the same network."
  value       = module.vpc.vpc_id
}


# ─────────────────────────────────────────
# KUBECTL CONFIG COMMAND
# ─────────────────────────────────────────

# A convenience output — prints the exact command needed
# to configure kubectl after the cluster is provisioned.
output "configure_kubectl" {
  description = "Run this command to configure kubectl to connect to your new EKS cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

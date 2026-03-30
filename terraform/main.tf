# ═══════════════════════════════════════════════════════════════
# main.tf — GitOps Capstone: AWS EKS Infrastructure
# Author  : Muathaf
# Purpose : Provision a production-ready EKS cluster on AWS
#           using official Terraform modules for VPC and EKS.
#
# What this file creates:
#   1. A VPC with public and private subnets across 2 AZs
#   2. An EKS cluster running Kubernetes
#   3. A managed node group (EC2 workers) for the cluster
#
# Apply with:
#   terraform init
#   terraform plan
#   terraform apply
# ═══════════════════════════════════════════════════════════════


# ─────────────────────────────────────────
# TERRAFORM SETTINGS
# ─────────────────────────────────────────

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"   # Use AWS provider v5.x
    }
  }
}


# ─────────────────────────────────────────
# AWS PROVIDER
# ─────────────────────────────────────────

# Tells Terraform which AWS region to deploy into.
# The region value comes from variables.tf.
provider "aws" {
  region = var.aws_region
}


# ─────────────────────────────────────────
# DATA SOURCE — AVAILABILITY ZONES
# ─────────────────────────────────────────

# Dynamically fetch the list of available AZs in our region.
# This avoids hardcoding AZ names (e.g., us-east-1a, us-east-1b),
# making the config portable across regions.
data "aws_availability_zones" "available" {
  state = "available"
}


# ─────────────────────────────────────────
# MODULE — VPC (Virtual Private Cloud)
# ─────────────────────────────────────────

# The official AWS VPC Terraform module handles all the complex
# networking setup: subnets, route tables, NAT gateways, IGW.
# Source: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  # VPC name and CIDR block — all resources live within 10.0.0.0/16
  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  # Spread across 2 Availability Zones for high availability.
  # If one AZ goes down, workloads fail over to the other.
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # ── Private Subnets ────────────────────────────────────────────
  # EKS worker nodes (EC2) run in private subnets.
  # They are NOT directly reachable from the internet —
  # traffic goes through the NAT Gateway instead.
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  # ── Public Subnets ─────────────────────────────────────────────
  # Load Balancers and the NAT Gateway live here.
  # These subnets have a route to the Internet Gateway.
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  # ── NAT Gateway ────────────────────────────────────────────────
  # Allows private subnet resources (worker nodes) to pull
  # Docker images and reach the internet — without being
  # directly exposed to inbound internet traffic.
  enable_nat_gateway   = true
  single_nat_gateway   = true   # one NAT GW to save cost (use false for prod HA)
  enable_dns_hostnames = true   # required for EKS

  # ── Tags required by EKS ───────────────────────────────────────
  # These tags tell AWS Load Balancer Controller which subnets
  # to use when creating load balancers for Kubernetes Services.
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  tags = {
    Project     = var.cluster_name
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}


# ─────────────────────────────────────────
# MODULE — EKS CLUSTER
# ─────────────────────────────────────────

# The official AWS EKS Terraform module provisions the control plane,
# IAM roles, security groups, and managed node groups.
# Source: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # ── Cluster Identity ───────────────────────────────────────────
  cluster_name    = var.cluster_name
  cluster_version = "1.29"   # Kubernetes version — update as new versions release

  # ── Networking ─────────────────────────────────────────────────
  # Deploy the cluster into our VPC, using only private subnets
  # for worker nodes (more secure).
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Allow kubectl access from outside the cluster (e.g., from your laptop).
  # Set to false to restrict to VPN/bastion access only.
  cluster_endpoint_public_access = true

  # ── EKS Managed Add-ons ────────────────────────────────────────
  # These are AWS-managed plugins that Kubernetes needs to function:
  #   - coredns    : Internal DNS resolution between pods
  #   - kube-proxy : Network rules for Service routing
  #   - vpc-cni    : AWS VPC networking for pods (assigns real VPC IPs)
  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  # ── Managed Node Group ─────────────────────────────────────────
  # A managed node group is a set of EC2 instances (worker nodes)
  # that AWS manages for you — auto-scaling, patching, replacing
  # unhealthy nodes automatically.
  eks_managed_node_groups = {

    main = {
      # Node group name
      name = "${var.cluster_name}-nodes"

      # Instance type: t3.medium gives 2 vCPU / 4GB RAM.
      # Good for dev/staging. Use m5.large or c5.xlarge for production.
      instance_types = ["t3.medium"]

      # Cluster size:
      #   min_size     : Always keep at least 1 node running
      #   max_size     : Auto-scale up to 3 nodes under load
      #   desired_size : Start with 2 nodes
      min_size     = 1
      max_size     = 3
      desired_size = 2

      # Nodes use private subnets — not directly reachable from internet
      subnet_ids = module.vpc.private_subnets

      # EBS volume for node storage
      disk_size = 20   # GB

      tags = {
        Project     = var.cluster_name
        Environment = "production"
        ManagedBy   = "Terraform"
      }
    }
  }

  tags = {
    Project     = var.cluster_name
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# EKS CLUSTER OUTPUTS
# ============================================================

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.eks.arn
}


# ============================================================
# VPC OUTPUT
# ============================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.eks_vpc.id
}


# ============================================================
# SUBNET OUTPUTS
# ============================================================

output "public_subnets" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnets" {
  description = "Private subnet IDs"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}


# ============================================================
# IAM OUTPUTS
# ============================================================

output "eks_cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  description = "EKS worker node IAM role ARN"
  value       = aws_iam_role.eks_node_role.arn
}


# ============================================================
# NODE GROUP OUTPUT
# ============================================================

output "node_group_name" {
  description = "EKS managed node group name"
  value       = aws_eks_node_group.eks_nodes.node_group_name
}
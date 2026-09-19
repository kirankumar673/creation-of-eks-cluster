# ============================================================
# EKS CLUSTER
# ============================================================

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  # Use the Kubernetes version supported by your AWS region/account.
  # Change this if needed.
  version = "1.33"

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = var.cluster_name
  }
}


# ============================================================
# EKS MANAGED NODE GROUP
# ============================================================

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name = aws_eks_cluster.eks.name

  node_group_name = "eks-node-group"

  node_role_arn = aws_iam_role.eks_node_role.arn

  # Worker nodes are placed in PRIVATE subnets
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  instance_types = [
    var.instance_type
  ]

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = var.desired_nodes
    min_size     = var.min_nodes
    max_size     = var.max_nodes
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy
  ]

  tags = {
    Name = "eks-node-group"
  }
}


# ============================================================
# EKS VPC CNI ADD-ON
# ============================================================

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "vpc-cni"

  depends_on = [
    aws_eks_node_group.eks_nodes
  ]
}


# ============================================================
# EKS CORE DNS ADD-ON
# ============================================================

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "coredns"

  depends_on = [
    aws_eks_node_group.eks_nodes
  ]
}


# ============================================================
# EKS KUBE PROXY ADD-ON
# ============================================================

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "kube-proxy"

  depends_on = [
    aws_eks_node_group.eks_nodes
  ]
}
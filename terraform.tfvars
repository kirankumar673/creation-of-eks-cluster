aws_region   = "eu-west-3"
cluster_name = "eks-cluster"
vpc_cidr     = "10.0.0.0/16"

instance_type = "m7i-flex.large"

desired_nodes = 2
min_nodes     = 2
max_nodes     = 3

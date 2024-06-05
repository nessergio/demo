module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = vpc.one.vpc_id
  subnet_ids = aws_subnet.cluster[*].id

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t2.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

  }
}

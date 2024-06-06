module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = aws_vpc.one.id
  subnet_ids = aws_subnet.cluster_private[*].id


  control_plane_subnet_ids = aws_subnet.cluster_private[*].id

  create_kms_key              = false
  create_cloudwatch_log_group = false
  cluster_encryption_config   = {}

  cluster_addons = {
     coredns = { most_recent = true }
     kube-proxy = { most_recent = true }
     vpc-cni = { most_recent = true }
  }

  /*
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }*/

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

  }
}


module "lb_role" {
 source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

 role_name                              = "demo_eks_lb"
 attach_load_balancer_controller_policy = true

 oidc_providers = {
     main = {
       provider_arn               = module.eks.oidc_provider_arn
       namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
     }
 }
 }

/*


resource "aws_iam_role" "demo-eks-role" {
  name = "demo-eks-cluster"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json # (not shown)
}

resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo-eks-role.name
}

resource "aws_eks_cluster" "demo-eks-cluster" {
  name     = "demo-eks-cluster"
  role_arn = aws_iam_role.demo-eks-role.arn

  vpc_config {
    subnet_ids = concat(aws_subnet.cluster_private[*].id, aws_subnet.cluster_public[*].id)
  }

  depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy]
}

// Create EKS Nodes

resource "aws_iam_role" "nodes_iam_role" {
  name = "eks-node-group-nodes"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json # (not shown)
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes_iam_role.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes_iam_role.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes_iam_role.name
}

resource "aws_eks_node_group" "private-eks-nodes" {
  cluster_name    = aws_eks_cluster.demo-eks-cluster.name
  node_group_name = "private-eks-nodes"
  node_role_arn   = aws_iam_role.nodes_iam_role.arn

  subnet_ids      = aws_subnet.cluster_private[*].id

  capacity_type   = "ON_DEMAND"
  instance_types  = ["t2.micro"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # taint {
  #   key = "team"
  #   value = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly
  ]

}
*/


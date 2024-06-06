module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = aws_vpc.one.id
  subnet_ids = concat(aws_subnet.cluster_private[*].id, aws_subnet.cluster_public[*].id)


  #control_plane_subnet_ids = aws_subnet.cluster_private[*].id

  create_kms_key              = false
  create_cloudwatch_log_group = false
  cluster_encryption_config   = {}

  cluster_addons = {
     coredns = { most_recent = true }
     kube-proxy = { most_recent = true }
     vpc-cni = { most_recent = true }
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.medium"]

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

resource "kubernetes_service_account" "service-account" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lb_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = aws_vpc.one.id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = local.cluster_name
  }
}


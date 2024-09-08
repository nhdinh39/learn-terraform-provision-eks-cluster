data "aws_eks_cluster" "example" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "example" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.example.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.example.token
}


resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "AWSLoadBalancerControllerPolicy-${module.eks.cluster_name}"
  description = "IAM policy for AWS Load Balancer Controller"
  policy = file("iam_policy.json")
}

module "irsa-controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AWSLoadBalancerControllerRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.aws_load_balancer_controller.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller-education-eks"]
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = "aws-load-balancer-controller-education-eks"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${module.irsa-controller.iam_role_arn}"
    }
  }
  automount_service_account_token = true
}

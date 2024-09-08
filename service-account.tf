module "eks_iam_role" {
  source = "cloudposse/eks-iam-role/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  eks_cluster_oidc_issuer_url = module.eks.oidc_provider

  # Create a role for the service account named `autoscaler` in the Kubernetes namespace `kube-system`
  service_account_name      = "aws-load-balancer-controller-education-eks"
  service_account_namespace = "kube-system"

  managed_policy_arns       = ["${aws_iam_policy.aws_load_balancer_controller.arn}"]
  depends_on  = [aws_iam_policy.aws_load_balancer_controller]
#   JSON IAM policy document to assign to the service account role
#   aws_iam_policy_document = [local.iam_policy.Statement]
}


resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "AWSLoadBalancerControllerPolicy-${module.eks.cluster_name}"
  description = "IAM policy for AWS Load Balancer Controller"
  policy = file("iam_policy.json")
}
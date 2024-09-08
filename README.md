# Learn Terraform - Provision an EKS Cluster

This repo is a companion repo to the [Provision an EKS Cluster tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks), containing
Terraform configuration files to provision an EKS cluster on AWS.

```
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
```

### Install AWS Load Balancer Controller with Helm

```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
  --cluster=education-eks-MpC8kusT \
  --namespace=kube-system \
  --name=aws-load-balancer-controller-education-eks \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::261093894796:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

#### Helm 

```
helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=education-eks-MpC8kusT \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller-education-eks

kubectl get deployment -n kube-system aws-load-balancer-controller
```

#### Ref:
https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html
https://registry.terraform.io/modules/cloudposse/eks-iam-role/aws/latest



{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::261093894796:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/E0C5357DF783356C868BE8492D8A3C36"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.ap-southeast-1.amazonaws.com/id/E0C5357DF783356C868BE8492D8A3C36:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "oidc.eks.ap-southeast-1.amazonaws.com/id/E0C5357DF783356C868BE8492D8A3C36:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller-dinhnh1"
                }
            }
        }
    ]
}
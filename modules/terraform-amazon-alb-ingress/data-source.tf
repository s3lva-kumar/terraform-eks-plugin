data "aws_caller_identity" "current" {}


data "aws_eks_cluster" "cluster" {
  name = var.cluster-name
}

data "tls_certificate" "eks-cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_eks_cluster_auth" "cluserAuth" {
  name = var.cluster-name
}


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-alb-ingress-controller"]

    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]

    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"]
      type        = "Federated"
    }
  }
}
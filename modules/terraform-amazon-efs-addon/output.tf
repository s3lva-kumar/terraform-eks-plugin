output "federated" {
  value = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

output "stringvalue" {
  value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
}

output "test" {
  value = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
}

output "new-test" {
  value = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
}
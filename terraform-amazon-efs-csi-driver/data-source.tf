data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "tls_certificate" "eks-cret" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_eks_cluster_auth" "cluserAuth" {
  name = var.cluster_name
}
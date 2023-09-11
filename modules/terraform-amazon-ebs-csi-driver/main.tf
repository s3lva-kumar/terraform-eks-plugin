resource "aws_iam_openid_connect_provider" "k8s-cluster" {
  count = var.create_OIDC_Identity_providers ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks-cert.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.eks-cert.url
}

resource "aws_iam_role" "oidc-role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "AmazonEKS_EBS_CSI_DriverRole"
}

resource "aws_iam_role_policy_attachment" "attach-alb-role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.oidc-role.name
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.addon_version
  service_account_role_arn = aws_iam_role.oidc-role.arn
  
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

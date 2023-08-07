# locals {
#   service_account_names = ["efs-csi-controller-sa", "efs-csi-node-sa"]
# }

resource "aws_iam_openid_connect_provider" "k8s-cluster" {
  count           = var.create_OIDC_Identity_providers ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks-cert.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.eks-cert.url
}

resource "aws_iam_role" "oidc-role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "AmazonEKS_EFS_CSI_DriverRole"
}

resource "aws_iam_policy_attachment" "efs-driver-policy" {
  name       = "AmazonEKS_EFS_CSI_DriverRole"
  roles      = ["${aws_iam_role.oidc-role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

# resource "kubernetes_service_account" "k8s-service-account" {
#   count = 2
#   metadata {
#     name      = local.service_account_names[count.index]
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.oidc-role.arn
#     }
#     labels = {
#       "app.kubernetes.io/name"       = "aws-efs-csi-driver"
#       "app.kubernetes.io/managed-by" = "terraform"
#     }
#   }
# }

resource "aws_eks_addon" "efs-csi" {
  cluster_name             = var.cluster-name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = var.addon_version
  service_account_role_arn = aws_iam_role.oidc-role.arn
  configuration_values = jsonencode({
    replicaCount = 4
  })
  tags = {
    "eks_addon" = "efs-csi"
    "terraform" = "true"
  }
  #depends_on = [ kubernetes_service_account.k8s-service-account ]
}
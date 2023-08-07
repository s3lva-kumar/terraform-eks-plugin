resource "aws_iam_openid_connect_provider" "k8s-cluster" {
  count = var.create_OIDC_Identity_providers ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks-cert.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.eks-cert.url
}

resource "aws_iam_policy" "alb-policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("templates/iam_policy.json")
}

resource "aws_iam_role" "oidc-role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "AmazonEKSLoadBalancerControllerRole"
}

resource "aws_iam_role_policy_attachment" "attach-alb-role" {
  policy_arn = aws_iam_policy.alb-policy.arn
  role       = aws_iam_role.oidc-role.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluserAuth.token
  #load_config_file       = false
}

resource "kubernetes_service_account" "k8s-service-account" {
  metadata {
    name      = "aws-alb-ingress-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.oidc-role.arn
    }
    labels = {
      "app.kubernetes.io/name"       = "aws-alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluserAuth.token
    #load_config_file       = false
  }
}

resource "helm_release" "alb-controller" {
  name       = "alb-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.5.1"
  namespace  = "kube-system"

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-alb-ingress-controller"
  }
  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.cluster.name
  }
}


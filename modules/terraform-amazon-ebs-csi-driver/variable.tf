variable "cluster_name" {
}

variable "service_account_name" {
  default = "ebs-csi-controller-sa"
}

variable "addon_version"{
  default = "v1.19.0-eksbuild.2"
}

variable "create_OIDC_Identity_providers" {
  type = bool
  description = "Give only true or false"
}
variable "cluster-name" {
  default = "eks-test-cluster"
}

variable "create_OIDC_Identity_providers" {
  type = bool
  description = "Give only true or false"
}

variable "region" {
  default = ""
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}
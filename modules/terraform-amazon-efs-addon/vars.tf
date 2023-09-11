variable "cluster-name" {}

variable "create_OIDC_Identity_providers" {
  type        = bool
  description = "Give only true or false"
}

variable "addon_version" {
  default = "v1.5.8-eksbuild.1"
}
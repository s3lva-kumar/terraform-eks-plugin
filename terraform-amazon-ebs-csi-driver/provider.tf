terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAYTUGZTJLZZ4SPRKV"
  secret_key = "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"
}

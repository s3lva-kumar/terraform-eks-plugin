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
  access_key = "AKIAUAII4CRPWSX3Z4KK"
  secret_key = "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"
}

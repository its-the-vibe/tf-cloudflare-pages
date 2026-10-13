terraform {
  required_version = ">= 1.15.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# 3. Configure the provider with actual credentials
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
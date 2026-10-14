variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}
variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API token with appropriate permissions"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "repo_owner" {
  type        = string
  description = "GitHub username or organization"
}

variable "repo_name" {
  type        = string
  description = "GitHub repository name"
}

variable "custom_domain" {
  type        = string
  description = "Domain name for the Cloudflare Pages project"
}
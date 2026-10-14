variable "account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

variable "project_name" {
  type        = string
  description = "Name for the Pages project. Must begin with a lowercase letter or digit and contain only lowercase letters, digits, and hyphens."
}

variable "repo_owner" {
  type        = string
  description = "GitHub username or organization"
}

variable "repo_name" {
  type        = string
  description = "GitHub repository name"
}

variable "root_dir" {
  type        = string
  description = "Subdirectory path inside the monorepo (e.g., 'apps/marketing-site')"
}

variable "build_command" {
  type        = string
  description = "Build command for the Cloudflare Pages project (e.g., 'npm run build')"
  default     = ""
}

variable "destination_dir" {
  type        = string
  description = "Destination directory for the build output (e.g., 'dist')"
  default     = ""
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "full_domain_name" {
  type        = string
  description = "Full domain name for the Cloudflare Pages project (e.g., 'www.example.com')"
}

variable "subdomain" {
  type        = string
  description = "Subdomain for the Cloudflare Pages project (e.g., 'www', or '@' for apex)"
}
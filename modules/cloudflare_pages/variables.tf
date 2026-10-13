variable "account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

variable "project_name" {
  type        = string
  description = "Name of the Cloudflare Pages project"
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
  type    = string
  default = ""
}

variable "destination_dir" {
  type    = string
  default = ""
}

variable "env_vars" {
  type    = map(string)
  default = {}
}
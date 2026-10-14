terraform {
  required_version = ">= 1.15.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

resource "cloudflare_pages_project" "this" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = "main"

  source = {
    type = "github"

    config = {
      owner                         = var.repo_owner
      repo_name                     = var.repo_name
      production_branch             = "main"
      preview_deployment_setting    = true
      production_deployment_enabled = true
      preview_deployment_setting    = "all"
      pr_comments_enabled           = true
      path_includes                 = ["${var.root_dir}/*"]
      preview_branch_includes       = ["${var.root_dir}/*"]
    }
  }

  build_config = {
    build_command   = var.build_command
    destination_dir = var.destination_dir
    root_dir        = var.root_dir # Critical setting for monorepos!
  }

  deployment_configs = {
    production = {
      environment_variables = var.env_vars
    }
    preview = {
      environment_variables = var.env_vars
    }
  }
}

# 2. Attach a Custom Domain to the Pages Project
resource "cloudflare_pages_domain" "custom_domain" {
  depends_on   = [cloudflare_pages_project.this]
  name         = var.full_domain_name
  account_id   = var.account_id
  project_name = cloudflare_pages_project.this.name
}

# 3. Route DNS to the Cloudflare Pages Subdomain
resource "cloudflare_dns_record" "site_dns" {
  depends_on = [cloudflare_pages_project.this]
  zone_id    = var.zone_id
  name       = var.subdomain
  content    = cloudflare_pages_project.this.subdomain
  type       = "CNAME"
  proxied    = true
  ttl        = 1
}
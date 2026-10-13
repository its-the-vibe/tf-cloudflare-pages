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

  source {
    type = "github"

    config {
      owner                         = var.repo_owner
      repo_name                     = var.repo_name
      production_branch             = "main"
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "all"
      pr_comments_enabled           = true
    }
  }

  build_config {
    build_command   = var.build_command
    destination_dir = var.destination_dir
    root_dir        = var.root_dir # Critical setting for monorepos!
  }

  deployment_configs {
    production {
      environment_variables = var.env_vars
    }
    preview {
      environment_variables = var.env_vars
    }
  }
}
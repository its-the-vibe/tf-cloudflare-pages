module "apex" {
  source           = "./modules/cloudflare_pages"
  account_id       = var.cloudflare_account_id
  repo_owner       = var.repo_owner
  repo_name        = var.repo_name
  project_name     = "apex"
  root_dir         = "apex"
  full_domain_name = "${var.custom_domain}"
  subdomain        = "@"
  zone_id          = var.cloudflare_zone_id
}

module "gradient_lab" {
  source           = "./modules/cloudflare_pages"
  account_id       = var.cloudflare_account_id
  repo_owner       = var.repo_owner
  repo_name        = var.repo_name
  project_name     = "gradient-lab"
  root_dir         = "GradientLab"
  full_domain_name = "gradientlab.${var.custom_domain}"
  subdomain        = "gradientlab"
  zone_id          = var.cloudflare_zone_id
}

module "local_ledger" {
  source           = "./modules/cloudflare_pages"
  account_id       = var.cloudflare_account_id
  repo_owner       = var.repo_owner
  repo_name        = var.repo_name
  project_name     = "local-ledger"
  root_dir         = "LocalLedger"
  full_domain_name = "localledger.${var.custom_domain}"
  subdomain        = "localledger"
  zone_id          = var.cloudflare_zone_id
  build_command    = "npm run build"
  destination_dir  = "dist"
}

module "spinny_globe" {
  source           = "./modules/cloudflare_pages"
  account_id       = var.cloudflare_account_id
  repo_owner       = var.repo_owner
  repo_name        = var.repo_name
  project_name     = "spinny-globe"
  root_dir         = "spinny-globe"
  full_domain_name = "spinny-globe.${var.custom_domain}"
  subdomain        = "spinny-globe"
  zone_id          = var.cloudflare_zone_id
  build_command    = "npm run build"
  destination_dir  = "dist"
}
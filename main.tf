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
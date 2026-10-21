# 1. Dummy A record for www to allow Cloudflare to proxy and process requests
resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  type    = "A"
  content = "192.0.2.1" # Standard IP target (formerly 'value' in v4)
  ttl     = 1           # 1 means 'automatic'
  proxied = true
}

# 2. Redirect Rule forwarding www.example.com to example.com
resource "cloudflare_ruleset" "redirect_www_to_apex" {
  zone_id     = var.cloudflare_zone_id
  name        = "Redirect www to Apex"
  description = "Redirects www subdomains to the apex domain preserving path and query string"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      action      = "redirect"
      description = "Redirect www.example.com to example.com"
      enabled     = true
      expression  = "(http.host eq \"www.${var.custom_domain}\")"

      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://${var.custom_domain}\", http.request.uri.path)"
          }
        }
      }
    }
  ]
}

module "apex" {
  source           = "./modules/cloudflare_pages"
  account_id       = var.cloudflare_account_id
  repo_owner       = var.repo_owner
  repo_name        = var.repo_name
  project_name     = "apex"
  root_dir         = "apex"
  full_domain_name = var.custom_domain
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

module "coin_toss" {
  source           = "./modules/cloudflare_pages"
  account_id       = var.cloudflare_account_id
  repo_owner       = var.repo_owner
  repo_name        = var.repo_name
  project_name     = "coin-toss"
  root_dir         = "CoinToss"
  full_domain_name = "cointoss.${var.custom_domain}"
  subdomain        = "cointoss"
  zone_id          = var.cloudflare_zone_id
}

module "magic_8" {
  source           = "./modules/cloudflare_pages"
  account_id       = var.cloudflare_account_id
  repo_owner       = var.repo_owner
  repo_name        = var.repo_name
  project_name     = "magic-8"
  root_dir         = "Magic8"
  full_domain_name = "magic8.${var.custom_domain}"
  subdomain        = "magic8"
  zone_id          = var.cloudflare_zone_id
}

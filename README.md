# tf-cloudflare-pages

Terraform configuration for deploying and managing multiple Cloudflare Pages
projects from directories in a GitHub repository. The root configuration
currently provisions the `gradient-lab`, `local-ledger`, and `spinny-globe`
sites, attaches custom domains, and creates their DNS records.

## Prerequisites

- Terraform CLI **1.15.0 or later**.
- A Cloudflare account with the sites' domain added as a zone.
- A GitHub account and repository containing the site source directories.
- The GitHub repository connected to Cloudflare Pages. Authorize Cloudflare
  to access the repository in the Cloudflare dashboard before applying this
  configuration.
- (For remote state) a Cloudflare R2 bucket and its S3-compatible access
  credentials.

The Cloudflare provider is `cloudflare/cloudflare` version `~> 5.0` (the lock
file currently selects `5.28.0`).

## Project structure

| Path | Purpose |
| --- | --- |
| `providers.tf` | Terraform and provider version requirements; configures the Cloudflare provider using the API token variable. |
| `backend.tf` | Declares an S3-compatible remote state backend, intended for Cloudflare R2. |
| `variables.tf` | Inputs for Cloudflare credentials and account/zone IDs, the GitHub repository, and the custom domain. |
| `main.tf` | Instantiates the reusable module once for each Pages project. |
| `modules/cloudflare_pages/` | Reusable module that creates a Pages project, custom domain, and CNAME DNS record. |
| `.terraform.lock.hcl` | Pins the selected provider version and checksums. |

## Quick start

### 1. Create a Cloudflare API token

In the Cloudflare dashboard, create an API token with the permissions needed
to manage Pages projects and DNS records for the target zone (typically
**Cloudflare Pages: Edit** at the account level and **DNS: Edit** for the
zone). Limit the token's resources to the relevant account and zone. The
exact permission names may vary as Cloudflare updates its dashboard.

Find the **Account ID** on the account overview page and the **Zone ID** on
the domain's overview page.

### 2. Configure input variables

Provide the required values through environment variables or a
`terraform.tfvars` file. Environment variables keep the API token out of
version control:

```sh
export TF_VAR_cloudflare_account_id="your-cloudflare-account-id"
export TF_VAR_cloudflare_api_token="your-cloudflare-api-token"
export TF_VAR_cloudflare_zone_id="your-cloudflare-zone-id"
export TF_VAR_repo_owner="your-github-owner"
export TF_VAR_repo_name="your-repository"
export TF_VAR_custom_domain="example.com"
```

Do not commit credentials or secret values. `cloudflare_api_token` is marked
sensitive by Terraform.

### 3. Initialize the backend

`backend.tf` declares an S3 backend but intentionally does not hard-code a
bucket, state key, or R2 endpoint. Supply those when initializing. For
example:

```sh
export AWS_ACCESS_KEY_ID="your-r2-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-r2-secret-access-key"

terraform init \
  -backend-config="bucket=your-state-bucket" \
  -backend-config="key=tf-cloudflare-pages/terraform.tfstate" \
  -backend-config="region=auto" \
  -backend-config="endpoint=https://your-account-id.r2.cloudflarestorage.com"
```

Use R2 S3-compatible credentials for the backend, not the Cloudflare API
token. Keep the state bucket private. To use local state instead, remove or
comment out the backend declaration in `backend.tf` before running
`terraform init`.

### 4. Review and apply

```sh
terraform validate
terraform plan
terraform apply
```

Review the plan before applying. Terraform creates the Pages projects and
their custom domains and DNS records. Cloudflare deploys from the connected
GitHub repository's `main` branch; verify the repository and directory names
match the configured values.

## Configuration

The root module requires the following variables:

| Variable | Required | Description |
| --- | --- | --- |
| `cloudflare_account_id` | Yes | Cloudflare account ID in which to create the Pages projects. |
| `cloudflare_api_token` | Yes | Cloudflare API token with Pages and DNS permissions. Marked sensitive. |
| `cloudflare_zone_id` | Yes | Zone ID for the domain that will host the project subdomains. |
| `repo_owner` | Yes | GitHub username or organization that owns the source repository. |
| `repo_name` | Yes | GitHub repository name connected to Cloudflare Pages. |
| `custom_domain` | Yes | Base domain name, without a subdomain (for example, `example.com`). |

Set these values using `TF_VAR_<variable_name>` environment variables or in
a `terraform.tfvars` file. The values above configure the root module; the
reusable child module has additional inputs described below.

## Configured projects

Each block in `main.tf` passes a project directory and domain settings to the
same module. The checked-in configuration is:

| Project | Repository directory (`root_dir`) | Domain | Build command | Output directory |
| --- | --- | --- | --- | --- |
| `gradient-lab` | `GradientLab` | `gradientlab.<custom_domain>` | None | None |
| `local-ledger` | `LocalLedger` | `localledger.<custom_domain>` | `npm run build` | `dist` |
| `spinny-globe` | `spinny-globe` | `spinny-globe.<custom_domain>` | `npm run build` | `dist` |

For example, to add a project, add another module block to the root
`main.tf`, using the same required arguments and setting its directory,
project name, and domain:

```hcl
module "my_site" {
  source           = "./modules/cloudflare_pages"
  account_id       = var.cloudflare_account_id
  repo_owner       = var.repo_owner
  repo_name        = var.repo_name
  project_name     = "my-site"
  root_dir         = "path/to/site"
  full_domain_name = "my-site.${var.custom_domain}"
  subdomain        = "my-site"
  zone_id          = var.cloudflare_zone_id
  build_command    = "npm run build"
  destination_dir  = "dist"
  env_vars         = { NODE_VERSION = "20" }
}
```

Ensure `root_dir` matches the directory in the GitHub repository and that the
site's build command and output directory match its framework. Project names
must begin with a lowercase letter or digit and contain only lowercase
letters, digits, and hyphens.

## `cloudflare_pages` module reference

Source: `./modules/cloudflare_pages`

The module creates a Cloudflare Pages project connected to GitHub, attaches
the configured custom domain, and creates a proxied CNAME DNS record pointing
at the Pages project's generated subdomain. It uses `main` as the production
branch and configures preview deployments for the selected repository path.

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `account_id` | Yes | — | Cloudflare account ID. |
| `project_name` | Yes | — | Pages project name; lowercase letters, digits, and hyphens, starting with a letter or digit. |
| `repo_owner` | Yes | — | GitHub username or organization. |
| `repo_name` | Yes | — | GitHub repository name. |
| `root_dir` | Yes | — | Site directory within the repository. |
| `zone_id` | Yes | — | Cloudflare zone ID for the DNS record. |
| `full_domain_name` | Yes | — | Full custom domain, such as `www.example.com`. |
| `subdomain` | Yes | — | DNS record name within the zone, such as `www`. |
| `build_command` | No | `""` | Build command, such as `npm run build`. |
| `destination_dir` | No | `""` | Build output directory, such as `dist`. |
| `env_vars` | No | `{}` | Map of environment variables applied to production and preview deployments. |

## Troubleshooting

- **Provider authentication or permission errors:** Confirm the API token is
  valid, set as `TF_VAR_cloudflare_api_token`, and has Pages edit access for
  the account and DNS edit access for the zone.
- **Pages project cannot connect to GitHub:** Confirm Cloudflare's GitHub app
  is authorized for the repository, and check `repo_owner`, `repo_name`, and
  `root_dir` spelling and capitalization.
- **Build fails or the deployed site is blank:** Check the project's build
  logs and verify `build_command`, `destination_dir`, and `root_dir` against
  the site's build configuration.
- **Custom domain or DNS record fails:** Verify `full_domain_name` belongs to
  the configured `zone_id`, `subdomain` is the intended DNS record name, and
  the token can edit DNS records in that zone.
- **Backend initialization fails:** Check the R2 bucket name, S3-compatible
  endpoint, and `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`. If moving
  existing state to or from a backend, follow Terraform's `init -migrate-state`
  prompts and back up state before migration.

For provider-specific details, see the
[Cloudflare Terraform provider documentation](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs).
For Pages concepts and deployment behavior, see
[Cloudflare Pages documentation](https://developers.cloudflare.com/pages/).

terraform {
  required_providers {
    porkbun = {
      source  = "cullenmcdermott/porkbun"
      version = "~> 0.3"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.22"
    }

    discord = {
      source  = "Lucky3028/discord"
      version = "~> 2.0"
    }

    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = "~> 3.22"
    }
  }
}

provider "porkbun" {
  api_key    = var.porkbun_api_key
  secret_key = var.porkbun_secret_key
}

provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = var.grafana_cloud_token
}

provider "discord" {
  token = var.discord_token
}

provider "grafana" {
  alias = "stack"

  url  = module.monitoring.grafana_cloud_stack_url
  auth = module.monitoring.grafana_cloud_stack_service_account_token
}

provider "pagerduty" {
  token = var.pagerduty_api_key
}

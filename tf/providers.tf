terraform {
  required_providers {
    porkbun = {
      source  = "cullenmcdermott/porkbun"
      version = "~> 0.2"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.12"
    }

    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = "~> 3.6"
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

provider "grafana" {
  alias = "stack"
  url   = grafana_cloud_stack.main.url
}

provider "pagerduty" {
  token = var.pagerduty_api_key
}

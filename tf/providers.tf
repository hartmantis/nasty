terraform {
  required_providers {
    porkbun = {
      source  = "cullenmcdermott/porkbun"
      version = "~> 0.2"
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

provider "pagerduty" {
  token = var.pagerduty_api_key
}

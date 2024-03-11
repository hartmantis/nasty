terraform {
  required_providers {
    grafana = {
      source                = "grafana/grafana"
      configuration_aliases = [grafana.cloud, grafana.stack]
    }

    discord = {
      source = "Lucky3028/discord"
    }

    pagerduty = {
      source = "PagerDuty/pagerduty"
    }
  }
}

resource "grafana_cloud_stack" "main" {
  provider = grafana.cloud

  name        = var.grafana_cloud_slug
  slug        = var.grafana_cloud_slug
  region_slug = var.grafana_cloud_region
}

resource "grafana_cloud_stack_service_account" "tf" {
  provider   = grafana.cloud
  stack_slug = grafana_cloud_stack.main.slug

  name       = "TF admin account"
  role       = "Admin"
}

resource "grafana_cloud_stack_service_account_token" "tf" {
  provider           = grafana.cloud
  stack_slug         = grafana_cloud_stack.main.slug

  name               = "TF admin key"
  service_account_id = grafana_cloud_stack_service_account.tf.id
}

resource "grafana_cloud_access_policy" "metrics_publisher" {
  provider = grafana.cloud
  region   = var.grafana_cloud_region

  name         = "metrics-publisher"
  display_name = "Metrics Publisher"
  scopes       = ["metrics:write"]

  realm {
    type       = "stack"
    identifier = grafana_cloud_stack.main.id
  }
}

resource "grafana_cloud_access_policy" "logs_publisher" {
  provider = grafana.cloud
  region   = var.grafana_cloud_region

  name         = "logs-publisher"
  display_name = "Logs Publisher"
  scopes       = ["logs:write"]

  realm {
    type       = "stack"
    identifier = grafana_cloud_stack.main.id
  }
}

# TODO: TF can manage the tokens if I can figure out how to have it feed them
# into an Agenix secrets file.

resource "grafana_contact_point" "main" {
  provider = grafana.stack

  name = "Main contact point for alerting"

  email {
    addresses = [var.grafana_alert_contact_email]
    message   = "{{ template \"default.message\" .}}"
    subject   = "{{ template \"default.title\" .}}"
  }

  pagerduty {
    integration_key = pagerduty_service_integration.grafana_cloud.integration_key
  }
}

data "http" "grafana_dashboard_node_exporter" {
  url = "https://grafana.com/api/dashboards/1860/revisions/${var.grafana_dashboard_node_exporter_revision}/download"
}

resource "grafana_dashboard" "node_exporter" {
  provider = grafana.stack

  config_json = data.http.grafana_dashboard_node_exporter.response_body
}

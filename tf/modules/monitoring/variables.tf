variable "grafana_cloud_slug" {
  description = "Name of the Grafana Cloud stack to manage (https://<slug>.grafana.net)"
  sensitive   = true
}
variable "grafana_cloud_region" {
  description = "Region slug the Grafana Cloud stack will be located in"
}
variable "grafana_alert_contact_email" {
  description = "Email address for Grafana Cloud alerting"
  sensitive   = true
}
variable "grafana_dashboard_node_exporter_revision" {
  description = "Version of the Node Exporter dashboard to install"
}

variable "discord_server_id" {
  description = "ID of the Discord server we'll be sending alerts to"
  sensitive   = true
}

variable "pagerduty_admin_email" {
  description = "The admin user's PagerDuty email address"
  sensitive   = true
}

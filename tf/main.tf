terraform {
  required_version = "~> 1.9.0"
}

module "dns" {
  source = "./modules/dns"

  domain          = var.domain
  ip              = var.ip_address
  outside_name    = var.outside_name
  outside_ip      = var.outside_ip_address
  root_txt_record = var.root_txt_record
  mx_server       = var.mx_server
}

module "monitoring" {
  source = "./modules/monitoring"

  providers = {
    grafana.cloud = grafana.cloud
    grafana.stack = grafana.stack
    discord       = discord
    pagerduty     = pagerduty
  }

  grafana_cloud_slug                       = var.grafana_cloud_slug
  grafana_cloud_region                     = var.grafana_cloud_region
  grafana_alert_contact_email              = var.grafana_alert_contact_email
  grafana_dashboard_node_exporter_revision = var.grafana_dashboard_node_exporter_revision
  discord_server_id                        = var.discord_server_id
  pagerduty_admin_email                    = var.pagerduty_admin_email
}

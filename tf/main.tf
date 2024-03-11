terraform {
  required_version = "~> 1.6.1"
}

module "dns" {
  source = "./modules/dns"

  domain       = var.domain
  ip           = var.ip_address
  outside_name = var.outside_name
  outside_ip   = var.outside_ip_address
  mx_server    = var.mx_server
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

moved {
  from = discord_category_channel.notifications
  to   = module.monitoring.discord_category_channel.notifications
}

moved {
  from = discord_text_channel.alerts
  to   = module.monitoring.discord_text_channel.alerts
}

moved {
  from = discord_webhook.grafana_alerts
  to   = module.monitoring.discord_webhook.grafana_alerts
}

moved {
  from = pagerduty_escalation_policy.default
  to   = module.monitoring.pagerduty_escalation_policy.default
}

moved {
  from = pagerduty_service.nasty
  to   = module.monitoring.pagerduty_service.nasty
}

moved {
  from = pagerduty_service_integration.grafana_cloud
  to   = module.monitoring.pagerduty_service_integration.grafana_cloud
}

moved {
  from = grafana_folder.alerts
  to   = module.monitoring.grafana_folder.alerts
}

moved {
  from = grafana_rule_group.nasty_1m_rules
  to   = module.monitoring.grafana_rule_group.nasty_1m_rules
}

moved {
  from = grafana_cloud_stack.main
  to   = module.monitoring.grafana_cloud_stack.main
}

moved {
  from = grafana_cloud_stack_service_account.tf
  to   = module.monitoring.grafana_cloud_stack_service_account.tf
}

moved {
  from = grafana_cloud_stack_service_account_token.tf
  to   = module.monitoring.grafana_cloud_stack_service_account_token.tf
}

moved {
  from = grafana_cloud_access_policy.metrics_publisher
  to   = module.monitoring.grafana_cloud_access_policy.metrics_publisher
}

moved {
  from = grafana_cloud_access_policy.logs_publisher
  to   = module.monitoring.grafana_cloud_access_policy.logs_publisher
}

moved {
  from = grafana_contact_point.main
  to   = module.monitoring.grafana_contact_point.main
}

moved {
  from = grafana_notification_policy.main
  to   = module.monitoring.grafana_notification_policy.main
}

moved {
  from = grafana_dashboard.node_exporter
  to   = module.monitoring.grafana_dashboard.node_exporter
}

resource "terraform_data" "empty" {}
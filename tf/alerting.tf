data "discord_server" "main" {
  server_id = var.discord_server_id
}

resource "discord_category_channel" "notifications" {
  name      = "notifications"
  server_id = data.discord_server.main.id
}

resource "discord_text_channel" "alerts" {
  name      = "alerts"
  server_id = data.discord_server.main.id
  category  = discord_category_channel.notifications.id
}

resource "discord_webhook" "grafana_alerts" {
  channel_id = discord_text_channel.alerts.id
  name       = "AlertBot"
}

# The user already exists just by virtue of setting up the PagerDuty account.
data "pagerduty_user" "admin" {
  email = var.pagerduty_admin_email
}

resource "pagerduty_escalation_policy" "default" {
  name = "Default"

  rule {
    escalation_delay_in_minutes = 15
    target {
      type = "user_reference"
      id   = data.pagerduty_user.admin.id
    }
  }
}

resource "pagerduty_service" "nasty" {
  name              = "NASty"
  escalation_policy = pagerduty_escalation_policy.default.id
  alert_creation    = "create_alerts_and_incidents"
}

resource "pagerduty_service_integration" "grafana_cloud" {
  name    = "Grafana Cloud"
  service = pagerduty_service.nasty.id
  type    = "events_api_v2_inbound_integration"
}

resource "grafana_folder" "alerts" {
  provider = grafana.stack
  
  title    = "Alerts"
}

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

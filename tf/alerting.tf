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

  title = "Alerts"
}

resource "grafana_rule_group" "nasty_1m_rules" {
  name             = "NASty 1m Alerts"
  interval_seconds = 60
  folder_uid       = grafana_folder.alerts.uid

  rule {
    name      = "Not-Online ZFS Pools"
    condition = "B"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "grafanacloud-prom"

      model = jsonencode({
        disableTextWrap     = false
        editorMode          = "builder"
        expr                = "sum(node_zfs_zpool_state{state!=\"online\"})"
        fullMetaSearch      = false
        includeNullMetadata = true
        instant             = true
        intervalMs          = 1000
        legendFormat        = "__auto"
        maxDataPoints       = 43200
        range               = false
        refId               = "A"
        useBackend          = false
      })
    }

    data {
      ref_id = "B"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"

      model = jsonencode({
        conditions = [
          {
            evaluator = {
              params = [0]
              type   = "gt"
            }
            operator = { type = "and" }
            query = {
              params = ["C"]
            }
            reducer = {
              params = []
              type   = "last"
            }
            type = "query"
          }
        ]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression    = "A"
        intervalMs    = 1000
        maxDataPoints = 43200
        refId         = "C"
        type          = "threshold"
      })
    }

    no_data_state = "Alerting"
  }
}
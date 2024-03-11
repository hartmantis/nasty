# TODO: TF can manage the tokens if I can figure out how to have it feed them
# into an Agenix secrets file.

resource "grafana_contact_point" "main" {
  provider = grafana.stack

  name = "Admin Contact"

  email {
    addresses = [var.grafana_alert_contact_email]
    message   = "{{ template \"default.message\" .}}"
    subject   = "{{ template \"default.title\" .}}"
  }

  discord {
    url                  = discord_webhook.grafana_alerts.url
    use_discord_username = true
  }

  pagerduty {
    integration_key = pagerduty_service_integration.grafana_cloud.integration_key
  }
}

resource "grafana_notification_policy" "main" {
  provider = grafana.stack

  contact_point = grafana_contact_point.main.name
  group_by      = ["grafana_folder", "alertname"]
}

data "http" "grafana_dashboard_node_exporter" {
  url = "https://grafana.com/api/dashboards/1860/revisions/${var.grafana_dashboard_node_exporter_revision}/download"
}

resource "grafana_dashboard" "node_exporter" {
  provider = grafana.stack

  config_json = data.http.grafana_dashboard_node_exporter.response_body
}

resource "grafana_folder" "alerts" {
  provider = grafana.stack

  title = "Alerts"
}

resource "grafana_rule_group" "nasty_1m_rules" {
  provider = grafana.stack

  name             = "NASty 1m Alerts"
  interval_seconds = 60
  folder_uid       = grafana_folder.alerts.uid

  rule {
    name      = "Not-Online ZFS Pools"
    condition = "B"
    for       = "3m"

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

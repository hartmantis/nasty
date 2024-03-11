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

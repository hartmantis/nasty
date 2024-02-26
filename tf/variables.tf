variable "porkbun_api_key" {
  description = "An API key for the Porkbun domain registrar"
}
variable "porkbun_secret_key" {
  description = "A secret key for the Porkbun domain registrar"
}
variable "domain" {
  description = "The domain name we're managing DNS entries for our NAS under"
}
variable "ip_address" {
  description = "The IP address of our NAS"
}
variable "outside_name" {
  description = "Hostname that'll point at a public IP for external access"
}
variable "outside_ip_address" {
  description = "Public IP that the external access hostname will point to"
}
variable "mx_server" {
  description = "The mail server for the domain"
}

variable "grafana_cloud_token" {
  description = "Access Policy token for Grafana Cloud with the following scopes: accesspolicies:read|write|delete, stacks:read|write|delete"
}
variable "grafana_cloud_slug" {
  description = "Name of the Grafana Cloud stack to manage (https://<slug>.grafana.net)"
}

variable "pagerduty_admin_email" {
  description = "The admin user's PagerDuty email address"
}
variable "pagerduty_api_key" {
  description = "An API key for accessing PagerDuty"
}

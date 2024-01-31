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
variable "pagerduty_admin_email" {
  description = "The admin user's PagerDuty email address"
}
variable "pagerduty_api_key" {
  description = "An API key for accessing PagerDuty"
}

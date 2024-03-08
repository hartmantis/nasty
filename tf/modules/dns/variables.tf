variable "domain" {
  description = "The domain name we're managing DNS entries for our NAS under"
}
variable "ip" {
  description = "The IP address of our NAS"
}
variable "outside_name" {
  description = "Hostname that'll point at a public IP for external access"
}
variable "outside_ip" {
  description = "Public IP that the external access hostname will point to"
}
variable "mx_server" {
  description = "The mail server for the domain"
}

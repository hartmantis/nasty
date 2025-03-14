variable "domain" {
  description = "The domain name we're managing DNS entries for our NAS under"
  sensitive   = true
}
variable "ip" {
  description = "The IP address of our NAS"
  sensitive   = true
}
variable "outside_name" {
  description = "Hostname that'll point at a public IP for external access"
  sensitive   = true
}
variable "outside_ip" {
  description = "Public IP that the external access hostname will point to"
  sensitive   = true
}
variable "root_txt_record" {
  description = "The TXT record the domain's mail provider requires to prove ownership"
  sensitive   = true
}
variable "mx_servers" {
  description = "The mail server(s) and priorities for the domain"
  type        = map(number)
  sensitive   = true
}

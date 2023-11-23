terraform {
  required_version = "~> 1.6.0"
}

resource "porkbun_dns_record" "nasty" {
  domain  = var.domain
  type    = "A"
  content = var.ip_address
}

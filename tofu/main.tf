terraform {
  required_version = "~> 1.6.0"
}

resource "porkbun_dns_record" "nasty_root" {
  domain  = var.domain
  name    = ""
  type    = "A"
  content = var.ip_address
  ttl     = 600
  notes   = "Root domain A record"
}

resource "porkbun_dns_record" "nasty_wildcard" {
  domain  = var.domain
  name    = "*"
  type    = "A"
  content = var.ip_address
  ttl     = 600
  notes   = "Wildcard DNS for all NAS services"
}

resource "porkbun_dns_record" "nasty_root" {
  domain  = var.domain
  name    = ""
  type    = can(cidrhost("${var.ip}/128", 0)) ? "AAAA" : "A"
  content = var.ip
  ttl     = 600
  notes   = "Root domain A record"
}

resource "porkbun_dns_record" "nasty_wildcard" {
  domain  = var.domain
  name    = "*"
  type    = can(cidrhost("${var.ip}/128", 0)) ? "AAAA" : "A"
  content = var.ip
  ttl     = 600
  notes   = "Wildcard DNS for all NAS services"
}

resource "porkbun_dns_record" "external_access" {
  domain  = var.domain
  name    = var.outside_name
  type    = can(cidrhost("${var.outside_ip}/128", 0)) ? "AAAA" : "A"
  content = var.outside_ip
  ttl     = 600
  notes   = "External access point"
}

resource "porkbun_dns_record" "root_mx" {
  domain  = var.domain
  name    = ""
  type    = "MX"
  content = var.mx_server
  ttl     = 600
  notes   = "Mail server for the domain"
}

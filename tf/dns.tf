resource "porkbun_dns_record" "nasty_root" {
  domain  = var.domain
  name    = ""
  type    = can(cidrhost("${var.ip_address}/128", 0)) ? "AAAA" : "A"
  content = var.ip_address
  ttl     = 600
  notes   = "Root domain A record"
}

resource "porkbun_dns_record" "nasty_wildcard" {
  domain  = var.domain
  name    = "*"
  type    = can(cidrhost("${var.ip_address}/128", 0)) ? "AAAA" : "A"
  content = var.ip_address
  ttl     = 600
  notes   = "Wildcard DNS for all NAS services"
}

resource "porkbun_dns_record" "nasty_root_mx" {
  domain  = var.domain
  name    = ""
  type    = "MX"
  content = var.mx_server
  ttl     = 600
  notes   = "Mail server for the domain"
}

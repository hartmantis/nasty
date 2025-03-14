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

resource "porkbun_dns_record" "root_txt" {
  domain  = var.domain
  name    = ""
  type    = "TXT"
  content = var.root_txt_record
  ttl     = 600
  notes   = "TXT record to prove domain ownership"
}

resource "porkbun_dns_record" "root_mx" {
  count    = length(var.mx_servers)
  domain   = var.domain
  name     = ""
  type     = "MX"
  content  = keys(var.mx_servers)[count.index]
  prio     = values(var.mx_servers)[count.index]
  ttl      = 600
  notes   = "Mail server for the domain"
}

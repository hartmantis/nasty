terraform {
  required_version = "~> 1.6.1"
}

module "dns" {
  source = "./modules/dns"

  domain       = var.domain
  ip           = var.ip_address
  outside_name = var.outside_name
  outside_ip   = var.outside_ip_address
  mx_server    = var.mx_server
}

moved {
  from = porkbun_dns_record.nasty_root
  to   = module.dns.porkbun_dns_record.nasty_root
}

moved {
  from = porkbun_dns_record.nasty_wildcard
  to   = module.dns.porkbun_dns_record.nasty_wildcard
}

moved {
  from = porkbun_dns_record.external_access
  to   = module.dns.porkbun_dns_record.external_access
}

moved {
  from = porkbun_dns_record.nasty_root_mx
  to   = module.dns.porkbun_dns_record.root_mx
}

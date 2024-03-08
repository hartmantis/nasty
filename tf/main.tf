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

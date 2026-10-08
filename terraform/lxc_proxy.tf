module "lxc_proxy" {
  source       = "./modules/proxmox_lxc"
  hostname     = "proxy-lxc"
  cores        = 2
  memory       = 2048
  ip_address   = "10.0.10.2/24"
  gateway      = "10.0.10.1"
  vlan_tag     = 10
  unprivileged = true
  nesting      = true
  tags         = ["proxy"]
  admin_ip         = var.admin_ip
  allow_public_web = true
}
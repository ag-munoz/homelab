module "lxc_runner" {
  source         = "./modules/proxmox_lxc"
  hostname       = "runner-lxc"
  vmid           = 102
  cores          = 2
  memory         = 2048
  ip_address     = "192.168.0.152/24"
  gateway        = "192.168.0.1"
  unprivileged   = true
  nesting        = true                
  tags           = ["ci-cd", "runner"]
  admin_ip       = var.admin_ip
  ssh_public_key = var.ssh_public_key

  proxy_ip     = null
  service_port = null
}
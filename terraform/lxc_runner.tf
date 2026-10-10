module "lxc_runner" {
  source           = "./modules/proxmox_lxc"
  hostname         = "runner-lxc"
  cores            = 2
  memory           = 2048
  ip_address       = "192.168.0.152/24"
  gateway          = "192.168.0.1"
  unprivileged     = true
  nesting          = true
  tags             = ["github-actions"]
  admin_ip         = var.admin_ip
  allow_public_web = false
  ssh_public_key   = var.ssh_public_key
}

output "runner_lxc_ip" {
  value       = "192.168.0.152/24"
  description = "IP del runner local"
}
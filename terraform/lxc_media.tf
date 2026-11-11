module "lxc_media" {
  source       = "./modules/proxmox_lxc"
  hostname     = "media-lxc"
  cores        = 2
  memory       = 2048
  ip_address   = "192.168.0.151/24"
  gateway      = "192.168.0.1"
  unprivileged = true
  nesting      = true
  tags         = ["media"]
  admin_ip     = var.admin_ip
  proxy_ip     = "192.168.0.150"
  service_port = "8096"
  ssh_public_key = var.ssh_public_key
  vmid   = 100
  extra_firewall_rules = [
    {
      type    = "in"
      action  = "ACCEPT"
      source  = "192.168.0.150"
      proto   = "tcp"
      dport   = "8096,8989,7878,6767,9696,8123"          
      comment = "Permite entrada de Proxy a Jellyfin, Sonarr, Radarr, Bazarr, Prowlarr y qBit UI"
    },
    {
      type    = "in"
      action  = "ACCEPT"
      proto   = "tcp"
      dport   = "6881"          
      comment = "Permite trafico P2P (TCP) entrante desde Internet"
    },
    {
      type    = "in"
      action  = "ACCEPT"
      proto   = "udp"
      dport   = "6881"          
      comment = "Permite trafico P2P (UDP) entrante desde Internet"
    },
    {
      type    = "in"
      action  = "ACCEPT"
      proto   = "udp"
      dport   = "53"          
      comment = "Permite trafico DNS"
    },
    {
      type    = "in"
      action  = "ACCEPT"
      proto   = "tcp"
      dport   = "80,443"          
      comment = "Permite trafico HTTP/HTTPS"
    }
  ]

}

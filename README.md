# 🚀 Automated Homelab Infrastructure

[![Proxmox VE](https://img.shields.io/badge/Proxmox_VE-8.x-E57000?style=for-the-badge&logo=proxmox&logoColor=white)](https://www.proxmox.com)
[![Terraform](https://img.shields.io/badge/Terraform-1.x-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-2.x-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

An **Infrastructure as Code (IaC)** and **Automated Configuration Management** repository that provisions, secures, and deploys a reproducible, self-healing Homelab environment on **Proxmox VE** using **Terraform**, **Ansible**, and **Docker**.

---

## 🎯 Executive Summary & Core Competencies

This project demonstrates production-ready DevOps practices applied to local infrastructure:

- **Zero-Touch Provisioning:** Full end-to-end automation from hypervisor container creation to containerized service health check validation.
- **Declarative Infrastructure:** 100% defined in code via Terraform using the `bpg/proxmox` provider.
- **Configuration & Orchestration:** Idempotent Ansible playbooks for system hardening, Docker engine deployment, and Compose stack lifecycle.
- **Security & Network Segmentation:** Granular per-container Proxmox firewalls, isolated LXCs, automated SSH key injection, and restricted LAN administration limits.

---

## 📐 Architecture & Network Topology

The environment runs isolated, unprivileged Debian 12 LXC containers with feature flags enabled (e.g., `nesting` for containerized runtimes).

```mermaid
flowchart TD
    Client(("LAN Network\n(192.168.0.0/24)"))

    subgraph Proxmox ["Proxmox VE Hypervisor"]
        FW{"Proxmox Firewall Engine\nInbound: SSH (22)\nOutbound: DNS/Web"}
        
        subgraph ProxyLXC ["proxy-lxc (CT 101) - 192.168.0.150"]
            Traefik("Traefik v3 (Proxy)")
            Homarr("Homarr (Dashboard)")
        end
        
        subgraph MediaLXC ["media-lxc (CT 100) - 192.168.0.151"]
            Jellyfin("Jellyfin")
            Sonarr("Sonarr")
            Radarr("Radarr")
            Bazarr("Bazarr")
        end
    end

    Client -->|SSH Management| FW
    Client -->|HTTP/HTTPS Proxy| ProxyLXC
    Client -->|Media Streaming| MediaLXC
    
    FW -.->|Secures| ProxyLXC
    FW -.->|Secures| MediaLXC
```

---

## 🛠️ Tech Stack & Key Features

| Component | Technology | Purpose & Implementation Highlights |
| :--- | :--- | :--- |
| **Hypervisor** | Proxmox VE 8.x | LXC virtualization with unprivileged isolation and `nesting` enabled. |
| **Provisioning** | Terraform (`bpg/proxmox`) | Modularized resource definitions, provider-managed firewalls, and storage mapping. |
| **Config Management** | Ansible | Automated package management, Docker engine provisioning, and Compose deployment. |
| **Reverse Proxy** | Traefik v3 | Dynamic routing, SSL management, and container exposure control. |
| **Dashboard** | Homarr | Tailored interface with explicit `HOSTNAME` and `PORT` environment bindings. |
| **Media Suite** | Jellyfin + *arr Stack | Fully integrated entertainment automation pipeline (Sonarr, Radarr, Bazarr). |

---

## 🔒 Security Architecture

1. **Automated SSH Key Injection:** Terraform dynamically injects developer public keys (`~/.ssh/id_ed25519.pub`) during container initialization, completely eliminating password authentication.
2. **Stateful Proxmox Firewall:**
   * Global firewall switches enabled programmatically via `proxmox_virtual_environment_firewall_options`.
   * Strictly limited inbound access: Port `22` (SSH) is locked to the local administrative subnetwork (`192.168.0.0/24`).
   * Explicit egress restrictions blocking unauthorized internal LAN pivoting while allowing DNS (`53/UDP`) and HTTP/S (`80,443/TCP`).
3. **Resilient Container Health Checks:** Custom environment variables (`PORT=7575`, `HOSTNAME=0.0.0.0`) configured to ensure accurate Docker health status reporting.

---

## 🌐 Deployed Services Directory

### 🟢 `proxy-lxc` (IP: 192.168.0.150)
| Service | Exposed Ports | Function |
| :--- | :--- | :--- |
| **Traefik** | `80`, `443`, `8080` | Reverse Proxy & Internal Dashboard |
| **Homarr** | `7575` | Unified Homelab Portal (`healthy`) |

### 🔵 `media-lxc` (IP: 192.168.0.151)
| Service | Exposed Ports | Function |
| :--- | :--- | :--- |
| **Jellyfin** | `8096` | Media Streaming Interface |
| **Sonarr** | `8989` | Smart TV Series Downloader |
| **Radarr** | `7878` | Smart Movie Downloader |
| **Bazarr** | `6767` | Automated Subtitle Synchronization |

---

## 📁 Repository Structure

```text
homelab/
├── .gitignore                      # Prevents staging secrets, keys, and tfstate files
├── README.md                       # Infrastructure documentation
├── terraform/                      # Infrastructure as Code
│   ├── main.tf                     # Environment invocation & backend config
│   ├── variables.tf                # Environment input variables
│   ├── outputs.tf                  # Generated IP and node information
│   └── modules/
│       └── proxmox_lxc/            # Reusable LXC & Firewall terraform module
└── ansible/                        # Configuration & Deployment
    ├── inventory.ini               # Host definitions and SSH mappings
    ├── site.yml                    # Main orchestration playbook
    └── roles/                      # Provisioning roles (Docker, Proxy, Media)
```

---

## 🚀 Deployment Workflow

### 1. Prerequisites
* Proxmox VE host configured with API token or SSH access.
* Local workstation with `terraform` (>= 1.5) and `ansible` installed.
* SSH key pair generated at `~/.ssh/id_ed25519`.

### 2. Infrastructure Provisioning (Terraform)
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### 3. Application & Service Deployment (Ansible)
```bash
cd ../ansible
ansible-playbook -i inventory.ini site.yml
```

### 4. Automated Health Verification
```bash
# Verify SSH Connectivity
ansible all -i inventory.ini -m ping

# Verify Running Docker Containers & Health States
ansible all -i inventory.ini -m command -a "docker ps"
```

---

## 📜 License & Author

Distributed under the MIT License. Designed and maintained as part of a DevOps/SRE Infrastructure Portfolio.
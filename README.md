# 🏗️ Infrastructure as Code & GitOps Environment

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)]()
[![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat&logo=ansible&logoColor=white)]()
[![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=flat&logo=proxmox&logoColor=white)]()
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)]()
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white)]()
[![Status](https://img.shields.io/badge/Status-Active-success.svg)]()

Este repositorio contiene la arquitectura completa, aprovisionamiento automatizado y gestión de configuración de una infraestructura de nube privada (*Homelab*). 

El proyecto sirve como **Prueba de Concepto (PoC)** y entorno de producción personal para demostrar la aplicación de prácticas modernas de **DevOps, Site Reliability Engineering (SRE) y GitOps**.

## 🎯 Objetivos del Proyecto & Prácticas Implementadas

- **Aprovisionamiento Declarativo (IaC):** Creación de infraestructura inmutable y reproducible utilizando Terraform.
- **Gestión de Configuración Idempotente:** Estandarización de nodos y despliegue de software automatizado mediante Ansible.
- **Arquitectura Modular:** Uso de módulos de Terraform y *Roles* de Ansible para maximizar la reutilización del código.
- **Integración y Despliegue Continuo (CI/CD):** Pipelines automatizados con GitHub Actions utilizando *Self-Hosted Runners* para operar de forma segura detrás del firewall.
- **Aislamiento de Servicios:** Segmentación de cargas de trabajo en contenedores LXC (capa de SO) y Docker (capa de aplicación).

---

## 📐 Arquitectura del Sistema y Flujo GitOps

El ciclo de vida de la infraestructura está completamente automatizado y versionado en este repositorio. Cualquier cambio en la rama principal dispara el pipeline de reconciliación.

```text
 ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
 │ 1. Git (Fuente)  │      │ 2. CI/CD Pipeline│      │ 3. Hypervisor    │
 │ Modificación de  ├─────►│ GitHub Actions   ├─────►│ Proxmox VE API   │
 │ código (Push)    │      │ (Self-Hosted)    │      │                  │
 └──────────────────┘      └────────┬─────────┘      └─────────┬────────┘
                                    │                          │
                                    ▼                          ▼
 ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
 │ 6. Aplicación    │      │ 5. Configuración │      │ 4. IaC / Compute │
 │ Docker / Compose │◄─────┤ Ansible Roles    │◄─────┤ Terraform State  │
 │ (Servicios UP)   │      │ (Idempotencia)   │      │ (LXC Containers) │
 └──────────────────┘      └──────────────────┘      └──────────────────┘
```

---

## 🛠️ Stack Tecnológico

| Capa | Tecnología | Propósito |
| :--- | :--- | :--- |
| **Virtualización / Compute** | Proxmox VE | Hipervisor bare-metal y gestión de contenedores LXC. |
| **Infraestructura (IaC)** | Terraform | Definición del estado de la infraestructura y aprovisionamiento. |
| **Configuración (CaC)** | Ansible | Orquestación, hardening del SO y despliegue de dependencias. |
| **Contenedorización** | Docker & Compose | Aislamiento de aplicaciones a nivel de microservicios. |
| **CI/CD** | GitHub Actions | Automatización de flujos de trabajo (*Pipelines*). |

---

## 📁 Estructura del Repositorio

El código está estructurado siguiendo las mejores prácticas de separación de responsabilidades:

```text
├── .github/workflows/       # Definición de pipelines de CI/CD
├── ansible/                 # Playbooks y Roles (Configuration as Code)
│   ├── inventory.ini        # Inventario dinámico/estático de nodos
│   ├── site.yml             # Orquestador principal de Playbooks
│   └── roles/               
│       ├── common/          # Tareas base (Hardening, utilidades, usuarios)
│       ├── docker/          # Instalación automatizada del daemon de Docker
│       ├── media/           # Stack de aplicaciones (Carga de trabajo A)
│       ├── proxy/           # Capa de red y Reverse Proxy (Carga de trabajo B)
│       └── runner/          # Aprovisionamiento del Agente de CI/CD
├── compose/                 # Manifiestos declarativos de Docker
│   ├── media/               
│   └── proxy/               
└── terraform/               # Código de Infraestructura (HCL)
    ├── modules/proxmox_lxc/ # Módulo DRY personalizado para estandarizar LXCs
    ├── lxc_*.tf             # Definiciones de nodos específicos
    ├── providers.tf         # Configuración del provider de Telmate/bpg
    └── variables.tf         # Inyección de variables de entorno y estado
```

---

## 🤖 CI/CD Pipeline (GitHub Actions)

El despliegue está completamente automatizado. Al hacer un *push* o *merge* a la rama `main`, el archivo `main.yml` orquesta el siguiente flujo utilizando un **Self-Hosted Runner** interno:

1. **Linting & Validación:** Comprobación de sintaxis en Terraform y Ansible.
2. **Terraform Apply:** Sincronización del estado de la infraestructura en Proxmox.
3. **Ansible Provisioning:** Ejecución del playbook principal para aplicar configuraciones a los LXC y redesplegar los contenedores Docker afectados.

### Requisitos de Secrets
Para el correcto funcionamiento del pipeline, es necesario inyectar los siguientes secretos en la configuración de GitHub (`Settings > Secrets and variables`):
- `PROXMOX_API_URL`
- `PROXMOX_API_TOKEN_ID`
- `PROXMOX_API_TOKEN_SECRET`
- `SSH_PRIVATE_KEY` *(Para la conexión de Ansible a los LXC)*

---

## 🔒 Seguridad y Gestión de Secretos

Para cumplir con los estándares de seguridad empresariales, el proyecto implementa:

1. **Inyección de Secretos:** Ninguna credencial o token está hardcodeado en el código. Terraform y Ansible consumen el entorno de CI/CD o archivos locales `.env`.
2. **Principio de Menor Privilegio:** Uso de un *Self-Hosted Runner* efímero que se comunica localmente con la API de Proxmox, evitando exponer paneles de administración a internet.
3. **Segmentación de Red:** Los servicios expuestos (Proxy Inverso) se ejecutan en contenedores separados lógicamente de las cargas de trabajo internas.

---

## 🚀 Despliegue Manual / Onboarding Local

Para replicar o desarrollar sobre este entorno de manera local sin pasar por el pipeline:

### 1. Aprovisionamiento (Terraform)
```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"
```

### 2. Configuración y Orquestación (Ansible)
Una vez que el proveedor de infraestructura reporta el estado exitoso, se ejecuta la configuración:
```bash
cd ansible
ansible-playbook -i inventory.ini site.yml
```
# Wordpress Turbinado 2.0

Infrastructure as Code, instalação automatizada do WordPress e Monitoramento na AWS.

<p align="center">
  <img src="wordpressturbinado.png" alt="Arquitetura" width="800">
</p>

---

## Objetivo

Provisionar dois servidores WordPress na AWS de forma automatizada com Terraform e Ansible, com monitoramento via Prometheus e Grafana.

---

## Arquitetura de Rede

```
                          INTERNET
                              │
                    ┌─────────▼──────────┐
                    │   Internet Gateway  │
                    └─────────┬──────────┘
                              │
          ┌───────────────────▼────────────────────┐
          │         VPC PÚBLICA 172.16.0.0/16       │
          │                                          │
          │  ┌──────────────┐  ┌──────────────┐     │
          │  │ EC2           │  │ EC2           │     │
          │  │ wordpress_a   │  │ wordpress_b   │     │
          │  │ 172.16.1.x    │  │ 172.16.2.x    │     │
          │  │ (IP público)  │  │ (IP público)  │     │
          │  └──────┬───────┘  └──────┬────────┘     │
          └─────────┼────────────────-┼───────────────┘
                    │   VPC Peering   │
                    └────────┬────────┘
                             │
          ┌──────────────────▼─────────────────────┐
          │         VPC PRIVADA 10.0.0.0/16         │
          │                                          │
          │  ┌────────────────────────────────────┐  │
          │  │  Subnets Privadas (sem rota IGW)   │  │
          │  │  10.0.1.0/24  ├── RDS MySQL 8.0   │  │
          │  │  10.0.2.0/24  │   (não acessível   │  │
          │  │  10.0.3.0/24  │    pela internet)  │  │
          │  └───────────────┴───────────────────-┘  │
          │                                           │
          │  ┌─────────────────────────────────────┐  │
          │  │  Subnet NAT (10.0.0.0/24)           │  │
          │  │  NAT Gateway → Internet (saída only) │  │
          │  └─────────────────────────────────────┘  │
          └────────────────────────────────────────────┘
```

### Princípios de segurança da rede

| Camada | Acesso de entrada | Acesso de saída |
|--------|------------------|-----------------|
| EC2 (pública) | Internet (80, 443, 22) | Internet (irrestrito) |
| RDS (privada) | Apenas EC2 via Peering (3306) | Via NAT Gateway |
| VPC Peering | Rota bidirecional entre VPCs | — |

- O RDS **não tem IP público** e não é acessível pela internet
- As EC2 conectam ao RDS pelo endpoint privado via VPC Peering
- A senha do RDS fica no **AWS SSM Parameter Store** (não no código)
- As variáveis sensíveis do Ansible ficam em **Ansible Vault** (não versionado)

---

## Pré-requisitos

- Conta válida na AWS com credenciais configuradas (`aws configure`)
- Terraform instalado (>= 1.0)
- Ansible instalado (>= 2.12)
- Par de chaves SSH criado na AWS (`my-ed25519-key`) e chave privada em `~/.ssh/id_ed25519`

---

## Estrutura do Projeto

```
.
├── infraiscode-public/     # Stack Terraform — VPC pública + EC2
│   ├── ec2-instance.tf     # Instâncias EC2 WordPress (com IP público e SG)
│   ├── vpc-publica.tf      # VPC 172.16.0.0/16 + subnets públicas a/b/c
│   ├── security-group.tf   # SGs: EC2 (22,80,443,9100) e RDS e Monitor
│   ├── internet-gw.tf      # Internet Gateway + route table pública
│   ├── route.tf            # Associações subnets públicas
│   ├── subnet-dba.tf       # DB subnet group (legado)
│   └── private.tf          # Chave SSH gerada via Terraform
│
├── infraiscode-private/    # Stack Terraform — VPC privada + RDS
│   ├── vpc.tf              # VPC 10.0.0.0/16 + 3 subnets privadas + 1 subnet NAT
│   ├── network.tf          # IGW, NAT Gateway, route tables privada e pública
│   ├── peering.tf          # VPC Peering (pública ↔ privada) + rota de retorno
│   ├── rds.tf              # RDS MySQL 8.0 nas subnets privadas
│   └── variables.tf        # ID da VPC pública
│
└── ansible/                # Automação de instalação
    ├── inventory.ini        # Hosts (não versionado)
    ├── wordpress.yml        # Playbook principal WordPress
    ├── monitoramento.yml    # Playbook de monitoramento
    ├── group_vars/
    │   └── wordpressturbinado/
    │       ├── vars.yml     # Variáveis públicas (db_host, db_password via vault)
    │       └── vault.yml    # Variáveis sensíveis criptografadas (não versionado)
    └── roles/
        ├── wordpress/
        │   ├── tasks/
        │   │   ├── main.yml
        │   │   ├── install_wordpress.yml
        │   │   └── templates/
        │   │       ├── vhost.nginx.conf.j2
        │   │       └── wp-config.php.j2
        │   └── templates/
        │       ├── vhost.nginx.conf.j2
        │       └── wp-config.php.j2
        └── monitoramento/
            └── tasks/
                ├── install_prometheus.yaml
                ├── install_grafana.yaml
                ├── install_node_exported.yml
                └── install_alertmanager.yaml
```

---

## Passo 1 — Provisionar Rede Pública + EC2

```bash
cd infraiscode-public/
terraform init
terraform plan
terraform apply
```

### O que é criado

| Recurso | Descrição |
|---------|-----------|
| VPC pública | `172.16.0.0/16` |
| Subnets públicas | `172.16.1.0/24` (a), `172.16.2.0/24` (b), `172.16.3.0/24` (c) |
| Internet Gateway | Saída para internet |
| Security Group EC2 | Portas 22, 80, 443, 9100 |
| EC2 `wordpress_a` | Amazon Linux 2023, t3.large, IP público |
| EC2 `wordpress_b` | Amazon Linux 2023, t3.large, IP público |

### Obter IPs públicos das instâncias

```bash
terraform show -json | python3 -c "
import json,sys
data=json.load(sys.stdin)
for r in data.get('values',{}).get('root_module',{}).get('resources',[]):
    if r['type']=='aws_instance':
        attrs=r['values']
        print(f\"{attrs.get('tags',{}).get('Name')}: {attrs.get('public_ip')}\")
"
```

---

## Passo 2 — Provisionar Rede Privada + RDS

### Arquitetura da rede privada

```
VPC Pública (172.16.0.0/16)          VPC Privada (10.0.0.0/16)
┌─────────────────────┐              ┌──────────────────────────────┐
│  EC2 wordpress_a    │              │  subnet-nat   10.0.0.0/24    │
│  EC2 wordpress_b    │◄─ Peering ──►│  subnet-priv1 10.0.1.0/24    │
│                     │              │  subnet-priv2 10.0.2.0/24    │
└─────────────────────┘              │  subnet-priv3 10.0.3.0/24    │
                                     │  NAT Gateway (saída internet) │
                                     │  RDS MySQL 8.0               │
                                     └──────────────────────────────┘
```

### Pré-requisito: criar senha no SSM

A senha do RDS é armazenada no AWS SSM Parameter Store e **nunca fica no código**:

```bash
aws ssm put-parameter \
  --name "/wordpress/db_password" \
  --value "<SUA_SENHA_SEGURA>" \
  --type "SecureString"
```

> Regras da senha RDS: não usar `@`, `/`, `"` ou espaços.

### Aplicar

```bash
cd infraiscode-private/
terraform init
terraform plan
terraform apply
```

### O que é criado

| Recurso | Descrição |
|---------|-----------|
| VPC privada | `10.0.0.0/16` |
| Subnet NAT | `10.0.0.0/24` — subnet pública exclusiva para o NAT Gateway |
| Subnets privadas | `10.0.1.0/24` (1a), `10.0.2.0/24` (1b), `10.0.3.0/24` (1c) |
| Internet Gateway | Necessário para o NAT Gateway ter saída para a internet |
| Elastic IP | IP público fixo associado ao NAT Gateway |
| NAT Gateway | Recebe tráfego das subnets privadas e sai via IGW |
| Route table NAT | Subnet NAT → `0.0.0.0/0` via Internet Gateway |
| Route table privada | Subnets privadas → `0.0.0.0/0` via NAT Gateway |
| VPC Peering | Comunicação direta entre VPC pública e privada |
| Security Group RDS | Aceita MySQL (3306) apenas do CIDR `172.16.0.0/16` |
| RDS MySQL 8.0 | `db.t3.micro`, 20GB gp2, nas 3 subnets privadas |

### Fluxo de rede

```
Subnets privadas (RDS)
  10.0.1.0/24
  10.0.2.0/24      →  NAT Gateway (10.0.0.x)  →  Internet Gateway  →  Internet
  10.0.3.0/24             (saída apenas)             (igw-vpc-privada)

EC2 (VPC pública 172.16.x.x)  ←──  VPC Peering  ──→  RDS (VPC privada 10.0.x.x)
```

- As subnets privadas **não recebem tráfego da internet** — apenas saem pelo NAT
- O RDS é acessado pelas EC2 diretamente via **VPC Peering**, sem passar pela internet
- O NAT Gateway usa um **Elastic IP** fixo para saída

### Obter o endpoint do RDS

```bash
terraform output rds_endpoint
```

---

## Passo 3 — Configurar Inventory do Ansible

Crie o arquivo `ansible/inventory.ini` (não versionado por conter IPs e caminhos de chaves):

```ini
[wordpressturbinado]
wordpress_a ansible_host=<IP_PUBLICO_A>
wordpress_b ansible_host=<IP_PUBLICO_B>

[wordpressturbinado:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### Configurar variáveis sensíveis com .env

Copie o arquivo de exemplo e preencha com os valores reais:

```bash
cd ansible/
cp .env.example .env
```

Edite o `.env` com os dados do seu ambiente:

```yaml
db_host: "<OUTPUT_DO_TERRAFORM_rds_endpoint>"
db_name: "wordpress"
db_user: "wpuser"
db_password: "<SUA_SENHA_DO_RDS>"
```

> O arquivo `.env` está no `.gitignore` e **nunca será versionado**. O `.env.example` serve como template e pode ser commitado.

### Testar conectividade

```bash
cd ansible/
ansible -i inventory.ini wordpressturbinado -m ping
```

---

## Passo 4 — Instalar WordPress com Ansible

```bash
cd ansible/
ansible-playbook -i inventory.ini wordpress.yml
```

### O que é instalado em cada instância

| Componente | Versão |
|------------|--------|
| Nginx | latest |
| PHP | 8.1 (Amazon Linux 2023) |
| PHP-FPM | latest |
| WordPress | latest |

> O banco de dados **não é instalado nas EC2** — o WordPress aponta diretamente para o RDS na rede privada via `db_host` definido no Ansible Vault.

---

## Passo 5 — Acessar via SSH

```bash
# wordpress_a
ssh -i ~/.ssh/id_ed25519 ec2-user@<IP_PUBLICO_A>

# wordpress_b
ssh -i ~/.ssh/id_ed25519 ec2-user@<IP_PUBLICO_B>
```

---

## Passo 6 — Acessar o WordPress

Após a instalação, acesse pelo navegador:

```
http://<IP_PUBLICO_A>
http://<IP_PUBLICO_B>
```

Complete o assistente de instalação do WordPress para definir o título do site, usuário admin e senha.

---

## Passo 7 — Monitoramento (Prometheus + Grafana)

```bash
cd ansible/
ansible-playbook -i monitoramento.ini monitoramento.yml
```

Métricas coletadas via **Node Exporter** (porta 9100):
- CPU
- Memória
- Disco
- Request HTTP

---

## Segurança — Variáveis e Arquivos Sensíveis

Nenhuma senha, token ou endpoint deve existir diretamente no código. Todos os dados sensíveis são gerenciados por arquivos `.env` locais protegidos pelo `.gitignore`.

### Arquivos protegidos pelo .gitignore

| Arquivo | Motivo |
|---------|--------|
| `*.pem` / `id_ed25519*` | Chaves SSH privadas |
| `**/terraform.tfstate` | Contém IPs, senhas e IDs da infra |
| `**/providers.tf` | Credenciais do provider AWS |
| `ansible/inventory.ini` | IPs públicos das instâncias |
| `ansible/.env` | Credenciais do banco de dados |
| `vaut-server/.env` | Token do HashiCorp Vault |

### Como configurar cada .env

**Ansible** — copie e preencha com os dados reais:

```bash
cp ansible/.env.example ansible/.env
```

```yaml
# ansible/.env
db_host:     "<OUTPUT: terraform output rds_endpoint>"
db_name:     "wordpress"
db_user:     "wpuser"
db_password: "<SUA_SENHA_DO_RDS>"
```

**Vault Server** — copie e preencha:

```bash
cp vaut-server/.env.example vaut-server/.env
```

```bash
# vaut-server/.env
VAULT_DEV_ROOT_TOKEN_ID=SEU_TOKEN_AQUI
VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200
```

**RDS** — senha armazenada no AWS SSM Parameter Store (nunca no código):

```bash
aws ssm put-parameter \
  --name "/wordpress/db_password" \
  --value "<SUA_SENHA_SEGURA>" \
  --type "SecureString"
```

> Regra da senha RDS: não usar `@`, `/`, `"` ou espaços.

---

## Recursos Opcionais (*)

- RDS — banco de dados gerenciado
- Memcached — repositório de sessões
- EFS — armazenamento escalável compartilhado
- Load Balancer + Auto Scaling
- CDN/WAF (Cloudflare ou AWS WAF)

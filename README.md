# Wordpress Turbinado 2.0

Infrastructure as Code, instalação automatizada do WordPress e Monitoramento na AWS.

<p align="center">
  <img src="wordpressturbinado.png" alt="Arquitetura" width="800">
</p>

---

## Objetivo

Provisionar dois servidores WordPress na AWS de forma automatizada com Terraform e Ansible, com monitoramento via Prometheus e Grafana.

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
├── infraiscode-aws/        # Infraestrutura Terraform
│   ├── ec2-instance.tf     # Instâncias EC2 WordPress
│   ├── vpc-publica.tf      # VPC e configurações de rede
│   ├── subnet-dba.tf       # Subnets e grupos de subnets RDS
│   ├── security-group.tf   # Security groups (SSH, HTTP, HTTPS, Node Exporter)
│   ├── internet-gw.tf      # Internet Gateway
│   ├── route.tf            # Route tables
│   └── private.tf          # Chave SSH gerada via Terraform
│
└── ansible/                # Automação de instalação
    ├── inventory.ini        # Hosts (não versionado)
    ├── wordpress.yml        # Playbook principal WordPress
    ├── monitoramento.yml    # Playbook de monitoramento
    └── roles/
        ├── wordpress/
        │   └── tasks/
        │       ├── main.yml
        │       ├── install_mysql.yml
        │       ├── install_wordpress.yml
        │       └── templates/
        │           ├── vhost.nginx.conf.j2
        │           └── wp-config.php.j2
        └── monitoramento/
            └── tasks/
                ├── install_prometheus.yaml
                ├── install_grafana.yaml
                ├── install_node_exported.yml
                └── install_alertmanager.yaml
```

---

## Passo 1 — Provisionar Infraestrutura com Terraform

### Inicializar e aplicar

```bash
cd infraiscode-aws/
terraform init
terraform plan
terraform apply
```

### O que é criado

| Recurso | Descrição |
|---------|-----------|
| VPC | `172.16.0.0/16` |
| Subnets públicas | `172.16.1.0/24` (us-east-1a), `172.16.2.0/24` (us-east-1b) |
| Internet Gateway | Acesso público às instâncias |
| Security Group | Portas 22, 80, 443, 9100 liberadas |
| EC2 `wordpress_a` | Amazon Linux 2023, t3.large, subnet-a |
| EC2 `wordpress_b` | Amazon Linux 2023, t3.large, subnet-b |

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

## Passo 2 — Configurar Inventory do Ansible

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

### Testar conectividade

```bash
cd ansible/
ansible -i inventory.ini wordpressturbinado -m ping
```

---

## Passo 3 — Instalar WordPress com Ansible

```bash
cd ansible/
ansible-playbook -i inventory.ini wordpress.yml
```

### O que é instalado em cada instância

| Componente | Versão |
|------------|--------|
| MariaDB | 10.5 |
| Nginx | latest |
| PHP | 8.1 (Amazon Linux 2023) |
| WordPress | latest |

### Credenciais do banco de dados

> **Atenção:** altere as credenciais abaixo antes de usar em produção.

| Parâmetro | Valor |
|-----------|-------|
| Database | `wordpress` |
| Usuário | `wpuser` |
| Senha | `Wp@12345` |

As credenciais ficam em `roles/wordpress/tasks/install_mysql.yml` e `roles/wordpress/tasks/templates/wp-config.php.j2`.

---

## Passo 4 — Acessar via SSH

```bash
# wordpress_a
ssh -i ~/.ssh/id_ed25519 ec2-user@<IP_PUBLICO_A>

# wordpress_b
ssh -i ~/.ssh/id_ed25519 ec2-user@<IP_PUBLICO_B>
```

---

## Passo 5 — Acessar o WordPress

Após a instalação, acesse pelo navegador:

```
http://<IP_PUBLICO_A>
http://<IP_PUBLICO_B>
```

Complete o assistente de instalação do WordPress para definir o título do site, usuário admin e senha.

---

## Passo 6 — Monitoramento (Prometheus + Grafana)

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

## Informações de Segurança

Os arquivos abaixo estão no `.gitignore` e **não devem ser versionados**:

| Arquivo | Motivo |
|---------|--------|
| `*.pem` / `id_ed25519` | Chaves SSH privadas |
| `terraform.tfstate` | Contém IPs, IDs e dados sensíveis da infra |
| `ansible/inventory.ini` | Contém IPs das máquinas |
| `providers.tf` | Pode conter credenciais de provider |

---

## Recursos Opcionais (*)

- RDS — banco de dados gerenciado
- Memcached — repositório de sessões
- EFS — armazenamento escalável compartilhado
- Load Balancer + Auto Scaling
- CDN/WAF (Cloudflare ou AWS WAF)

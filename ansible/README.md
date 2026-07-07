# ansible

Provisions the akkarilab home-lab from a clean Ubuntu install to a running stack —
the automated version of the manual steps in the top-level README.

## What it does

One playbook (`playbook.yml`), five roles run in order:

| Role         | What it sets up                                                        |
|--------------|------------------------------------------------------------------------|
| `base`       | apt cache + base packages (git, curl, ca-certificates, gnupg)          |
| `docker`     | Docker engine + Compose plugin from Docker's official apt repo         |
| `repo`       | git checkout at `/srv/home-lab` (git stays the source of truth)        |
| `nginx`      | nginx + certbot, obtains the TLS cert, deploys the site config, reload |
| `monitoring` | `docker compose up -d` for prometheus / grafana / node-exporter        |

It's idempotent — safe to re-run. The cert step is skipped once the cert exists, and
`docker compose` only changes what drifted.

## Run it

From your machine (Ansible runs over SSH, nothing to install on the server but Python):

```bash
cd ansible
ansible-playbook playbook.yml            # full provision / re-converge
ansible-playbook playbook.yml --check    # dry run, change nothing
ansible-playbook playbook.yml -t nginx   # (tags not wired yet — see below)
```

Target host and SSH user live in `inventory.ini`; deployment values (domain, email,
repo URL, paths) live in `group_vars/all.yml`.

## Requirements

- Ansible on your machine (`pipx install ansible` or `apt install ansible`).
- SSH access to the box as a sudo-capable user (`bilal` in the inventory).
  Key-based auth is easiest (`ssh-copy-id bilal@192.168.2.101`); then just pass
  `-K` at runtime for the sudo password. No passwords are stored in the repo.
- The box's DNS (`akkarilab.xyz`) resolving to it, so certbot can issue a cert on a
  fresh install. On the existing box the cert is already there and that step is skipped.

## Notes / not-yet

- **Hardening** (SSH lockdown, ufw, fail2ban, unattended-upgrades) is a deliberate
  phase 2 — this pass only reproduces the current setup.
- On a truly fresh box, certbot's `options-ssl-nginx.conf` / `ssl-dhparams.pem` are
  created by the nginx plugin on first run; the deployed config references them.

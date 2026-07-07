# akkarilab home lab

Infrastructure-as-code for everything running on the home server behind **akkarilab.xyz**.
The server pulls from this repo — no scattered configs, no copy-paste drift.

## What's in here

| Folder        | What it is                                                        |
|---------------|------------------------------------------------------------------|
| `landing/`    | Static landing page at `https://akkarilab.xyz/` + neofetch panel  |
| `monitoring/` | Prometheus + Grafana + node-exporter (CPU / memory / disk / net) |
| `nginx/`      | NGINX config: serves the landing page and reverse-proxies apps    |
| `ansible/`    | Provisions a clean Ubuntu box into the full stack (IaC)           |
| `.github/`    | CI (validate configs on PRs) + CD (deploy on push to `main`)      |

Each folder has its own `README.md`.

## Services & ports

| Service       | Container         | Host port  | URL                              |
|---------------|-------------------|------------|----------------------------------|
| Landing page  | (served by nginx) | 80 / 443   | https://akkarilab.xyz/           |
| Angular app   | (host :4200)      | 4200       | https://akkarilab.xyz/angular    |
| API           | (host :3000)      | 3000       | https://akkarilab.xyz/api/       |
| Grafana       | `grafana`         | 3001       | https://akkarilab.xyz/grafana/   |
| Prometheus    | `prometheus`      | 9090       | http://<server-ip>:9090          |
| node-exporter | `node-exporter`   | (internal) | scraped by Prometheus only       |

> Server LAN IP: `192.168.2.50`. Grafana/Prometheus are reachable directly by IP on the LAN;
> the landing page + Grafana are public via NGINX on akkarilab.xyz.

## Deploy (server pulls from git)

One-time — clone to `/srv` (world-traversable, so nginx can serve straight from it):
```bash
sudo git clone https://github.com/adssib/home-lab.git /srv/home-lab
```

Monitoring stack:
```bash
cd /srv/home-lab/monitoring && sudo docker compose up -d
```

NGINX config:
```bash
sudo cp /srv/home-lab/nginx/akkarilab.conf /etc/nginx/sites-enabled/main.conf
sudo nginx -t && sudo systemctl reload nginx
```

Neofetch panel: see [`landing/README.md`](landing/README.md) — make `sysinfo.sh` runnable + add the cron.

## Update later

```bash
cd /srv/home-lab && sudo git pull
# then re-apply whatever changed (see each folder's README):
#  - monitoring: cd monitoring && sudo docker compose up -d
#  - nginx:      sudo cp nginx/akkarilab.conf /etc/nginx/sites-enabled/main.conf && sudo nginx -t && sudo systemctl reload nginx
#  - landing:    nothing — it's served live from the checkout
```

## Prerequisites

Docker + the Compose plugin, NGINX (host package), and outbound internet for image pulls.

# akkarilab home lab

Infrastructure-as-code for everything running on the home server behind **akkarilab.xyz**.
Clone this repo onto the server and every service the lab hosts is defined here — no more
config scattered across random folders.

## What's in here

| Folder        | What it is                                                        |
|---------------|------------------------------------------------------------------|
| `landing/`    | The static landing page served at `https://akkarilab.xyz/`       |
| `monitoring/` | Prometheus + Grafana + node-exporter (CPU / memory / disk / net) |
| `nginx/`      | NGINX config: serves the landing page and reverse-proxies Grafana |

Each folder has its own `README.md` with the details.

## Services & ports

| Service       | Container         | Host port  | URL                              |
|---------------|-------------------|------------|----------------------------------|
| Landing page  | (served by nginx) | 80 / 443   | https://akkarilab.xyz/           |
| Grafana       | `grafana`         | 3001       | https://akkarilab.xyz/grafana/   |
| Prometheus    | `prometheus`      | 9090       | http://<server-ip>:9090          |
| node-exporter | `node-exporter`   | (internal) | scraped by Prometheus only       |

> The server lives on the LAN at `192.168.2.50` (or `.100` once the IP is settled).
> Grafana/Prometheus are reachable directly by IP on the LAN; the landing page and Grafana
> are reachable publicly through NGINX on akkarilab.xyz.

## Prerequisites (on the server)

- Docker + the Docker Compose plugin
- NGINX (installed as a host package)
- Outbound internet (to pull the container images the first time)

## Deploy (high level)

```bash
# 1. clone (or pull) this repo on the server
git clone https://github.com/adssib/home-lab.git
cd home-lab

# 2. bring up the monitoring stack
cd monitoring && docker compose up -d && cd ..

# 3. wire up NGINX (see nginx/README.md), then reload it
sudo nginx -t && sudo systemctl reload nginx
```

See each folder's README for the step-by-step.

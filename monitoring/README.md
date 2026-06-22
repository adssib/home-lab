# Monitoring stack

Prometheus + Grafana + node-exporter. Collects and visualises the server's health:
CPU, memory, disk, filesystem, network, load.

## How it fits together

```
node-exporter  ──scraped by──>  Prometheus  ──queried by──>  Grafana
(host metrics)      :9100           :9090                       :3001
```

- **node-exporter** reads the host's `/proc`, `/sys`, `/` and exposes the metrics.
- **Prometheus** scrapes node-exporter every 15s and stores the time-series.
- **Grafana** queries Prometheus and draws the dashboards.

All three run on one Compose network, so they reach each other **by service name**
(Prometheus scrapes `node-exporter:9100`). That's why there's no `host.docker.internal`
here — on native Linux Docker that name doesn't resolve, which is the classic reason a node
target shows up as `DOWN`.

## Run it

```bash
docker compose up -d      # pull images + start prometheus, grafana, node-exporter
docker compose ps         # all three should say "Up"
```

`restart: unless-stopped` means the stack auto-starts whenever Docker starts — so after a
reboot or power-cut, everything comes back on its own.

## Verify

1. Open `http://<server-ip>:9090/targets` — the `node` job should be **UP** (green).
2. If it's DOWN: `docker compose logs prometheus` and confirm node-exporter is running.

## Grafana is auto-provisioned (no manual setup)

The datasource and dashboard are declared in `grafana/` and mounted into the container, so
Grafana configures itself on **every** startup — including after a reboot or `down -v`:

```
grafana/
├── provisioning/
│   ├── datasources/datasource.yml   # Prometheus datasource (uid: prometheus)
│   └── dashboards/provider.yml      # tells Grafana to load dashboards from a folder
└── dashboards/
    └── node-exporter-full.json      # "Node Exporter Full" (grafana.com #1860)
```

Open `http://<server-ip>:3001` (or https://akkarilab.xyz/grafana/) → the **Node Exporter
Full** dashboard is already there, wired to Prometheus. Nothing to click.

> Update the dashboard: replace `grafana/dashboards/node-exporter-full.json` (re-export from
> grafana.com #1860, then `sed 's/${ds_prometheus}/prometheus/g'`), `git pull`, and
> `docker compose up -d`. Add more dashboards by dropping more `.json` files in that folder.

## Data persistence

- **Metric history** lives in the `prometheus-data` volume — survives restarts and recreates
  (`docker compose down` / `up`), which is what lets you watch health progress over time.
- **The datasource + dashboard** come from provisioning (git), so they're rebuilt on every
  start. Even `docker compose down -v` (which wipes the volumes) brings Grafana back fully
  configured — only your Prometheus metric *history* is lost on `down -v`.

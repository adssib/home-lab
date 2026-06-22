# NGINX

Public entry point for **akkarilab.xyz**. Serves the landing page at `/` and reverse-proxies
the Angular app (`/angular`), the API (`/api/`) and Grafana (`/grafana/`). Host-package NGINX
(apt), TLS via Certbot.

`akkarilab.conf` is the **source of truth** for the live config at
`/etc/nginx/sites-enabled/main.conf`.

## Deploy / update

```bash
sudo cp /srv/home-lab/nginx/akkarilab.conf /etc/nginx/sites-enabled/main.conf
sudo nginx -t                      # MUST pass before reloading
sudo systemctl reload nginx
```

The landing page itself is served straight from the git checkout (`root /srv/home-lab/landing;`),
so updating the page is just `git pull` — only nginx *config* changes need the copy above.

> Certbot manages the `ssl_*` / `listen 443 ssl` lines. They're already in `akkarilab.conf`;
> if certbot renews and edits them, re-sync the repo so it stays the source of truth.

> ⚠️ Don't point `root` at a home dir (`/home/...`) — nginx (www-data) can't traverse it
> (mode `drwxr-x---`) so you'd get a 403. `/srv` is world-traversable, which is why we use it.

## Handy commands

```bash
sudo nginx -t                            # validate config
sudo systemctl reload nginx              # apply without dropping connections
sudo systemctl status nginx              # running?
sudo tail -f /var/log/nginx/error.log    # debug
```

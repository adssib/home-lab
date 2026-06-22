# NGINX

Public entry point for **akkarilab.xyz**. Serves the landing page at `/` and reverse-proxies
Grafana at `/grafana/`.

> Assumes NGINX is installed as a **host package** (apt), not a container — that matches this
> setup, since NGINX isn't in `docker ps` but already proxies Grafana. Confirm with:
> ```bash
> which nginx && nginx -v
> ls /etc/nginx/sites-enabled/ /etc/nginx/conf.d/ 2>/dev/null
> ```

## ⚠️ Read before you deploy

You almost certainly **already have a working server block** for akkarilab.xyz (your Grafana
proxy works today). Do **not** blindly overwrite it and risk breaking TLS or the Grafana
proxy. `akkarilab.conf` here is a **reference** — the one piece you likely need to *add* to
your existing config is the landing-page root:

```nginx
root /var/www/akkarilab;   # or point straight at the repo: /home/<user>/home-lab/landing
index index.html;

location / {
    try_files $uri $uri/ =404;
}
```

Keep your existing `/grafana/` proxy and your real certificate paths.

## Deploy the landing page

```bash
# put the page where nginx will serve it
sudo mkdir -p /var/www/akkarilab
sudo cp ../landing/index.html /var/www/akkarilab/

# test the config, THEN reload (never skip the test)
sudo nginx -t
sudo systemctl reload nginx
```

Then open https://akkarilab.xyz/ — the default nginx page should be gone.

## Handy NGINX commands

```bash
sudo nginx -t                            # check config is valid before reloading
sudo systemctl reload nginx              # apply config without dropping connections
sudo systemctl restart nginx             # full restart
sudo systemctl status nginx              # is it running?
sudo tail -f /var/log/nginx/error.log    # debug
```

## If NGINX is actually a container

Then it isn't managed here yet — say the word and we'll add it to a Compose file and mount
this config + the landing page into it. For now this assumes the host-package setup.

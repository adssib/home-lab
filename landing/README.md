# Landing page

The static page served at the root of **https://akkarilab.xyz/** — replaces the default
"Welcome to nginx!" page with link cards (Grafana, CI/CD) and a neofetch-style system panel.

## Files

- `index.html` — the whole page. Plain HTML + inline CSS/JS, **no build step, no dependencies.**
- `sysinfo.sh` — generates `sysinfo.json` (host specs) that the neofetch panel fetches.
- `sysinfo.json` — generated at runtime, **git-ignored** (never committed).

## How it's served

NGINX serves this folder straight from the git checkout — `root /srv/home-lab/landing;`
(see [`../nginx/`](../nginx/)). Updating the live page is just `git pull`; no copying.

## System-info panel (neofetch)

A static page can't read the host hardware, so `sysinfo.sh` writes the specs to `sysinfo.json`
in this folder and the page fetches it (same-origin — no Prometheus exposure, no backend).

Set it up on the server:
```bash
sudo chmod +x /srv/home-lab/landing/sysinfo.sh   # (already +x in git, but just in case)
sudo /srv/home-lab/landing/sysinfo.sh            # generate it once
cat /srv/home-lab/landing/sysinfo.json           # sanity check

# refresh every 5 min + at boot (root crontab, so it can write into /srv)
( sudo crontab -l 2>/dev/null; \
  echo "*/5 * * * * /srv/home-lab/landing/sysinfo.sh"; \
  echo "@reboot /srv/home-lab/landing/sysinfo.sh" ) | sudo crontab -
```

If `sysinfo.json` is missing or unreadable, the panel just hides itself — the rest of the
page still works.

## Editing

- Change the links: edit the `<a href="...">` tags.
- The CI/CD card is a placeholder; set its `href` and remove the `coming-soon` class when the
  service is live.
- Want RAM *type* (e.g. DDR4)? That needs `sudo dmidecode -t memory` — ask and I'll add it to
  `sysinfo.sh`.

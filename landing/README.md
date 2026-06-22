# Landing page

The static page served at the root of **https://akkarilab.xyz/** — link cards (Grafana, CI/CD)
plus a neofetch-style panel of the server's specs.

## Files

- `index.html` — the whole page. Plain HTML + inline CSS. No build step, no JS, no dependencies.

## How it's served

NGINX serves this folder straight from the git checkout — `root /srv/home-lab/landing;`
(see [`../nginx/`](../nginx/)). Update the live page with `git pull`.

## The neofetch panel

The specs (host, model, OS, kernel, CPU, GPU, memory, disk) are **hard-coded** in `index.html`.
They almost never change, so there's no script, cron, or live fetch — just edit the
`<span class="v">` values if the hardware/OS changes. Grab fresh values with `fastfetch`
(or `lscpu` / `free -h` / `uname -a`).

## Editing

- Change the links: edit the `<a href="...">` tags.
- The CI/CD card is a placeholder; set its `href` and remove the `coming-soon` class when live.

#!/usr/bin/env bash
# Generates a neofetch-style system summary as JSON next to the landing page.
# index.html fetches sysinfo.json and renders the panel. Run it on a timer (cron) so
# the specs stay fresh — see README.md. Must run as a user that can write $OUT
# (root, since the web root under /srv is root-owned).

OUT="${1:-/srv/home-lab/landing/sysinfo.json}"

host="$(hostname 2>/dev/null)"
os="$( (. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-Linux}") )"
kernel="$(uname -r 2>/dev/null)"
arch="$(uname -m 2>/dev/null)"
uptime_str="$(uptime -p 2>/dev/null | sed 's/^up //')"

cpu="$(lscpu 2>/dev/null | sed -n 's/^Model name:[[:space:]]*//p' | head -n1)"
[ -z "$cpu" ] && cpu="$(sed -n 's/^model name[[:space:]]*:[[:space:]]*//p' /proc/cpuinfo 2>/dev/null | head -n1)"
cores="$(nproc 2>/dev/null)"

mem_total_kb="$(awk '/^MemTotal/{print $2}' /proc/meminfo 2>/dev/null)"
mem_avail_kb="$(awk '/^MemAvailable/{print $2}' /proc/meminfo 2>/dev/null)"
mem_total="" ; mem_used=""
if [ -n "$mem_total_kb" ] && [ -n "$mem_avail_kb" ]; then
  mem_total="$(awk -v k="$mem_total_kb" 'BEGIN{printf "%.1f", k/1048576}')"
  mem_used="$(awk -v t="$mem_total_kb" -v a="$mem_avail_kb" 'BEGIN{printf "%.1f", (t-a)/1048576}')"
fi

disk_used="" ; disk_total="" ; disk_pct=""
read -r disk_used disk_total disk_pct < <(df -h --output=used,size,pcent / 2>/dev/null | tail -n1) || true

load="$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null)"
now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# strip backslashes and double-quotes so values stay valid JSON
san() { printf '%s' "$1" | tr -d '\\"' ; }

cat > "$OUT" <<EOF
{
  "hostname": "$(san "$host")",
  "os": "$(san "$os")",
  "kernel": "$(san "$kernel")",
  "arch": "$(san "$arch")",
  "uptime": "$(san "$uptime_str")",
  "cpu": "$(san "$cpu")",
  "cores": "$(san "$cores")",
  "mem_used_gib": "$(san "$mem_used")",
  "mem_total_gib": "$(san "$mem_total")",
  "disk_used": "$(san "$disk_used")",
  "disk_total": "$(san "$disk_total")",
  "disk_pct": "$(san "$disk_pct")",
  "load": "$(san "$load")",
  "generated_at": "$now"
}
EOF

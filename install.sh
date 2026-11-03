#!/bin/bash
# ============================================================
#  BotVPN NEXUSDEV — AUTO INSTALLER (1 command)
#  Jalankan sebagai root di VPS Linux x86_64.
#  Butuh env GH_TOKEN = token GitHub (repo private).
# ============================================================
set -u

GREEN='\033[1;32m'; YELLOW='\033[1;33m'; RED='\033[1;31m'; NE='\033[0m'
logo() {
  echo -e "${GREEN}╔═════════════════════════════════════╗${NE}"
  echo -e "${GREEN}║     B O T V P N  •  N E X U S D E V  ║${NE}" | head -1
  echo -e "${GREEN}╚═════════════════════════════════════╝${NE}"
}

[ $EUID -ne 0 ] && { echo -e "${RED}Jalankan sebagai root!${NE}"; exit 1; }
logo
BOTDIR="/root/BotVPN"

# ---------- 1. ambil kode repo ----------
if [ -z "${GH_TOKEN:-}" ]; then
  echo -e "${RED}Env GH_TOKEN kosong. Export dulu:${NE}"
  echo    '  export GH_TOKEN="token github-mu"'
  exit 1
fi
echo -e "${YELLOW}[1/6] Mengunduh kode BotVPN...${NE}"
rm -rf "$BOTDIR" && mkdir -p "$BOTDIR"
curl -sL -H "Authorization: token ${GH_TOKEN}" \
  "https://api.github.com/repos/nexusdevbot/BotVPN/tarball/main" \
  | tar xz --strip-components=1 -C "$BOTDIR"
[ -f "$BOTDIR/app.js" ] || { echo -e "${RED}Gagal unduh. Cek GH_TOKEN.${NE}"; exit 1; }

# ---------- 2. node 20 ----------
echo -e "${YELLOW}[2/6] Menyiapkan Node.js...${NE}"
NODE=; [ -x /opt/node20/bin/node ] && NODE=yes
command -v node >/dev/null 2>&1 && node -v | grep -q "v20" && NODE=yes
if [ -z "$NODE" ]; then
  curl -sL https://nodejs.org/dist/v20.18.0/node-v20.18.0-linux-x64.tar.xz -o /tmp/n.tar.xz
  mkdir -p /opt && tar -xf /tmp/n.tar.xz -C /opt && mv /opt/node-v20.18.0-linux-x64 /opt/node20
fi
/opt/node20/bin/node -v || { echo -e "${RED}Node gagal!${NE}"; exit 1; }
export PATH=/opt/node20/bin:$PATH

# ---------- 3. npm install ----------
echo -e "${YELLOW}[3/6] Menginstall dependensi (npm)...${NE}"
cd "$BOTDIR" && npm install --registry=https://registry.npmjs.org --no-audit --no-fund >/dev/null 2>&1
[ -d node_modules/telegraf ] || { echo -e "${RED}npm install gagal!${NE}"; exit 1; }

# ---------- 4. config ----------
echo -e "${YELLOW}[4/6] Membuat .vars.json...${NE}"
if [ ! -f .vars.json ] || grep -q "ISI_TOKEN" .vars.json 2>/dev/null; then
  if [ -n "${BOT_TOKEN:-}" ] && [ -n "${ADMIN_ID:-}" ] && [ -n "${PAY_KEY:-}" ]; then
    cat > .vars.json <<EOF
{
  "BOT_TOKEN": "${BOT_TOKEN}",
  "USER_ID": "${ADMIN_ID}",
  "NAMA_STORE": "${NAMA_STORE:-TOKO VPN MURAH}",
  "PORT": "${PORT:-50123}",
  "PAYMENT_API": "${PAYMENT_API:-https://payotomatis.app/api}",
  "PAYMENT_KEY": "${PAY_KEY}"
}
EOF
  else
    read -rp "Token bot (dari @BotFather): " BT
    read -rp "ID Telegram admin: " AI
    read -rp "Key payotomatis: " PK
    read -rp "Nama toko [TOKO VPN MURAH]: " NS
    cat > .vars.json <<EOF
{
  "BOT_TOKEN": "${BT}",
  "USER_ID": "${AI}",
  "NAMA_STORE": "${NS:-TOKO VPN MURAH}",
  "PORT": "50123",
  "PAYMENT_API": "https://payotomatis.app/api",
  "PAYMENT_KEY": "${PK}"
}
EOF
  fi
fi
chmod 600 .vars.json

# ---------- 5. watchdog loop ----------
echo -e "${YELLOW}[5/6] Memasang penjaga proses...${NE}"
mkdir -p logs
cat > "$BOTDIR/run.sh" <<'EOF'
#!/bin/bash
export PATH=/opt/node20/bin:/usr/bin:/bin
cd /root/BotVPN
exec node app.js
EOF
chmod +x run.sh
cat > "$BOTDIR/keep.sh" <<'EOF'
#!/bin/bash
pgrep -f "[n]ode /root/BotVPN/app.js" >/dev/null || {
  cd /root/BotVPN
  setsid bash run.sh >> logs/bot.log 2>&1 < /dev/null &
}
EOF
chmod +x keep.sh
# cron kalau ada; kalau gak ada -> loop rapat
if command -v crontab >/dev/null 2>&1; then
  (crontab -l 2>/dev/null | grep -v BotVPN/keep.sh; echo "* * * * * /root/BotVPN/keep.sh") | crontab -
else
  pgrep -f "BotVPN/loop.sh" >/dev/null || setsid bash -c 'while true; do /root/BotVPN/keep.sh; sleep 30; done' >/dev/null 2>&1 &
fi

# ---------- 6. start ----------
echo -e "${YELLOW}[6/6] Menyalakan bot...${NE}"
bash keep.sh; sleep 6
if pgrep -f "[n]ode /root/BotVPN/app.js" >/dev/null; then
  echo -e "${GREEN}✅ BOT NYALA! Log: /root/BotVPN/logs/bot.log${NE}"
  echo -e "${GREEN}   Tes: buka bot lu di Telegram → /start${NE}"
else
  echo -e "${RED}❌ Bot gagal nyala. Cek log:${NE} tail -30 /root/BotVPN/logs/bot.log"
fi

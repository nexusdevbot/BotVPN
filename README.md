# 🤖 BotVPN — NEXUSDEV

Bot jualan VPN **serba otomatis** (SSH / VMess / VLess / Trojan / Shadowsocks) + saldo QRIS.
Base FighterTunnel yang sudah dirombak total sesuai standar NEXUSDEV.

---

## ⚡ Fitur (upgrade dari versi FT)

| Fitur | Detail |
|---|---|
| 🎨 Tombol inline BERWARNA | Bot API `style` — hijau (beli/bayar/ya), merah (hapus/batal), biru (aksi umum). Otomatis semua keyboard via interceptor `callApi` |
| ✏️ Anti-spam 1 pesan | Semua menu & prompt di-**edit** di satu pesan (`editOrSend`, 200+ titik) |
| 🧹 Ketikan auto-hapus | Input username/password/masa aktif/nominal langsung lenyap begitu dipakai |
| 💸 Topup QRIS | **payotomatis.app** — nominal di-**KETIK** langsung (tanpa keyboard karangan) |
| ⏳ QRIS 5 menit | Auto-expire 5 menit + foto QRIS auto-hapus + notif ke user |
| 🔄 Poller saldo | Cek status pembayaran tiap 15 detik — saldo masuk otomatis |
| 👋 Welcome NEXUSDEV | ASCII art + blockquote `❱ •¯•» ❞` ala bot utama |
| 🌐 API portless | `http://<domain>/api/createssh?...` — tanpa port :5888 |
| 🖥️ Watchdog | `keep.sh` + cron — bot idup lagi sendiri ≤30 detik kalau mati |

---

## 🚀 AUTO INSTALLER (1 command)

**Syarat:** token GitHub (repo private) + sebagai **root**.

```bash
export GH_TOKEN="token_github_mu"
BOT_TOKEN="9277...:AAG..." ADMIN_ID="123456789" PAY_KEY="key_payotomatis" \
  bash <(curl -sL -H "Authorization: token $GH_TOKEN" \
        https://raw.githubusercontent.com/nexusdevbot/BotVPN/main/install.sh)
```

Kalau env-nya tidak diisi, installer akan **bertanya interaktif** (token bot, ID admin, key payotomatis).

Installer otomatis: unduh repo → pasang Node.js 20 → npm install → buat `.vars.json` → pasang watchdog → nyalakan bot. Log: `/root/BotVPN/logs/bot.log`.

---

## 🔧 INSTALL MANUAL

```bash
git clone https://github.com/nexusdevbot/BotVPN.git /root/BotVPN
cd /root/BotVPN
npm install
nano .vars.json   # isi token bot, ID admin, key payotomatis
node app.js
```

### `.vars.json`

```json
{
  "BOT_TOKEN": "token dari @BotFather",
  "USER_ID": "ID Telegram admin",
  "NAMA_STORE": "TOKO VPN MURAH",
  "PORT": "50123",
  "PAYMENT_API": "https://payotomatis.app/api",
  "PAYMENT_KEY": "key payotomatis (merchant bot)"
}
```

### Daftar server (panel admin di bot)

Sekarang input **bebas ketik** (tanpa keyboard karangan):
- `Tambah Server` → ketik domain, auth, nama, quota, limit IP, batas create, harga satu-satu
- `Edit Domain / Auth / Nama` → klik → **langsung ketik** nilai barunya

---

## 🗄️ Arsitektur & alur jualan

```
Pembeli → bot (Telegram, long-poll telegraf)
         ↓ HTTP
      http://<domain-server>/api/createssh?user=&password=&exp=&iplimit=&auth=<key-lisensi>
         ↓
      SC NEXUSTUNELL (nginx :80/443 → proxy /api/ → 127.0.0.1:5888 api.js)
         ↓
      Akun dibuat → detail dikirim ke pembeli (pesan baru, bisa di-save)
```

**Bareng request:** `auth` = key lisensi VPS itu sendiri (nilai `/root/.key`) — sudah IP-gated oleh sistem lisensi `lic.tokonexus.dev`.

---

## 📋 Checklist tambah server baru di bot

1. VPS SC sudah ter-install (installer NEXUSTUNELL) & **`bot client`** sudah dijalankan
2. Nginx SC punya `location /api/` (bawaan installer) & service `api` jalan
3. Di bot: **Admin → Tambah Server** → isi domain + auth (key lisensi) + dst.
4. Test beli 1 akun — harus sukses

---

## 🛠️ Pemeliharaan

| Tugas | Perintah |
|---|---|
| Lihat log | `tail -f /root/BotVPN/logs/bot.log` |
| Restart bot | `pkill -f "node /root/BotVPN/app.js"` (watchdog nyalain lagi ≤30 dtk) |
| Cek proses | `pgrep -af "BotVPN/app.js"` |
| Update kode | `cd /root/BotVPN && git pull` lalu restart |

---

**NEXUSDEV © 2026** — dipelihara bareng Bos 🤝

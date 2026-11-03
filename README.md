# BotVPN — NEXUSDEV (FT Base + Full Upgrade)

Bot jualan VPN serba otomatis (SSH/VMess/VLess/Trojan/Shadowsocks) + saldo QRIS.

## Upgrade gila-gilaan dari versi FT:
- ✅ Tombol INLINE BERWARNA (Bot API `style`: hijau/merah/biru — otomatis semua keyboard)
- ✅ ANTI-SPAM: 1 pesan yg di-edit edit (editOrSend 200+ titik) + ketikan user auto-hapus
- ✅ Topup QRIS payotomatis.app — nominal di-KETIK langsung (tanpa keyboard karangan)
- ✅ QRIS auto-expire 5 menit + foto QR-nya auto-hapus + notif
- ✅ Welcome ala NEXUSDEV (ASCII + blockquote)
- ✅ API SC portless: http://<domain>/api/createssh?... (tanpa :5888)
- ✅ Poller saldo 15 detik (callback-full, anti selip)

## Setup
1. `npm install`
2. Isi `.vars.json` (token bot, id admin, key payotomatis)
3. Jalankan: `node app.js` (atau `keep.sh` + cron)

## Catatan
- Jalankan `bot client` dulu di VPS SC + pastikan `/etc/nginx` punya `location /api/` (bawaan installer).
- Auth server = key lisensi VPS tsb (/root/.key).

# VLESS + XTLS Reality Server with Docker Compose

[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://hub.docker.com/r/teddysun/xray)
[![Xray-core](https://img.shields.io/badge/Xray--core-latest-orange.svg)](https://github.com/XTLS/Xray-core)
[![GitHub stars](https://img.shields.io/github/stars/mikhailde/xray-vless-reality?style=social)](https://github.com/mikhailde/xray-vless-reality)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> ⭐ **If this project saved your time, please consider giving it a Star! It helps more people find this repository.**

A clean, lightweight configuration for deploying a **VLESS + XTLS Reality** proxy server based on Xray-core with Docker Compose. Designed to bypass Deep Packet Inspection (DPI) and ensure high stability on restricted networks.

---

## Requirements

* A Linux VPS (Ubuntu, Debian, CentOS, etc.) with a public IPv4.
* Docker and Docker Compose installed.
* **Port 443 (TCP)** opened in your firewall / cloud security groups.

---

## Quick Setup (1-Command)

Run the command below. The script generates credentials, configures Xray, starts the container, and **prints your ready-to-use client link & QR code**:

```bash
git clone https://github.com/mikhailde/xray-vless-reality.git && cd xray-vless-reality && chmod +x setup.sh && ./setup.sh
```

> [!TIP]
> Need to view your connection link or QR code again later? Just run `./setup.sh` anytime.

<details>
<summary><b>Manual Setup (Alternative)</b></summary>

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mikhailde/xray-vless-reality.git
   cd xray-vless-reality
   ```

2. **Generate credentials:**
   ```bash
   cat /proc/sys/kernel/random/uuid
   docker run --rm teddysun/xray:latest xray x25519
   openssl rand -hex 4
   ```

3. **Configure `xray_config.json`:**
   * Replace `YOUR_UUID_HERE` with your generated UUID.
   * Replace `YOUR_REALITY_PRIVATE_KEY_HERE` with your Private Key.
   * In `shortIds`, set your Short ID (e.g. `["b5383491"]`) or leave `[""]`.

4. **Start the container:**
   ```bash
   docker compose up -d
   ```
</details>

---

## Client Setup

### 1. Supported Clients
* **Android:** [v2rayNG](https://github.com/2dust/v2rayNG), [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid)
* **iOS:** Shadowrocket, Streisand, FoXray, Stash
* **Desktop:** [v2rayN](https://github.com/2dust/v2rayN), [Hiddify](https://github.com/hiddify/hiddify-app), Sing-box

### 2. How to Connect
* **Automated:** Scan the terminal QR code or import the `vless://` link from your clipboard.
* **Manual Parameters:**
  `Protocol: VLESS` | `Port: 443` | `Flow: xtls-rprx-vision` | `Security: reality` | `Network: tcp` | `SNI: www.microsoft.com` | `Fingerprint: chrome` | `Encryption: none`

---

## Security Notes

* **Never commit your generated `xray_config.json` with real private keys to a public repository!**
* If you fork this repo, run `git update-index --assume-unchanged xray_config.json` to prevent accidental credential commits.
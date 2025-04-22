# VLESS + XTLS Reality Server with Docker Compose

This repository contains configuration files for quickly setting up a proxy server using VLESS + XTLS Reality based on Xray-core, managed via Docker Compose. This configuration is designed to bypass complex DPI (Deep Packet Inspection) blocks and ensure a stable connection, especially on mobile operator networks.

## Technology Stack

*   **Protocol:** VLESS
*   **TLS Obfuscation:** XTLS Reality
*   **Core:** Xray-core (using the a href="https://hub.docker.com/r/teddysun/xray" target="_blank">teddysun/xray/a> Docker image)
*   **Deployment:** Docker & Docker Compose

## Requirements

*   A VPS (Virtual Private Server) with a public IP address running Linux (e.g., Ubuntu).
*   Docker and Docker Compose installed on the server. (See official Docker documentation)
*   Ability to connect to the server via SSH.

## Server Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/mikhailde/xray-vless-reality.git
    cd xray-vless-reality
    ```

2.  **Generate a UUID:**
    ```bash
    uuidgen
    ```
    Copy and save the generated UUID.

3.  **Generate XTLS Reality keys:**
    ```bash
    docker run --rm teddysun/xray:latest xray x25519
    ```
    Copy and save the **Private key** and **Public key**. **Never share your private key!**

4.  **(Optional) Generate a Short ID:**
    ```bash
    openssl rand -hex 8
    ```
    You can generate one or more Short IDs or use an empty string `""`.

5.  **Configure `xray_config.json`:**
    *   Open the `xray_config.json` file.
    *   Replace `"YOUR_UUID_HERE"` with your generated UUID.
    *   Replace `"YOUR_REALITY_PRIVATE_KEY_HERE"` with your generated **private** Reality key.
    *   In the `"shortIds"` section, replace `"YOUR_SHORT_ID_HERE"` with your generated Short ID (or leave `""`).
    *   Ensure `dest` and `serverNames` point to the desired target website (e.g., `www.microsoft.com:443` and `["www.microsoft.com", "microsoft.com"]`). This site must be accessible from your server.

6.  **Start the container:**
    ```bash
    docker compose up -d
    ```

7.  **Check the status:**
    ```bash
    docker compose ps
    # Should show the xray service with status 'Up'
    docker compose logs xray
    # Ensure there are no startup errors
    ```

## Client Setup

Use a client application that supports **VLESS** and **XTLS Reality** (e.g., v2rayNG, NekoBox, SagerNet, v2rayN, NekoRay, Shadowrocket, Stash, Quantumult X).

**Parameters:**

*   **Protocol/Type:** VLESS
*   **Address/Server:** Your server's IP address or domain name
*   **Port:** 443
*   **UUID:** YOUR_UUID_HERE (The one you generated and put in `xray_config.json`)
*   **Flow:** `xtls-rprx-vision`
*   **Encryption:** `none`
*   **Network/Transport:** `tcp`
*   **Security/Security Type:** `reality`
*   **SNI/Server Name:** `www.microsoft.com` (or the target site from `serverNames` in `xray_config.json`)
*   **Fingerprint:** `chrome` (or `firefox`)
*   **Public Key:** YOUR_REALITY_PUBLIC_KEY_HERE (The public key you generated)
*   **Short ID:** YOUR_SHORT_ID_HERE (The one you configured in `xray_config.json` and want to use)

## Important Security Note

*   **Never commit or publish your real Private Reality Key or UUID to public repositories!** Use placeholders in the configuration as shown in this example.
*   Keep your actual keys and UUID stored securely.

# Shadowsocks + v2ray-plugin (WS+TLS) via Caddy (Docker Compose)

Эта конфигурация позволяет быстро развернуть Shadowsocks сервер с использованием v2ray-plugin для маскировки трафика под WebSocket (WS) + TLS. В качестве веб-сервера для обработки TLS и проксирования используется Caddy. Все компоненты запускаются в Docker контейнерах с помощью Docker Compose.

## Пререквизиты

*   Сервер (VPS) с установленным **Docker** и **Docker Compose v2**.
*   **Доменное имя**, DNS A-запись которого указывает на IP-адрес вашего сервера.
*   Открытые порты **80** (для получения сертификата Let's Encrypt) и **443** (для HTTPS/WSS трафика) на вашем сервере.

## Конфигурация

1.  **Клонируйте репозиторий:**
    ```bash
    git clone https://github.com/mikhailde/shadowsocks-caddy-docker.git
    cd shadowsocks-caddy-docker
    ```

2.  **(При необходимости) Обновите бинарный файл v2ray-plugin:**
    Текущий файл `v2ray-plugin_exec` включен в репозиторий для удобства. Если вы хотите использовать другую версию, скачайте нужный релиз с [репозитория v2ray-plugin](https://github.com/shadowsocks/v2ray-plugin/releases), извлеките исполняемый файл `v2ray-plugin_linux_amd64` (или для вашей архитектуры) и переименуйте его в `v2ray-plugin_exec` в этой директории. Не забудьте сделать его исполняемым (`chmod +x v2ray-plugin_exec`).

3.  **Создайте и настройте `.env` файл:**
    Скопируйте шаблон:
    ```bash
    cp .env.example .env
    ```
    Отредактируйте `.env`:
    ```bash
    nano .env
    ```
    *   Установите **надежный пароль** для `SS_PASSWORD`.
    *   Установите **секретный путь** для `SS_WS_PATH` (например, `/a7b3c9d1e5f` или `/api/v2/streams/live`).

4.  **Отредактируйте `Caddyfile`:**
    ```bash
    nano Caddyfile
    ```
    *   Замените `your.domain.com` на **ваше реальное доменное имя**.
    *   Замените `your-email@example.com` на **ваш реальный email** (для уведомлений Let's Encrypt).
    *   Замените `/your-secret-path` на **тот же секретный путь**, который вы указали в `SS_WS_PATH` в файле `.env`.

## Запуск

Находясь в директории с файлами `docker-compose.yml`, `Caddyfile` и `.env`, выполните:
```bash
sudo docker compose up -d
```
Caddy автоматически получит TLS сертификат для вашего домена.

## Остановка

```bash
sudo docker compose down
```
Для удаления томов (данных Caddy, включая сертификаты) используйте:
```bash
sudo docker compose down -v
```

## Настройка клиента

Используйте следующие параметры в вашем клиенте Shadowsocks с поддержкой v2ray-plugin:

*   **Адрес/Сервер:** `ваше.доменное.имя`
*   **Порт:** `443`
*   **Пароль:** Ваш пароль из `.env` (`SS_PASSWORD`)
*   **Метод шифрования:** `AES-256-GCM` (или тот, что указан в `docker-compose.yml`)
*   **Плагин:** `v2ray-plugin`
*   **Опции плагина:**
    *   Режим: `websocket`
    *   TLS: Включено
    *   Хост/SNI: `ваше.доменное.имя`
    *   Путь: Ваш секретный путь из `.env` (`SS_WS_PATH`)

## Лицензия

Конфигурационные файлы предоставляются под лицензией MIT. Сам Shadowsocks, Caddy, v2ray-plugin имеют свои лицензии.

# 🦑 Squid Proxy with Flask User Management

This project sets up a Squid transparent proxy server inside Docker containers, managed by a Flask-based API. The project supports batch provisioning of proxies with unique IPs and ports.

## 🚀 Features

- Squid 3-based HTTP proxy with optional authentication
- RESTful Flask API for user and configuration management
- `.htpasswd`-based credential handling
- Batch deployment of multiple proxies with unique IPs
- Persistent volume for logs and cache

---

## 📦 Prerequisites

- Docker & Docker Compose
- Linux Shell (e.g. Bash)
- External Docker network (e.g. `ipvl2net`) created with static IP pool
---

```bash
  docker network create -d ipvlan \
   --subnet=103.66.177.240/28 \
   --gateway=103.66.177.241 \
   -o parent=enp0s31f6 \
   ipvl2net
```



## 🛠️ Build & Run

```bash
  chmod +x docker-squid-up.sh
  ./docker-squid-up.sh

```
## ⛔ Stop & Remove Container

```bash
  chmod +x docker-squid-down.sh
  ./docker-squid-down.sh
```

## 🗂️ Project Structure
```bash

├── templates/           
│   ├── index.html            
├── .htpasswd                  # Auth credentials (auto-generated)
├── docker-compose.yml         # Docker Compose config
├── docker-squid-up.sh         # Startup script
├── docker-squid-down.sh       # Teardown script
├── Dockerfile                 # Docker image definition
├── entrypoint.sh              # Entrypoint script for container setup
├── README.md                  # This file
├── squid_api.py               # Flask API

```

## 📬 Contact
## Developed with ❤️ by Blank System
Website: https://blanksystembd.com

Email: mdrakibhasanbd369@gmail.com


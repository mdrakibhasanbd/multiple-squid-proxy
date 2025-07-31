# 🦑 Squid Proxy with Flask User Management

This project sets up a Squid transparent proxy server inside Docker containers, managed by a Flask-based API. The
project supports batch provisioning of proxies with unique IPs and ports.

## 🚀 Features

- Squid 3-based HTTP proxy with optional authentication
- IPv4 and IPv6 support
- RESTful Flask API for user and configuration management
- `.htpasswd`-based credential handling
- Batch deployment of multiple proxies with unique IPs
- Persistent volume for logs and cache

---

## 📦 Prerequisites

- Docker & Docker Compose
- Linux Shell (e.g. Bash)
- External Docker network (e.g. `ipvl2net-ipv4, ipvl2net-ipv6`) created with static IP pool

---

```bash
  docker network create -d ipvlan \
   --subnet=103.66.177.240/28 \
   --gateway=103.66.177.241 \
   -o parent=enp0s3 \
   ipvl2net-ipv4
   
  docker network create \
    --driver ipvlan \
    --subnet=2406:59c0:5::/64 \
    --gateway=2406:59c0:5::1 \
    -o parent=enp0s3 \
    --ipv6 \
    ipvl2net-ipv6
```

## 🛠️ Build & Run

```bash
  chmod +x ipv4-docker-squid-up.sh
  chmod +x ipv6-docker-squid-up.sh
  
  ./ipv4-docker-squid-up.sh
  ./ipv6-docker-squid-up.sh

```

## ⛔ Stop & Remove Container

```bash
  chmod +x ipv4-docker-squid-down.sh
  chmod +x ipv6-docker-squid-down.sh
  
  ./ipv4-docker-squid-down.sh
  ./ipv6-docker-squid-down.sh
```

## 🔧 Squid Proxy Run Command

```bash

   squid -N -d 1

```

## 🗂️ Project Structure

```bash

├── templates/           
│   ├── index.html            
├── .htpasswd                  # Auth credentials (auto-generated)
├── docker-compose.yml         # Docker Compose config
├── ipv6-docker-squid-up.sh         # Startup script
├── ipv6-docker-squid-down.sh       # Teardown script
├── Dockerfile                 # Docker image definition
├── entrypoint.sh              # Entrypoint script for container setup
├── README.md                  # This file
├── squid_api.py               # Flask API

```

## 📬 Contact

## Developed with ❤️ by Blank System

Website: https://blanksystembd.com

Email: mdrakibhasanbd369@gmail.com


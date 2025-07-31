#!/bin/bash
set -e

# Create log directory for Squid
mkdir -p /var/log/squid
chmod -R 755 /var/log/squid
chown -R proxy:proxy /var/log/squid

# Setup IPv6 Google DNS resolvers
echo "Setting IPv6 DNS servers..."
echo "nameserver 2001:4860:4860::8888" > /etc/resolv.conf
echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf

# Set default port from environment or fallback
SQUID_PORT=${SQUID_PORT:-3128}
SQUID_USER=${SQUID_USER}
SQUID_PASS=${SQUID_PASS}

echo "Loading Squid configuration..."
if [ -n "${SQUID_USER}" ] && [ -n "${SQUID_PASS}" ]; then
  if [ ! -f /etc/squid/.htpasswd ]; then
    echo "Initializing .htpasswd..."
    mkdir -p /etc/squid
    htpasswd -c -b /etc/squid/.htpasswd "${SQUID_USER}" "${SQUID_PASS}"
  else
    echo "Appending/updating user in .htpasswd..."
    htpasswd -b /etc/squid/.htpasswd "${SQUID_USER}" "${SQUID_PASS}"
  fi
fi

# Write full IPv6-only squid.conf
echo "Creating full IPv6-only squid.conf..."
cat > /etc/squid/squid.conf <<EOF
# SQUID PROXY SERVER CONFIGURATION WITH BASIC AUTHENTICATION

# Network Configuration
http_port [::]:${SQUID_PORT} # HTTP Port (IPv6 only)

# ACL Definitions
acl SSL_ports port 443
acl Safe_ports port 80          # HTTP
acl Safe_ports port 21          # FTP
acl Safe_ports port 443         # HTTPS
acl Safe_ports port 1025-65535  # Unprivileged ports
acl CONNECT method CONNECT

# Basic Authentication Setup
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/.htpasswd
auth_param basic realm "Squid Proxy - Authentication Required"
auth_param basic credentialsttl 24 hours
auth_param basic casesensitive off
auth_param basic children 5

# Access Control Rules
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

# Require authentication for all other requests
acl authenticated proxy_auth REQUIRED
http_access allow authenticated

# Final deny rule
http_access deny all

# Logging
access_log daemon:/var/log/squid/access.log squid
cache_log /var/log/squid/cache.log
cache_store_log /var/log/squid/store.log

EOF

# Handle extra arguments passed to the script
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# Start Flask API in background
echo "Starting Flask API..."
/opt/venv/bin/python /app/squid_api.py &

# Start Squid with the config
if [[ -z ${1} ]]; then
  echo "Starting Squid on IPv6 port ${SQUID_PORT}..."
  exec $(which squid) -f /etc/squid/squid.conf -NYCd 1 ${EXTRA_ARGS}
else
  exec "$@"
fi

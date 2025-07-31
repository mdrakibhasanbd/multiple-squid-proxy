#!/bin/bash
set -e

mkdir -p /var/log/squid
chmod -R 755 /var/log/squid
chown -R proxy:proxy /var/log/squid

SQUID_USER=${SQUID_USER}
SQUID_PASS=${SQUID_PASS}
SQUID_PORT=${SQUID_PORT:-3128}   # Default port 3128 if not set

# Change or add http_port in squid.conf
if grep -q '^http_port' /etc/squid/squid.conf; then
  sed -i "s/^http_port .*/http_port ${SQUID_PORT}/" /etc/squid/squid.conf
else
  echo "http_port ${SQUID_PORT}" >> /etc/squid/squid.conf
fi

if [ -n "${SQUID_USER}" ] && [ -n "${SQUID_PASS}" ]; then
  if [ ! -s /etc/squid/.htpasswd ]; then
    echo "Initializing .htpasswd..."
    htpasswd -c -i -b /etc/squid/.htpasswd "${SQUID_USER}" "${SQUID_PASS}"
  else
    echo "Appending/updating user in .htpasswd..."
    htpasswd -i -b /etc/squid/.htpasswd "${SQUID_USER}" "${SQUID_PASS}"
  fi

  echo "Injecting authentication config into squid.conf..."
  sed -i "1 i\\
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/.htpasswd\\
auth_param basic children 5\\
auth_param basic realm Squid proxy-caching web server\\
auth_param basic credentialsttl 2 hours\\
auth_param basic casesensitive off" /etc/squid/squid.conf

  sed -i "/http_access deny all/ i\\
acl ncsa_users proxy_auth REQUIRED\\
http_access allow ncsa_users" /etc/squid/squid.conf
else
  echo "No authentication configured. Allowing open access..."
  sed -i "/http_access deny all/ i http_access allow all" /etc/squid/squid.conf
  sed -i "/http_access deny all/d" /etc/squid/squid.conf
  sed -i "/http_access deny manager/d" /etc/squid/squid.conf
fi

# Allow arguments to be passed to squid
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

# Default behavior: launch squid
if [[ -z ${1} ]]; then
  echo "Starting squid on port ${SQUID_PORT}..."
  exec $(which squid) -f /etc/squid/squid.conf -NYCd 1 ${EXTRA_ARGS}
else
  exec "$@"
fi

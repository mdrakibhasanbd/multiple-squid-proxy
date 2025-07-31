#!/bin/bash

# Define IP range and base path
START=243
END=244
BASE_IMAGE_DIR="ipv4"
NETWORK_NAME="ipvl2net-ipv4"

# Make sure the base directory exists
if [ ! -d "$BASE_IMAGE_DIR" ]; then
  echo "Base directory '$BASE_IMAGE_DIR' not found!"
  exit 1
fi

for IP in $(seq $START $END); do
  DIR="squid-proxy-${BASE_IMAGE_DIR}-${IP}"
  IPV4_ADDR="103.66.177.${IP}"

  echo "Creating container for IP: ${IPV4_ADDR}..."

  # Copy and enter directory
  cp -r "$BASE_IMAGE_DIR" "$DIR"
  cd "$DIR" || exit 1

  # Remove old docker-compose.yml if exists
  rm -f docker-compose.yml

  # Create new docker-compose.yml
  cat <<EOF > docker-compose.yml
version: '3'

services:
  ${DIR}:
    build: .
    dns:
      - 8.8.8.8
      - 8.8.4.4
    environment:
      - SQUID_USER=proxy
      - SQUID_PASS=secret123
      - SQUID_PORT=8090
    hostname: ${DIR}
    container_name: ${DIR}
    restart: always
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "50"
        tag: squid-proxy
    volumes:
      - ./var/cache:/var/spool/squid
      - ./var/log:/var/log/squid
      - .htpasswd:/etc/squid/.htpasswd:rw
    ports:
      - "8080:8080"    # Host 8080 to Container 8080 (SQUID_PORT)
      - "6000:5000"    # Host 6000 to Container 5000 (Flask API)
    networks:
      ${NETWORK_NAME}:
        ipv4_address: ${IPV4_ADDR}

networks:
  ${NETWORK_NAME}:
    external: true
EOF

  chmod 666 .htpasswd  # make it writable by Docker
  echo "✔️ Permissions updated for .htpasswd"

  # Build and run
  docker-compose up -d --build --force-recreate

  cd .. || exit 1
done

echo "✅ All containers from ${START} to ${END} created and running."
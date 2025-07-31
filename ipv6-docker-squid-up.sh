  #!/bin/bash

# Define IP range and base path
START=243
END=244
BASE_IMAGE_DIR="ipv6"
NETWORK_NAME="ipvl2net-ipv6"

# Make sure the base directory exists
if [ ! -d "$BASE_IMAGE_DIR" ]; then
  echo "Base directory '$BASE_IMAGE_DIR' not found!"
  exit 1
fi

for IP in $(seq $START $END); do
  DIR="squid-proxy-${BASE_IMAGE_DIR}-${IP}"
  IPV6_ADDR="2406:59c0:5::${IP}"  # IPv6 address based on the subnet

  echo "Creating container for IPv6: ${IPV6_ADDR}..."

  # Copy and enter directory
  cp -r "$BASE_IMAGE_DIR" "$DIR"
  cd "$DIR" || exit 1

  # Remove old docker-compose.yml if exists
  rm -f docker-compose.yml

  # Create new docker-compose.yml with both IPv4 and IPv6
  cat <<EOF > docker-compose.yml
version: '3'

services:
  ${DIR}:
    build: .
    dns:
      - 2001:4860:4860::8888
      - 2001:4860:4860::8844
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
    networks:
      ${NETWORK_NAME}:
        ipv6_address: ${IPV6_ADDR}

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

echo "✅ All containers from ${START} to ${END} created and running with IPv6 addresses."

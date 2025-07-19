FROM debian:buster-slim

LABEL maintainer="Rakib Hasan <N1oE2@example.com>"

RUN echo "deb http://archive.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -yq \
    squid \
    curl \
    nano \
    iputils-ping \
    apache2-utils \
    python3 \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment and install Flask
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install flask

# Backup original squid config and remove write perms
RUN mv /etc/squid/squid.conf /etc/squid/squid.conf.origin && chmod a-w /etc/squid/squid.conf.origin

# Remove commented and empty lines, preserve order (without sorting)
RUN grep -v '^\s*#' /etc/squid/squid.conf.origin | grep -v '^\s*$' > /etc/squid/squid.conf

WORKDIR /app

COPY squid_api.py /app/squid_api.py
COPY templates/index.html /app/templates/index.html

ADD entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

EXPOSE 5000
ENTRYPOINT ["/sbin/entrypoint.sh"]

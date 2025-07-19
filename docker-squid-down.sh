#!/bin/bash

# Define IP range and base path
START=243
END=252
BASE_IMAGE_DIR="docker-squid-proxy"

# Function to handle cleanup of a single IP
cleanup_ip() {
  local IP=$1
  local DIR="${BASE_IMAGE_DIR}-${IP}"
  local CONTAINER_NAME="squid-proxy-${IP}"

  if [ -d "$DIR" ]; then
    echo "🔻 Stopping and removing container for IP: 103.66.177.${IP}"

    # Change directory with error handling
    if ! cd "$DIR"; then
      echo "⚠️ Failed to enter directory $DIR"
      return 1
    fi

    # Stop and remove the container, volumes, and network association
    if ! docker-compose down -v --remove-orphans; then
      echo "⚠️ Failed to stop container $CONTAINER_NAME"
      cd ..
      return 1
    fi

    cd ..

    # Clean up the directory with proper permissions
    echo "🧹 Removing directory $DIR"
    if ! sudo rm -rf "$DIR"; then
      echo "⚠️ Failed to remove directory $DIR completely"
      # Try removing just the contents if directory removal fails
      sudo find "$DIR" -type f -exec rm -f {} \;
      sudo find "$DIR" -type d -exec rmdir {} \; 2>/dev/null
    fi
  else
    echo "⚠️ Directory $DIR not found, skipping..."
  fi
}

# Main execution loop
for IP in $(seq $START $END); do
  cleanup_ip "$IP"
done

echo "✅ Cleanup completed for IP range 103.66.177.$START to 103.66.177.$END"
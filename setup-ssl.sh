#!/bin/bash

# Description: Unified script to set up SSL certificates for Nginx running in a Docker container using either Let's Encrypt or OpenSSL.

# Default domain or IP, override with the DOMAIN environment variable
DOMAIN="${DOMAIN:-your_domain_or_IP}"
EMAIL="${EMAIL:-your_email@example.com}"
SSL_DIR="ssl"
NGINX_CONTAINER_NAME="nginx"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Ensure Docker is installed
if ! command_exists docker; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Prompt the user to choose between Let's Encrypt or OpenSSL
read -p "Do you want to use Let's Encrypt for SSL certificates? (y/n): " USE_LETSENCRYPT

if [[ "$USE_LETSENCRYPT" == "y" || "$USE_LETSENCRYPT" == "Y" ]]; then
    # Check and install Certbot if needed
    if ! command_exists certbot; then
        echo "Certbot not found. Installing..."
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y certbot
        elif command_exists brew; then
            brew install certbot
        else
            echo "Package manager not supported. Install Certbot manually."
            exit 1
        fi
    fi

    # Create temporary directory for Certbot
    TEMP_DIR=$(mktemp -d)

    # Run Certbot in standalone mode to generate certificates
    sudo certbot certonly --standalone -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --work-dir "$TEMP_DIR" --logs-dir "$TEMP_DIR" --config-dir "$TEMP_DIR"

    # Copy certificates to the Docker-mounted volume
    mkdir -p "$SSL_DIR"
    sudo cp "$TEMP_DIR/live/$DOMAIN/fullchain.pem" "$SSL_DIR/nginx.crt"
    sudo cp "$TEMP_DIR/live/$DOMAIN/privkey.pem" "$SSL_DIR/nginx.key"

    echo "Let's Encrypt SSL certificate has been generated and stored in the '$SSL_DIR' directory."
    echo "Ensure your Docker Compose Nginx service uses these files."

    # Clean up temporary files
    sudo rm -rf "$TEMP_DIR"
else
    # Check if existing certificates are present
    if [[ -f "$SSL_DIR/nginx.key" && -f "$SSL_DIR/nginx.crt" ]]; then
        read -p "Existing self-signed certificates found. Do you want to replace them? (y/n): " REPLACE_CERTS
        if [[ "$REPLACE_CERTS" != "y" && "$REPLACE_CERTS" != "Y" ]]; then
            echo "Keeping existing self-signed certificates."
            exit 0
        fi
    fi

    # Generate self-signed SSL certificate using OpenSSL
    mkdir -p "$SSL_DIR"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/nginx.key" \
        -out "$SSL_DIR/nginx.crt" \
        -subj "/CN=$DOMAIN"

    echo "Self-signed SSL certificate has been generated in the '$SSL_DIR' directory."
    echo "Ensure your Docker Compose Nginx service uses these files."
fi

# Restart the Nginx container to apply changes
if docker ps --format '{{.Names}}' | grep -q "$NGINX_CONTAINER_NAME"; then
    docker restart "$NGINX_CONTAINER_NAME"
    echo "Nginx container has been restarted to apply the new certificates."
else
    echo "Nginx container is not running. Please ensure it is started with Docker Compose."
fi

exit 0

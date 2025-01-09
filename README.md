# Raspi AI Toolkit

The **Raspi AI Toolkit** is a Docker-based solution for hosting AI tools on your Raspberry Pi. This toolkit includes:

- **Ollama**: A lightweight AI inference server.
- **Open WebUI**: A user-friendly web interface for interacting with AI models.
- **Nginx**: A reverse proxy server to handle HTTPS and routing.

## Features

- **HTTPS Support**: Includes an integrated script to generate either self-signed certificates or Let's Encrypt certificates for secure communication.
- **Centralized Configuration**: Uses a `.env` file for easy customization of domain, email, and port settings.
- **Persistent Volumes**: Ensures data is not lost when restarting containers.
- **Health Checks**: Built-in health checks for all services to ensure reliability.

## Prerequisites

- A Raspberry Pi with Docker installed.
- Domain name (required for Let's Encrypt certificates).
- Basic familiarity with terminal commands.

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/raspi-ai-toolkit.git
cd raspi-ai-toolkit
```

### 2. Configure Environment Variables

Copy the `.env.example` file to `.env` and update the variables as needed:

```bash
cp .env.example .env
```

Update the following variables in the `.env` file:

- `DOMAIN`: Your domain or IP address.
- `EMAIL`: Your email address (used for Let's Encrypt).
- `OPEN_WEBUI_PORT`: Port for Open WebUI.
- `OLLAMA_DOCKER_TAG`: Ollama image tag.
- `WEBUI_DOCKER_TAG`: Open WebUI image tag.

### 3. Generate SSL Certificates

Run the included script to set up SSL certificates for Nginx:

```bash
bash setup-ssl.sh
```

- If using Let's Encrypt, ensure your domain is properly configured with DNS and ports 80/443 are open.
- If using self-signed certificates, the script will prompt you if existing certificates are found.

### 4. Start the Services

Use Docker Compose to spin up the stack:

```bash
docker compose up -d
```

### 5. Verify Setup

- **Ollama**: Accessible at `http://<your-domain-or-IP>:11434`.
- **Open WebUI**: Accessible at `https://<your-domain-or-IP>`.

### 6. Nginx Configuration

The included Nginx configuration automatically uses the SSL certificates generated during setup. Make sure your certificates are mounted correctly in the Docker Compose file.

## Directory Structure

```
raspi-ai-toolkit/
├── conf.d/               # Nginx configuration directory
│   └── default.conf      # Default Nginx configuration
├── ssl/                  # Directory for SSL certificates
├── docker-compose.yml    # Docker Compose configuration
├── .env.example          # Example environment variables file
├── setup-ssl.sh          # Script for setting up SSL certificates
├── README.md             # This file
├── .gitignore            # Ignore unnecessary files
├── LICENSE               # License file
```

## Troubleshooting

1. **Certificate Issues**:
   - Ensure the correct paths to certificates are mounted in `docker-compose.yml`.
   - Verify domain DNS settings and open required ports for Let's Encrypt.

2. **Service Not Starting**:
   - Check logs for each service using `docker logs <service-name>`.

3. **Performance**:
   - Ensure your Raspberry Pi has sufficient resources to handle the AI models and web interface.

## Contributing

Feel free to submit issues or pull requests to improve this toolkit. Contributions are welcome!

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

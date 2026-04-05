#!/bin/bash

# Script to deploy SeaweedFS S3-compatible object storage using Docker
# This creates a local SeaweedFS instance for development
# Prompts user for configuration and creates seaweedfs.env file
#
# Usage: ./deploy-seaweedfs.sh [OPTIONS]
#   -y, --yes             Accept all defaults and auto-confirm prompts
#   --clean               Delete existing data directory when recreating (implies -y for data cleanup)
#   --name NAME           Container name (default: seaweedfs)
#   --master-port PORT    Master port (default: 9333)
#   --volume-port PORT    Volume port (default: 8080)
#   --s3-port PORT        S3 API port (default: 8333)
#   --filer-port PORT     Filer port (default: 8888)
#   --data-dir DIR        Data directory (default: ./_local_deploy/.seaweedfs)
#   --access-key KEY      S3 access key (default: auto-generated)
#   -h, --help            Show this help message

set -e

# Defaults
DEFAULT_CONTAINER_NAME="seaweedfs"
DEFAULT_SEAWEEDFS_MASTER_PORT="9333"
DEFAULT_SEAWEEDFS_VOLUME_PORT="8080"
DEFAULT_SEAWEEDFS_S3_PORT="8333"
DEFAULT_SEAWEEDFS_FILER_PORT="8888"
DEFAULT_DATA_DIR="./_local_deploy/.seaweedfs"
DEFAULT_S3_ACCESS_KEY=""

# Flags
AUTO_YES=false
AUTO_CLEAN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        --clean)
            AUTO_CLEAN=true
            shift
            ;;
        --name)
            DEFAULT_CONTAINER_NAME="$2"
            shift 2
            ;;
        --master-port)
            DEFAULT_SEAWEEDFS_MASTER_PORT="$2"
            shift 2
            ;;
        --volume-port)
            DEFAULT_SEAWEEDFS_VOLUME_PORT="$2"
            shift 2
            ;;
        --s3-port)
            DEFAULT_SEAWEEDFS_S3_PORT="$2"
            shift 2
            ;;
        --filer-port)
            DEFAULT_SEAWEEDFS_FILER_PORT="$2"
            shift 2
            ;;
        --data-dir)
            DEFAULT_DATA_DIR="$2"
            shift 2
            ;;
        --access-key)
            DEFAULT_S3_ACCESS_KEY="$2"
            shift 2
            ;;
        -h|--help)
            sed -n '7,18p' "$0"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to prompt user with default value (skipped in auto-yes mode)
prompt_with_default() {
    local prompt_text=$1
    local default_value=$2

    if [[ "$AUTO_YES" == true ]]; then
        echo "$default_value"
        return
    fi

    local input_value
    read -p "$(echo -e ${BLUE}$prompt_text [${default_value}]${NC}): " input_value
    echo "${input_value:-$default_value}"
}

# Function to confirm an action (auto-confirms in auto-yes mode)
confirm() {
    local prompt_text=$1

    if [[ "$AUTO_YES" == true ]]; then
        return 0
    fi

    read -p "$(echo -e ${BLUE}$prompt_text${NC}) (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Function to generate a secure random secret key
generate_secret_key() {
    # Generate a 32-character random secret key using /dev/urandom
    # Use base64 encoding and remove special characters that might cause issues
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32
}

# Log functions for consistent output formatting
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Print header
echo ""
echo -e "${GREEN}┌──────────────────────────────────────┐${NC}"
echo -e "${GREEN}│  SeaweedFS Deployment Configuration  │${NC}"
echo -e "${GREEN}└──────────────────────────────────────┘${NC}"
if [[ "$AUTO_YES" == true ]]; then
    log_info "Running in non-interactive mode with defaults"
else
    log_info "Leave any field blank to use the default value"
fi
echo ""

# Get configuration from user
CONTAINER_NAME=$(prompt_with_default "Container name" "$DEFAULT_CONTAINER_NAME")
SEAWEEDFS_MASTER_PORT=$(prompt_with_default "Master port" "$DEFAULT_SEAWEEDFS_MASTER_PORT")
SEAWEEDFS_VOLUME_PORT=$(prompt_with_default "Volume port" "$DEFAULT_SEAWEEDFS_VOLUME_PORT")
SEAWEEDFS_S3_PORT=$(prompt_with_default "S3 API port" "$DEFAULT_SEAWEEDFS_S3_PORT")
SEAWEEDFS_FILER_PORT=$(prompt_with_default "Filer port" "$DEFAULT_SEAWEEDFS_FILER_PORT")
DATA_DIR=$(prompt_with_default "Data directory" "$DEFAULT_DATA_DIR")

# S3 credentials
if [[ -n "$DEFAULT_S3_ACCESS_KEY" ]]; then
    S3_ACCESS_KEY="$DEFAULT_S3_ACCESS_KEY"
elif [[ "$AUTO_YES" == true ]]; then
    S3_ACCESS_KEY=$(generate_secret_key)
    log_info "Generated S3 Access Key"
else
    read -p "$(echo -e ${BLUE}S3 Access Key${NC}) [generated]: " S3_ACCESS_KEY_INPUT
    if [ -z "$S3_ACCESS_KEY_INPUT" ]; then
        S3_ACCESS_KEY=$(generate_secret_key)
        log_info "Generated S3 Access Key"
    else
        S3_ACCESS_KEY="$S3_ACCESS_KEY_INPUT"
    fi
fi

S3_SECRET_KEY=$(generate_secret_key)

echo ""
log_info "Configuration Summary:"
echo "  Container Name:    $CONTAINER_NAME"
echo "  Master Port:       $SEAWEEDFS_MASTER_PORT"
echo "  Volume Port:       $SEAWEEDFS_VOLUME_PORT"
echo "  S3 API Port:       $SEAWEEDFS_S3_PORT"
echo "  Filer Port:        $SEAWEEDFS_FILER_PORT"
echo "  S3 Access Key:     $S3_ACCESS_KEY"
echo "  S3 Secret Key:     [auto-generated]"
echo "  Data Directory:    $DATA_DIR"
echo ""

# Create seaweedfs.env file with the configuration
SEAWEEDFS_ENV_FILE="seaweedfs.env"
log_info "Creating seaweedfs.env file..."

cat > "$SEAWEEDFS_ENV_FILE" << EOF
# SeaweedFS Configuration - Generated by deploy-seaweedfs.sh
# Generated on: $(date)

# Container Configuration
CONTAINER_NAME=$CONTAINER_NAME
SEAWEEDFS_MASTER_PORT=$SEAWEEDFS_MASTER_PORT
SEAWEEDFS_VOLUME_PORT=$SEAWEEDFS_VOLUME_PORT
SEAWEEDFS_S3_PORT=$SEAWEEDFS_S3_PORT
SEAWEEDFS_FILER_PORT=$SEAWEEDFS_FILER_PORT
DATA_DIR=$DATA_DIR

# S3 Credentials
S3_ACCESS_KEY=$S3_ACCESS_KEY
S3_SECRET_KEY=$S3_SECRET_KEY

# S3 Connection Details
S3_ENDPOINT=http://localhost:$SEAWEEDFS_S3_PORT
S3_REGION=default

# S3 Bucket Name
S3_BUCKET=atluo-files
EOF

log_success "seaweedfs.env file created"
log_info "Location: $(pwd)/$SEAWEEDFS_ENV_FILE"
echo ""
log_info "Usage:"
echo "  1. Add S3_* variables to your .env file (from seaweedfs.env)"
echo "  2. Run 'source seaweedfs.env' to load container variables"
echo ""

# Ask for confirmation before proceeding
if ! confirm "[?] Deploy SeaweedFS container now?"; then
    log_warning "Deployment cancelled. Configuration saved to $SEAWEEDFS_ENV_FILE"
    exit 0
fi

echo ""

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if container already exists
if docker container ls -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_warning "Container '$CONTAINER_NAME' already exists."
    log_info "If you want a fresh instance with the new configuration above,"
    log_info "remove and create new."
    echo ""
    if confirm "[?] Remove and create new container?"; then
        log_info "Removing existing container..."
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
        log_success "Container removed"
    else
        log_info "Starting existing container..."
        docker start "$CONTAINER_NAME"
        log_success "SeaweedFS container started"
        echo "  S3 Endpoint: http://localhost:$SEAWEEDFS_S3_PORT"
        log_info "Using existing container - configuration may differ from generated one above"
        exit 0
    fi
fi

# Clean existing data directory if present
if [ -d "$DATA_DIR" ]; then
    if [[ "$AUTO_CLEAN" == true ]]; then
        log_info "Cleaning existing data directory (--clean)..."
        rm -rf "$DATA_DIR"
        log_success "Data directory deleted"
    else
        log_warning "Existing data directory found: $DATA_DIR"
        log_info "Old data may contain stale configuration that conflicts with the new setup."
        if confirm "[?] Delete existing data directory?"; then
            rm -rf "$DATA_DIR"
            log_success "Data directory deleted"
        else
            log_warning "Keeping existing data - the new configuration may not take effect"
        fi
    fi
fi

# Check if all ports are available (after handling existing container)
for port in $SEAWEEDFS_MASTER_PORT $SEAWEEDFS_VOLUME_PORT $SEAWEEDFS_S3_PORT $SEAWEEDFS_FILER_PORT; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_error "Port $port is already in use."
        log_info "Please choose different ports or stop the service using them."
        exit 1
    fi
done

# Create data directory
log_info "Creating data directory..."
mkdir -p "$DATA_DIR"

# SeaweedFS image
SEAWEEDFS_IMAGE="chrislusf/seaweedfs:latest"

# Run SeaweedFS container
log_info "Creating SeaweedFS container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    -e AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY" \
    -e AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY" \
    -p "$SEAWEEDFS_MASTER_PORT:9333" \
    -p "$SEAWEEDFS_VOLUME_PORT:8080" \
    -p "$SEAWEEDFS_S3_PORT:8333" \
    -p "$SEAWEEDFS_FILER_PORT:8888" \
    -v "$(cd "$DATA_DIR" && pwd):/data" \
    "$SEAWEEDFS_IMAGE" \
    server -s3

# Wait for SeaweedFS to be ready
log_info "Waiting for SeaweedFS to start..."
sleep 5

# Check if container is running
if docker container inspect "$CONTAINER_NAME" 2>/dev/null | grep -q '"Status": "running"'; then
    echo ""
    echo -e "${GREEN}┌──────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│   SeaweedFS Deployed Successfully    │${NC}"
    echo -e "${GREEN}└──────────────────────────────────────┘${NC}"
    echo ""
    log_info "Container Details:"
    echo "  Name:            $CONTAINER_NAME"
    echo "  Data Directory:  $(cd "$DATA_DIR" && pwd)"
    echo ""
    log_info "Service Endpoints:"
    echo "  Master Server:   http://localhost:$SEAWEEDFS_MASTER_PORT"
    echo "  Volume Server:   http://localhost:$SEAWEEDFS_VOLUME_PORT"
    echo "  S3 API:          http://localhost:$SEAWEEDFS_S3_PORT"
    echo "  Filer:           http://localhost:$SEAWEEDFS_FILER_PORT"
    echo ""
    log_info "S3 Credentials:"
    echo "  Access Key:      $S3_ACCESS_KEY"
    echo "  Secret Key:      [auto-generated]"
    echo ""
    log_info "Next Steps:"
    echo "  1. Add S3 variables to .env file (from seaweedfs.env)"
    echo "  2. Backend is configured to use S3_ENDPOINT and S3 credentials"
    echo ""
    log_info "Container Management:"
    echo "  Stop:  docker stop $CONTAINER_NAME"
    echo "  Start: docker start $CONTAINER_NAME"
    echo "  Logs:  docker logs $CONTAINER_NAME"
    echo ""
else
    log_error "Failed to start SeaweedFS container"
    log_info "Run 'docker logs $CONTAINER_NAME' for more information"
    exit 1
fi

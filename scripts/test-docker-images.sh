#!/bin/bash

# Test script for pulling and running pre-built Docker images from GitHub Container Registry
# Usage: ./scripts/test-docker-images.sh [tag]
# Default tag: pr-93-review

set -e

TAG=${1:-pr-93-review}
REPO_OWNER="voioo"

echo "🐳 Testing LifeForge Docker Images"
echo "==================================="
echo "Tag: $TAG"
echo ""

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install docker-compose first."
    exit 1
fi

echo "📦 Pulling images from GHCR..."
echo ""

# Pull images
docker pull ghcr.io/${REPO_OWNER}/lifeforge-db:${TAG} || echo "⚠️  Failed to pull db image"
docker pull ghcr.io/${REPO_OWNER}/lifeforge-server:${TAG} || echo "⚠️  Failed to pull server image"
docker pull ghcr.io/${REPO_OWNER}/lifeforge-client:${TAG} || echo "⚠️  Failed to pull client image"

echo ""
echo "🔍 Checking local images..."
docker images | grep "lifeforge" || echo "No lifeforge images found locally"

echo ""
echo "🚀 Starting services with docker-compose.images.yaml..."
echo ""

# Check if env file exists
if [ ! -f "./env/.env.docker" ]; then
    echo "⚠️  Warning: ./env/.env.docker not found!"
    echo "   Creating from example..."
    if [ -f "./env/.env.docker.example" ]; then
        cp ./env/.env.docker.example ./env/.env.docker
        echo "   ✓ Created ./env/.env.docker from example"
        echo "   ⚠️  Please review and update the configuration!"
    else
        echo "   ❌ No example file found. Please create ./env/.env.docker manually."
        exit 1
    fi
fi

# Start services
docker-compose -f docker-compose.images.yaml down 2>/dev/null || true
docker-compose -f docker-compose.images.yaml up -d

echo ""
echo "⏳ Waiting for services to start..."
echo ""

# Wait for services
sleep 10

# Check service status
echo "📊 Service Status:"
docker-compose -f docker-compose.images.yaml ps

echo ""
echo "🔗 Access Points:"
echo "  - Application: http://localhost"
echo "  - API: http://localhost/api"
echo ""

echo "📝 Useful Commands:"
echo "  - View logs: docker-compose -f docker-compose.images.yaml logs -f"
echo "  - Stop: docker-compose -f docker-compose.images.yaml down"
echo "  - Restart: docker-compose -f docker-compose.images.yaml restart"
echo ""

echo "✅ Setup complete! LifeForge should be available at http://localhost"
echo ""
echo "⚠️  Note: First startup may take a few minutes as the database initializes."

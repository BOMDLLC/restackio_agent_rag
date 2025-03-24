#!/bin/bash

# Script to set up environment variables for the Agent RAG project

# Display welcome message
echo "Setting up environment variables for Agent RAG with Weaviate..."

# Check if .env file exists, create if not
if [ ! -f .env ]; then
    touch .env
    echo "Created new .env file"
else
    echo "Found existing .env file, will update it"
fi

# Ask for required variables
read -p "Enter Restack API Key: " RESTACK_API_KEY
read -p "Enter Restack Engine ID (press Enter for default): " RESTACK_ENGINE_ID
RESTACK_ENGINE_ID=${RESTACK_ENGINE_ID:-""}

read -p "Enter Restack Engine Address (press Enter for default 'localhost:6233'): " RESTACK_ENGINE_ADDRESS
RESTACK_ENGINE_ADDRESS=${RESTACK_ENGINE_ADDRESS:-"localhost:6233"}

read -p "Enter Restack Engine API Address (press Enter for default 'http://localhost:6233'): " RESTACK_ENGINE_API_ADDRESS
RESTACK_ENGINE_API_ADDRESS=${RESTACK_ENGINE_API_ADDRESS:-"http://localhost:6233"}

read -p "Enter Weaviate URL (press Enter for default 'http://localhost:8080'): " WEAVIATE_URL
WEAVIATE_URL=${WEAVIATE_URL:-"http://localhost:8080"}

read -p "Enter Weaviate API Key (press Enter if authentication not required): " WEAVIATE_API_KEY

read -p "Enter OpenAI API Key for Weaviate vectorization: " OPENAI_API_KEY

# Create the .env file content
cat > .env << EOF
# Restack Configuration
RESTACK_API_KEY=${RESTACK_API_KEY}
RESTACK_ENGINE_ID=${RESTACK_ENGINE_ID}
RESTACK_ENGINE_ADDRESS=${RESTACK_ENGINE_ADDRESS}
RESTACK_ENGINE_API_ADDRESS=${RESTACK_ENGINE_API_ADDRESS}

# Weaviate Configuration
WEAVIATE_URL=${WEAVIATE_URL}
WEAVIATE_API_KEY=${WEAVIATE_API_KEY}
OPENAI_API_KEY=${OPENAI_API_KEY}
EOF

echo "Environment variables set successfully!"
echo "To load these variables in your current shell, run: source .env"
echo "Remember to start both Restack and Weaviate containers:"
echo "  - Restack: docker run -d --pull always --name restack -p 5233:5233 -p 6233:6233 -p 7233:7233 -p 9233:9233 ghcr.io/restackio/restack:main"
echo "  - Weaviate: docker run -d --name weaviate -p 8080:8080 -e QUERY_DEFAULTS_LIMIT=25 -e AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED=true -e PERSISTENCE_DATA_PATH='/var/lib/weaviate' -e DEFAULT_VECTORIZER_MODULE=text2vec-openai -e ENABLE_MODULES=text2vec-openai -e OPENAI_APIKEY='${OPENAI_API_KEY}' semitechnologies/weaviate:1.22.4"

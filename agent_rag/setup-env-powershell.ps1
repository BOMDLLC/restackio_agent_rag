# PowerShell script to set up environment variables for the Agent RAG project
# Run first: 'Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass'
#

# Display welcome message
Write-Host "Setting up environment variables for Agent RAG with Weaviate..." -ForegroundColor Green

# Check if .env file exists, create if not
if (-not (Test-Path -Path ".env")) {
    New-Item -Path ".env" -ItemType File | Out-Null
    Write-Host "Created new .env file" -ForegroundColor Yellow
} else {
    Write-Host "Found existing .env file, will update it" -ForegroundColor Yellow
}

# Ask for required variables
$RESTACK_API_KEY = Read-Host -Prompt "Enter Restack API Key"
$RESTACK_ENGINE_ID = Read-Host -Prompt "Enter Restack Engine ID (press Enter for default)"
if ([string]::IsNullOrWhiteSpace($RESTACK_ENGINE_ID)) {
    $RESTACK_ENGINE_ID = ""
}

$RESTACK_ENGINE_ADDRESS = Read-Host -Prompt "Enter Restack Engine Address (press Enter for default 'localhost:6233')"
if ([string]::IsNullOrWhiteSpace($RESTACK_ENGINE_ADDRESS)) {
    $RESTACK_ENGINE_ADDRESS = "localhost:6233"
}

$RESTACK_ENGINE_API_ADDRESS = Read-Host -Prompt "Enter Restack Engine API Address (press Enter for default 'http://localhost:6233')"
if ([string]::IsNullOrWhiteSpace($RESTACK_ENGINE_API_ADDRESS)) {
    $RESTACK_ENGINE_API_ADDRESS = "http://localhost:6233"
}

$WEAVIATE_URL = Read-Host -Prompt "Enter Weaviate URL (press Enter for default 'http://localhost:8080')"
if ([string]::IsNullOrWhiteSpace($WEAVIATE_URL)) {
    $WEAVIATE_URL = "http://localhost:8080"
}

$WEAVIATE_API_KEY = Read-Host -Prompt "Enter Weaviate API Key (press Enter if authentication not required)"

$OPENAI_API_KEY = Read-Host -Prompt "Enter OpenAI API Key for Weaviate vectorization"

# Create the .env file content
$envContent = @"
# Restack Configuration
RESTACK_API_KEY=$RESTACK_API_KEY
RESTACK_ENGINE_ID=$RESTACK_ENGINE_ID
RESTACK_ENGINE_ADDRESS=$RESTACK_ENGINE_ADDRESS
RESTACK_ENGINE_API_ADDRESS=$RESTACK_ENGINE_API_ADDRESS

# Weaviate Configuration
WEAVIATE_URL=$WEAVIATE_URL
WEAVIATE_API_KEY=$WEAVIATE_API_KEY
OPENAI_API_KEY=$OPENAI_API_KEY
"@

Set-Content -Path ".env" -Value $envContent

Write-Host "Environment variables set successfully!" -ForegroundColor Green
Write-Host "Remember to start both Restack and Weaviate containers:" -ForegroundColor Cyan
Write-Host "  - Restack: docker run -d --pull always --name restack -p 5233:5233 -p 6233:6233 -p 7233:7233 -p 9233:9233 ghcr.io/restackio/restack:main" -ForegroundColor White
Write-Host "  - Weaviate: docker run -d --name weaviate -p 8080:8080 -e QUERY_DEFAULTS_LIMIT=25 -e AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED=true -e PERSISTENCE_DATA_PATH='/var/lib/weaviate' -e DEFAULT_VECTORIZER_MODULE=text2vec-openai -e ENABLE_MODULES=text2vec-openai -e OPENAI_APIKEY='$OPENAI_API_KEY' semitechnologies/weaviate:1.22.4" -ForegroundColor White

Write-Host "`nTo load these variables in your current PowerShell session, run:" -ForegroundColor Cyan
Write-Host "Get-Content .env | ForEach-Object { if(`$_ -match '^(.+)=(.+)$') { `$key=`$matches[1]; `$value=`$matches[2]; [Environment]::SetEnvironmentVariable(`$key, `$value, 'Process') }}" -ForegroundColor White

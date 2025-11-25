#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${PROJECT_DIR}/terraform"

echo -e "${YELLOW}=== Projet1: Serverless Backend with LocalStack ===${NC}\n"

# Function to print status messages
print_status() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
print_status "Checking dependencies..."

if ! command -v docker &> /dev/null; then
  print_error "Docker is not installed. Please install Docker first."
  exit 1
fi

if ! command -v docker-compose &> /dev/null; then
  print_error "Docker Compose is not installed. Please install Docker Compose first."
  exit 1
fi

if ! command -v terraform &> /dev/null; then
  print_error "Terraform is not installed. Please install Terraform first."
  exit 1
fi

print_status "All dependencies found.\n"

# Start LocalStack
print_status "Starting LocalStack containers..."
docker-compose -f "${PROJECT_DIR}/docker-compose.yml" up -d
sleep 5

print_status "Waiting for LocalStack to be ready..."
until curl -s http://localhost:4566/_localstack/health | grep -q '"services"'; do
  echo -n "."
  sleep 2
done
echo ""
print_status "LocalStack is ready!\n"

# Initialize Terraform
print_status "Initializing Terraform..."
cd "${TERRAFORM_DIR}"

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

terraform init -upgrade

print_status "Planning Terraform deployment..."
terraform plan -out=tfplan

print_status "Applying Terraform configuration..."
terraform apply tfplan

print_status "Retrieving outputs..."
terraform output

echo -e "\n${GREEN}=== Deployment Complete ===${NC}"
echo -e "${YELLOW}LocalStack Services:${NC}"
echo "  S3: http://localhost:4566"
echo "  DynamoDB: http://localhost:4566"
echo "  Lambda: http://localhost:4566"
echo "  API Gateway: http://localhost:4566"
echo ""
echo -e "${YELLOW}AWS CLI access:${NC}"
echo "  aws --endpoint-url=http://localhost:4566 s3 ls"
echo "  aws --endpoint-url=http://localhost:4566 dynamodb list-tables"
echo ""
echo -e "${YELLOW}Terraform state:${NC}"
echo "  Location: ${TERRAFORM_DIR}/terraform.tfstate"
echo ""
echo -e "${YELLOW}To stop LocalStack:${NC}"
echo "  docker-compose -f ${PROJECT_DIR}/docker-compose.yml down"

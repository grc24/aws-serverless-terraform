#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
BUCKET_NAME="${1:-development-state-lock-projet1-serverless}"
WEBSITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/website" && pwd)"
ENDPOINT_URL="${2:-http://localhost:4566}"

echo -e "${YELLOW}=== Uploading Website to S3 ===${NC}\n"

# Check if bucket exists
echo -e "${YELLOW}Checking S3 bucket...${NC}"
if ! aws s3 ls "s3://$BUCKET_NAME" --endpoint-url="$ENDPOINT_URL" &> /dev/null; then
    echo -e "${RED}Error: Bucket '$BUCKET_NAME' not found${NC}"
    echo "Create the bucket first with terraform apply"
    exit 1
fi

echo -e "${GREEN}✓ Bucket found${NC}\n"

# Upload files
echo -e "${YELLOW}Uploading website files...${NC}"
aws s3 sync "$WEBSITE_DIR" "s3://$BUCKET_NAME" \
    --endpoint-url="$ENDPOINT_URL" \
    --delete \
    --no-progress

echo -e "\n${GREEN}✓ Files uploaded successfully${NC}\n"

# Set content types
echo -e "${YELLOW}Setting content types...${NC}"
aws s3api put-object-acl \
    --bucket "$BUCKET_NAME" \
    --key "index.html" \
    --acl public-read \
    --endpoint-url="$ENDPOINT_URL" 2>/dev/null || true

aws s3api put-object-acl \
    --bucket "$BUCKET_NAME" \
    --key "error.html" \
    --acl public-read \
    --endpoint-url="$ENDPOINT_URL" 2>/dev/null || true

echo -e "${GREEN}✓ ACLs configured${NC}\n"

# Display access information
echo -e "${GREEN}=== Website Ready ===${NC}"
echo ""
echo -e "${YELLOW}S3 Website Endpoint:${NC}"
echo "http://$BUCKET_NAME.s3-website-eu-west-3.amazonaws.com"
echo ""
echo -e "${YELLOW}Direct S3 Access (LocalStack):${NC}"
echo "http://localhost:4566/$BUCKET_NAME/index.html"
echo ""
echo -e "${YELLOW}Files Uploaded:${NC}"
aws s3 ls "s3://$BUCKET_NAME" --endpoint-url="$ENDPOINT_URL" --recursive | awk '{print "  - " $4}'

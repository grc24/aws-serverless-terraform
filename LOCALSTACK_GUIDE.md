# LocalStack Execution Guide

This guide explains how to run the Projet1 Serverless Backend using AWS LocalStack for local development and testing.

## Prerequisites

- Docker & Docker Compose
- Terraform (>= 1.0)
- AWS CLI (optional, for testing)
- curl (for health checks)

## Quick Start

### Option 1: Automated Setup (Recommended)

```bash
cd /home/cloudenv/PERSONAL-PROJECT/localstack/Projet1
chmod +x setup-localstack.sh
./setup-localstack.sh
```

This script will:
1. Check dependencies
2. Start LocalStack containers
3. Initialize Terraform
4. Deploy infrastructure
5. Display connection details

### Option 2: Manual Setup

#### Step 1: Start LocalStack

```bash
cd /home/cloudenv/PERSONAL-PROJECT/localstack/Projet1
docker-compose up -d
```

Verify LocalStack is running:
```bash
curl http://localhost:4566/_localstack/health
```

#### Step 2: Initialize Terraform

```bash
cd terraform

# Set environment variables
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Initialize Terraform
terraform init
```

#### Step 3: Plan Infrastructure

```bash
terraform plan -out=tfplan
```

#### Step 4: Apply Configuration

```bash
terraform apply tfplan
```

#### Step 5: View Outputs

```bash
terraform output
```

## Testing the Deployment

### Using AWS CLI with LocalStack

```bash
# Set endpoint
export AWS_ENDPOINT_URL=http://localhost:4566

# List S3 buckets
aws s3 ls --endpoint-url=$AWS_ENDPOINT_URL

# List DynamoDB tables
aws dynamodb list-tables --endpoint-url=$AWS_ENDPOINT_URL

# Scan products table
aws dynamodb scan \
  --table-name products-catalog \
  --endpoint-url=$AWS_ENDPOINT_URL
```

### Insert Test Data

```bash
aws dynamodb put-item \
  --table-name products-catalog \
  --item '{
    "product_id": {"S": "PROD-001"},
    "name": {"S": "Premium Laptop"},
    "category": {"S": "electronics"},
    "price": {"N": "999.99"},
    "stock": {"N": "50"}
  }' \
  --endpoint-url=http://localhost:4566
```

### Query Products

```bash
aws dynamodb get-item \
  --table-name products-catalog \
  --key '{"product_id": {"S": "PROD-001"}}' \
  --endpoint-url=http://localhost:4566
```

## Cleanup

### Stop LocalStack

```bash
docker-compose down
```

### Remove Terraform State (if needed)

```bash
cd terraform
rm -rf .terraform terraform.tfstate* tfplan
```

### Destroy All Resources

```bash
cd terraform
terraform destroy
```

## Architecture Components

```
┌─────────────────┐
│   LocalStack    │
├─────────────────┤
│ ┌─────────────┐ │
│ │      S3     │ │  (State backend & general storage)
│ ├─────────────┤ │
│ │  DynamoDB   │ │  (Products catalog table)
│ ├─────────────┤ │
│ │   Lambda    │ │  (Serverless functions)
│ ├─────────────┤ │
│ │ API Gateway │ │  (RESTful endpoints)
│ ├─────────────┤ │
│ │     IAM     │ │  (Access control)
│ ├─────────────┤ │
│ │    Logs     │ │  (CloudWatch logging)
│ └─────────────┘ │
└─────────────────┘
```

## Debugging

### View LocalStack Logs

```bash
docker-compose logs -f localstack
```

### Check Terraform State

```bash
cd terraform
terraform show
```

### List All Resources

```bash
cd terraform
terraform state list
```

### Validate Configuration

```bash
cd terraform
terraform validate
```

## Environment Variables

The following environment variables are used by LocalStack and Terraform:

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export TF_VAR_environment=development
export TF_VAR_aws_region=us-east-1
```

## Troubleshooting

### Port 4566 Already in Use

```bash
# Find process using port 4566
lsof -i :4566

# Kill the process
kill -9 <PID>
```

### Terraform State Lock Issues

```bash
cd terraform
rm -f .terraform.lock.hcl
terraform init
```

### LocalStack Not Responding

```bash
# Stop and remove containers
docker-compose down --remove-orphans

# Clean up volumes
docker volume prune

# Start fresh
docker-compose up -d
```

### Permission Denied on setup script

```bash
chmod +x setup-localstack.sh
```

## Next Steps

1. Deploy Lambda functions that interact with DynamoDB
2. Create API Gateway routes to invoke Lambda
3. Test end-to-end workflow
4. Implement CI/CD pipeline for testing

For more information, visit:
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS API Documentation](https://docs.aws.amazon.com/)

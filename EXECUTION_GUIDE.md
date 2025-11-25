# Execute Project with AWS LocalStack

## Quick Reference

### Fastest Way to Get Started

```bash
# 1. Navigate to project directory
cd /home/cloudenv/PERSONAL-PROJECT/localstack/Projet1

# 2. Run the setup script (automated)
chmod +x setup-localstack.sh
./setup-localstack.sh
```

Or use Make (if installed):

```bash
make setup
```

---

## Step-by-Step Manual Execution

### Step 1: Start LocalStack

```bash
cd /home/cloudenv/PERSONAL-PROJECT/localstack/Projet1

# Start containers
docker-compose up -d

# Verify health
curl http://localhost:4566/_localstack/health
```

Expected output: `{"services": {"s3": "running", "dynamodb": "running", ...}}`

### Step 2: Initialize Terraform

```bash
cd terraform

# Set AWS credentials for LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Initialize Terraform
terraform init
```

### Step 3: Deploy Infrastructure

```bash
# Plan the deployment
terraform plan -out=tfplan

# Apply the configuration
terraform apply tfplan

# View outputs
terraform output
```

### Step 4: Verify Deployment

```bash
# List DynamoDB tables
aws dynamodb list-tables --endpoint-url=http://localhost:4566

# List S3 buckets
aws s3 ls --endpoint-url=http://localhost:4566

# Describe products table
aws dynamodb describe-table \
  --table-name products-catalog \
  --endpoint-url=http://localhost:4566
```

---

## Using Make Commands

If you have `make` installed, use these convenient commands:

```bash
make start    # Start LocalStack
make health   # Check health
make init     # Initialize Terraform
make plan     # Plan deployment
make apply    # Apply configuration
make test     # Run tests
make destroy  # Destroy resources
make clean    # Stop and clean everything
make help     # Show all commands
```

---

## Testing the Deployment

### Insert Test Data

```bash
aws dynamodb put-item \
  --table-name products-catalog \
  --item '{
    "product_id": {"S": "LAPTOP-001"},
    "name": {"S": "Gaming Laptop"},
    "category": {"S": "electronics"},
    "price": {"N": "1299.99"},
    "stock": {"N": "25"}
  }' \
  --endpoint-url=http://localhost:4566
```

### Query Data

```bash
aws dynamodb get-item \
  --table-name products-catalog \
  --key '{"product_id": {"S": "LAPTOP-001"}}' \
  --endpoint-url=http://localhost:4566
```

### Scan Products

```bash
aws dynamodb scan \
  --table-name products-catalog \
  --endpoint-url=http://localhost:4566
```

---

## Project Structure

```
Projet1/
├── README.md                    # Project overview
├── LOCALSTACK_GUIDE.md         # Detailed LocalStack guide
├── Makefile                     # Make commands
├── docker-compose.yml           # Docker Compose config
├── setup-localstack.sh          # Automated setup script
└── terraform/
    ├── main.tf                  # Terraform configuration
    ├── localstack.tf            # LocalStack provider config
    ├── state_backend.tf         # S3 & DynamoDB state setup
    ├── iam.tf                   # IAM roles and policies
    ├── dynamodb.tf              # DynamoDB table
    ├── api_gateway.tf           # API Gateway
    ├── variables.tf             # Input variables
    ├── outputs.tf               # Output values
    └── terraform.tfvars.example # Example variables
```

---

## Accessing LocalStack Services

All services run on: `http://localhost:4566`

### AWS CLI Access

```bash
# Always use --endpoint-url for LocalStack
aws <service> <command> --endpoint-url=http://localhost:4566
```

### Common AWS CLI Commands

```bash
# S3
aws s3 ls --endpoint-url=http://localhost:4566

# DynamoDB
aws dynamodb list-tables --endpoint-url=http://localhost:4566

# Lambda
aws lambda list-functions --endpoint-url=http://localhost:4566

# API Gateway
aws apigateway get-rest-apis --endpoint-url=http://localhost:4566

# IAM
aws iam list-roles --endpoint-url=http://localhost:4566
```

---

## Environment Variables

Set these for easier CLI usage:

```bash
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

Then use AWS CLI without --endpoint-url:

```bash
aws dynamodb list-tables  # Works with ENDPOINT_URL env var
```

---

## Monitoring and Debugging

### View LocalStack Logs

```bash
docker-compose logs -f localstack
```

### Check Container Status

```bash
docker-compose ps
```

### View Terraform State

```bash
cd terraform
terraform show          # Full state
terraform state list    # All resources
```

### Validate Terraform

```bash
cd terraform
terraform validate
terraform fmt           # Format code
```

---

## Cleanup

### Stop Containers (Keep Data)

```bash
docker-compose down
```

### Full Cleanup (Remove Everything)

```bash
# Using script
make clean

# Or manually
docker-compose down
cd terraform && rm -rf .terraform terraform.tfstate* tfplan
docker volume prune
```

---

## Architecture Deployed

```
Internet
   │
   ├─→ API Gateway (HTTP)
       └─→ Lambda Function
           └─→ DynamoDB Table (products-catalog)

Storage Backend:
   ├─→ S3 Bucket (terraform-state)
   └─→ DynamoDB Table (terraform-locks)

Logging:
   └─→ CloudWatch Logs
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Port 4566 in use | `docker-compose down && docker volume prune` |
| Terraform state locked | `rm terraform/.terraform.lock.hcl && terraform init` |
| LocalStack not ready | Wait 30 seconds after `docker-compose up -d` |
| AWS CLI not found | Install: `pip install awscli-local` or use `aws --endpoint-url=...` |
| Permission denied on script | `chmod +x setup-localstack.sh` |

---

## Next Steps

1. ✅ Deploy infrastructure with LocalStack
2. 📝 Create Lambda functions for product operations
3. 🔌 Connect API Gateway routes to Lambda
4. 🧪 Test end-to-end workflow
5. 📊 Implement monitoring and logging
6. 🚀 Migrate to AWS (production)

---

## References

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS DynamoDB Design Patterns](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/)
- [API Gateway Integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/)

.PHONY: help setup start stop logs init plan apply destroy clean test health deploy-website invalidate-cache

DOCKER_COMPOSE_FILE := docker-compose.yml
TERRAFORM_DIR := terraform
AWS_ENDPOINT := http://localhost:4566
BUCKET_NAME ?= development-state-lock-projet1-serverless

help:
	@echo "Projet1: Serverless Backend with LocalStack"
	@echo ""
	@echo "Infrastructure:"
	@echo "  make setup        - Full setup with LocalStack and Terraform"
	@echo "  make start        - Start LocalStack containers"
	@echo "  make stop         - Stop LocalStack containers"
	@echo "  make health       - Check LocalStack health"
	@echo "  make logs         - View LocalStack logs"
	@echo "  make init         - Initialize Terraform"
	@echo "  make plan         - Plan Terraform deployment"
	@echo "  make apply        - Apply Terraform configuration"
	@echo "  make destroy      - Destroy all resources"
	@echo "  make clean        - Clean Terraform state and containers"
	@echo ""
	@echo "Website:"
	@echo "  make deploy-website - Deploy static website to S3"
	@echo "  make invalidate-cache - Invalidate CloudFront cache"
	@echo ""
	@echo "Testing:"
	@echo "  make test         - Run test operations"
	@echo ""

setup: start init apply deploy-website
	@echo "✓ Full setup complete!"

start:
	@echo "Starting LocalStack containers..."
	docker-compose -f $(DOCKER_COMPOSE_FILE) up -d
	@echo "Waiting for LocalStack to be ready..."
	@until curl -s $(AWS_ENDPOINT)/_localstack/health | grep -q '"services"'; do \
		echo -n "."; \
		sleep 2; \
	done
	@echo ""
	@echo "✓ LocalStack is ready!"

stop:
	@echo "Stopping LocalStack containers..."
	docker-compose -f $(DOCKER_COMPOSE_FILE) down
	@echo "✓ Containers stopped"

logs:
	docker-compose -f $(DOCKER_COMPOSE_FILE) logs -f localstack

health:
	@curl -s $(AWS_ENDPOINT)/_localstack/health | jq .

init: start
	@echo "Initializing Terraform..."
	cd $(TERRAFORM_DIR) && \
	export AWS_ACCESS_KEY_ID=test && \
	export AWS_SECRET_ACCESS_KEY=test && \
	export AWS_DEFAULT_REGION=us-east-1 && \
	terraform init -upgrade
	@echo "✓ Terraform initialized"

plan:
	@echo "Planning Terraform deployment..."
	cd $(TERRAFORM_DIR) && \
	export AWS_ACCESS_KEY_ID=test && \
	export AWS_SECRET_ACCESS_KEY=test && \
	export AWS_DEFAULT_REGION=us-east-1 && \
	terraform plan -out=tfplan
	@echo "✓ Plan created"

apply:
	@echo "Applying Terraform configuration..."
	cd $(TERRAFORM_DIR) && \
	export AWS_ACCESS_KEY_ID=test && \
	export AWS_SECRET_Avariable "dynamodb_table_name" {
#   description = "DynamoDB table name for products"
#   type        = string
#   default     = "products-catalog"
# }

# variable "read_capacity" {
#   description = "DynamoDB read capacity units"
#   type        = number
#   default     = 100
# }

# variable "write_capacity" {
#   description = "DynamoDB write capacity units"
#   type        = number
#   default     = 100
# }CCESS_KEY=test && \
	export AWS_DEFAULT_REGION=us-east-1 && \
	terraform apply tfplan
	@echo "✓ Infrastructure deployed"

destroy:
	@echo "Destroying all resources..."
	cd $(TERRAFORM_DIR) && \
	export AWS_ACCESS_KEY_ID=test && \
	export AWS_SECRET_ACCESS_KEY=test && \
	export AWS_DEFAULT_REGION=us-east-1 && \
	terraform destroy -auto-approve
	@echo "✓ Resources destroyed"

clean: stop destroy
	@echo "Cleaning up..."
	cd $(TERRAFORM_DIR) && rm -rf .terraform terraform.tfstate* tfplan .terraform.lock.hcl
	@echo "✓ Cleanup complete"

test:
	@echo "Testing LocalStack deployment..."
	@echo ""
	@echo "1. Listing S3 buckets:"
	aws s3 ls --endpoint-url=$(AWS_ENDPOINT) || echo "S3 not ready"
	@echo ""
	@echo "2. Listing website files in bucket:"
	aws s3 ls s3://$(BUCKET_NAME)/ --endpoint-url=$(AWS_ENDPOINT) --recursive || echo "Bucket empty or not found"
	@echo ""
	@echo "3. Accessing website:"
	@curl -s http://localhost:4566/$(BUCKET_NAME)/index.html | head -20 || echo "Website not accessible"
	@echo ""
	@echo "✓ Tests completed"

deploy-website:
	@echo "Deploying website to S3..."
	@chmod +x deploy-website.sh
	@./deploy-website.sh $(BUCKET_NAME) $(AWS_ENDPOINT)

invalidate-cache:
	@echo "Getting CloudFront distribution ID..."
	@DIST_ID=$$(cd $(TERRAFORM_DIR) && export AWS_ACCESS_KEY_ID=test && export AWS_SECRET_ACCESS_KEY=test && terraform output -raw cloudfront_distribution_id); \
	if [ -z "$$DIST_ID" ]; then \
		echo "Error: CloudFront distribution not found"; \
		exit 1; \
	fi; \
	echo "Invalidating CloudFront cache (Distribution: $$DIST_ID)..."; \
	aws cloudfront create-invalidation \
		--distribution-id $$DIST_ID \
		--paths "/*" \
		--endpoint-url=$(AWS_ENDPOINT) || echo "Note: CloudFront cache invalidation may not be fully supported in LocalStack"

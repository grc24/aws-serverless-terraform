# 🚀 Projet1 Serverless Backend - SETUP COMPLETE

## ✅ System Status: FULLY OPERATIONAL

All components of your three-tier serverless backend are now working end-to-end.

---

## 📊 Architecture Overview

### **Tier 1: Presentation Layer**
- **S3 Static Website** with responsive design
- Live product grid fetching from API
- Fallback demo data when API unavailable
- Hosted at: `http://localhost:4566/project1-website/`

### **Tier 2: API Gateway**
- **REST API v1** with 4 endpoints
- AWS_PROXY integration with Lambda
- Automatic request/response transformation
- Access logging to CloudWatch

### **Tier 3: Compute & Data Layer**
- **AWS Lambda** (Python 3.8) for business logic
- **DynamoDB** for product catalog storage
- **SES** for email notifications
- **IAM** roles and policies for security

---

## 🔧 API Endpoints

All endpoints are functional and tested:

```bash
# Create/Update Product
curl -X PUT http://localhost:4566/restapis/7hz2npsel6/development/_user_request_/products \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "SKU-123",
    "name": "Product Name",
    "price": 99.99,
    "category": "Electronics",
    "description": "Product description",
    "stock": 50
  }'

# Get All Products
curl -X GET http://localhost:4566/restapis/7hz2npsel6/development/_user_request_/products

# Get Single Product
curl -X GET http://localhost:4566/restapis/7hz2npsel6/development/_user_request_/products/SKU-123

# Delete Product
curl -X DELETE http://localhost:4566/restapis/7hz2npsel6/development/_user_request_/products/SKU-123
```

---

## 📧 Email Notifications

**✅ FIXED**: Email notifications now working via SES!

**What happens:**
1. Product is created via PUT /products endpoint
2. Lambda function automatically calls SES SendEmail
3. Email notification sent to awsdavid20@gmail.com
4. LocalStack captures email locally for testing
5. In production AWS, emails will be sent to verified address

**LocalStack Email Storage:**
```bash
# View all captured emails
docker compose exec localstack ls /tmp/localstack/state/ses/

# View specific email content
docker compose exec localstack cat /tmp/localstack/state/ses/<email-id>.json
```

**Email Format:**
- From: awsdavid20@gmail.com
- To: awsdavid20@gmail.com
- Subject: "Product Created: {ProductName}"
- Body: HTML-formatted with product details

---

## 🗄️ Database

**DynamoDB Table: `products-catalog`**

Schema:
- **Partition Key**: product_id (String)
- **Attributes**: name, price, category, description, stock
- **Global Secondary Index**: category-index (for filtering by category)
- **Point-in-time Recovery**: Enabled
- **TTL**: expiration_time attribute

View products:
```bash
aws dynamodb scan --table-name products-catalog \
  --endpoint-url http://localhost:4566 \
  --region eu-west-3
```

---

## 🚀 Quick Start Commands

### Start the Infrastructure
```bash
cd /home/cloudenv/PERSONAL-PROJECT/localstack/Projet1
docker compose up -d
```

### Deploy/Update Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Add a Test Product
```bash
curl -X PUT http://localhost:4566/restapis/7hz2npsel6/development/_user_request_/products \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "TEST-001",
    "name": "Test Product",
    "price": 49.99,
    "category": "Electronics",
    "description": "A test product",
    "stock": 10
  }'
```

### Check Email Was Sent
```bash
docker compose logs --tail=50 | grep "Email notification sent"
```

---

## 📁 Project Structure

```
Projet1/
├── terraform/                    # IaC files
│   ├── main.tf                  # Main configuration
│   ├── variables.tf             # Input variables
│   ├── lambda.tf                # Lambda function setup
│   ├── api_gateway.tf           # REST API v1 configuration
│   ├── dynamodb.tf              # DynamoDB table
│   ├── iam.tf                   # IAM roles
│   ├── allow-lambda-to-dynamodb.tf  # Lambda permissions
│   ├── ses.tf                   # SES email service
│   ├── product_api.py           # Lambda function code
│   ├── product_api.zip          # Packaged Lambda function
│   ├── outputs.tf               # Terraform outputs
│   └── terraform.tfstate        # State file (local)
│
├── website/                     # S3 static website
│   ├── index.html               # Main landing page
│   └── error.html               # 404 error page
│
├── docker-compose.yml           # LocalStack services
├── Makefile                     # Automation commands
└── README.md                    # Documentation
```

---

## ✨ Features Implemented

- ✅ Infrastructure as Code (Terraform)
- ✅ Local Development Environment (LocalStack)
- ✅ REST API with 4 endpoints (CRUD)
- ✅ DynamoDB table with GSI
- ✅ Lambda function with business logic
- ✅ SES email notifications on product creation
- ✅ S3 static website hosting
- ✅ Website-API integration
- ✅ CloudWatch logging
- ✅ IAM security policies
- ✅ Error handling and validation

---

## 🔍 Troubleshooting

### "Email not sending"
→ Verify email address first:
```bash
docker compose exec localstack awslocal ses verify-email-identity \
  --email-address awsdavid20@gmail.com \
  --region eu-west-3
```

### "Lambda timeout"
→ Check endpoint URL in Lambda env vars. Should be `http://localstack:4566` (NOT localhost)

### "API Gateway endpoints not working"
→ Check the api_id in your API URL:
```bash
aws apigateway get-rest-apis --endpoint-url http://localhost:4566 --region eu-west-3
```

### "DynamoDB scan returns empty"
→ Products only appear after successful Lambda execution. Check Lambda logs:
```bash
docker compose logs --tail=100 | grep -i "product created"
```

---

## 🌐 Production Migration

To migrate to real AWS:

1. **Create AWS account** and configure credentials
2. **Update provider** in terraform/main.tf (remove localstack.tf)
3. **Verify email** in SES console (required for production)
4. **Run terraform apply** on production region
5. **Update website** with production API endpoint
6. **Configure CloudFront** for CDN acceleration
7. **Set up CI/CD** pipeline for deployments

---

## 📝 Next Steps (Optional)

- [ ] Add product search/filtering endpoints
- [ ] Implement product update (PUT with partial updates)
- [ ] Add shopping cart functionality
- [ ] Create product detail page on website
- [ ] Set up automated backups
- [ ] Configure CloudFront CDN
- [ ] Implement authentication/authorization
- [ ] Add monitoring and alerting
- [ ] Create CI/CD pipeline
- [ ] Deploy to production AWS

---

## 📞 Support

For issues or questions:
1. Check LocalStack logs: `docker compose logs`
2. Verify Terraform state: `terraform show`
3. Test API endpoints directly with curl
4. Check Lambda function code in `product_api.py`
5. Review CloudWatch logs in LocalStack

---

**Last Updated**: 2025-11-25
**Status**: ✅ Production Ready for LocalStack
**Next Target**: Real AWS Production Deployment

# Complete Projet1 Architecture

## System Overview

```
╔════════════════════════════════════════════════════════════════════════╗
║                    PROJET1: SERVERLESS THREE-TIER BACKEND              ║
║          E-Commerce Product Catalog with Static Website Hosting       ║
╚════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────┐
│                          END USERS / BROWSERS                           │
└────────────────────────┬────────────────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   ╔═════════╗  ╔══════════════╗  ╔═══════════════╗
   │CloudFront│  │ API Gateway  │  │  S3 Website   │
   │   CDN    │  │   (REST API) │  │   Endpoint    │
   └────┬────┘  └──────┬───────┘  └───────┬───────┘
        │               │                  │
        │               │                  │
        ▼               ▼                  ▼
   ╔═════════════════────────────────────────────╗
   │         LOCALSTACK / AWS SERVICES           │
   ├─────────────────────────────────────────────┤
   │                                             │
   │  ┌──────────────────────────────────────┐  │
   │  │  S3 BUCKET (Static Website Host)    │  │
   │  │  ├─ index.html                      │  │
   │  │  ├─ error.html                      │  │
   │  │  ├─ logs/ (request logs)            │  │
   │  │  └─ Versioning enabled              │  │
   │  └──────────────────────────────────────┘  │
   │                    ▲                        │
   │                    │                        │
   │  ┌─────────────────┴──────────────────┐    │
   │  │  CloudFront Distribution (CDN)     │    │
   │  │  ├─ Origin Access Identity (OAI)   │    │
   │  │  ├─ GZIP Compression enabled       │    │
   │  │  ├─ 1 hour cache TTL               │    │
   │  │  └─ Global edge locations          │    │
   │  └──────────────────────────────────────┘  │
   │                                             │
   │  ┌──────────────────────────────────────┐  │
   │  │  API GATEWAY (REST Endpoints)        │  │
   │  │  ├─ GET    /products                 │  │
   │  │  ├─ GET    /products/{id}            │  │
   │  │  ├─ POST   /products                 │  │
   │  │  ├─ PUT    /products/{id}            │  │
   │  │  └─ DELETE /products/{id}            │  │
   │  └──────────────────────────────────────┘  │
   │                    ▲                        │
   │                    │                        │
   │                    ▼                        │
   │  ┌──────────────────────────────────────┐  │
   │  │  LAMBDA FUNCTIONS (Compute)          │  │
   │  │  ├─ GetProducts handler              │  │
   │  │  ├─ GetProductById handler           │  │
   │  │  ├─ CreateProduct handler            │  │
   │  │  ├─ UpdateProduct handler            │  │
   │  │  └─ DeleteProduct handler            │  │
   │  └──────────────────────────────────────┘  │
   │                    ▲                        │
   │                    │ DynamoDB Queries      │
   │                    ▼                        │
   │  ┌──────────────────────────────────────┐  │
   │  │  DYNAMODB (NoSQL Database)           │  │
   │  │  ├─ Table: products-catalog          │  │
   │  │  ├─ Primary Key: product_id (String) │  │
   │  │  ├─ GSI: category (for filtering)    │  │
   │  │  ├─ Encryption: AES256               │  │
   │  │  ├─ Versioning: Enabled              │  │
   │  │  ├─ PITR: Point-in-time recovery    │  │
   │  │  └─ TTL: Configurable expiration    │  │
   │  └──────────────────────────────────────┘  │
   │                                             │
   │  ┌──────────────────────────────────────┐  │
   │  │  IAM (Access Control)                │  │
   │  │  ├─ Lambda Execution Role            │  │
   │  │  │  ├─ dynamodb:GetItem              │  │
   │  │  │  ├─ dynamodb:Query                │  │
   │  │  │  ├─ dynamodb:PutItem              │  │
   │  │  │  ├─ logs:CreateLogGroup           │  │
   │  │  │  └─ logs:PutLogEvents             │  │
   │  │  └─ Trust: lambda.amazonaws.com      │  │
   │  └──────────────────────────────────────┘  │
   │                                             │
   │  ┌──────────────────────────────────────┐  │
   │  │  CLOUDWATCH LOGS (Logging)           │  │
   │  │  ├─ API Gateway access logs          │  │
   │  │  ├─ Lambda execution logs            │  │
   │  │  └─ DynamoDB metrics                 │  │
   │  └──────────────────────────────────────┘  │
   │                                             │
   └─────────────────────────────────────────────┘
```

## Data Flow

### 1. **Website Request Flow**
```
User Browser
    │
    ├─→ CloudFront (checks cache)
    │   ├─ Cache Hit: Return from edge location
    │   └─ Cache Miss: Fetch from S3
    │       ↓
    │   S3 Bucket
    │   ├─ index.html
    │   ├─ error.html
    │   └─ Returns to CloudFront
    │
    └─→ Response to Browser
```

### 2. **Product Lookup Flow (< 1ms latency)**
```
Browser (JavaScript)
    │
    ├─→ API Gateway
    │   │
    │   ├─→ Lambda Function
    │   │   │
    │   │   ├─→ DynamoDB Query
    │   │   │   ├─ Primary Key Lookup: ~1ms
    │   │   │   └─ GSI Query: ~5ms
    │   │   │
    │   │   └─→ Return formatted JSON
    │   │
    │   └─→ API Response (Cache-enabled)
    │
    └─→ Render Products in Grid
```

### 3. **Product Creation Flow**
```
Browser Form Submit
    │
    ├─→ API Gateway (POST /products)
    │   │
    │   ├─→ Lambda Function
    │   │   │
    │   │   ├─→ Validation
    │   │   │
    │   │   ├─→ DynamoDB PutItem
    │   │   │   ├─ Generate product_id
    │   │   │   ├─ Add timestamp
    │   │   │   └─ Store attributes
    │   │   │
    │   │   └─→ Return created product
    │   │
    │   └─→ Success Response
    │
    └─→ Update UI / Show confirmation
```

## Infrastructure Components

### **1. Static Website Layer (S3 + CloudFront)**

**S3 Configuration:**
- Bucket name: `development-state-lock-projet1-serverless`
- Region: `eu-west-3`
- Versioning: Enabled
- Encryption: AES256
- Public Access: Enabled (via policy)
- CORS: Enabled
- Logging: S3 request logs

**CloudFront Distribution:**
- Origin: S3 bucket (private)
- Origin Access Identity: Yes
- Default root object: `index.html`
- Error document: `error.html`
- Cache behavior:
  - Default TTL: 1 hour
  - Min TTL: 0
  - Max TTL: 24 hours
- Compression: GZIP enabled
- Protocol: HTTP/HTTPS (redirect to HTTPS)

### **2. API Layer (API Gateway + Lambda)**

**API Gateway:**
- Type: HTTP REST API
- Endpoints:
  - `GET /products`
  - `GET /products/{product_id}`
  - `POST /products`
  - `PUT /products/{product_id}`
  - `DELETE /products/{product_id}`
- Integration: Lambda proxy
- Logging: CloudWatch

**Lambda Functions:**
- Runtime: Node.js / Python
- Timeout: 30 seconds
- Memory: 256 MB
- Execution Role: Attached with DynamoDB permissions
- Logging: CloudWatch Logs

### **3. Database Layer (DynamoDB)**

**Products Table:**
- Name: `products-catalog`
- Billing: PROVISIONED (100 RCU / 100 WCU)
- Primary Key: `product_id` (String)
- Attributes:
  - `product_id`: String (PK)
  - `name`: String
  - `category`: String
  - `price`: Number
  - `stock`: Number
  - `created_at`: String (ISO timestamp)
  - `updated_at`: String (ISO timestamp)

**Global Secondary Indexes:**
- `category-index`:
  - Partition Key: `category`
  - Projection: ALL
  - RCU/WCU: Same as table

**Features:**
- Point-in-time recovery: Enabled
- TTL: Configurable (auto-expiration)
- Encryption: Enabled
- Versioning: Implicit (last write wins)

### **4. Security Layer (IAM)**

**Lambda Execution Role:**
- Trust: Lambda service
- Permissions:
  - `dynamodb:GetItem`
  - `dynamodb:PutItem`
  - `dynamodb:UpdateItem`
  - `dynamodb:DeleteItem`
  - `dynamodb:Query`
  - `dynamodb:Scan`
  - `logs:CreateLogGroup`
  - `logs:CreateLogStream`
  - `logs:PutLogEvents`

**S3 Bucket Policy:**
- Public read for website files
- CloudFront OAI access
- Deny insecure transport (HTTP)

### **5. Monitoring Layer (CloudWatch)**

**Logs:**
- API Gateway access logs
- Lambda execution logs
- DynamoDB error logs

**Metrics:**
- API request count
- API latency
- Lambda duration
- Lambda errors
- DynamoDB read/write units

**Alarms:**
- CloudFront 4XX/5XX errors
- Lambda error rate
- DynamoDB throttling

## Performance Characteristics

| Metric | Value | Notes |
|--------|-------|-------|
| **Lookup Latency** | < 1ms | DynamoDB direct access |
| **Global Availability** | 99.99% | SLA from AWS |
| **Concurrent Users** | Unlimited | Auto-scaling |
| **Request Rate** | Unlimited | Unlimited with provisioning |
| **Storage** | Unlimited | DynamoDB grows automatically |
| **Data Transfer** | Per GB | S3 + CloudFront combined |

## Scalability

- **DynamoDB**: Auto-scales with on-demand or provisioned capacity
- **Lambda**: Concurrent executions scale automatically
- **API Gateway**: Built-in scaling to millions of requests
- **CloudFront**: Global edge network with automatic scaling
- **S3**: Unlimited storage and request rate

## High Availability

- **Multi-AZ**: DynamoDB automatically replicated
- **Global Delivery**: CloudFront edge locations worldwide
- **Redundancy**: Lambda distributed across AZs
- **Backup**: S3 versioning + DynamoDB PITR
- **Failover**: Automatic regional failover

## Security Architecture

```
┌─────────────────────────────────────────┐
│         Internet (Public)                 │
└────────────────┬────────────────────────┘
                 │ HTTPS only
                 ▼
┌─────────────────────────────────────────┐
│  CloudFront + WAF (Optional)              │
│  - DDoS protection                        │
│  - Geographic restrictions                │
│  - Rate limiting                          │
└────────────────┬────────────────────────┘
                 │ Private (OAI)
                 ▼
┌─────────────────────────────────────────┐
│  API Gateway + IAM Authentication         │
│  - API keys (optional)                    │
│  - Lambda authorizers                     │
│  - CORS validation                        │
└────────────────┬────────────────────────┘
                 │ Fine-grained IAM
                 ▼
┌─────────────────────────────────────────┐
│  Lambda Functions                         │
│  - Input validation                       │
│  - Business logic                         │
│  - Error handling                         │
└────────────────┬────────────────────────┘
                 │ Encrypted connection
                 ▼
┌─────────────────────────────────────────┐
│  DynamoDB (Encrypted at rest)             │
│  - AES-256 encryption                     │
│  - VPC endpoints (optional)                │
│  - Fine-grained access control            │
└─────────────────────────────────────────┘
```

## Disaster Recovery

| Scenario | Recovery | RTO | RPO |
|----------|----------|-----|-----|
| **Data Loss** | DynamoDB PITR | 5 min | 35 sec |
| **Service Outage** | Auto-failover | < 1 min | None |
| **Region Failure** | Manual failover | 1 hour | None |
| **Accidental Delete** | Restore from backup | 1 min | Point in time |

## Cost Optimization

1. **DynamoDB**: On-demand pricing for variable workloads
2. **Lambda**: Pay only for execution time
3. **API Gateway**: Per-request pricing model
4. **CloudFront**: Reduced origin requests via caching
5. **S3**: Minimal storage costs, lifecycle policies
6. **CloudWatch**: 5GB free logs per month

## Deployment Architecture

```
├─ Terraform Configuration
│  ├─ state_backend.tf       (S3 + CloudFront)
│  ├─ dynamodb.tf            (Database)
│  ├─ api_gateway.tf         (REST API)
│  ├─ iam.tf                 (Security)
│  ├─ variables.tf           (Configuration)
│  ├─ outputs.tf             (Resource URLs)
│  └─ cloudfront.tf          (CDN)
│
├─ Website
│  ├─ index.html             (Landing page)
│  └─ error.html             (Error handling)
│
└─ Deployment Scripts
   ├─ deploy-website.sh      (Upload to S3)
   └─ Makefile               (Management)
```

## Environment Variables

```bash
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DEFAULT_REGION=eu-west-3
TF_VAR_environment=development
TF_VAR_aws_region=eu-west-3
TF_VAR_project_name=projet1-serverless
```

## Key Takeaways

✅ **Serverless**: No servers to manage or scale
✅ **Cost-Effective**: Pay only for what you use
✅ **Highly Available**: 99.99% uptime SLA
✅ **Globally Distributed**: CloudFront edge locations worldwide
✅ **Secure**: Multi-layer security with IAM + encryption
✅ **Fast**: Sub-millisecond latency for product lookups
✅ **Scalable**: Auto-scaling to handle traffic spikes
✅ **Observable**: CloudWatch logs and metrics

## SAA-C03 Exam Concepts Covered

- API Gateway integration types
- Lambda execution roles and policies
- DynamoDB partition keys and GSI
- CloudFront distributions and caching
- S3 bucket policies and public access
- IAM role trust relationships
- CloudWatch metrics and alarms
- Encryption at rest and in transit
- High availability and disaster recovery

---

This architecture represents a production-ready e-commerce backend built entirely on AWS serverless services with zero operational overhead.

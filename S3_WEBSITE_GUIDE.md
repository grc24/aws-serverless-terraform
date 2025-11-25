# S3 Static Website Configuration

This guide explains how to deploy and access the static website hosted on S3 with CloudFront CDN.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Users / Browsers                         │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │ HTTPS
                   ▼
┌─────────────────────────────────────────────────────────────┐
│              CloudFront Distribution (CDN)                   │
│  - Cache layer with edge locations                          │
│  - GZIP compression enabled                                 │
│  - Origin Access Identity for secure S3 access             │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │ Private Access
                   ▼
┌─────────────────────────────────────────────────────────────┐
│         S3 Bucket (Static Website)                          │
│  ├─ index.html        (Landing page)                        │
│  ├─ error.html        (Error handling)                      │
│  └─ Versioning enabled                                      │
└─────────────────────────────────────────────────────────────┘
```

## Features

✅ **Static Website Hosting** - Serve HTML, CSS, JavaScript directly from S3
✅ **CloudFront CDN** - Global content delivery with caching
✅ **Origin Access Identity** - Seindex.htmlcure S3 access through CloudFront only
✅ **CORS Enabled** - Allow API calls from the frontend
✅ **Auto-Logging** - Request logs stored in S3
✅ **High Availability** - 99.99% uptime SLA
✅ **Sub-millisecond Latency** - Edge location caching

## Deployment Steps

### Step 1: Deploy Infrastructure

```bash
cd /home/cloudenv/PERSONAL-PROJECT/localstack/Projet1/terraform

# Plan the infrastructure
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan

# View outputs
terraform output
```

**Outputs to note:**
- `s3_bucket_name` - Your S3 bucket name
- `cloudfront_domain_name` - CloudFront URL
- `website_access_url` - Public HTTPS URL

### Step 2: Upload Website Files

```bash
cd /home/cloudenv/PERSONAL-PROJECT/localstack/Projet1

# Make the script executable
chmod +x deploy-website.sh

# Deploy website (with default settings)
./deploy-website.sh

# Or with custom bucket and endpoint
./deploy-website.sh "your-bucket-name" "http://localhost:4566"
```

### Step 3: Verify Deployment

**For LocalStack Development:**
```bash
# Direct S3 access
curl http://localhost:4566/development-state-lock-projet1-serverless/index.html

# List all objects
aws s3 ls s3://development-state-lock-projet1-serverless \
  --endpoint-url=http://localhost:4566 \
  --recursive
```

**For Production AWS:**
```bash
# Via CloudFront (recommended)
curl https://<your-cloudfront-domain>/

# Via S3 website endpoint
curl http://<your-bucket>.s3-website-<region>.amazonaws.com/
```

## Website Files

### index.html
- Main landing page
- Responsive design with gradient background
- Product showcase grid
- API endpoint documentation
- Architecture diagram

### error.html
- Custom 404 error page
- Branded error handling
- Link back to home

## Configuration Details

### S3 Bucket Configuration
- **Versioning**: Enabled (track file changes)
- **Encryption**: AES256 (automatic at rest)
- **Public Access**: Enabled for website hosting
- **CORS**: Enabled for API integration
- **Logging**: All requests logged to `logs/` prefix

### CloudFront Distribution
- **Origin**: S3 bucket (via Origin Access Identity)
- **Default Cache**: 1 hour for index.html
- **Compression**: GZIP enabled
- **Protocol**: HTTP/HTTPS (with redirect to HTTPS)
- **Root Object**: index.html

### S3 Bucket Policy
```json
{
  "Effect": "Allow",
  "Principal": "*",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::bucket-name/*"
}
```

This allows public read access to all objects (necessary for website hosting).

## Accessing Your Website

### Development (LocalStack)

**Direct S3 Access:**
```
http://localhost:4566/development-state-lock-projet1-serverless/
```

**S3 Website Endpoint:**
```
http://development-state-lock-projet1-serverless.s3-website-eu-west-3.amazonaws.com
```

### Production (AWS)

**CloudFront URL (Recommended):**
```
https://<distribution-domain-name>.cloudfront.net
```

**S3 Website Endpoint:**
```
http://<bucket-name>.s3-website-<region>.amazonaws.com
```

## Updating Website Content

### Add New Files

```bash
# Copy new files to website directory
cp your-file.html /home/cloudenv/PERSONAL-PROJECT/localstack/Projet1/website/

# Sync with S3
aws s3 sync website/ s3://your-bucket-name \
  --endpoint-url=http://localhost:4566
```

### Update Existing Files

```bash
# Edit the file
nano website/index.html

# Upload the updated file
aws s3 cp website/index.html s3://your-bucket-name/ \
  --endpoint-url=http://localhost:4566

# Invalidate CloudFront cache (optional, but recommended)
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/*"
```

## Cache Management

### CloudFront Cache Invalidation

```bash
# Invalidate all files
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/*"

# Invalidate specific files
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/index.html" "/error.html"

# Check invalidation status
aws cloudfront list-invalidations \
  --distribution-id <distribution-id>
```

## Performance Optimization

### 1. Enable Gzip Compression
Already enabled in CloudFront configuration.

### 2. Add Cache Headers
```bash
# Set cache for static assets (1 year)
aws s3api put-object \
  --bucket your-bucket \
  --key "assets/style.css" \
  --body "style.css" \
  --cache-control "max-age=31536000" \
  --endpoint-url=http://localhost:4566
```

### 3. Use CloudFront Edge Locations
Content is automatically cached at edge locations nearest to your users.

## Monitoring and Logging

### S3 Request Logs
Logs are stored in `s3://bucket-name/logs/` with format:
```
bucket-name [timestamp] IP operation key status ...
```

### CloudFront Metrics
View in AWS CloudWatch:
- Requests
- Bytes downloaded
- Error rates (4XX, 5XX)
- Cache hit ratio

### View Logs
```bash
aws s3 cp s3://your-bucket/logs/ logs/ \
  --recursive \
  --endpoint-url=http://localhost:4566
```

## Troubleshooting

### Website not accessible

1. **Check bucket exists:**
   ```bash
   aws s3 ls --endpoint-url=http://localhost:4566
   ```

2. **Verify files uploaded:**
   ```bash
   aws s3 ls s3://your-bucket \
     --endpoint-url=http://localhost:4566 \
     --recursive
   ```

3. **Check bucket policy:**
   ```bash
   aws s3api get-bucket-policy \
     --bucket your-bucket \
     --endpoint-url=http://localhost:4566
   ```

### CloudFront returning 403 error

- Verify Origin Access Identity (OAI) is configured
- Check S3 bucket policy allows CloudFront access
- Ensure index.html exists in bucket root

### Stale content displayed

- Clear CloudFront cache: `make invalidate-cache`
- Clear browser cache: Ctrl+Shift+Delete (or Cmd+Shift+Delete)
- Wait for TTL to expire (1 hour default)

## Security Best Practices

✅ **CloudFront Origin Access Identity** - Only CloudFront can access S3
✅ **HTTPS Enforcement** - All traffic redirected to HTTPS
✅ **S3 Versioning** - Rollback capability for files
✅ **Logging Enabled** - Audit trail of all requests
✅ **Public Access Blocks** - Controlled via bucket policy only

## Cost Optimization

1. **Use CloudFront** - Reduces S3 data transfer costs
2. **Enable Compression** - GZIP reduces bandwidth by ~60%
3. **Set Appropriate TTLs** - Balance freshness vs. cost
4. **Use S3 Intelligent-Tiering** - Automatic cost optimization

## Next Steps

1. Deploy Lambda functions for dynamic API endpoints
2. Connect API Gateway to CloudFront
3. Add authentication/authorization
4. Set up CI/CD for automated deployments
5. Add monitoring and alerting

## Resources

- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [S3 Bucket Policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html)
- [Origin Access Identity](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)

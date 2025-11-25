# S3 Static Website - Quick Start

Get your serverless e-commerce website up and running in minutes!

## 🚀 Quick Deploy (5 minutes)

```bash
cd /home/cloudenv/PERSONAL-PROJECT/localstack/Projet1

# 1. Start LocalStack and deploy everything
make setup

# 2. Deploy the website
make deploy-website

# 3. View your site
curl http://localhost:4566/development-state-lock-projet1-serverless/index.html
```

That's it! Your website is now live. 🎉

## 📋 What Gets Deployed

✅ S3 Bucket with website hosting enabled
✅ CloudFront CDN distribution  
✅ Origin Access Identity for secure access
✅ CORS configuration for API integration
✅ Request logging to S3
✅ Custom error handling

## 🌐 Access Your Website

### Development (LocalStack)
```
http://localhost:4566/development-state-lock-projet1-serverless/
```

### Production (AWS)
```
https://<your-cloudfront-domain>.cloudfront.net/
```

## 📁 Website Structure

```
website/
├── index.html      # Main landing page with product showcase
└── error.html      # Custom 404 error page
```

## ✏️ Customize Your Website

Edit the files and redeploy:

```bash
# Edit the homepage
nano website/index.html

# Update on S3
make deploy-website

# Clear cache (optional)
make invalidate-cache
```

## 🔍 Verify Deployment

```bash
# Check S3 bucket
aws s3 ls s3://development-state-lock-projet1-serverless \
  --endpoint-url=http://localhost:4566 \
  --recursive

# Get CloudFront info
cd terraform && terraform output cloudfront_domain_name

# Test website access
curl -I http://localhost:4566/development-state-lock-projet1-serverless/index.html
```

## 📊 Monitor Your Site

```bash
# View CloudFront metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name Requests \
  --start-time 2025-01-01T00:00:00Z \
  --end-time 2025-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum

# View S3 request logs
aws s3 cp s3://development-state-lock-projet1-serverless/logs/ logs/ \
  --recursive \
  --endpoint-url=http://localhost:4566
```

## 🔧 Management Commands

```bash
# Deploy website
make deploy-website

# Invalidate CloudFront cache (after updates)
make invalidate-cache

# Add new pages
cp my-page.html website/
make deploy-website

# View infrastructure outputs
cd terraform && terraform output

# Stop everything
make stop

# Clean up completely
make clean
```

## 🎯 Next Steps

1. **Add More Pages** - Create additional HTML files in the `website/` folder
2. **Connect API** - Point the product grid to your API Gateway endpoint
3. **Custom Domain** - Add Route53 DNS records (production)
4. **Security** - Add WAF rules and API keys (production)
5. **Monitoring** - Set up CloudWatch alarms

## 📚 Learn More

- See `S3_WEBSITE_GUIDE.md` for detailed documentation
- Check `EXECUTION_GUIDE.md` for infrastructure details
- Review `README.md` for project overview

## ⚡ Performance Tips

- Files are cached by CloudFront (1 hour default)
- Compression is automatically enabled
- Edge locations serve content globally
- S3 logs all requests for analytics

## 🐛 Troubleshooting

**Website not loading?**
```bash
# Check S3 bucket exists
aws s3 ls --endpoint-url=http://localhost:4566

# Check files uploaded
make test

# View logs
docker-compose logs -f localstack
```

**Old content showing?**
```bash
# Clear CloudFront cache
make invalidate-cache

# Wait 1 hour for default TTL
```

**Changes not appearing?**
```bash
# Redeploy website
make deploy-website

# Or manually update file
aws s3 cp website/index.html s3://development-state-lock-projet1-serverless/ \
  --endpoint-url=http://localhost:4566
```

## 💡 Pro Tips

1. Use `make setup` for complete fresh deployment
2. Edit files locally, then `make deploy-website` to update
3. Check `terraform output` for all resource URLs
4. Monitor CloudFront metrics in CloudWatch
5. Keep S3 versioning enabled for rollbacks

---

**Questions?** Check the detailed guides or view the Terraform configuration in `terraform/state_backend.tf`.

Happy deploying! 🚀

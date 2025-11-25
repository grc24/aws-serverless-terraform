# Project 1: The Serverless "Three-Tier" Backend

## Production Context
A high-traffic e-commerce product catalog. You need sub-millisecond latency for product lookups and a RESTful API interface for the frontend, without managing servers.

## SAA-C03 Concepts
- API Gateway integration types
- DynamoDB Partition Keys
- IAM Execution Roles

## Architecture

```
Client -> API Gateway -> Lambda -> DynamoDB
```

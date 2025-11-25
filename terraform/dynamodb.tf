resource "aws_dynamodb_table" "products" {
  name           = var.dynamodb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "product_id"

  # Primary Key
  attribute {
    name = "product_id"
    type = "S"
  }

  # Global Secondary Index - Query by category
  attribute {
    name = "category"
    type = "S"
  }

  global_secondary_index {
    name            = "category-index"
    hash_key        = "category"
    read_capacity   = var.read_capacity
    write_capacity  = var.write_capacity
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }

  tags = {
    Name = "Product Catalog Table"
  }
}

# Table Schema Documentation:
# Partition Key: product_id (String)
# 
# Item Structure (as used by Lambda):
# {
#   "product_id": "unique-id",           # Required - String (S)
#   "name": "Product Name",              # Required - String (S)
#   "price": 99.99,                      # Required - Number (N)
#   "category": "Electronics",           # Optional - String (S) - Queryable via GSI
#   "description": "Product desc",       # Optional - String (S)
#   "stock": 100,                        # Optional - Number (N)
#   "expiration_time": 1735689600        # Optional - Number (N) - TTL attribute
# }
#
# Global Secondary Index: category-index
# Allows querying products by category
#
# All non-key attributes are stored dynamically (schemaless)

import boto3
import json
import logging
import os
from decimal import Decimal

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# DynamoDB client - use environment variable for endpoint or default to localhost
dynamodb_endpoint = os.environ.get('DYNAMODB_ENDPOINT', 'http://localhost:4566')
dynamodb = boto3.client('dynamodb', endpoint_url=dynamodb_endpoint, region_name='eu-west-3')
TABLE_NAME = 'products-catalog'

# SNS client for notifications
sns_endpoint = os.environ.get('DYNAMODB_ENDPOINT', 'http://localhost:4566')  # Use same endpoint as DynamoDB
sns = boto3.client('sns', endpoint_url=sns_endpoint, region_name='eu-west-3')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN', '')

class DecimalEncoder(json.JSONEncoder):
    """Helper class to convert DynamoDB Decimal types to float for JSON serialization"""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def parse_body(body):
    """Parse request body"""
    if isinstance(body, str):
        return json.loads(body)
    return body

def send_notification(product_id, product_name, action="created"):
    """Send SNS notification when product is created"""
    if not SNS_TOPIC_ARN:
        logger.warning("SNS_TOPIC_ARN not configured. Skipping notification.")
        return
    
    try:
        message = f"""
Product {action.upper()}!

Product ID: {product_id}
Product Name: {product_name}
Timestamp: {json.dumps(product_id)}

This is an automated notification from Projet1 Serverless Backend.
        """.strip()
        
        subject = f"Product {action.capitalize()}: {product_name}"
        
        response = sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=subject,
            Message=message
        )
        
        logger.info(f"Notification sent for product {product_id}. MessageId: {response.get('MessageId')}")
        return response
    except Exception as e:
        logger.error(f"Error sending SNS notification: {str(e)}")
        # Don't fail the request if notification fails
        return None

def put_product(body):
    """Create or update a product"""
    try:
        product_data = parse_body(body)
        
        required_fields = ['product_id', 'name', 'price']
        if not all(field in product_data for field in required_fields):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Missing required fields: product_id, name, price'})
            }
        
        item = {
            'product_id': {'S': str(product_data['product_id'])},
            'name': {'S': str(product_data['name'])},
            'price': {'N': str(product_data['price'])},
        }
        
        # Add optional fields
        if 'category' in product_data:
            item['category'] = {'S': str(product_data['category'])}
        if 'description' in product_data:
            item['description'] = {'S': str(product_data['description'])}
        if 'stock' in product_data:
            item['stock'] = {'N': str(product_data['stock'])}
        
        dynamodb.put_item(TableName=TABLE_NAME, Item=item)
        
        logger.info(f"Product created/updated: {product_data['product_id']}")
        
        # Send SNS notification
        send_notification(
            product_data['product_id'],
            product_data['name'],
            action="created"
        )
        
        return {
            'statusCode': 201,
            'body': json.dumps({
                'message': 'Product created/updated successfully',
                'product_id': product_data['product_id']
            })
        }
    except Exception as e:
        logger.error(f"Error putting item: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Internal server error: {str(e)}'})
        }

def get_product(product_id):
    """Get a single product by ID"""
    try:
        response = dynamodb.get_item(
            TableName=TABLE_NAME,
            Key={'product_id': {'S': product_id}}
        )
        
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': f'Product {product_id} not found'})
            }
        
        item = response['Item']
        product = {
            'product_id': item['product_id']['S'],
            'name': item['name']['S'],
            'price': float(item['price']['N']),
        }
        
        if 'category' in item:
            product['category'] = item['category']['S']
        if 'description' in item:
            product['description'] = item['description']['S']
        if 'stock' in item:
            product['stock'] = int(item['stock']['N'])
        
        logger.info(f"Product retrieved: {product_id}")
        return {
            'statusCode': 200,
            'body': json.dumps(product)
        }
    except Exception as e:
        logger.error(f"Error getting item: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Internal server error: {str(e)}'})
        }

def get_all_products():
    """List all products"""
    try:
        response = dynamodb.scan(TableName=TABLE_NAME)
        
        products = []
        for item in response.get('Items', []):
            product = {
                'product_id': item['product_id']['S'],
                'name': item['name']['S'],
                'price': float(item['price']['N']),
            }
            
            if 'category' in item:
                product['category'] = item['category']['S']
            if 'description' in item:
                product['description'] = item['description']['S']
            if 'stock' in item:
                product['stock'] = int(item['stock']['N'])
            
            products.append(product)
        
        logger.info(f"Retrieved {len(products)} products")
        return {
            'statusCode': 200,
            'body': json.dumps({
                'count': len(products),
                'products': products
            })
        }
    except Exception as e:
        logger.error(f"Error scanning items: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Internal server error: {str(e)}'})
        }

def delete_product(product_id):
    """Delete a product"""
    try:
        # Check if product exists
        response = dynamodb.get_item(
            TableName=TABLE_NAME,
            Key={'product_id': {'S': product_id}}
        )
        
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': f'Product {product_id} not found'})
            }
        
        dynamodb.delete_item(
            TableName=TABLE_NAME,
            Key={'product_id': {'S': product_id}}
        )
        
        logger.info(f"Product deleted: {product_id}")
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Product {product_id} deleted successfully'
            })
        }
    except Exception as e:
        logger.error(f"Error deleting item: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Internal server error: {str(e)}'})
        }

def handler(event, context):
    """Main Lambda handler for REST API v1 (LocalStack compatible)"""
    logger.info(f"Event: {json.dumps(event)}")
    
    try:
        # REST API v1 event format
        http_method = event.get('httpMethod', '')
        path = event.get('path', '')
        body = event.get('body', '')
        
        # Extract product_id from path parameters if present
        path_parameters = event.get('pathParameters', {})
        product_id = path_parameters.get('product_id') if path_parameters else None
        
        logger.info(f"Method: {http_method}, Path: {path}, ProductId: {product_id}")
        
        # Route to appropriate handler
        if http_method == 'PUT' and '/products' in path:
            return put_product(body)
        
        elif http_method == 'GET' and path == '/products/{product_id}' and product_id:
            return get_product(product_id)
        
        elif http_method == 'GET' and path == '/products':
            return get_all_products()
        
        elif http_method == 'DELETE' and product_id:
            return delete_product(product_id)
        
        else:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Invalid request'})
            }
    
    except Exception as e:
        logger.error(f"Unhandled error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Internal server error: {str(e)}'})
        }
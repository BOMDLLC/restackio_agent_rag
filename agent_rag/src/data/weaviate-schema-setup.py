import weaviate
from weaviate.util import get_valid_uuid

# Connect to Weaviate
client = weaviate.Client("http://localhost:8080")

# Define the schema for the SalesItem class
schema = {
    "classes": [
        {
            "class": "SalesItem",
            "description": "An item that is on sale",
            "properties": [
                {
                    "name": "item_id",
                    "dataType": ["int"],
                    "description": "The unique identifier for the item"
                },
                {
                    "name": "type",
                    "dataType": ["string"],
                    "description": "The type/category of the item"
                },
                {
                    "name": "name",
                    "dataType": ["string"],
                    "description": "The name of the item"
                },
                {
                    "name": "retail_price_usd",
                    "dataType": ["number"],
                    "description": "The regular retail price in USD"
                },
                {
                    "name": "sale_price_usd",
                    "dataType": ["number"],
                    "description": "The discounted sale price in USD"
                },
                {
                    "name": "sale_discount_pct",
                    "dataType": ["int"],
                    "description": "The discount percentage"
                }
            ],
            "vectorizer": "text2vec-openai",  # Choose appropriate vectorizer
            "moduleConfig": {
                "text2vec-openai": {  # Configuration for the vectorizer
                    "model": "ada",
                    "modelVersion": "002",
                    "vectorizeClassName": True
                }
            }
        }
    ]
}

# Create schema
client.schema.create(schema)

# Sample data to insert
items = [
    {
        "item_id": 101,
        "type": "snowboard",
        "name": "Alpine Blade",
        "retail_price_usd": 450,
        "sale_price_usd": 360,
        "sale_discount_pct": 20,
    },
    {
        "item_id": 102,
        "type": "snowboard",
        "name": "Peak Bomber",
        "retail_price_usd": 499,
        "sale_price_usd": 374,
        "sale_discount_pct": 25,
    },
    {
        "item_id": 201,
        "type": "apparel",
        "name": "Thermal Jacket",
        "retail_price_usd": 120,
        "sale_price_usd": 84,
        "sale_discount_pct": 30,
    },
    {
        "item_id": 202,
        "type": "apparel",
        "name": "Insulated Pants",
        "retail_price_usd": 150,
        "sale_price_usd": 112,
        "sale_discount_pct": 25,
    },
    {
        "item_id": 301,
        "type": "boots",
        "name": "Glacier Grip",
        "retail_price_usd": 250,
        "sale_price_usd": 200,
        "sale_discount_pct": 20,
    },
    {
        "item_id": 302,
        "type": "boots",
        "name": "Summit Steps",
        "retail_price_usd": 300,
        "sale_price_usd": 210,
        "sale_discount_pct": 30,
    },
    {
        "item_id": 401,
        "type": "accessories",
        "name": "Goggles",
        "retail_price_usd": 80,
        "sale_price_usd": 60,
        "sale_discount_pct": 25,
    },
    {
        "item_id": 402,
        "type": "accessories",
        "name": "Warm Gloves",
        "retail_price_usd": 60,
        "sale_price_usd": 48,
        "sale_discount_pct": 20,
    },
]

# Insert data
with client.batch as batch:
    batch.batch_size = 100
    
    for item in items:
        # Create a unique ID for each item
        item_uuid = get_valid_uuid(str(item["item_id"]))
        
        # Add object to batch
        batch.add_data_object(
            data_object=item,
            class_name="SalesItem",
            uuid=item_uuid
        )

print("Schema created and data loaded successfully!")

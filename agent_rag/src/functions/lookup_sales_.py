import os
from typing import List

import weaviate
from pydantic import BaseModel
from restack_ai.function import NonRetryableError, function, log


class SalesItem(BaseModel):
    item_id: int
    type: str
    name: str
    retail_price_usd: float
    sale_price_usd: float
    sale_discount_pct: int


@function.defn()
async def lookup_sales(query: str = "") -> str:
    try:
        log.info("lookup_sales function started with query: {query}")
        
        # Connect to Weaviate
        weaviate_url = os.getenv("WEAVIATE_URL", "http://localhost:8080")
        weaviate_api_key = os.getenv("WEAVIATE_API_KEY")
        
        # Configure authentication if API key is provided
        auth_config = None
        if weaviate_api_key:
            auth_config = weaviate.auth.AuthApiKey(api_key=weaviate_api_key)
        
        # Initialize Weaviate client
        client = weaviate.Client(
            url=weaviate_url,
            auth_client_secret=auth_config,
        )
        
        # Verify connection
        if not client.is_ready():
            raise Exception("Weaviate server is not ready")
        
        # Build the query based on user input
        # If query is empty, return all sales items
        search_params = {
            "class_name": "SalesItem",
            "properties": ["item_id", "type", "name", "retail_price_usd", "sale_price_usd", "sale_discount_pct"],
            "limit": 10
        }
        
        if query:
            # Use semantic search if there's a query
            results = (
                client.query
                .get(**search_params)
                .with_near_text({"concepts": [query]})
                .with_additional(["certainty"])
                .do()
            )
        else:
            # Otherwise just get all items on sale
            results = client.query.get(**search_params).do()
        
        # Extract data from results
        items: List[SalesItem] = []
        
        if "data" in results and "Get" in results["data"] and "SalesItem" in results["data"]["Get"]:
            weaviate_items = results["data"]["Get"]["SalesItem"]
            
            for item_data in weaviate_items:
                item = SalesItem(
                    item_id=item_data.get("item_id"),
                    type=item_data.get("type"),
                    name=item_data.get("name"),
                    retail_price_usd=item_data.get("retail_price_usd"),
                    sale_price_usd=item_data.get("sale_price_usd"),
                    sale_discount_pct=item_data.get("sale_discount_pct")
                )
                items.append(item)
        
        # Return serialized items
        return str(items)
    except Exception as e:
        error_message = f"lookup_sales function failed: {e}"
        log.error(error_message)
        raise NonRetryableError(error_message) from e

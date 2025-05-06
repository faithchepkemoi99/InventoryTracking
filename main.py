from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

# Database connection
conn = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)
cursor = conn.cursor(dictionary=True)

app = FastAPI()

# Pydantic models
class Product(BaseModel):
    product_name: str
    categoryID: int
    supplierID: int
    price: float
    stock_quantity: int

class ProductUpdate(Product):
    productID: int

class ProductOut(Product):
    productID: int

# Route to initialize DB from SQL file
@app.post("/setup-db")
def setup_database():
    try:
        with open("inventory_schema.sql", "r") as f:
            sql_script = f.read()
        for statement in sql_script.strip().split(';'):
            if statement.strip():
                cursor.execute(statement)
        conn.commit()
        return {"message": "Database setup completed."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Routes
@app.post("/products/", response_model=ProductOut)
def add_product(product: Product):
    query = """
        INSERT INTO products (product_name, categoryID, supplierID, price, stock_quantity)
        VALUES (%s, %s, %s, %s, %s)
    """
    cursor.execute(query, (product.product_name, product.categoryID, product.supplierID, product.price, product.stock_quantity))
    conn.commit()
    product_id = cursor.lastrowid
    return {"productID": product_id, **product.dict()}

@app.get("/products/", response_model=List[ProductOut])
def get_products():
    cursor.execute("SELECT * FROM products")
    result = cursor.fetchall()
    return result

@app.put("/products/{product_id}")
def update_product(product_id: int, product: Product):
    cursor.execute("SELECT * FROM products WHERE productID = %s", (product_id,))
    if not cursor.fetchone():
        raise HTTPException(status_code=404, detail="Product not found")

    update_query = """
        UPDATE products
        SET product_name=%s, categoryID=%s, supplierID=%s, price=%s, stock_quantity=%s
        WHERE productID=%s
    """
    cursor.execute(update_query, (product.product_name, product.categoryID, product.supplierID, product.price, product.stock_quantity, product_id))
    conn.commit()
    return {"message": "Product updated"}

@app.delete("/products/{product_id}")
def delete_product(product_id: int):
    cursor.execute("SELECT * FROM products WHERE productID = %s", (product_id,))
    if not cursor.fetchone():
        raise HTTPException(status_code=404, detail="Product not found")

    cursor.execute("DELETE FROM products WHERE productID = %s", (product_id,))
    conn.commit()
    return {"message": "Product deleted"}

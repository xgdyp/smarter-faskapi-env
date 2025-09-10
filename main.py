from typing import Optional
from fastapi import FastAPI
from pydantic import BaseModel

# 实例化 FastAPI
app = FastAPI()

# 示例数据模型
class Item(BaseModel):
    name: str
    price: float
    is_offer: Optional[bool] = None

# --- 路由定义 ---

# 根路由：返回一个简单的 JSON 消息
@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI"}

# 带有路径参数的路由
# URL: /items/5?q=somequery
@app.get("/items/{item_id}")
def read_item(item_id: int, q: Optional[str] = None):
    return {"item_id": item_id, "q": q}

# POST 请求：接收 JSON 数据
@app.post("/items/")
def create_item(item: Item):
    return {"item_name": item.name, "item_price": item.price}
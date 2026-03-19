from typing import Annotated
from pydantic import BaseModel, Field
from fastapi import APIRouter, Path, Query,Cookie
router = APIRouter()

class User(BaseModel):
    model_config = {"extra":"forbid"}
    age:int = Field(le=100,gt=0)
    name : str = Field('default_name',max_length=20)
    tags : list[str] = []

@router.get("/user")
async def get_user():
    return ""

@router.get("/user/setInfo")
async def setInfo(userInfo:Annotated[User,Query()]):
    return userInfo

@router.get("/user/items/{item_id}")
async def read_user_items(
    item_id: Annotated[int, Path(title="The ID of the item to get")],
    q: Annotated[str | None, Query(alias="item-query",max_length=30)] = None,
):
    results = {"item_id": item_id}
    if q:
        results.update({"q": q})
    return results

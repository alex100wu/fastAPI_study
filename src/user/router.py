from typing import Annotated

from fastapi import APIRouter, Path, Query

router = APIRouter()


@router.get("/user")
async def get_user():
    return ""


@router.get("/user/items/{item_id}")
async def read_user_items(
    item_id: Annotated[int, Path(title="The ID of the item to get")],
    q: Annotated[str | None, Query(alias="item-query")] = None,
):
    results = {"item_id": item_id}
    if q:
        results.update({"q": q})
    return results

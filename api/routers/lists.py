from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from api import models, schemas
from api.database import get_db

router = APIRouter()


@router.get("/", response_model=List[schemas.ListResponse])
def list_grocery_lists(db: Session = Depends(get_db)):
    return db.query(models.GroceryList).all()


@router.post("/", response_model=schemas.ListResponse, status_code=201)
def create_list(grocery_list: schemas.ListCreate, db: Session = Depends(get_db)):
    db_list = models.GroceryList(**grocery_list.model_dump())
    db.add(db_list)
    db.commit()
    db.refresh(db_list)
    return db_list


@router.get("/{list_id}", response_model=schemas.ListDetailResponse)
def get_list(list_id: int, db: Session = Depends(get_db)):
    grocery_list = db.query(models.GroceryList).filter(models.GroceryList.id == list_id).first()
    if not grocery_list:
        raise HTTPException(status_code=404, detail="List not found")
    return grocery_list


@router.delete("/{list_id}", status_code=204)
def delete_list(list_id: int, db: Session = Depends(get_db)):
    grocery_list = db.query(models.GroceryList).filter(models.GroceryList.id == list_id).first()
    if not grocery_list:
        raise HTTPException(status_code=404, detail="List not found")
    db.delete(grocery_list)
    db.commit()


@router.post("/{list_id}/items", response_model=schemas.ListItemResponse, status_code=201)
def add_list_item(list_id: int, item: schemas.ListItemCreate, db: Session = Depends(get_db)):
    grocery_list = db.query(models.GroceryList).filter(models.GroceryList.id == list_id).first()
    if not grocery_list:
        raise HTTPException(status_code=404, detail="List not found")
    db_item = models.ListItem(list_id=list_id, **item.model_dump())
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item


@router.patch("/{list_id}/items/{item_id}", response_model=schemas.ListItemResponse)
def update_list_item(
    list_id: int,
    item_id: int,
    updates: schemas.ListItemUpdate,
    db: Session = Depends(get_db),
):
    item = db.query(models.ListItem).filter(
        models.ListItem.id == item_id,
        models.ListItem.list_id == list_id,
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="List item not found")
    for field, value in updates.model_dump(exclude_none=True).items():
        setattr(item, field, value)
    db.commit()
    db.refresh(item)
    return item


@router.delete("/{list_id}/items/{item_id}", status_code=204)
def delete_list_item(list_id: int, item_id: int, db: Session = Depends(get_db)):
    item = db.query(models.ListItem).filter(
        models.ListItem.id == item_id,
        models.ListItem.list_id == list_id,
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="List item not found")
    db.delete(item)
    db.commit()

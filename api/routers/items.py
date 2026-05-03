from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from api import models, schemas
from api.database import get_db
from api.prediction import predict_runout_date

router = APIRouter()


@router.get("/", response_model=List[schemas.ItemResponse])
def list_items(
    category_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
):
    query = db.query(models.Item)
    if category_id is not None:
        query = query.filter(models.Item.category_id == category_id)
    return query.all()


@router.post("/", response_model=schemas.ItemResponse, status_code=201)
def create_item(item: schemas.ItemCreate, db: Session = Depends(get_db)):
    category_name = None
    if item.category_id:
        category = db.query(models.Category).filter(models.Category.id == item.category_id).first()
        category_name = category.name if category else None

    db_item = models.Item(
        **item.model_dump(),
        predicted_runout_date=predict_runout_date(category_name),
    )
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item


@router.get("/{item_id}", response_model=schemas.ItemResponse)
def get_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(models.Item).filter(models.Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@router.patch("/{item_id}", response_model=schemas.ItemResponse)
def update_item(item_id: int, updates: schemas.ItemUpdate, db: Session = Depends(get_db)):
    item = db.query(models.Item).filter(models.Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    for field, value in updates.model_dump(exclude_none=True).items():
        setattr(item, field, value)

    # Recompute runout date when category changes
    if updates.category_id is not None:
        category = db.query(models.Category).filter(models.Category.id == updates.category_id).first()
        item.predicted_runout_date = predict_runout_date(
            category.name if category else None, item.date_added
        )

    db.commit()
    db.refresh(item)
    return item


@router.delete("/{item_id}", status_code=204)
def delete_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(models.Item).filter(models.Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    db.delete(item)
    db.commit()

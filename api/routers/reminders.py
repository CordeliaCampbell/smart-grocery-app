from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from api import models, schemas
from api.database import get_db

router = APIRouter()


@router.get("/", response_model=List[schemas.ReminderResponse])
def list_reminders(db: Session = Depends(get_db)):
    return db.query(models.Reminder).all()


@router.post("/", response_model=schemas.ReminderResponse, status_code=201)
def create_reminder(reminder: schemas.ReminderCreate, db: Session = Depends(get_db)):
    item = db.query(models.Item).filter(models.Item.id == reminder.item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    db_reminder = models.Reminder(**reminder.model_dump())
    db.add(db_reminder)
    db.commit()
    db.refresh(db_reminder)
    return db_reminder


@router.patch("/{reminder_id}", response_model=schemas.ReminderResponse)
def update_reminder(
    reminder_id: int,
    updates: schemas.ReminderUpdate,
    db: Session = Depends(get_db),
):
    reminder = db.query(models.Reminder).filter(models.Reminder.id == reminder_id).first()
    if not reminder:
        raise HTTPException(status_code=404, detail="Reminder not found")
    for field, value in updates.model_dump(exclude_none=True).items():
        setattr(reminder, field, value)
    db.commit()
    db.refresh(reminder)
    return reminder


@router.delete("/{reminder_id}", status_code=204)
def delete_reminder(reminder_id: int, db: Session = Depends(get_db)):
    reminder = db.query(models.Reminder).filter(models.Reminder.id == reminder_id).first()
    if not reminder:
        raise HTTPException(status_code=404, detail="Reminder not found")
    db.delete(reminder)
    db.commit()

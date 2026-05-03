from datetime import date
from typing import List, Optional

from pydantic import BaseModel


# ─────────────────────────────────────────
# Category
# ─────────────────────────────────────────

class CategoryCreate(BaseModel):
    name: str
    default_runout_days: int = 14
    icon: Optional[str] = None


class CategoryResponse(BaseModel):
    id: int
    name: str
    default_runout_days: int
    icon: Optional[str]

    model_config = {"from_attributes": True}


# ─────────────────────────────────────────
# Item
# ─────────────────────────────────────────

class ItemCreate(BaseModel):
    name: str
    category_id: Optional[int] = None
    quantity: int = 1
    unit: str = "unit"
    reminder_enabled: bool = True


class ItemUpdate(BaseModel):
    name: Optional[str] = None
    category_id: Optional[int] = None
    quantity: Optional[int] = None
    unit: Optional[str] = None
    reminder_enabled: Optional[bool] = None


class ItemResponse(BaseModel):
    id: int
    name: str
    category_id: Optional[int]
    quantity: int
    unit: str
    date_added: date
    predicted_runout_date: Optional[date]
    reminder_enabled: bool

    model_config = {"from_attributes": True}


# ─────────────────────────────────────────
# List + ListItem
# ─────────────────────────────────────────

class ListItemCreate(BaseModel):
    item_name: str
    quantity: int = 1
    unit: str = "unit"


class ListItemUpdate(BaseModel):
    checked: Optional[bool] = None
    quantity: Optional[int] = None
    unit: Optional[str] = None


class ListItemResponse(BaseModel):
    id: int
    item_name: str
    quantity: int
    unit: str
    checked: bool

    model_config = {"from_attributes": True}


class ListCreate(BaseModel):
    name: str
    list_type: str = "custom"


class ListResponse(BaseModel):
    id: int
    name: str
    list_type: str

    model_config = {"from_attributes": True}


class ListDetailResponse(ListResponse):
    list_items: List[ListItemResponse] = []


# ─────────────────────────────────────────
# Reminder
# ─────────────────────────────────────────

class ReminderCreate(BaseModel):
    item_id: int
    scheduled_date: date


class ReminderUpdate(BaseModel):
    sent: Optional[bool] = None
    scheduled_date: Optional[date] = None


class ReminderResponse(BaseModel):
    id: int
    item_id: int
    scheduled_date: date
    sent: bool

    model_config = {"from_attributes": True}


# ─────────────────────────────────────────
# Image analysis
# ─────────────────────────────────────────

class DetectedItem(BaseModel):
    name: str
    category: str
    confidence: float = 1.0


class ImageAnalysisResponse(BaseModel):
    detected_items: List[DetectedItem]
    image_id: int

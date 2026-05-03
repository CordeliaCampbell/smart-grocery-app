from datetime import date, datetime

from sqlalchemy import JSON, Boolean, Column, Date, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from api.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    items = relationship("Item", back_populates="user")
    lists = relationship("GroceryList", back_populates="user")


class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    default_runout_days = Column(Integer, default=14)
    icon = Column(String(50))

    items = relationship("Item", back_populates="category")


class Item(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=True)
    name = Column(String(255), nullable=False)
    quantity = Column(Integer, default=1)
    unit = Column(String(50), default="unit")
    date_added = Column(Date, default=date.today)
    predicted_runout_date = Column(Date, nullable=True)
    reminder_enabled = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", back_populates="items")
    category = relationship("Category", back_populates="items")
    reminders = relationship("Reminder", back_populates="item", cascade="all, delete-orphan")


class GroceryList(Base):
    __tablename__ = "lists"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    name = Column(String(255), nullable=False)
    list_type = Column(String(100), default="custom")
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="lists")
    list_items = relationship("ListItem", back_populates="grocery_list", cascade="all, delete-orphan")


class ListItem(Base):
    __tablename__ = "list_items"

    id = Column(Integer, primary_key=True, index=True)
    list_id = Column(Integer, ForeignKey("lists.id"), nullable=False)
    item_name = Column(String(255), nullable=False)
    quantity = Column(Integer, default=1)
    unit = Column(String(50), default="unit")
    checked = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    grocery_list = relationship("GroceryList", back_populates="list_items")


class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(Integer, primary_key=True, index=True)
    item_id = Column(Integer, ForeignKey("items.id"), nullable=False)
    scheduled_date = Column(Date, nullable=False)
    sent = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    item = relationship("Item", back_populates="reminders")


class UploadedImage(Base):
    __tablename__ = "uploaded_images"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    file_path = Column(String(500), nullable=False)
    vision_response = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

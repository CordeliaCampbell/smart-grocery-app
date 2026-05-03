# API Reference

Base URL: `http://localhost:8000`  
Interactive docs: `http://localhost:8000/docs`

## Items

| Method | Path | Description |
|--------|------|-------------|
| GET | `/items/` | List all items (optional `?category_id=`) |
| POST | `/items/` | Create item |
| GET | `/items/{id}` | Get item |
| PATCH | `/items/{id}` | Update item (partial) |
| DELETE | `/items/{id}` | Delete item |

## Categories

| Method | Path | Description |
|--------|------|-------------|
| GET | `/categories/` | List all categories |
| POST | `/categories/` | Create category |
| GET | `/categories/{id}` | Get category |

## Lists

| Method | Path | Description |
|--------|------|-------------|
| GET | `/lists/` | List all grocery lists |
| POST | `/lists/` | Create list |
| GET | `/lists/{id}` | Get list with items |
| DELETE | `/lists/{id}` | Delete list |
| POST | `/lists/{id}/items` | Add item to list |
| PATCH | `/lists/{id}/items/{item_id}` | Update list item (check/uncheck) |
| DELETE | `/lists/{id}/items/{item_id}` | Remove item from list |

## Reminders

| Method | Path | Description |
|--------|------|-------------|
| GET | `/reminders/` | List all reminders |
| POST | `/reminders/` | Create reminder |
| PATCH | `/reminders/{id}` | Update reminder (mark sent / reschedule) |
| DELETE | `/reminders/{id}` | Delete reminder |

## Images

| Method | Path | Description |
|--------|------|-------------|
| POST | `/images/analyze` | Upload image → detect items (requires `OPENAI_API_KEY`) |

### Image analysis request

`multipart/form-data` with field `file` (image/jpeg or image/png).

### Image analysis response

```json
{
  "image_id": 1,
  "detected_items": [
    { "name": "Milk", "category": "Dairy", "confidence": 0.95 },
    { "name": "Eggs", "category": "Eggs",  "confidence": 0.88 }
  ]
}
```

## Health check

`GET /health` → `{ "status": "ok" }`

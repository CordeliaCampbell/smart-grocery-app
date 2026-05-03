# Smart Grocery App — SwiftUI + MySQL MVP

## Problem
Build a solo-developer iOS MVP that lets users photograph grocery/household items, confirm AI-detected items, track inventory in MySQL, predict run-out dates, and send local reminders.

## Architecture Overview
Three layers:
1. **iOS app** (Swift/SwiftUI, MVVM) — all UI, local notifications, image capture
2. **REST API** (Python FastAPI) — thin bridge between iOS and MySQL; handles image-to-item detection via OpenAI Vision
3. **MySQL database** — canonical store for items, lists, categories, reminders

## Project Layout
```
smart-grocery-app/
├── ios/SmartGrocery/         # Xcode project
│   ├── App/
│   ├── Models/
│   ├── ViewModels/
│   ├── Views/
│   └── Services/
├── api/                      # FastAPI backend
│   ├── main.py
│   ├── routers/
│   ├── models.py
│   └── requirements.txt
├── db/
│   └── schema.sql
├── docs/
├── history/
└── Taskfile.yml
```

## Database Schema
Seven tables: `users`, `categories`, `items`, `lists`, `list_items`, `reminders`, `uploaded_images`.
Key design choices:
- `items.predicted_runout_date` computed server-side from category default rules
- `reminders` stores scheduled date + whether push was sent
- `uploaded_images` stores S3/local path + raw Vision API JSON response for reprocessing

## API Layer (FastAPI)
Endpoints grouped into routers:
- `POST /images/analyze` — accepts multipart image, calls OpenAI Vision, returns detected item list
- `GET/POST/PATCH/DELETE /items` — inventory CRUD
- `GET/POST /lists` + `GET/POST/DELETE /lists/{id}/items`
- `GET/POST /categories`
- `GET/POST/PATCH /reminders`

Prediction logic lives in `api/prediction.py`: rule-based lookup by category (e.g. Dairy → 7 days, Paper Products → 28 days) with a fallback of 14 days.

## iOS App (SwiftUI MVVM)
**Models** (plain Swift structs mirroring API responses): `Item`, `Category`, `GroceryList`, `ListItem`, `Reminder`

**Services**:
- `APIService` — `URLSession`-based, async/await, maps to/from `Codable` models
- `NotificationService` — `UNUserNotificationCenter` wrapper, schedules/cancels local notifications
- `ImageRecognitionService` — wraps `POST /images/analyze`, returns `[DetectedItem]`

**ViewModels + Views** (one pair per screen):
- `HomeView` / `HomeViewModel` — summary dashboard, upcoming run-outs
- `UploadView` / `UploadViewModel` — `PhotosUI` picker + camera via `AVFoundation`, calls `ImageRecognitionService`
- `ConfirmItemsView` / `ConfirmItemsViewModel` — editable list of detected items before saving
- `InventoryView` / `InventoryViewModel` — full item list, search, filter by category
- `ListsView` / `ListsViewModel` — grocery/supply lists
- `CategoriesView` — simple category browser
- `RemindersView` / `RemindersViewModel` — toggle reminders per item, view schedule

**Local caching**: `SwiftData` models shadow the API responses so the app works offline.

## Prediction Rules (MVP)
Category-to-days lookup in `api/prediction.py`:
- Dairy → 7, Produce → 5, Eggs → 12, Frozen → 30
- Cleaning/Laundry → 28, Paper Products → 21
- Skincare/Haircare → 45, Medicine → 60
- Default fallback → 14

## Image Recognition Flow
`UploadView` → user picks/captures photo → `ImageRecognitionService.analyze(image)` → `POST /images/analyze` → FastAPI calls OpenAI `gpt-4o` with vision → returns JSON array of item names + categories → `ConfirmItemsView` lets user edit → confirmed items `POST /items`.

## Phases

**Phase 1 — Foundation**
- MySQL schema + seed data
- FastAPI skeleton with DB connection (SQLAlchemy + PyMySQL)
- Taskfile with `task db:migrate`, `task api:dev`, `task api:test`

**Phase 2 — API**
- Items, categories, lists, reminders routers
- Prediction logic
- Image analysis endpoint
- pytest suite (≥75% coverage)

**Phase 3 — iOS App**
- Xcode project scaffold, SwiftData models, `APIService`
- All screens in order: Home → Upload → Confirm → Inventory → Lists → Reminders
- `NotificationService` integration

**Phase 4 — Polish**
- Offline caching via SwiftData sync
- Error states + empty states
- Reminder scheduling end-to-end test

## Key Constraints
- API key for OpenAI stored in `secrets/.env`, never in code
- All docs go in `docs/`, history in `history/`
- Files < 500 lines; split routers per resource
- Conventional Commits throughout

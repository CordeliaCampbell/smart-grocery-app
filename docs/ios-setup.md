# iOS App — Xcode Setup

All Swift source files are in `ios/SmartGrocery/`. Follow these steps to create the Xcode project and wire them in.

## 1. Create the Xcode project

1. Open Xcode → **File > New > Project**
2. Choose **iOS › App**
3. Fill in:
   - **Product Name**: `SmartGrocery`
   - **Interface**: SwiftUI
   - **Storage**: SwiftData
   - **Language**: Swift
4. Save into `ios/` (so the `.xcodeproj` sits at `ios/SmartGrocery.xcodeproj`)
5. Set the **Minimum Deployments** target to **iOS 17.0**

## 2. Replace the generated files

Delete the auto-generated `ContentView.swift` and `SmartGroceryApp.swift` that Xcode created.

Then **drag the entire `ios/SmartGrocery/` folder** into the project navigator (check "Create groups", uncheck "Copy items if needed").

Your project should have these groups:

```
SmartGrocery/
├── App/
│   ├── SmartGroceryApp.swift
│   └── ContentView.swift
├── Models/
├── ViewModels/
├── Views/
├── Services/
└── Utils/
```

## 3. Add required capabilities & Info.plist keys

In **Signing & Capabilities**, add:
- **Push Notifications** (for local notifications)
- **Background Modes › Background fetch** (optional, for sync)

In **Info.plist** (or the Info tab of your target), add:

| Key | Value |
|-----|-------|
| `NSPhotoLibraryUsageDescription` | "Needed to pick grocery photos from your library." |
| `NSCameraUsageDescription` | "Needed to photograph items for recognition." |
| `NSUserNotificationsUsageDescription` | "Needed to remind you when items are running low." |

## 4. Configure the API base URL

The app defaults to `http://localhost:8000`. When you deploy the FastAPI server elsewhere, change the constant in:

```
ios/SmartGrocery/Services/APIService.swift  →  static let baseURL
```

For production, add an `App Transport Security` exception or use HTTPS.

## 5. Build & run

Select a Simulator (iPhone 15 or newer) and press **⌘R**. The app will connect to whatever `baseURL` you configured.

## 6. Running the backend locally

```bash
# First time
task api:install
cp secrets/.env.example secrets/.env   # fill in your values

# Start the API
task api:dev
# → http://localhost:8000

# Apply the MySQL schema (requires MySQL running)
task db:migrate
```

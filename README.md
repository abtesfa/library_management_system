# 📚 Library Management System — Flutter Frontend

A production-grade, multi-role Library Management System built with **Flutter 3+** for Web, Android, iOS, and Desktop.

---

## 📁 Flutter Project Architecture

```
├── android/                             # Native Android configuration
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/com/example/library_management_system/MainActivity.kt
│   ├── build.gradle
│   └── settings.gradle
│
├── ios/                                 # Native iOS configuration
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   └── Info.plist
│   └── Podfile
│
├── web/                                 # Flutter Web runner
│   ├── index.html
│   └── manifest.json
│
├── test/                                # Widget & unit test suite
│   └── widget_test.dart
│
├── assets/                              # App assets
│   ├── images/
│   └── icons/
│
├── lib/                                 # Main Flutter Source Code
│   ├── main.dart                        # Main application shell with top header navigation
│   │
│   ├── config/                          # App configuration & route tables
│   │   ├── app_config.dart
│   │   └── routes.dart
│   │
│   ├── constants/                       # Theme colors & library business rules
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   │
│   ├── models/                          # Strongly-typed data models
│   │   ├── book.dart                    # Book & inventory model
│   │   ├── user.dart                    # User roles & default hardcoded credentials
│   │   ├── borrow_record.dart           # Circulation borrow & reservation models
│   │   └── staff.dart                   # Staff members & system settings
│   │
│   ├── data/                            # Initial seed & mock repository
│   │   └── mock_library_data.dart
│   │
│   ├── services/                        # State management & business logic (Provider)
│   │   ├── library_service.dart         # Books, loans, returns, and reservation state
│   │   └── auth_service.dart            # Multi-role login & session state
│   │
│   ├── theme/                           # Global Material 3 design system
│   │   └── app_theme.dart
│   │
│   ├── utils/                           # Formatters & helper functions
│   │   └── date_formatter.dart
│   │
│   ├── widgets/                         # Reusable UI widgets
│   │   ├── header/
│   │   │   └── top_header_bar.dart      # Full-width top navigation bar (No sidebar!)
│   │   ├── dialogs/
│   │   │   ├── sign_in_dialog.dart      # Default hardcoded credentials modal (Admin, Librarian, Reader)
│   │   │   └── add_book_dialog.dart
│   │   ├── cards/
│   │   │   └── book_card.dart
│   │   └── common/
│   │       └── status_pill.dart
│   │
│   └── screens/                         # Multi-Role Dashboard Screens
│       ├── landing/
│       │   └── landing_screen.dart      # Public landing page with featured books & search
│       │
│       ├── admin/                       # Administrator Portal
│       │   ├── admin_dashboard_screen.dart
│       │   ├── admin_inventory_screen.dart
│       │   ├── admin_settings_screen.dart
│       │   └── staff_management_screen.dart
│       │
│       ├── librarian/                   # Librarian Desk Portal
│       │   └── librarian_desk_screen.dart  # Counter circulation (Borrow & Return & Fines)
│       │
│       └── reader/                      # Reader/Student Portal
│           ├── reader_home_screen.dart     # Catalog & Book Reservations
│           ├── reader_my_books_screen.dart # Active Borrows & Renewals
│           └── reader_reservations_screen.dart # Reservation pickups
│
├── pubspec.yaml                         # Flutter dependencies & assets manifest
└── analysis_options.yaml                # Flutter linter configuration
```

---

## 🚀 How to Run

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run on Chrome (Flutter Web)
flutter run -d chrome

# 3. Or run on Android / iOS Simulator
flutter run
```

## 🔑 Default Hardcoded Credentials (1-Click Preset)

| Role | Email | Password | Target Dashboard |
|---|---|---|---|
| 👑 **Admin** | `admin@library.com` | `admin123` | Book Inventory, Staff, LMS Settings |
| 📖 **Librarian** | `librarian@library.com` | `lib123` | Desk Circulation, Borrow & Return |
| 🎓 **Reader** | `reader@library.com` | `reader123` | Reader Catalog, My Books, Holds |

# Library Management System — Flutter Frontend

A multi-role library management app (Admin, Librarian, Reader) built with
Flutter. It talks to the Spring Boot backend in `../backend`.

## Project structure

```
lib/
├── main.dart                     # App entry point and role-based navigation shell
├── config/
│   ├── api_config.dart           # Backend base URL (change it here)
│   └── app_images.dart           # Sample book cover URLs
├── constants/
│   └── app_colors.dart           # Brand colors
├── models/                       # Data classes parsed from API responses
├── services/                     # API clients and the LibraryService state
├── theme/
│   └── app_theme.dart            # Material 3 theme
├── widgets/
│   ├── dialogs/sign_in_dialog.dart
│   └── header/top_header_bar.dart
└── screens/
    ├── landing/                  # Public landing page
    ├── admin/                    # Inventory, staff, and LMS settings
    ├── librarian/                # Borrow/return desk and notifications
    └── reader/                   # Home, my books, and reservations
```

## Run

1. Start the backend (see `../backend`) on port 8080.
2. Set the server address in `lib/config/api_config.dart`:
   - Chrome or desktop: `http://localhost:8080/api`
   - Android emulator: `http://10.0.2.2:8080/api`
3. Run the app:

```bash
flutter pub get
flutter run -d chrome
```

## Demo accounts

The sign-in dialog uses fixed demo accounts (defined in `lib/models/user.dart`).

| Role      | Email                 | Password       |
|-----------|-----------------------|----------------|
| Admin     | `admin@library.com`   | `admin123`     |
| Librarian | `librarian@library.com` | `librarian123` |
| Reader    | `reader@library.com`  | `reader123`    |

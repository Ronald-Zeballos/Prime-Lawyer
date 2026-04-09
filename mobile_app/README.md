# Mobile App

Flutter application for the Prime Lawyer MVP.

## Purpose

- Keep mobile code isolated from the backend.
- Consume the backend REST API through a clear feature-based structure.
- Demonstrate the MVP flow from login to documents.

## Implemented MVP Features

- login with JWT
- session persistence
- home screen
- clients listing and creation
- case files listing, creation and detail
- documents listing and registration

## Structure

- `lib/app/`: app bootstrap, routes, theme and environment config
- `lib/core/`: HTTP client, storage, shared services and base utilities
- `lib/modules/`: feature modules
- `lib/shared/`: shared UI and cross-feature models/providers

## Local Run

1. Make sure the backend is already running on your machine.
2. Install dependencies:

```powershell
cd mobile_app
flutter pub get
```

3. Run the app:

```powershell
cd mobile_app
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

## API Base URL Notes

- Android emulator: `http://10.0.2.2:3000/api/v1`
- iOS simulator or desktop: `http://localhost:3000/api/v1`
- Physical device: `http://<YOUR_LOCAL_IP>:3000/api/v1`

If needed, override the URL with `--dart-define=API_BASE_URL=...`.

## Demo Credentials

- Email: `admin@demo.com`
- Password: `Admin123*`

## Current Limitations

- File registration uses a simple file picker for the MVP.
- OCR is not implemented yet.
- The app was structured for growth, but the demo scope stays intentionally small.

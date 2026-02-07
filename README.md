# yas_ui

A new Flutter project.

## Google sign-in on Web (Chrome)

When running on web, use a **fixed port** so the Cognito callback URL matches:

1. In **AWS Cognito** → your User Pool → **App integration** → **App client** (the one with Hosted UI) → **Hosted UI**:
   - Under **Callback URL(s)** add: `http://localhost:3000/`
   - Under **Sign out URL(s)** add: `http://localhost:3000/` (if not already set)
2. Run the app with that port:
   - Double-click `run_web.bat`, or
   - In terminal: `flutter run -d chrome --web-port=3000`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

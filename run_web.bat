@echo off
REM Run Flutter web on fixed port 3000 so Cognito callback URL matches.
REM In AWS Cognito, add: http://localhost:3000/
flutter run -d chrome --web-port=3000

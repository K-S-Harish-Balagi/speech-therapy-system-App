# Flutter Web Login App

Simple login UI built with Flutter.
Connects to a Node.js + Express backend.

## 🛠 Tech Used
- Flutter
- Dart
- http package

## 🌐 API Host Configuration

Change the backend URL depending on platform:

Flutter Web:
http://localhost:3000

Android Emulator:
http://10.0.2.2:3000

Physical Mobile Device:
http://YOUR_PC_IP:3000
Example:
http://192.168.1.5:3000

## ▶️ Run

1. Install packages:
   flutter pub get

2. Make sure backend is running.

3. Run:
   flutter run -d chrome

## 🔐 Test Login
Username: admin  
Password: 1234

## 📌 Flow
Flutter → HTTP POST → Express → MongoDB → JSON → Flutter
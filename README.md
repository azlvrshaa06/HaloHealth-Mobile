# HaloHealth Mobile Application

A Flutter mobile application for home health monitoring. HaloHealth is built around a physical telemedicine kit (blood pressure monitor, pulse oximeter, heart rate monitor, and thermometer). It stores each measurement in the cloud, shows the history and the live device status, and lets the patient send the latest readings to a doctor through an in-app chat. The app uses Firebase Authentication for accounts and Cloud Firestore for real-time data.

> This is an academic prototype developed for the Mobile Applications and Development for Engineering course (CPEN6222010) at Binus University. It is not a medical device and must not be used as a basis for diagnosis or treatment.

---

## Project Team

| Name | Student ID | Role |
|------|------------|------|
| Nathalie Arwan | 2802454820 | Configuration, design, and implementation of the `data/` folder (except `dummy_devices.dart`), the user model (`user.dart`), the History and Doctor List screens, the authentication state, the app theme, and the Firebase setup |
| Azalia Varsha Jeslyn Putri Legowo | 2802519902 | Configuration, design, and implementation of the Chat, Device Description, Home, Login, and Profile screens, the dummy device data (`dummy_devices.dart`), the chat state, all widgets, and the device model |
| Julius Lim Khan | 2802527381 | Widgets, Firebase integration, and state management |

Widgets, state management, and the Firebase setup were worked on jointly by more than one member.

---

## Background and Objectives

Conventional health examinations usually require a visit to a clinic, which means travel time, long queues, and dependency on the availability of medical staff. Standalone home medical devices only show the latest reading and do not keep a digital record, so long-term monitoring and sharing data with a doctor stay difficult.

HaloHealth uses the smartphone as the bridge between home measurements and professional evaluation. The app collects the readings from the kit, stores them in a structured way, and presents them in a simple interface for patients of all ages.

The objectives are as follows.

1. Design a mobile app that works together with home monitoring devices so users can collect routine health data at home.
2. Store, organize, and track patient health records over time with a Firebase database.
3. Provide an in-app chat that lets a patient send the most recent health data to a medical professional.
4. Present the data with a simple and informative interface that is easy to understand for the general public.

---

## Key Features

- **Account system.** Register and login on a single screen with Firebase Authentication. Registration validates all fields locally and shows every error at once.
- **Real-time device monitoring.** The home screen shows the battery level of each device and the latest measurement, updated live from Firestore without any manual refresh.
- **Measurement history.** A full history per device, ordered from the newest to the oldest, with a clear empty state when no data exists.
- **Device information.** A guide for each device with a description, normal ranges, and usage tips.
- **Doctor consultation.** A doctor list with search, and a chat that can attach the patient's latest measurement as a snapshot.
- **Kit Box control.** A confirmation dialog flow to unlock and lock the kit box (UI simulation).
- **Profile management.** View and edit name, age, and phone number directly on the profile screen.

---

## System Overview

### Architecture

The system is designed in three layers.

```
 HARDWARE LAYER              CLOUD LAYER                   PRESENTATION LAYER
┌────────────────┐     ┌──────────────────────┐     ┌───────────────────────────┐
│ Telemedicine   │     │ Firebase             │     │ Flutter mobile app        │
│ kit (sensors)  │────▶│ Authentication       │◀───▶│ Login / Home / History    │
│                │     │ Cloud Firestore      │     │ Device info / Doctor chat │
└────────────────┘     └──────────────────────┘     └───────────────────────────┘
```

1. **Hardware layer.** The kit measures the vital signs and sends the values to the account of the user in the cloud.
2. **Cloud layer.** Firebase Authentication verifies each user and issues a unique user ID (UID). Cloud Firestore stores all data in documents and collections tied to that UID.
3. **Presentation layer.** The Flutter app listens to Firestore streams and rebuilds the interface immediately when new data arrives.

> The current build does not communicate with the physical kit. Measurements and battery levels are generated as dummy data (see [Try the App with Dummy Data](#try-the-app-with-dummy-data)). The kit is expected to write to the same Firestore structure that the app reads.

### Tech Stack

| Component | Package / Tool | Version |
|-----------|----------------|---------|
| Framework | Flutter (Dart SDK) | Dart `^3.10.8` |
| Authentication | `firebase_auth` | `^5.0.0` |
| Firebase core | `firebase_core` | `^3.0.0` |
| Database | `cloud_firestore` | `^5.6.12` |
| State management | `provider` | `^6.1.2` |
| Icons | `cupertino_icons` | `^1.0.8` |
| Lints | `flutter_lints` | `^6.0.0` |
| Development | Android Studio and the Android emulator | - |

The app targets the Android platform.

### Firestore Data Model

Each device has its own sub-collection, so the history can be sorted on the client and no composite index is required.

```
users/{uid}                                  profile document
users/{uid}/alat/{deviceName}                device document (battery)
users/{uid}/alat/{deviceName}/riwayat/{id}   one measurement record
```

The device names (`{deviceName}`) are `Tensimeter`, `Heart Rate Monitor`, `Oximeter`, and `Termometer`.

| Document | Fields |
|----------|--------|
| `users/{uid}` | `uid`, `nama`, `email`, `usia`, `jenisKelamin`, `telepon`, `kodeKit`, `createdAt` |
| `alat/{deviceName}` | `baterai` (0 to 100) |
| `riwayat` of `Tensimeter` | `sistol`, `diastol`, `denyutJantung`, `waktu` |
| `riwayat` of `Oximeter` | `saturasi`, `bpm`, `statusSaturasi`, `waktu` |
| `riwayat` of `Termometer` | `suhu`, `statusSuhu`, `waktu` |
| `riwayat` of `Heart Rate Monitor` | `bpm`, `waktu` |

---

## Repository Structure

```
FInalMADE/
├── .gitignore
├── README.md
└── code/
    ├── pubspec.yaml
    └── lib/
        ├── main.dart                         # app entry point
        ├── firebase_options.example.dart     # template (copy to firebase_options.dart)
        ├── screens/
        │   ├── login_screen.dart
        │   ├── home_screen.dart
        │   ├── riwayat_screen.dart
        │   ├── device_desc.dart
        │   ├── doctor_list_screen.dart
        │   ├── chat_screen.dart
        │   └── profile_screen.dart
        ├── widgets/
        │   ├── device_card_widget.dart
        │   ├── riwayat_card_widget.dart
        │   ├── doctor_card_widget.dart
        │   ├── kitbox_button_widget.dart
        │   └── device_desc_components.dart
        ├── models/
        │   ├── user.dart
        │   └── device_model.dart
        ├── state/
        │   ├── chat_state.dart
        │   ├── kitbox_state.dart
        │   └── auth_state.dart
        ├── services/
        │   └── dialog_service.dart
        ├── data/
        │   ├── dummy_doctors.dart
        │   ├── dummy_info_device.dart
        │   ├── dummy_devices.dart
        │   └── riwayat_data.dart
        └── theme/
            └── colors.dart
```

The repository contains only the Dart source and `pubspec.yaml`. The Android platform folder is generated during setup (see [Getting Started](#getting-started)).

### Module Descriptions

| Module | Description |
|--------|-------------|
| `main.dart` | Initializes Firebase, registers `ChatState` with Provider, applies the Material 3 theme (pink seed color), and opens `LoginScreen`. |
| `login_screen.dart` | Single screen with a Login tab and a Register tab. Validates input locally, calls Firebase Authentication, and writes the profile document to Firestore. |
| `home_screen.dart` | Main hub. Hosts the history carousel, the device carousel, and the navigation drawer (profile, Kit Box, dummy data, logout). |
| `riwayat_screen.dart` | Shows the complete measurement history of one device from Firestore. |
| `device_desc.dart` | Device guide screen. The text comes from `data/dummy_info_device.dart`, and the layout comes from `widgets/device_desc_components.dart`. |
| `doctor_list_screen.dart` | Doctor directory with a search field. |
| `chat_screen.dart` and `state/chat_state.dart` | Chat interface and its Provider state, including the "send measurement" feature. |
| `profile_screen.dart` | Streams the profile document and supports inline editing. |
| `models/` | `UserModel` (with `toMap` and `fromMap`) and the measurement models. |
| `services/dialog_service.dart` | Confirmation dialogs for unlocking and locking the Kit Box. |
| `data/dummy_doctors.dart`, `data/dummy_info_device.dart` | Static doctor list and static device information. |
| `state/auth_state.dart`, `state/kitbox_state.dart`, `data/dummy_devices.dart`, `data/riwayat_data.dart` | Earlier helpers that are not used by the current screens. They are kept for reference. |

---

## Screens and Navigation

```
LoginScreen
    └── HomeScreen
          ├── ProfileScreen
          ├── RiwayatScreen          (tap a history card)
          ├── DeviceDesc             (tap a device card)
          └── DoctorListScreen
                └── ChatScreen
```

| Screen | Description |
|--------|-------------|
| Login and Register | Registration collects name, age, gender, email, password (minimum 6 characters), phone number, and Kit Box code. After registering, the user returns to the login tab. |
| Home | Two horizontal carousels. The first shows the latest reading of each device. The second shows each device with its live battery level (red at 20% or below). |
| History | All records of a device in chronological order, newest first. |
| Device Description | About the device, normal ranges, and tips. |
| Doctor List | Static doctor cards with a search bar. |
| Chat | Messages with a doctor, plus a panel to attach the latest reading of a device. |
| Profile | Personal information with an edit mode for name, age, and phone number. |

---

## Software Design

### Startup

1. `WidgetsFlutterBinding.ensureInitialized()` prepares the Flutter engine.
2. `Firebase.initializeApp` runs with `DefaultFirebaseOptions.currentPlatform`.
3. `runApp` starts the app inside `ChangeNotifierProvider<ChatState>`.
4. The first screen is always `LoginScreen`.

### Registration and Login

1. Registration validates all fields locally and reports every error in one pass.
2. `createUserWithEmailAndPassword` creates the Firebase account.
3. A document is written to `users/{uid}` through `UserModel.toMap`, and the display name is updated.
4. Login uses `signInWithEmailAndPassword`, then replaces the screen with `HomeScreen`. Firebase error codes are translated to readable messages.

### Real-Time Data

Each carousel card owns an independent Firestore snapshot stream. A battery change or a new measurement refreshes only the affected card, without polling and without rebuilding the whole screen. The history is sorted by `waktu` on the client side.

### Sending a Measurement to a Doctor

1. The user opens a doctor and selects a device in the "Kirim riwayat Anda" panel.
2. `ChatState` fetches the newest record of that device from Firestore.
3. The values are stored inside the chat message as a snapshot, so the bubble keeps the original numbers even when new data arrives later.
4. If the device has no record yet, the bubble shows that no data is available.

### Kit Box

The Kit Box button in the drawer opens a confirmation dialog to unlock or lock the box. It currently changes only the state shown in the app and is not connected to a physical lock.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart `3.10.8` or newer
- Android Studio with an Android emulator, or a physical Android device
- A Google account for [Firebase](https://console.firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

### 1. Clone and generate the Android project

The repository does not include the Android platform folder. Generate it inside `code/`.

```bash
git clone https://github.com/<username>/<repository>.git
cd <repository>/code
flutter create . --project-name finpromade --org com.example --platforms=android
```

The package name must stay `finpromade`, because the source files import `package:finpromade/...`. If the command creates `test/widget_test.dart`, delete that file, because it refers to a class that does not exist in this project. Run `git status` afterwards to confirm that nothing under `lib/` was changed.

```bash
flutter pub get
```

### 2. Create your own Firebase project

This repository does not include the Firebase configuration of the original project, so you need your own.

1. In the Firebase console, create a project.
2. Enable **Authentication** with the **Email/Password** provider.
3. Create a **Cloud Firestore** database.
4. Connect the app to your project with the FlutterFire CLI.

```bash
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android
```

This command generates `lib/firebase_options.dart`, which is excluded from Git. As a manual alternative, copy `lib/firebase_options.example.dart` to `lib/firebase_options.dart` and fill in your own values.

### 3. Set the Firestore security rules

All data of the app lives under `users/{uid}`, so each user can be limited to their own data. Open **Firestore Database > Rules** and publish the following.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

If a device (for example the IoT kit) writes to Firestore, it must authenticate as that user, or it will be rejected by these rules.

### 4. Run the app

```bash
flutter run
```

### Try the App with Dummy Data

1. Register a new account. The Kit Box code can be any non-empty text, because it is not validated yet.
2. Log in, then open the drawer menu.
3. Tap **Buat Sub-Koleksi Dummy**. This writes one sample record for the Tensimeter, Oximeter, and Termometer into your account.
4. The history cards on the home screen update immediately.

---

## Testing and Results

The testing was done manually on the Android emulator with 33 scenarios in three categories.

| No | Category | Scenarios | Passed | Failed | Pass Rate |
|----|----------|-----------|--------|--------|-----------|
| 1 | UI behavior under different inputs | 10 | 10 | 0 | 100% |
| 2 | Navigation flow | 9 | 9 | 0 | 100% |
| 3 | State change and real-time data validation | 14 | 14 | 0 | 100% |
| | Total | 33 | 33 | 0 | 100% |

Additional observations from the tests.

- The register form validates the required fields independently and shows all errors at once.
- Battery changes and new measurements appear in the app within about one to two seconds without a manual refresh.
- The deepest navigation path (Home, doctor list, chat) reverses correctly, and logout clears the navigation stack so the user cannot go back to the home screen.
- Screens without data show a clear empty state instead of failing silently.

---

## Limitations and Future Work

- The build is not connected to the physical kit. Measurements and battery levels come from dummy data.
- The Kit Box is a UI simulation. QR scanning and device pairing were replaced with a confirmation dialog, and the Kit Box code entered at registration is stored but not validated.
- The chat is a simulation. Messages are kept only in memory, are lost when the app restarts, and no real doctor replies. Voice and video consultation are not implemented.
- The doctor list is static dummy data, and only the first doctor can be consulted.
- Only the patient role exists. There is no doctor role and no integration with hospital systems.
- The Heart Rate Monitor is no longer part of the final hardware setup, but it still appears in the interface. Its device description page currently shows the Tensimeter content.
- Proposed screens such as notifications, reminders, and unit conversion settings are not implemented.
- The app targets Android only.

Planned improvements include integration with the physical kit, real doctor accounts and messaging stored in Firestore, QR-based Kit Box pairing, and push notifications.

---

## Troubleshooting

**The build fails with `No Firebase App` or `firebase_options.dart` cannot be found.** The configuration file is missing. Run `flutterfire configure` or copy the example file (see step 2 of Getting Started).

**The Android build complains about `minSdkVersion`.** Some Firebase plugins require a higher minimum SDK. Set `minSdk = 23` in `android/app/build.gradle` (or `build.gradle.kts`) and run the build again.

**Login or registration fails.** Make sure the Email/Password provider is enabled in Firebase Authentication. Passwords must have at least 6 characters.

**The history or battery stays empty.** There is no data yet for your account. Use **Buat Sub-Koleksi Dummy** from the drawer, or write records to `users/{uid}/alat/{deviceName}/riwayat` from your device.

**You see `permission-denied` errors.** The Firestore rules do not allow the request. Check that you are signed in and that the rules match the ones in step 3.

---

## Credits and References

- Built with [Flutter](https://docs.flutter.dev/), [Firebase](https://firebase.google.com/docs/flutter/setup), [Cloud Firestore](https://firebase.google.com/docs/firestore), and [Provider](https://pub.dev/packages/provider).

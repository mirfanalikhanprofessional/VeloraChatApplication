# Velora

Real-time Flutter chat app using **Firebase Authentication**, **Cloud Firestore**, **Clean Architecture**, and a **feature-first UI** layer. State management: **Bloc**. Navigation: **go_router**. Toasts: **toastification**. DI: **get_it**.

## Features

- Welcome, login, and sign-up with lavender Velora UI
- Email/password auth with optional Remember me (secure storage)
- Forgot password → Firebase reset email → set new password
- Profile with two-letter initials avatar (name / bio / email)
- User profile stored in Firestore `users` collection
- Chats list with search, avatar strip, and unread-style badges
- Real-time 1:1 chat (Firestore)
- Message CRUD: send, live read, long-press edit, long-press delete
- Loading / empty / error + retry, pull-to-refresh on users list
- Hive local cache for users list + recent messages (faster open)
- Connectivity checks, stream first-event timeouts, cache TTL (10 min)
- Responsive layouts for phone / tablet widths
- Profile edit & logout
- Declarative routing (`go_router`)
- Toast notifications via `toastification`

## Architecture

```
lib/
├── core/
│   ├── config/             # providers.dart + registerDependencies()
│   ├── router/             # GoRouter + AuthSession
│   ├── constants/          # AppInfo, AppColors
│   ├── theme/
│   ├── widgets/
│   └── utils/
├── domain/
│   ├── entities/
│   ├── auth/               # AuthRepository, AuthUseCase
│   ├── users/              # UsersRepository, UsersUseCase
│   └── chat/               # ChatRepository, ChatUseCase
├── data/
│   ├── models/
│   ├── auth/               # AuthDataSource, AuthRepositoryImpl
│   ├── users/              # UsersDataSource, UsersRepositoryImpl
│   └── chat/               # ChatDataSource, ChatRepositoryImpl
└── features/               # AuthBloc / ChatBloc + UI
    ├── auth/
    ├── users/
    └── chat/
```

### Module naming

| Module | Bloc | UseCase | Repository | Impl | DataSource |
|--------|------|---------|------------|------|------------|
| Auth | AuthBloc | AuthUseCase | AuthRepository | AuthRepositoryImpl | AuthDataSource |
| Users | — | UsersUseCase | UsersRepository | UsersRepositoryImpl | UsersDataSource |
| Chat | ChatBloc | ChatUseCase | ChatRepository | ChatRepositoryImpl | ChatDataSource |

### Dependency flow

`UI (StreamBuilder) / Bloc → UseCase → Repository → DataSource`

## Firebase setup

Project: `chatapplication-f7e6d`

Config already present:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

### Enable services in Firebase Console

1. **Authentication** → Sign-in method → enable **Email/Password**
2. **Firestore Database** → Create database (start in test mode for development, then tighten rules)

### Suggested Firestore rules (development)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /chats/{chatId} {
      allow read, write: if request.auth != null
        && request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

> For production, restrict message writes to `senderId == auth.uid` and validate chat membership carefully.

### Password reset flow (free Spark plan)

Uses Firebase Auth only — no Cloud Functions / Blaze plan required.

1. **Forgot password** — sends Firebase’s password-reset email  
2. **Reset password** — paste the `oobCode` from the email link URL, then set a new password  

Example link fragment: `...?mode=resetPassword&oobCode=ABC123...`

### Data model

| Collection | Fields |
|------------|--------|
| `users/{uid}` | `uid`, `email`, `displayName`, `bio`, `createdAt` |
| `chats/{chatId}` | `participants`, `lastMessage`, `lastMessageAt`, `updatedAt` |
| `chats/{chatId}/messages/{id}` | `senderId`, `receiverId`, `text`, `timestamp`, `updatedAt` |

`chatId` = sorted `uidA_uidB`.

## Run

```bash
flutter pub get
flutter run
```

Register two accounts on two devices/emulators (or web + device) to test real-time chat.

## Test

```bash
flutter test
```

Coverage includes:

- Core: `buildChatId`, validators, Hive cache + TTL, `NetworkInfo`, stream timeout, session storage (remember-me + first-launch welcome)
- Domain: `AppUser`, `ChatMessage`
- Auth bloc: login/register session rules, logout, remember-me / password visibility
- Data/API layer (mocked datasources): auth / users / chat success + network/server failures
- Widgets: Welcome (marks first launch), Login, MessageBubble, CommonLoading, CommonEmptyView (+ Retry), ResponsiveCenter

## Tech stack

- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `flutter_bloc`, `get_it`, `dartz`, `equatable`
- `hive`, `hive_flutter` (local chat cache)
- `connectivity_plus` (explicit offline detection)
- `flutter_secure_storage` (session / remember-me)
- `google_fonts`, `intl`, `go_router`, `toastification`

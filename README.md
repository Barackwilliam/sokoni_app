# Sokoni App — MVP (Phase 1)

App ya kuunganisha watumiaji na biashara za karibu: **Mafundi, Maduka, Beauty, Restaurant**.

## Features zilizopo (Phase 1)

- Login kwa namba ya simu + OTP (Firebase Auth)
- Home: search bar + categories 4 + business listings
- Search ya jina la biashara
- Business profile: maelezo, picha, rating, location, call/WhatsApp buttons
- Reviews & ratings
- Business owner anaweza ku-register biashara yake na ku-upload picha

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Maps/Location:** Geolocator + Geocoding (Google Maps full integration tunaongeza Phase 2 kwa map view)

## Hatua za Kuanzisha Project

### 0. Generate platform folders (android/ios/web)

Code niliyokuandalia ni `lib/` na `pubspec.yaml` tu (Dart code). Folders za `android/`, `ios/`, `web/` hazipo bado kwa sababu hizo zinahitaji Flutter SDK ku-generate (sina access hapa). Kabla ya kuendelea, kwenye terminal yako, ndani ya folder ya project hii fanya:

```
flutter create .
```

Hii itaongeza android/ios/web folders bila kugusa lib/main.dart au pubspec.yaml uliyonayo tayari (flutter create haiandiki upya files zilizopo).

### 1. Install dependencies

```
flutter pub get
```

### 2. Unganisha na Firebase project yako

Kama huna Firebase project bado, fungua [console.firebase.google.com](https://console.firebase.google.com) na utengeneze mpya (jina mfano "sokoni-app").

Kisha kwenye terminal:

```
dart pub global activate flutterfire_cli
flutterfire configure
```

Hii itakuuliza uchague Firebase project yako na itazalisha upya `lib/firebase_options.dart` na values halisi (badala ya placeholder zilizopo sasa).

### 3. Washa huduma zinazohitajika kwenye Firebase Console

- **Authentication** → Sign-in method → washa **Phone**
- **Firestore Database** → tengeneza database (production mode)
- **Storage** → washa (kwa picha za biashara)

### 4. Weka Firestore Security Rules

Nakili content ya `firestore.rules` (iliyopo kwenye root ya project hii) kwenda Firebase Console → Firestore → Rules, kisha Publish.

### 5. Firestore Indexes

Firestore itakuonyesha link ya kuunda composite index automatic wakati wa ku-test app (kwenye terminal/console error itakuwa na link ya moja kwa moja ya "Create Index"). Index kuu inayohitajika:

- `businesses`: `category` (Ascending) + `createdAt` (Descending)

### 6. Endesha App

```
flutter run
```

## Muundo wa Folders

```
lib/
  models/          -> BusinessModel, ReviewModel
  services/        -> AuthService, FirestoreService, StorageService
  screens/         -> splash, auth_gate, login, otp, home, search,
                      my_listings, profile, add business, notifications,
                      business profile
  widgets/         -> BusinessCard, ContactButtons, ShimmerLoader
  utils/constants.dart -> categories, colors, collection names
```

## Kinachofuata (Phase 2 — kama mlivyokubaliana na mteja)

- Cart system
- Booking system
- Payment integration (M-Pesa, Tigo Pesa, Airtel Money)
- Live order/service tracking

## Note muhimu

- `lib/firebase_options.dart` ina placeholder values - LAZIMA uifanyie `flutterfire configure` kabla app haijafanya kazi.
- Phone auth na Firebase inahitaji SHA-1/SHA-256 fingerprint ya app yako iwekwe kwenye Firebase Console (Android) - vinginevyo OTP haitatumwa kwenye real device.
- Kwa testing haraka bila real phone number, unaweza kuongeza "test phone numbers" kwenye Firebase Console → Authentication → Sign-in method → Phone → Phone numbers for testing.


> **Angalia `MAREKEBISHO.md`** kwa orodha kamili ya bug fixes na maboresho ya toleo hili.

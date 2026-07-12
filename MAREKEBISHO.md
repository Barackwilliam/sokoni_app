# Sokoni App — Marekebisho (12 Julai 2026)

Orodha kamili ya bugs zilizorekebishwa na features zilizoboreshwa.

## Bugs kubwa (critical)

1. **Login ilikuwa haitumiki kabisa.** Splash "Get Started" ilienda moja kwa moja
   HomeScreen bila auth — na kwa kuwa Firestore rules zinahitaji login, data yote
   ingekataliwa. Sasa kuna `AuthGate` (lib/screens/auth_gate.dart) inayosikiliza
   `authStateChanges`: umelogin → Home, hujalogin → Login. Sign Out sasa
   inakurudisha Login screen automatic.

2. **Release APK isingekuwa na internet.** `INTERNET` permission ilikuwa kwenye
   debug manifest tu. Imeongezwa kwenye main AndroidManifest, pamoja na
   `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` (geolocator) na `<queries>`
   za `tel:` na `https:` (url_launcher kwenye Android 11+).

3. **`firebase_options.dart` ilikuwa na `REPLACE_ME`** — app ingeshindwa ku-init
   Firebase. Android values halisi zimejazwa kutoka google-services.json.
   iOS/web bado zinahitaji `flutterfire configure` (angalia note ndani ya file).
   Pia `Platform.operatingSystem` (dart:io) imebadilishwa kuwa
   `defaultTargetPlatform` ili isivunje web build.

4. **Bottom nav ilikuwa imevunjika.** Tab ya "Listings" ilikuwa na index 0 sawa
   na Home (zilikuwa zinawaka pamoja, Listings ilifungua Home). Sasa kuna screen
   halisi ya **My Listings** (index 3) na Profile ni index 4.

5. **`test/widget_test.dart`** ilikuwa default counter test inayoreference
   `MyApp` isiyokuwepo — `flutter test` na `flutter analyze` zingefeli.
   Imebadilishwa na tests halisi za BusinessModel/ReviewModel/categories.

## Features mpya / zilizoboreshwa

- **My Listings screen** — mmiliki anaona biashara zake, ana-toggle
  Open/Closed, na anaweza ku-delete (na picha zake Storage zinafutwa pia).
  Query haiitaji composite index (sorting inafanyika client-side).
- **Resend OTP** — button ya Resend sasa inafanya kazi, na countdown ya 60s
  na `forceResendingToken`. Error messages za Firebase zimefanywa rafiki
  (invalid code, session expired, network, too many requests...).
- **Auto-verification (Android)** — SMS ikisomwa automatic, app ina-sign-in
  moja kwa moja bila kuingiza code.
- **Upload ya picha imeundwa upya:**
  - Document id inatengenezwa KWANZA (`newBusinessId()`), picha zinapanda
    chini ya `businesses/{id}/...` — hakuna tena orphan images.
  - Upload ni bytes-based (`putData`) — inafanya kazi Android, iOS NA web
    (zamani web ilikuwa inaskip picha kimya kimya).
  - ContentType sahihi inawekwa (jpeg/png/webp/gif).
- **Reviews:** review moja kwa kila user kwa kila biashara (doc id =
  `businessId_userId`). Ukituma tena, review yako ya zamani ina-update na
  average inarekebishwa kwa usahihi ndani ya transaction moja. Namba za simu
  za reviewers zime-mask kwa privacy (+255 712 *** 678). Error handling +
  confirmation snackbars zimeongezwa.
- **Namba za simu** zinanormalize kwenda +255 zikihifadhiwa, na WhatsApp link
  inaunda `wa.me/255...` sahihi hata kama mmiliki aliweka 07...
- **Greeting** ya Home sasa inafuata muda (Morning/Afternoon/Evening).
- **Call/WhatsApp buttons** — `canLaunchUrl` (isiyoaminika bila queries)
  imeondolewa; sasa try/catch na snackbar kama kifaa hakina dialer/WhatsApp.
- Typo `madukaCOlor` → `madukaColor` kila mahali; dead code imeondolewa;
  app label Android sasa ni "Sokoni" badala ya "sokoni_app".

## Usalama (security)

- **`storage.rules` mpya** — Storage ilikuwa haina rules kwenye project.
  Sasa: signed-in users tu, picha tu, max 5MB kwa file. `firebase.json`
  imeupdate ili `firebase deploy --only firestore:rules,storage` ifanye kazi.
- **`firestore.rules`** — validation ya rating (lazima namba 1–5) kwenye
  create na update ya reviews; user hawezi kubadilisha `userId` ya review.
- **ONYO:** Zip ya awali ilikuwa na `.dart_tool/chrome-device/` yenye Cookies,
  Login Data na History za Chrome yako. Zip hii mpya ni safi (hakuna `.git`,
  `build/`, `.dart_tool/`, `.idea/`, wala ile copy ya zamani iliyokuwa nested
  ndani ya `sokoni_app/sokoni_app/`). Usishare tena ile zip ya zamani.

## Hatua za kukamilisha kwenye mashine yako

```bash
flutter pub get
flutter analyze          # inapaswa kuwa 0 issues
flutter test             # tests 3 zinapita
firebase deploy --only firestore:rules,storage   # deploy rules mpya
flutter run
```

Kumbuka: kwa iOS/web endesha `flutterfire configure` kwanza. Kwa OTP kwenye
real Android device, hakikisha SHA-1/SHA-256 fingerprints ziko Firebase Console.

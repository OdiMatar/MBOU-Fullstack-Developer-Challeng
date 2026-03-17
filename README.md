# Odai Shop - Fullstack Demo (Laravel API + Flutter App)

Dit project is een fullstack webshop-demo met:
- een Laravel backend (`backend`) voor de API en data-opslag
- een Flutter client (`app`) voor mobile (en eventueel web)

De app ondersteunt rollen (`admin` en `user`), productbeheer, winkelwagen, afrekenen en profielbeheer.

## 1. Features

- Inloggen en registreren
- Producten bekijken, zoeken, filteren en sorteren
- Admin-functionaliteit: producten toevoegen, bewerken en verwijderen
- Gebruikersfunctionaliteit: productdetails bekijken, winkelwagen beheren en afrekenen
- Profiel bewerken (inclusief profielfoto upload)
- Admin dashboard voor gebruikersbeheer

## 2. Tech Stack

- Backend: Laravel 12, PHP 8.2+
- Database: SQLite (standaard in dit project)
- Frontend app: Flutter (Dart 3.10+)
- HTTP client: `package:http`
- Image upload/picker: `image_picker`

## 3. Projectstructuur

```text
.
|- app/                 # Flutter app
|- backend/             # Laravel API
|- START.bat            # Start backend (localhost)
|- START_MOBILE.bat     # Start backend + app voor echte telefoon
|- TEST_API.bat         # Simpele API test
|- LOGIN_GEGEVENS.md    # Testaccounts
```

## 4. Vereisten

- Flutter SDK
- Android Studio (voor emulator) of een echte telefoon met USB-debugging
- PHP 8.2+
- Composer

## 5. Snelstart (Windows)

### Optie A: Emulator

1. Start de backend:
```bat
START.bat
```
2. Start een Android emulator in Android Studio.
3. Start de Flutter app:
```bat
cd app
flutter run
```

### Optie B: Echte telefoon

1. Zorg dat telefoon en laptop op hetzelfde netwerk zitten.
2. Start alles met je lokale IP:
```bat
START_MOBILE.bat JOUW_PC_IP
```

Voorbeeld:
```bat
START_MOBILE.bat 10.32.99.66
```

Je kunt ook een specifiek device-id meegeven:
```bat
START_MOBILE.bat 10.32.99.66 DEVICE_ID
```

## 6. Handmatige setup (vanaf nul)

### Backend

```bat
cd backend
composer install
copy .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed --class=AdminSeeder
php artisan db:seed --class=ItemSeeder
php artisan serve --host=0.0.0.0 --port=8000
```

### Flutter app

```bat
cd app
flutter pub get
flutter run
```

Voor echte telefoon:
```bat
flutter run --dart-define=API_HOST=JOUW_PC_IP
```

## 7. Testaccounts

Zie ook [`LOGIN_GEGEVENS.md`](LOGIN_GEGEVENS.md).

- Admin:
  - Email: `admin@odai.com`
  - Wachtwoord: `admin123`
- Gebruiker:
  - Email: `user@test.com`
  - Wachtwoord: `user123`

## 8. Belangrijkste API endpoints

- Auth:
  - `POST /api/register`
  - `POST /api/login`
  - `POST /api/logout`
- Users:
  - `GET /api/users`
  - `PUT /api/users/{id}`
  - `POST /api/users/{id}` (multipart update met `_method=PUT`)
  - `DELETE /api/users/{id}`
- Items:
  - `GET /api/items`
  - `GET /api/items/{id}`
  - `POST /api/items`
  - `PUT /api/items/{id}`
  - `DELETE /api/items/{id}`
- Cart:
  - `GET /api/cart/user/{userId}`
  - `POST /api/cart`
  - `PUT /api/cart/{id}`
  - `DELETE /api/cart/{id}`
  - `POST /api/cart/checkout`
- Purchases:
  - `POST /api/purchases`
  - `GET /api/purchases/user/{userId}`

## 9. Handige scripts

- `START.bat`: start Laravel API op `http://localhost:8000`
- `START_MOBILE.bat`: start backend + flutter run met `API_HOST`
- `TEST_API.bat`: test endpoint(s) snel
- `DEBUG.bat`: bekijk Flutter logs
- `RESTART_APP.bat`: herstart app op emulator

## 10. Troubleshooting

- API niet bereikbaar vanuit emulator:
  - gebruik `10.0.2.2` (dit is al de standaard in de app voor emulator)
- API niet bereikbaar op echte telefoon:
  - gebruik `--dart-define=API_HOST=JOUW_PC_IP`
  - controleer dat poort `8000` in Windows Firewall open staat
  - controleer dat telefoon en laptop op hetzelfde netwerk zitten
- Lege of oude data:
  - voer opnieuw migraties/seeds uit in `backend`

## 11. Bekende beperkingen

- Loginstatus in de Flutter app wordt nu in-memory opgeslagen (`AuthService`), dus niet persistent na app-herstart.
- API-routes hebben geen token-auth middleware; dit is een demo-opzet.

## 12. Demo flow

1. Login als `admin@odai.com` om producten en gebruikers te beheren.
2. Login als `user@test.com` om producten te bekijken, toe te voegen aan winkelwagen en af te rekenen.
3. Bewerk je profiel en upload eventueel een profielfoto.


# Setup Instructies

## ⚡ Snelstart

Dubbelklik op `START.bat` om de Laravel API te starten!

De API draait dan op `http://localhost:8000`

## Flutter App Starten

1. Open Android Studio
2. Start een emulator (AVD Manager)
3. Open terminal in deze folder
4. Run:
```bash
cd app
flutter run
```

## API Testen

Dubbelklik op `TEST_API.bat` om de API endpoints te testen.

Of gebruik deze curl commando's:

```bash
# Items ophalen
curl http://localhost:8000/api/items

# Item aanmaken
curl -X POST http://localhost:8000/api/items -H "Content-Type: application/json" -d "{\"name\":\"Laptop\",\"description\":\"MacBook Pro\"}"
```

## Project Structuur

### Backend (Laravel)
- `backend/routes/api.php` - API routes
- `backend/app/Http/Controllers/ItemController.php` - Controller met 2 endpoints

### App (Flutter)
- `app/lib/main.dart` - App entry point
- `app/lib/screens/items_list_screen.dart` - Lijst scherm
- `app/lib/screens/add_item_screen.dart` - Toevoeg scherm
- `app/lib/services/api_service.dart` - API communicatie
- `app/lib/models/item.dart` - Data model

## Troubleshooting

### API niet bereikbaar vanuit emulator
- Gebruik `http://10.0.2.2:8000` in plaats van `localhost:8000`
- Dit staat al correct in `api_service.dart`

### Emulator start niet
- Check Android Studio > Tools > AVD Manager
- Maak een nieuwe Virtual Device aan

### Flutter doctor errors
Run: `flutter doctor` en volg de instructies

## Wat werkt nu al

✅ Laravel API met 2 endpoints (GET /api/items, POST /api/items)
✅ Flutter app met 2 schermen (lijst + toevoegen)
✅ Data ophalen en tonen in lijst
✅ Data toevoegen via formulier
✅ Basis validatie
✅ Error handling
✅ Loading states
✅ CORS geconfigureerd

## Volgende Stappen

Kies wat je wilt toevoegen:
- Auth (login/register)
- Filters/zoeken
- Offline caching
- Betere UI
- Categories/tags
- Notificaties

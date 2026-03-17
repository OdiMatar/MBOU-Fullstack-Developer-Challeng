# Debug Guide - Flutter + Laravel

## 🔍 Debugging Opties

### 1. Flutter DevTools (Beste optie!)

De app draait nu in debug mode. Je hebt toegang tot Flutter DevTools:

**Open in browser:**
- Kijk in de terminal output voor een URL zoals:
  `http://127.0.0.1:49309/YipVJXr88NY=/devtools/`
- Open deze URL in Chrome
- Je krijgt toegang tot:
  - Widget Inspector (UI structuur bekijken)
  - Performance profiler
  - Network inspector
  - Logging console
  - Memory profiler

### 2. VS Code Debugging (Aanbevolen)

**Setup:**
1. Open VS Code
2. Open de `app` folder
3. Installeer de Flutter extension (als je die nog niet hebt)
4. Druk op F5 of klik op "Run and Debug"
5. Kies "Flutter: Select Device" → kies je emulator
6. Zet breakpoints in je code (klik links van de regel nummers)

**Voordelen:**
- Breakpoints zetten
- Variabelen inspecteren
- Step through code
- Hot reload met `r` toets
- Hot restart met `R` toets

### 3. Print Statements (Simpelste)

Voeg `print()` statements toe in je code:

```dart
// In api_service.dart
Future<List<Item>> getItems() async {
  print('🔵 API Call: Getting items...');
  try {
    final response = await http.get(Uri.parse('$baseUrl/items'));
    print('🔵 Response status: ${response.statusCode}');
    print('🔵 Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('🔵 Parsed data: $data');
      // ... rest van code
    }
  } catch (e) {
    print('🔴 Error: $e');
    throw Exception('Fout bij ophalen items: $e');
  }
}
```

**Logs bekijken:**
- In de terminal waar `flutter run` draait
- Of run: `flutter logs` in een nieuwe terminal

### 4. Flutter Inspector in Terminal

Terwijl de app draait, type in de terminal:
- `r` - Hot reload (snelle refresh)
- `R` - Hot restart (volledige restart)
- `p` - Toggle performance overlay
- `o` - Toggle platform (Android/iOS)
- `w` - Dump widget hierarchy
- `t` - Dump rendering tree
- `q` - Quit

### 5. Laravel API Debugging

**Logs bekijken:**
```bash
# In backend folder
php artisan tail

# Of bekijk het log bestand
type storage/logs/laravel.log
```

**Debug in Controller:**
```php
// In ItemController.php
public function index()
{
    \Log::info('📍 Items endpoint called');
    
    $items = self::$items;
    \Log::info('📍 Returning items:', $items);
    
    return response()->json([
        'success' => true,
        'data' => $items
    ]);
}
```

### 6. Network Debugging

**Chrome DevTools (voor web versie):**
1. Run: `flutter run -d chrome`
2. Open Chrome DevTools (F12)
3. Ga naar Network tab
4. Zie alle API calls

**Android Emulator:**
1. Open Android Studio
2. View → Tool Windows → Logcat
3. Filter op "flutter" of "com.example.app"

### 7. API Testen met Postman/cURL

Test de API los van de app:

```bash
# Test GET
curl http://localhost:8000/api/items

# Test POST
curl -X POST http://localhost:8000/api/items ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Debug Item\",\"description\":\"Test\"}"
```

## 🐛 Veelvoorkomende Problemen

### API niet bereikbaar
**Symptoom:** "Failed to load items" error

**Debug:**
1. Check of Laravel draait: `http://localhost:8000` in browser
2. Check API response: `curl http://localhost:8000/api/items`
3. Check emulator gebruikt `10.0.2.2` niet `localhost`
4. Voeg prints toe in `api_service.dart`

### CORS Error
**Symptoom:** "CORS policy" error in logs

**Fix:**
- Check `backend/config/cors.php`
- Moet `'allowed_origins' => ['*']` zijn

### JSON Parsing Error
**Symptoom:** "type 'Null' is not a subtype of type 'String'"

**Debug:**
1. Print de response: `print(response.body)`
2. Check of de keys kloppen met je model
3. Check of nullable fields `?` hebben in Dart

## 📱 Live Debugging Tips

**Hot Reload gebruiken:**
1. Maak een wijziging in je code
2. Druk op `r` in de terminal
3. De app update direct zonder opnieuw te builden!

**Widget Inspector:**
- Voeg `debugPrint()` toe voor gedetailleerde logs
- Gebruik `debugDumpApp()` om widget tree te zien
- Gebruik `debugDumpRenderTree()` voor render info

## 🎯 Snelle Debug Workflow

1. **Probleem identificeren** - Wat werkt niet?
2. **Logs checken** - Kijk in terminal/logcat
3. **Prints toevoegen** - Voeg `print()` statements toe
4. **Hot reload** - Druk op `r` om te testen
5. **API testen** - Test API los met curl/Postman
6. **Fix maken** - Los het probleem op
7. **Hot reload** - Test de fix direct!

## 🔧 Debug Mode Features

De app draait nu in debug mode, dit betekent:
- ✅ Hot reload enabled
- ✅ DevTools beschikbaar
- ✅ Alle assertions enabled
- ✅ Debug banner zichtbaar
- ✅ Performance overlay beschikbaar

Voor production build:
```bash
flutter build apk --release
```

## 💡 Pro Tips

1. **Gebruik emoji's in logs** - Makkelijker te vinden
   ```dart
   print('🔵 API Call');
   print('🟢 Success');
   print('🔴 Error');
   ```

2. **Structured logging**
   ```dart
   debugPrint('API Response: ${response.body}', wrapWidth: 1024);
   ```

3. **Conditional debugging**
   ```dart
   const bool DEBUG = true;
   if (DEBUG) print('Debug info');
   ```

4. **Use assert for development checks**
   ```dart
   assert(items.isNotEmpty, 'Items should not be empty');
   ```

Veel succes met debuggen! 🚀

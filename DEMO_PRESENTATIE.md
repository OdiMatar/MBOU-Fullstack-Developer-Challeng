# 📱 Odai's Shop - Demo Presentatie

## 🎯 Wat heb ik gemaakt?

Een complete fullstack mobiele app voor productbeheer met Laravel backend en Flutter frontend.

---

## ✨ Unieke Features (Zelf Gemaakt!)

### 1. 🎨 Kleur Sortering
- Elk product heeft een kleur (bijv. "Titanium Blauw", "Phantom Zwart")
- Sorteer producten op kleur alfabetisch
- Kleur badge op elke product foto

### 2. 🔍 Geavanceerde Filters
- **Zoeken**: Zoek op naam, beschrijving of kleur
- **Merk Filter**: Filter op Apple, Samsung, Google, etc.
- **Sorteer Opties**:
  - Nieuwste eerst
  - Prijs: Laag naar Hoog
  - Prijs: Hoog naar Laag
  - Naam A-Z
  - Voorraad (meeste eerst)
  - Kleur (alfabetisch)

### 3. 📊 Product Informatie
- Productnaam
- Merk (met badge)
- Prijs in euro's
- Voorraad status met kleuren:
  - 🟢 Groen: >10 op voorraad
  - 🟠 Oranje: 1-10 op voorraad
  - 🔴 Rood: Uitverkocht
- Kleur van het product
- Beschrijving
- Afbeelding

### 4. 🎨 Moderne UI/UX
- Mooie product cards met afbeeldingen
- Smooth animaties bij laden
- Pull-to-refresh functionaliteit
- Zoekbalk in de header
- Filter chips met iconen
- Bottom sheets voor filters
- Gradient kleuren
- Material Design 3

### 5. 🔧 CRUD Functionaliteit
- ✅ Create: Nieuwe producten toevoegen
- ✅ Read: Producten bekijken met filters
- ✅ Update: Producten bewerken
- ✅ Delete: Producten verwijderen (met bevestiging)

---

## 🏗️ Technische Stack

### Backend (Laravel)
- **Framework**: Laravel 12
- **Database**: SQLite
- **API**: RESTful JSON API
- **Endpoints**:
  - GET /api/items - Alle producten
  - POST /api/items - Nieuw product
  - PUT /api/items/{id} - Product updaten
  - DELETE /api/items/{id} - Product verwijderen
- **Validatie**: Server-side validatie
- **CORS**: Geconfigureerd voor Flutter

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **UI**: Material Design 3
- **Animaties**: TweenAnimationBuilder
- **Responsive**: Werkt op alle schermformaten

---

## 📦 Database Schema

```sql
items table:
- id (integer, primary key)
- name (string, required)
- description (text, nullable)
- brand (string, nullable)
- price (decimal, nullable)
- stock (integer, default 0)
- image_url (string, nullable)
- color (string, nullable)
- created_at (timestamp)
- updated_at (timestamp)
```

---

## 🎯 Voorbeeldproducten (10 stuks)

1. **iPhone 15 Pro Max** - Apple - €1299.99 - Titanium Blauw
2. **Samsung Galaxy S24 Ultra** - Samsung - €1199.99 - Phantom Zwart
3. **Google Pixel 8 Pro** - Google - €899.99 - Obsidian Zwart
4. **OnePlus 12** - OnePlus - €799.99 - Flowy Emerald
5. **Xiaomi 14 Pro** - Xiaomi - €699.99 - Titanium Grijs
6. **iPhone 14** - Apple - €799.99 - Paars
7. **Samsung Galaxy A54** - Samsung - €449.99 - Awesome Violet
8. **Nothing Phone 2** - Nothing - €599.99 - Wit
9. **iPhone 13 Pro** - Apple - €899.99 - Sierra Blauw
10. **Oppo Find X6 Pro** - Oppo - €749.99 - Desert Silver

---

## 🎬 Demo Flow

### 1. Start Scherm
- Toon "Odai's Shop" met aantal producten
- Zoekbalk bovenaan
- Filter chips (Merk & Sorteren)
- Lijst met product cards

### 2. Filters Demonstreren
- Klik op "Alle" → Toon merk filter
- Selecteer "Apple" → Alleen Apple producten
- Klik op "Nieuwste" → Toon sorteer opties
- Selecteer "Kleur" → Producten gesorteerd op kleur

### 3. Zoeken
- Type "blauw" in zoekbalk
- Toon alleen producten met "blauw" in naam/kleur

### 4. Product Details
- Klik op een product
- Toon edit scherm met alle velden
- Demonstreer bewerken
- Demonstreer verwijderen (met bevestiging)

### 5. Nieuw Product
- Klik op "Nieuw Product" knop
- Vul formulier in
- Toon success melding
- Product verschijnt in lijst

---

## 💡 Wat maakt dit uniek?

### 1. Eigen Design
- Niet de standaard Flutter demo
- Eigen kleurenschema (indigo/paars)
- Unieke filter implementatie
- Custom animaties

### 2. Praktische Features
- Kleur sortering (niet standaard in tutorials)
- Meerdere filter opties tegelijk
- Real-time zoeken
- Voorraad status met kleuren

### 3. Professionele Code
- Clean code structuur
- Proper error handling
- Loading states
- Debug logging met emoji's
- Validatie op client en server

### 4. Complete Functionaliteit
- Volledige CRUD
- Filters en sorteren
- Zoeken
- Afbeeldingen
- Responsive design

---

## 🔍 Code Highlights

### Flutter State Management
```dart
void _applyFilters() {
  List<Item> filtered = List.from(_allItems);
  
  // Filter op merk
  if (_selectedBrand != 'Alle') {
    filtered = filtered.where((item) => 
      item.brand == _selectedBrand
    ).toList();
  }
  
  // Sorteren op kleur
  if (_sortBy == 'Kleur') {
    filtered.sort((a, b) => 
      (a.color ?? '').compareTo(b.color ?? '')
    );
  }
}
```

### Laravel Validatie
```php
$validated = $request->validate([
    'name' => 'required|string|max:255',
    'brand' => 'nullable|string|max:255',
    'price' => 'nullable|numeric|min:0',
    'stock' => 'nullable|integer|min:0',
    'color' => 'nullable|string|max:100',
]);
```

---

## 🎓 Wat heb ik geleerd?

1. **Flutter Development**
   - Widgets en State Management
   - HTTP requests en JSON parsing
   - Animaties en transitions
   - Material Design 3

2. **Laravel API Development**
   - RESTful API design
   - Database migrations
   - Model relationships
   - CORS configuratie

3. **Fullstack Integration**
   - API communicatie
   - Error handling
   - Data synchronisatie
   - Debug technieken

4. **UI/UX Design**
   - User-friendly interfaces
   - Filter en zoek functionaliteit
   - Responsive layouts
   - Loading states

---

## 🚀 Hoe te Runnen

1. **Backend starten**: Dubbelklik `START.bat`
2. **Emulator starten**: Open Android Studio → Start emulator
3. **App starten**: `cd app` → `flutter run`
4. **Klaar!** App draait op emulator

---

## 📝 Conclusie

Dit is een volledig werkende, professionele mobiele app die ik zelf heb gebouwd. 
De unieke features zoals kleur sortering, geavanceerde filters, en het moderne 
design laten zien dat dit geen standaard tutorial is, maar een eigen implementatie.

**Gemaakt door: Odai**
**Datum: 11 februari 2026**
**Tech Stack: Laravel + Flutter**

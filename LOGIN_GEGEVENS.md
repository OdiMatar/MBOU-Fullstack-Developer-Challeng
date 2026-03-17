# 🔐 Login Gegevens - Odai App

## Admin Account (Kan alles bewerken)

**Email:** admin@odai.com  
**Wachtwoord:** admin123

**Rechten:**
- ✅ Producten toevoegen
- ✅ Producten bewerken
- ✅ Producten verwijderen
- ✅ Alle producten bekijken
- ❌ Kan NIET kopen (alleen beheren)

---

## Normale Gebruiker (Kan alleen kopen)

**Email:** user@test.com  
**Wachtwoord:** user123

**Rechten:**
- ✅ Producten bekijken
- ✅ Producten kopen
- ✅ Product details zien
- ❌ Kan NIET bewerken
- ❌ Kan NIET toevoegen
- ❌ Kan NIET verwijderen

---

## Verschillen

### Als Admin:
- Titel toont: "Odai App (Admin)"
- Zie "+" knop om nieuwe producten toe te voegen
- Klik op product → Direct naar bewerk scherm
- Geen "Kopen" knop

### Als Normale Gebruiker:
- Titel toont: "Odai App"
- Geen "+" knop (kan niet toevoegen)
- Klik op product → Product detail scherm met "Kopen" knop
- Kan aantal kiezen en product kopen

---

## Nieuwe Account Aanmaken

Je kunt ook een nieuw account aanmaken:
1. Klik op "Registreer" op het login scherm
2. Vul naam, email en wachtwoord in
3. Nieuwe accounts zijn automatisch "user" (geen admin)

---

## Test Scenario's

### Test 1: Admin Functionaliteit
1. Log in als admin (admin@odai.com / admin123)
2. Zie "(Admin)" in de titel
3. Klik op "+" om nieuw product toe te voegen
4. Klik op een product om te bewerken
5. Verwijder een product

### Test 2: Gebruiker Functionaliteit
1. Log uit (klik op logout icoon)
2. Log in als user (user@test.com / user123)
3. Zie geen "(Admin)" in de titel
4. Geen "+" knop zichtbaar
5. Klik op een product
6. Zie product details met "Kopen" knop
7. Kies aantal en klik "Kopen"

### Test 3: Registratie
1. Log uit
2. Klik "Registreer"
3. Maak nieuw account aan
4. Log in met nieuwe account
5. Je bent nu een normale gebruiker

---

## Technische Details

**Database:**
- Users tabel heeft `role` kolom ('admin' of 'user')
- Purchases tabel slaat aankopen op
- Items tabel heeft voorraad die automatisch vermindert bij aankoop

**API Endpoints:**
- POST /api/login - Inloggen
- POST /api/register - Registreren
- POST /api/purchases - Product kopen
- GET /api/purchases/user/{id} - Aankopen van gebruiker

**Flutter:**
- AuthService controleert of gebruiker admin is
- UI past zich aan op basis van role
- SharedPreferences slaat user data op

# Arsenal Manager — Flutter UI

Batman/Wayne Enterprises-themed mobile inventory management app. Built with Flutter, backed by the [ArsenalApi](../ArsenalApi) C# ASP.NET Core 8 Web API.

---

## Features

- **Dashboard** — stat cards (Total Gear, Critical, Low Stock, In Stock), division chips, top gear by quantity, supply alerts
- **Arsenal** — searchable inventory list with color-coded status indicators, tap to edit
- **Add/Edit Gear** — form with division dropdown, quantity input, notes; delete from edit screen
- **Stats** — donut/pie chart breakdown (In Stock / Low Stock / Critical), per-division summary

---

## Design Tokens

| Token | Value |
|---|---|
| Background | `#0D0D0D` |
| Card surface | `#1A1A1A` |
| Card elevated | `#222222` |
| Primary accent (Wayne blue) | `#1E90FF` |
| Secondary accent | `#1B4FBF` |
| In Stock | `#4CAF50` |
| Low Stock | `#FFC107` |
| Critical | `#F44336` |
| Text primary | `#FFFFFF` |
| Text secondary | `#9E9E9E` |
| Fonts | Orbitron (headers), Roboto (body) |

**Stock thresholds:** Critical ≤ 5 | Low 6–15 | In Stock > 15

**Naming conventions:** Inventory → Arsenal | Items → Gear | Categories → Divisions | Add Item → Add Gear

---

## Tech Stack

| Dependency | Version | Purpose |
|---|---|---|
| `http` | ^1.1.0 | HTTP calls to C# API |
| `provider` | ^6.1.1 | State management |
| `google_fonts` | ^6.1.0 | Orbitron + Roboto fonts |
| `fl_chart` | ^0.65.0 | Donut/pie chart on Stats screen |
| `percent_indicator` | ^4.2.3 | Progress indicators |

---

## Project Structure

```
lib/
├── main.dart                    # App entry, MultiProvider, 3-tab BottomNavigationBar
├── theme/
│   └── app_theme.dart           # Full Batman dark theme + color constants
├── models/
│   ├── gear_item.dart           # GearItem + StockStatus enum
│   ├── division.dart            # Division model
│   └── dashboard_stats.dart     # DashboardStats aggregate
├── services/
│   └── api_service.dart         # HTTP client — all API calls
├── providers/
│   └── arsenal_provider.dart    # ChangeNotifier state layer
├── screens/
│   ├── dashboard_screen.dart    # Home screen
│   ├── arsenal_screen.dart      # Searchable gear list
│   ├── add_gear_screen.dart     # Create new gear
│   ├── edit_gear_screen.dart    # Edit / delete gear
│   └── stats_screen.dart        # Pie chart + division breakdown
└── widgets/
    ├── bat_app_bar.dart          # Custom AppBar with Wayne shield icon
    ├── stat_card.dart            # Metric card with accent glow
    ├── gear_card.dart            # List tile with status border
    └── status_badge.dart         # Green/yellow/red pill badge
```

---

## Getting Started

### Prerequisites
- Flutter SDK (3.x+)
- ArsenalApi running locally (see [../ArsenalApi/README.md](../ArsenalApi/README.md))

### Install dependencies
```bash
flutter pub get
```

### Configure API URL

Edit `lib/services/api_service.dart`:

```dart
// Android emulator
static const String baseUrl = 'http://10.0.2.2:5000/api';

// Web or desktop
static const String baseUrl = 'http://localhost:5000/api';

// Physical device (use your machine's LAN IP)
static const String baseUrl = 'http://192.168.x.x:5000/api';
```

### Run
```bash
flutter run
```

---

## API Contract

All data comes from the ArsenalApi. Expected endpoints:

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/gear` | All gear (optional `?search=`) |
| GET | `/api/gear/{id}` | Single gear item |
| POST | `/api/gear` | Create gear item |
| PUT | `/api/gear/{id}` | Update gear item |
| DELETE | `/api/gear/{id}` | Delete gear item |
| GET | `/api/divisions` | All divisions |
| GET | `/api/dashboard/stats` | `{ totalGear, criticalCount, lowStockCount, inStockCount }` |

---

## Test Checklist

- [ ] Dashboard shows live counts from API
- [ ] Add Gear form → item appears in Arsenal list
- [ ] Tap item → Edit screen pre-populated
- [ ] Delete item → removed from list
- [ ] Stats screen → percentages match actual data
- [ ] Search bar filters Arsenal list in real time
- [ ] Pull-to-refresh on Dashboard reloads data

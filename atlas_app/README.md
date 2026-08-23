# 📱 Atlas Mobile Application (`atlas_app`)

> **Android Beta Release (`v1.0.0-beta`)** • Package ID: `com.atlas.trips`

The primary mobile client for **Project Atlas — Collaborative Group Travel & Expenses OS**. Built with Flutter 3.x, Riverpod 3.4, GoRouter, and Supabase.

---

## 📖 Main Documentation

For the complete product overview, architectural documentation, roadmap, and full feature breakdown, please see the [**Root README**](../README.md) and the comprehensive [**Documentation Suite (`/docs`)**](../docs/).

---

## ⚡ Quick Start

```bash
# 1. Navigate to mobile workspace
cd atlas_app

# 2. Get dependencies
flutter pub get

# 3. Run with environment configuration
flutter run --dart-define-from-file=.env
```

---

## 🛠️ Key Architectural Layers

* **`lib/core/`**: Custom design system (`AtlasCard`, `AtlasButton`, `AtlasAvatar`), 120Hz display optimization, dynamic dark/light theme, and deep-link routing.
* **`lib/features/trips/`**: Trip dashboard, dynamic greetings, destination cards, and trip overview metrics.
* **`lib/features/consensus/`**: "Consensus Before Commitment" voting engine with quorum tracking.
* **`lib/features/itinerary/`**: Interactive timeline with day scrubber and event taxonomy.
* **`lib/features/ledger/`**: Group expense splitter, animated odometer spend counters, and per-person balance calculator.
* **`lib/features/chat/`**: WebSocket realtime group communication and ambient backdrop.
* **`lib/features/members/`**: RBAC permissions and deep-link invitation generator.
* **`lib/features/notifications/`**: Realtime in-app alert feed.
* **`lib/features/auth/`**: Supabase authentication and onboarding carousel.

---

*See [Project Atlas Root README](../README.md) for full details.*

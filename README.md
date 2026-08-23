# 🌍 Project Atlas — Collaborative Group Travel & Expenses OS

<div align="center">

![Project Atlas Logo](atlas-logo-vector.svg)

### *The intelligent, all-in-one operating system for modern group travel.*

[![Status](https://img.shields.io/badge/Status-Beta%20v1.0.0-blue.svg?style=for-the-badge&logo=rocket)](https://github.com/vishwarajkhatpe/project-atlas)
[![Flutter](https://img.shields.io/badge/Flutter-3.x%20%7C%20Dart%203.12+-02569B.svg?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Backend](https://img.shields.io/badge/Backend-Supabase%20%2F%20PostgreSQL-3ECF8E.svg?style=for-the-badge&logo=supabase)](https://supabase.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20Riverpod%203.4-FF6F00.svg?style=for-the-badge)](https://riverpod.dev)
[![Display](https://img.shields.io/badge/Display-120Hz%20ProMotion%20Optimized-9C27B0.svg?style=for-the-badge)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-Proprietary%20%2F%20Internal-red.svg?style=for-the-badge)](#license)

**[Overview](#-executive-summary) • [Current Beta Features](#-current-beta-implementation-detailed-breakdown) • [Architecture](#-system-architecture--tech-stack) • [Roadmap](#-product-roadmap--future-evolution) • [Getting Started](#-getting-started--local-development) • [Docs Suite](#-documentation-suite-volumes-0110)**

---

</div>

## 📌 Executive Summary

**Project Atlas** is a mobile-first collaborative operating system engineered to eliminate friction across every phase of group travel.

Today, planning a trip with friends, family, or colleagues requires constantly switching between at least **7 disconnected applications**:
* 💬 **WhatsApp / Telegram**: Buried discussions, endless polls, and lost decisions.
* 📍 **Google Maps**: Scattered pins and disconnected location notes.
* 💸 **Splitwise / Tricount**: Isolated expense tracking with no itinerary context.
* 📁 **Google Drive / Dropbox**: Chaotic booking PDFs, flight tickets, and photo dumps.
* 📝 **Apple Notes / Notion**: Out-of-date static itineraries that only one person edits.
* 🏨 **Booking Platforms**: Disjointed confirmation emails and voucher screenshots.
* 🏦 **Banking Apps**: Messy peer-to-peer settlement calculations.

### The Project Atlas Paradigm
Instead of asking travelers to juggle fragmented tools, **Atlas** unifies the entire journey into a single real-time collaborative workspace:

$$\text{Trip Idea} \longrightarrow \text{Consensus} \longrightarrow \text{Itinerary} \longrightarrow \text{Execution} \longrightarrow \text{Ledger} \longrightarrow \text{Memories}$$

1. **Democratic Consensus**: Important decisions (dates, destinations, hotels, activities) are resolved through formal structured voting rather than chaotic chat debates.
2. **Synchronized Timeline**: A real-time day-by-day interactive itinerary updated instantaneously across all devices.
3. **Integrated Group Ledger**: Real-time expense splitting, currency management, and live per-person balance calculations tied directly to trip events.
4. **Sub-Millisecond Communication**: In-trip real-time chat synchronized via Supabase WebSockets.
5. **Granular Access Control**: Robust Role-Based Access Control (`Owner`, `Planner`, `Member`) protected by PostgreSQL Row-Level Security (RLS).

---

## 🚀 Current Project Status: `v1.0.0-Beta`

> [!IMPORTANT]
> **Active Release Stage: Android Beta (v1.0.0-beta)**
> 
> The codebase has successfully completed **Phase 1 (Core Collaborative Engine)** and passed a rigorous **Android Production Readiness & Security Audit**. 
> All foundational trip coordination features are fully implemented, connected to Supabase Cloud, and ready for closed-beta testing. Advanced capabilities (AI itinerary engine, OCR receipt scanning, debt graph simplification, shared photo vault) are scheduled for **v1.1+ and v2.0**.

```text
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             PROJECT ATLAS LIFECYCLE                              │
├─────────────────────────┬─────────────────────────┬──────────────────────────────┤
│  PHASE 0: SPECIFICATION │   PHASE 1: BETA (NOW)   │     PHASE 2+: V1.0 & V2.0    │
│  ✅ 10-Volume PRD Suite │  ✅ Mobile Core App     │  ⏳ AI Itinerary Generator   │
│  ✅ Database Schema     │  ✅ Consensus Engine    │  ⏳ OCR Receipt Scanner      │
│  ✅ Security Policies   │  ✅ Group Ledger        │  ⏳ Debt Simplification      │
│  ✅ UI/UX Design Tokens │  ✅ Realtime Chat       │  ⏳ Shared Photo Vault       │
│  ✅ Android Audit Pass  │  ✅ Deep-Link Invites   │  ⏳ Offline SQLite Sync      │
└─────────────────────────┴─────────────────────────┴──────────────────────────────┘
```

---

## ✨ Current Beta Implementation (Detailed Breakdown)

The current `v1.0.0-beta` client delivers a rich, production-grade Flutter experience built with **Clean Architecture**, **Riverpod State Management**, and **Supabase Realtime**.

```
atlas_app/
├── lib/
│   ├── core/
│   │   ├── constants/       # App-wide static configuration
│   │   ├── router/          # GoRouter auth-guarded routing & deep link dispatching
│   │   ├── services/        # Deep link listener & system integrations
│   │   ├── theme/           # AppColors, AppTheme, typography, radii, spacing
│   │   ├── utils/           # Error translation (AppErrorHandler, AuthErrorFormatter)
│   │   └── widgets/         # Atomic design system (AtlasCard, AtlasButton, AtlasAvatar, etc.)
│   └── features/
│       ├── auth/            # Supabase Auth, onboarding carousel, profile management
│       ├── chat/            # WebSocket realtime group messaging & ambient background
│       ├── consensus/       # Democratic proposal voting engine & quorum calculation
│       ├── itinerary/       # Day-by-day interactive timeline & event taxonomy
│       ├── ledger/          # Group expense tracking, odometer counters & share calculation
│       ├── members/         # RBAC roster, email invites & deep-link token generation
│       ├── notifications/   # In-app alert feed for proposals, itinerary, & ledger
│       └── trips/           # Trips dashboard, dynamic greeting, cover cards & overview
```

### 1. 🗂️ Intelligent Trips Dashboard & Hub
* **Dynamic Time-Context Greetings**: Personalized welcoming headers ("Good morning / afternoon / evening, Explorer") with live user profile integration.
* **Tri-State Trip Filter Chips**: Seamlessly switch between `All`, `Upcoming`, and `Past` journeys.
* **Rich Visual Cover Cards**: Destination cards featuring dynamic high-resolution photography, contextual fallback generators, and gradient mesh overlays.
* **Departure Countdowns**: Instant status badges ("3d away", "Ongoing", "Completed").
* **Floating Capsule Navigation**: Custom interactive bottom navigation bar with fluid finger-drag scrubbing across the 6 trip sub-modules.
* **Trip Creation Modal**: Smooth bottom sheet with date-range pickers, destination metadata, and atomic database provisioning.

---

### 2. 🗳️ "Consensus Before Commitment" Decision Engine
* **Structured Proposals**: Eliminates lost WhatsApp agreements by transforming travel ideas into actionable, trackable voting cards.
* **5 Proposal Categories**:
  * 📍 `Destination`
  * 📅 `Dates`
  * 🏨 `Accommodation`
  * 🏄 `Activity`
  * 💡 `Other`
* **Tri-State Voting Mechanism**: Every trip member can cast their vote (`Approve`, `Reject`, `Abstain`) with instant tactile haptic feedback.
* **Live Quorum & Visual Progress Bars**: Real-time percentage bars dynamically calculate approval ratios against group size.
* **Role-Gated Resolution**: Trip Owners and Planners can formally **Finalize (Approve)** or **Reject** proposals, cementing decisions into the trip itinerary.

---

### 3. 📅 Interactive Chronological Itinerary
* **Timeline View with Day Scrubber**: Horizontal date-selector bar allowing instant navigation across each day of the journey.
* **Color-Coded Event Taxonomy**: Visual category chips for `Flight`, `Hotel`, `Food`, `Activity`, `Sightseeing`, `Transport`, and `Other`.
* **Timezone-Resilient Scheduling**: Accurate start and end timestamp handling with ISO-8601 formatting.
* **CRUD Management**: Planners and Owners can add, edit, or remove itinerary events with real-time multi-device synchronization.

---

### 4. 💳 Group Ledger & Expense Splitter
* **Transparent Shared Ledger**: Track all group expenditures in one unified financial feed.
* **Animated Odometer Counter**: Dynamic numerical rolling counter displaying the total trip investment in real-time.
* **4-Metric Financial Breakdown**:
  1. 💰 **Total Trip Spend**: Cumulative group cost.
  2. 👥 **User Share Per Person**: Exact individual liability based on active roster count.
  3. 💳 **You Paid**: Total amount fronted by the current user.
  4. ⚖️ **Net Balance**: Live indicator of whether the user is owed money or needs to settle.
* **Multi-Currency Support**: Built-in formatting for `USD ($)`, `EUR (€)`, `GBP (£)`, `INR (₹)`, `JPY (¥)`, `AUD ($)`, `CAD ($)`, etc.
* **Defensive Financial Parsing**: Strict parsing logic protecting against precision degradation across PostgreSQL `NUMERIC(10, 2)` columns.

---

### 5. 💬 Realtime Group Chat & Presence
* **Sub-Millisecond WebSocket Sync**: Direct Supabase Realtime channel integration for instantaneous messaging.
* **Ambient UI Design**: Glassmorphic message bubbles layered over an animated ambient background.
* **Sender Profiles & Relative Timestamps**: Profile avatars, sender names, and relative human-readable timestamps (`timeago`).
* **Quick Member Access**: One-tap shortcut from chat directly into the live trip member roster.

---

### 6. 👥 Member Management, RBAC & Deep Linking
* **Granular Role-Based Access Control (RBAC)**:
  * 👑 **Owner**: Full administrative control (trip deletion, member removal, proposal resolution, itinerary management).
  * 🛠️ **Planner**: Manage itinerary events, create proposals, and resolve consensus items.
  * 🎒 **Member**: Vote on proposals, log expenses, participate in chat, and view full trip details.
* **Click-to-Join Deep Linking**: Instant invitation generation (`atlas://trip/join?token=...`) with seamless app link dispatching.
* **Native System Sharing**: Built-in integration with `SharePlus` to dispatch invite links via WhatsApp, Telegram, SMS, or Email.
* **Real-time Member Listeners**: Instant roster updates when new travelers join or are removed.

---

### 7. 🔔 In-App Notification Center
* **Live Activity Streams**: Consolidated alert feed for trip invitations, newly logged proposals, vote thresholds reached, and itinerary adjustments.
* **Unread Indicators**: Visual badges keeping travelers synchronized on pending actions.

---

### 8. 🎨 Design System & Native Performance
* **Adaptive Dark & Light Themes**: Curated HSL color palette (`AppColors`, `AppTheme`) paired with **Plus Jakarta Sans** and **Outfit** typography.
* **120Hz High-Refresh Rate Optimization**: Integrated `flutter_displaymode` unlocking ultra-smooth 120Hz ProMotion animations on supported Android hardware.
* **Edge-to-Edge Experience**: Transparent status and system navigation bars adhering to Android 15 edge-to-edge guidelines.
* **Tactile Haptics & Micro-Animations**: `BouncyWidget` spring physics, `flutter_animate` staggered entrances, and contextual haptic feedback.
* **Offline Resilience & Error Shielding**:
  * Real-time network monitor (`ConnectivityBanner`) with automatic reconnection.
  * `CachedNetworkImage` with procedural, AI-styled gradient fallbacks.
  * Friendly, sanitized error translations (`AuthErrorFormatter`, `AppErrorHandler`).

---

## 🏗️ System Architecture & Tech Stack

Project Atlas adheres strictly to **Clean Architecture** and the **Separation of Concerns**, ensuring high testability, modularity, and rapid feature expansion.

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                             PRESENTATION LAYER                              │
│         Flutter UI Widgets  •  Riverpod AsyncNotifiers  •  GoRouter         │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (Calls)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│                                DOMAIN LAYER                                 │
│          Business Logic  •  Consensus Rules  •  Split Algorithms            │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (Implements)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│                                 DATA LAYER                                  │
│       Repositories  •  PostgREST Queries  •  Supabase Realtime Streams      │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (Network / WebSocket)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│                            SUPABASE BACKEND / CLOUD                         │
│   PostgreSQL 15  •  Row Level Security  •  Triggers & RPCs  •  GoTrue Auth  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Technology Matrix

| Layer | Technology | Purpose & Capabilities |
|---|---|---|
| **Mobile Client** | **Flutter 3.x / Dart 3.12+** | Cross-platform high-performance native rendering engine |
| **State Management** | **Flutter Riverpod 3.4** | Compile-safe, declarative state management & dependency injection |
| **Navigation & Routing** | **GoRouter 17.4** | Declarative URL-based routing, deep link parsing, auth guards |
| **Backend & Database** | **Supabase / PostgreSQL 15** | Managed PostgreSQL database, authentication, realtime replication |
| **Security & Auth** | **Supabase Auth + RLS** | JWT authentication, automated profile trigger, Row-Level Security |
| **Realtime Sync** | **Supabase Realtime Channels** | WebSocket pub/sub for instant chat, proposals, votes, and roster sync |
| **Design & Typography** | **Google Fonts / Lucide** | Plus Jakarta Sans, Outfit, Lucide modern iconography |
| **Hardware & Native** | **DisplayMode & Haptics** | 120Hz refresh rates, predictive back gestures, tactile feedback |

---

## 🗄️ Database Architecture & Row-Level Security (RLS)

The backend is built upon a secure, normalized PostgreSQL schema residing in `supabase/schema.sql`.

```
                    ┌─────────────────────────┐
                    │      public.users       │
                    └────────────┬────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │ 1:N                   │ 1:N                   │ 1:N
┌────────▼────────┐     ┌────────▼────────┐     ┌────────▼────────┐
│  public.trips   │     │  trip_members   │     │ trip_invitations│
└────────┬────────┘     └─────────────────┘     └─────────────────┘
         │
         ├───────────────────────┬───────────────────────┬───────────────────────┐
         │ 1:N                   │ 1:N                   │ 1:N                   │ 1:N
┌────────▼────────┐     ┌────────▼────────┐     ┌────────▼────────┐     ┌────────▼────────┐
│ public.proposals│     │itinerary_events │     │ public.expenses │     │ public.messages │
└────────┬────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘
         │ 1:N
┌────────▼────────┐
│  public.votes   │
└─────────────────┘
```

### Security & Integrity Highlights
1. **Multi-Tenant Row-Level Security (RLS)**: Every single table enforces strict RLS policies. Users can only read or write records belonging to trips where they hold verified membership.
2. **Privilege Escalation Prevention**: Invitation validation checks prevent unauthorized users from self-assigning `owner` or `planner` roles.
3. **Optimized Membership Verification**: The `is_trip_member(_trip_id, _user_id)` `SECURITY DEFINER` function eliminates recursive RLS evaluation loops.
4. **Atomic Trip Provisioning**: Stored procedure `create_trip_with_owner()` guarantees that trip creation and owner role assignment execute within a single ACID transaction.
5. **Realtime Replication Publication**: The `supabase_realtime` publication actively broadcasts changes across `messages`, `trips`, `trip_members`, `trip_invitations`, `proposals`, `votes`, `itinerary_events`, and `expenses`.

---

## 🗺️ Product Roadmap & Future Evolution

Project Atlas follows a structured **3-Phase Evolution Roadmap** transitioning from the current robust collaborative core to an AI-native travel operating ecosystem.

```text
  CURRENT BETA                         VERSION 1.1 - 1.3                      VERSION 2.0 (VISION)
┌──────────────────────────────┐     ┌──────────────────────────────┐     ┌──────────────────────────────┐
│  v1.0.0-Beta (Active)        │     │  v1.1 - v1.3 (Upcoming)      │     │  v2.0 (AI Operating System)  │
├──────────────────────────────┤     ├──────────────────────────────┤     ├──────────────────────────────┤
│ • Complete Trip Hub & Nav    │ ──► │ • Offline SQLite Cache/Sync  │ ──► │ • Multi-Agent Travel Planner │
│ • Democratic Consensus Engine│     │ • OCR Receipt & Bill Scanner │     │ • AI Decision Arbitration    │
│ • Interactive Timeline Plan  │     │ • Debt Graph Simplification  │     │ • Shared Media AI Vault      │
│ • Shared Group Ledger        │     │ • Live Multi-Currency Rates  │     │ • Real-time Location Radar   │
│ • Realtime WebSocket Chat    │     │ • Push Notifications (FCM)   │     │ • Travel Booking API Sync    │
│ • Android Production Hardened│     │ • iOS App Store Launch       │     │ • React/Next.js Web Portal   │
└──────────────────────────────┘     └──────────────────────────────┘     └──────────────────────────────┘
```

### 📍 Stage 1: Current Beta (`v1.0.0-beta`) — *Completed & Active*
- [x] Full Architectural & PRD Documentation Suite (Volumes 01–10).
- [x] End-to-end Supabase Auth flow with auto-provisioning database triggers.
- [x] Trips Dashboard with multi-state filters and destination cover cards.
- [x] Consensus voting engine with live quorum calculations.
- [x] Interactive day-by-day itinerary with event taxonomy.
- [x] Shared expense ledger with dynamic per-person share metrics.
- [x] WebSocket realtime chat with glassmorphic UI.
- [x] Granular RBAC permissions (`owner`, `planner`, `member`).
- [x] Deep link invite generation and token routing (`com.atlas.trips`).
- [x] 120Hz display optimization, edge-to-edge UI, and Android production audit compliance.

### 📍 Stage 2: Mobile v1.0 & Financial Intelligence (`v1.1` - `v1.3`)
- [ ] **Offline Resilience Engine**: Local SQLite / Hive cache allowing travelers to browse itineraries, read chats, and log expenses without active cellular reception.
- [ ] **OCR Smart Receipt Scanner**: Computer-vision powered receipt capture using edge ML to automatically extract vendor, line items, tax, and totals into the ledger.
- [ ] **Debt Graph Simplification**: Algorithmic peer-to-peer debt minimization (e.g., reducing 15 cross-member debts down to 3 optimal settlement transfers).
- [ ] **Live Currency Conversion**: Automatic real-time foreign exchange rate fetching for multi-country expeditions.
- [ ] **Push Notification Infrastructure**: Firebase Cloud Messaging (FCM) and Apple Push Notification Service (APNs) background dispatching.
- [ ] **iOS Production Certification**: Native iOS deployment with full Apple ProMotion and Liquid Retina adaptation.

### 📍 Stage 3: AI-Native Operating System (`v1.5` - `v2.0`)
- [ ] **Autonomous AI Itinerary Architect**: Natural language trip generation synthesizing group preferences, budgets, flight schedules, and weather forecasts into comprehensive itineraries.
- [ ] **AI Decision Arbiter**: Intelligent assistant in group chats that detects disagreements, summarizes trade-offs, and drafts balanced consensus proposals.
- [ ] **Collaborative Shared Media Vault**: High-speed photo/video vault with on-device perceptual hashing, automatic blur filtering, duplicate removal, and AI highlight reels.
- [ ] **Realtime Group Radar**: Opt-in live geolocation sharing and dynamic meeting point recommendations when exploring foreign cities.
- [ ] **Direct Booking Integrations**: In-app reservations for airlines, hotels, and activities via global travel API connectors.
- [ ] **Desktop & Web Companion Ecosystem**: React / Next.js web application for large-screen trip administration and enterprise group coordination.

---

## 🛠️ Getting Started & Local Development

Follow these instructions to run the Project Atlas mobile client locally.

### 1. Prerequisites
* **Flutter SDK**: `^3.24.0` or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
* **Dart SDK**: `^3.12.0` (bundled with Flutter)
* **Android Studio / Xcode**: Configured for Android/iOS emulation
* **Supabase Project**: A valid Supabase cloud instance or local Supabase CLI installation

### 2. Clone the Repository
```bash
git clone https://github.com/vishwarajkhatpe/project-atlas.git
cd project-atlas
```

### 3. Configure Environment Variables
Create an environment file `atlas_app/.env` (or pass build arguments) with your Supabase credentials:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here
```

### 4. Setup Database Schema
1. Open your Supabase Project Dashboard $\rightarrow$ **SQL Editor**.
2. Copy and execute the contents of [`supabase/schema.sql`](supabase/schema.sql).
3. Ensure the `supabase_realtime` publication is active for all core tables.

### 5. Install Dependencies & Launch
```bash
cd atlas_app

# Fetch Flutter dependencies
flutter pub get

# Run on connected Android / iOS device or emulator
flutter run --dart-define-from-file=.env
```

### 6. Build Release Binaries
```bash
# Build Android App Bundle for Google Play
flutter build appbundle --release --dart-define-from-file=.env

# Build Android APK
flutter build apk --release --dart-define-from-file=.env
```

---

## 📜 Documentation Suite (Volumes 01–10)

Project Atlas is backed by an enterprise-grade architectural documentation suite located in the [`docs/`](docs/) directory:

| Document | Title & Focus |
|---|---|
| 📘 [**Volume 01**](docs/Volume-01-Product-Vision.md) | **Product Vision & Business Requirements**: Core philosophy, market analysis, and user journeys. |
| 📘 [**Volume 02**](docs/Volume-02-Functional-Requirements.md) | **Functional Requirements Spec (FRS)**: Complete functional breakdown of all 13 platform engines. |
| 📘 [**Volume 03**](docs/Volume-03-System-Architecture-and-Technical-Design.md) | **System Architecture & Technical Design**: Monolith vs. microservices, data flows, and communication layers. |
| 📘 [**Volume 04**](docs/Volume-04-Domain-Model-and-Database-Design.md) | **Domain Model & Database Schema**: Entity relationship modeling, consensus policies, and data lifecycles. |
| 📘 [**Volume 05**](docs/Volume-05-AI-Architecture-and-Intelligence-Platform.md) | **AI Architecture & Intelligence Platform**: LLM orchestration, CV pipelines, token budgets, and safety. |
| 📘 [**Volume 06**](docs/Volume-06-Backend-Architecture-and-API-Design.md) | **Backend Architecture & API Design**: REST/GraphQL contract design, authentication, and caching patterns. |
| 📘 [**Volume 07**](docs/Volume-07-Client-Applications.md) | **Client Applications Design**: Mobile & Web client structure, offline synchronization, and state management. |
| 📘 [**Volume 08**](docs/Volume-08-Platform-Infrastructure-and-Operations.md) | **Infrastructure & Operations**: Cloud infrastructure, CI/CD pipelines, SRE standards, and disaster recovery. |
| 📘 [**Volume 09**](docs/Volume-09-Engineering-Standards-and-Development-Guide.md) | **Engineering Standards & Contributor Guide**: Code conventions, Clean Architecture rules, and Definition of Done. |
| 📘 [**Volume 10**](docs/Volume-10-Product-Roadmap-and-Future-Evolution.md) | **Product Roadmap & Future Evolution**: Strategic multi-year growth trajectory and platform scaling. |

---

## 📈 Engineering Journey & Major Git Milestones

A summary of the core engineering achievements reflected across our commit history:

```text
9c01ba4  feat: Upgrade navigation bar, chat UX, and add app-wide micro-animations
d5d43ff  feat: Add UX, polish, and edge case handling (offline resilience, error translation, image fallbacks)
255606f  fix: resolve deep link auth race condition, ledger precision, and itinerary timezones
60eb366  feat(ui): implement cached network images with contextual ai generated fallbacks
0bd4486  feat(ui): implement glassmorphism across tabs and refine hero header layouts
77baca9  feat(playstore): add vector logo SVG, configure com.atlas.trips package ID, generate native launcher icons
8122d14  feat(auth): overhaul welcome onboarding, login, and signup screens with dark luxury design
2647309  feat: implement system dynamic dark mode, 120Hz high refresh rate optimizations
37a3865  feat(dashboard): overhaul Home Screen with dynamic greeting, trip filter chips, and rich cover cards
95ce813  feat(navigation): implement floating capsule nav bar with interactive finger drag scrubbing
b836390  feat(overview): overhaul Home screen with 4-metric grid, unread chat status, and restored travelers card
0a7a6de  feat(itinerary): add interactive timeline, day selector bar, category chips, and card layout fixes
5fef440  feat(ledger): add animated total cost counter and interactive expense metrics
c68b8b5  fix: invitations layout crash, Realtime websocket sync, and RLS security loop policies
37c7d4f  chore: update schema.sql with audit report architectural fixes and RLS hardening
61e5bb2  chore: complete Android beta production readiness audit
```

---

## 🔒 Security & Privacy Standards

* **Zero Plaintext Secrets**: Build-time environment variable injection via `--dart-define-from-file`.
* **Zero Trust Data Access**: Granular PostgreSQL Row-Level Security ensuring strict multi-tenant boundary isolation.
* **Predictive Back & Safe Exits**: Android 15 compliant predictive back gestures and dirty-check pop scopes on all entry sheets.
* **Privacy First**: User location and financial data are encrypted in transit (TLS 1.3) and at rest.

---

## 👥 Contributors & Maintainers

* **Lead Architect & Engineering**: [Vishwaraj Khatpe](https://github.com/vishwarajkhatpe)
* **Design & Experience**: Project Atlas Product & UI/UX Team

---

<div align="center">

**Built with ❤️ for travelers who want to explore the world together, without the chaos.**

*© 2026 Project Atlas. All rights reserved.*

</div>

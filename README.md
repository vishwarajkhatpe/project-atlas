# 🌍 Project Atlas — Collaborative Group Travel & Expenses OS

<div align="center">

![Project Atlas Logo](atlas-logo-vector.svg)

### *The intelligent, all-in-one operating system for modern group travel.*

[![Status](https://img.shields.io/badge/Status-Beta%20v0.1.0-blue.svg?style=for-the-badge&logo=rocket)](https://github.com/vishwarajkhatpe/project-atlas)
[![Flutter](https://img.shields.io/badge/Flutter-3.x%20%7C%20Dart%203.12+-02569B.svg?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Backend](https://img.shields.io/badge/Backend-Supabase%20%2F%20PostgreSQL-3ECF8E.svg?style=for-the-badge&logo=supabase)](https://supabase.com)
[![Display](https://img.shields.io/badge/Display-120Hz%20ProMotion%20Optimized-9C27B0.svg?style=for-the-badge)](https://developer.android.com)

**[Overview](#-executive-summary) • [Current Beta Features](#-core-product-features-detailed-breakdown) • [Roadmap](#-product-roadmap--future-evolution) • [Download](#-download--installation) • [Developer Journey](#-the-developer-journey)**

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

## 🚀 Current Project Status: `v0.1.0-Beta`

> [!IMPORTANT]
> **Active Release Stage: Android Beta (v0.1.0-beta)**
> 
> The application has successfully passed rigorous **Android Production Readiness & Security Audits**. 
> All foundational trip coordination features are fully implemented, connected to Supabase Cloud, and ready for closed-beta testing. Advanced capabilities (AI itinerary engine, OCR receipt scanning, debt graph simplification, shared photo vault) are scheduled for `v1.0` and beyond.

---

## ✨ Core Product Features (Detailed Breakdown)

The current `v0.1.0-beta` client delivers a rich, production-grade mobile experience built for scale and performance.

### 1. 🗂️ Intelligent Trips Dashboard & Hub
* **Dynamic Time-Context Greetings**: Personalized welcoming headers ("Good morning / afternoon / evening, Explorer").
* **Tri-State Trip Filter Chips**: Seamlessly switch between `All`, `Upcoming`, and `Past` journeys.
* **Rich Visual Cover Cards**: Destination cards featuring dynamic high-resolution photography, contextual fallback generators, and gradient mesh overlays.
* **Departure Countdowns**: Instant status badges ("3d away", "Ongoing", "Completed").
* **Floating Capsule Navigation**: Custom interactive bottom navigation bar with fluid finger-drag scrubbing across the 6 trip sub-modules.

### 2. 🗳️ "Consensus Before Commitment" Decision Engine
* **Structured Proposals**: Eliminates lost WhatsApp agreements by transforming travel ideas into actionable, trackable voting cards.
* **5 Proposal Categories**: 📍 `Destination`, 📅 `Dates`, 🏨 `Accommodation`, 🏄 `Activity`, 💡 `Other`.
* **Tri-State Voting Mechanism**: Every trip member can cast their vote (`Approve`, `Reject`, `Abstain`) with instant tactile haptic feedback.
* **Live Quorum & Visual Progress Bars**: Real-time percentage bars dynamically calculate approval ratios against group size.
* **Role-Gated Resolution**: Trip Owners and Planners can formally **Finalize (Approve)** or **Reject** proposals, cementing decisions into the trip itinerary.

### 3. 📅 Interactive Chronological Itinerary
* **Timeline View with Day Scrubber**: Horizontal date-selector bar allowing instant navigation across each day of the journey.
* **Color-Coded Event Taxonomy**: Visual category chips for `Flight`, `Hotel`, `Food`, `Activity`, `Sightseeing`, `Transport`, and `Other`.
* **Timezone-Resilient Scheduling**: Accurate start and end timestamp handling with ISO-8601 formatting.
* **Real-Time Sync**: Planners and Owners can add, edit, or remove itinerary events with real-time multi-device synchronization.

### 4. 💳 Group Ledger & Expense Splitter
* **Transparent Shared Ledger**: Track all group expenditures in one unified financial feed.
* **Animated Odometer Counter**: Dynamic numerical rolling counter displaying the total trip investment in real-time.
* **4-Metric Financial Breakdown**:
  1. 💰 **Total Trip Spend**: Cumulative group cost.
  2. 👥 **User Share Per Person**: Exact individual liability based on active roster count.
  3. 💳 **You Paid**: Total amount fronted by the current user.
  4. ⚖️ **Net Balance**: Live indicator of whether the user is owed money or needs to settle.
* **Multi-Currency Support**: Built-in formatting for `USD ($)`, `EUR (€)`, `GBP (£)`, `INR (₹)`, etc.

### 5. 💬 Realtime Group Chat & Presence
* **Sub-Millisecond WebSocket Sync**: Direct Supabase Realtime channel integration for instantaneous messaging.
* **Ambient UI Design**: Glassmorphic message bubbles layered over an animated ambient background.
* **Sender Profiles & Timestamps**: Profile avatars, sender names, and relative human-readable timestamps.

### 6. 👥 Member Management, RBAC & Deep Linking
* **Granular Role-Based Access Control (RBAC)**: Enforced securely at the database level using Row-Level Security.
  * 👑 **Owner**: Full administrative control.
  * 🛠️ **Planner**: Manage itinerary events, create proposals, and resolve consensus items.
  * 🎒 **Member**: Vote, log expenses, and chat.
* **Click-to-Join Deep Linking**: Instant invitation generation (`atlas://trip/join?token=...`).
* **Native System Sharing**: Dispatch invite links via WhatsApp, Telegram, SMS, or Email.

### 7. 🎨 Design System & Native Performance
* **Adaptive Themes**: Curated Dark Luxury and Clean Light themes.
* **120Hz High-Refresh Rate Optimization**: Ultra-smooth 120Hz ProMotion animations on supported Android hardware.
* **Edge-to-Edge Experience**: Transparent status and system navigation bars.
* **Tactile Haptics & Micro-Animations**: Spring physics, staggered entrances, and contextual haptic feedback.
* **Offline Resilience & Error Shielding**: Real-time network monitor with automatic reconnection and friendly error translations.

---

## 🗺️ Product Roadmap & Future Evolution

Project Atlas follows a structured **3-Phase Evolution Roadmap** transitioning from the current robust collaborative core to an AI-native travel operating ecosystem.

### 📍 Stage 1: Current Beta (`v0.1.0-beta`) — *Completed & Active*
- [x] End-to-end Supabase Auth flow with auto-provisioning database triggers.
- [x] Trips Dashboard, Consensus voting engine, and Interactive day-by-day itinerary.
- [x] Shared expense ledger with dynamic per-person share metrics.
- [x] WebSocket realtime chat with glassmorphic UI.
- [x] Deep link invite generation and token routing.
- [x] 120Hz display optimization, edge-to-edge UI, and Android production audit compliance.

### 📍 Stage 2: Financial Intelligence & Growth (`v1.1` - `v1.3`)
- [ ] **Offline Resilience Engine**: Local SQLite sync allowing travelers to browse itineraries and log expenses without active cellular reception.
- [ ] **OCR Smart Receipt Scanner**: Computer-vision powered receipt capture using edge ML to automatically extract vendor, line items, and totals into the ledger.
- [ ] **Debt Graph Simplification**: Algorithmic peer-to-peer debt minimization to resolve balances with the fewest possible transfers.
- [ ] **Live Currency Conversion**: Automatic real-time foreign exchange rate fetching.
- [ ] **Push Notification Infrastructure**: Firebase Cloud Messaging (FCM) background dispatching.

### 📍 Stage 3: AI-Native Operating System (`v1.5` - `v2.0`)
- [ ] **Autonomous AI Itinerary Architect**: Natural language trip generation synthesizing group preferences, budgets, flight schedules, and weather forecasts.
- [ ] **Collaborative Shared Media Vault**: High-speed photo/video vault with on-device perceptual hashing, automatic blur filtering, duplicate removal, and AI highlight reels.
- [ ] **Realtime Group Radar**: Opt-in live geolocation sharing and dynamic meeting point recommendations.
- [ ] **Direct Booking Integrations**: In-app reservations for airlines, hotels, and activities via global travel API connectors.

---

## 📦 Download & Installation

The application will be distributed as an installable **APK Bundle** via GitHub Releases.

1. Navigate to the **[Releases](https://github.com/vishwarajkhatpe/project-atlas/releases)** tab of this repository.
2. Download the latest `v0.1.0-beta` APK.
3. Install the APK on your Android device to start planning your group trips.

*(Note: Ensure that installation from "Unknown Sources" is temporarily enabled in your Android settings during the install.)*

---

## 👨‍💻 The Developer Journey

**Project Atlas was entirely architected, designed, and engineered by a single developer.** 

From formulating the core product vision, crafting the UI/UX design language, designing the relational database schema, implementing Row-Level Security, to writing thousands of lines of Dart and Flutter code — this project represents a comprehensive solo endeavor to build a production-ready, highly scalable, and beautifully designed mobile platform from scratch.

* **Sole Developer & Architect**: [Vishwaraj Khatpe](https://github.com/vishwarajkhatpe)

### Core Technologies Utilized
* **Frontend**: Flutter 3.x, Dart 3.12+, Riverpod 3.4, GoRouter
* **Backend**: Supabase, PostgreSQL 15, Supabase Auth, WebSockets
* **Design & UX**: Plus Jakarta Sans, Outfit, Lucide Icons, 120Hz optimizations, Glassmorphism

---

<div align="center">

**Built with ❤️ for travelers who want to explore the world together, without the chaos.**

*© 2026 Project Atlas. All rights reserved.*

</div>

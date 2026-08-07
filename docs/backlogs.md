# Project Atlas Backlog & Progress Tracker

This document tracks the implementation progress of Project Atlas, serving as a historical record of what has been built and what is planned for future phases.

## Phase 1: MVP (Minimum Viable Product)
**Status:** In Progress
**Goal:** Prove the "Consensus Before Commitment" concept using a lean Flutter + Supabase stack.

### Implemented
- [x] Define initial Supabase database schema (Users, Trips)
- [x] Initialize Flutter project

### In Progress
- [x] Set up basic routing and state management (Riverpod)

### To Do (MVP Scope)
- [ ] Supabase Authentication (Email/Password)
- [ ] Trip Dashboard (Create/View Trips)
- [ ] Member Invitations
- [ ] Consensus UI (Propose and Vote)
- [ ] Basic Shared Itinerary (Populated by approved proposals)
- [ ] Basic Ledger (Expense tracking)
- [ ] Basic Trip Chat

---

## Phase 2: Future Scope (Deferred Features)
These features were identified in the initial documentation but have been deliberately deferred to post-MVP to minimize complexity and focus on the core value proposition.

- **Advanced Location Services:** Interactive maps, live GPS tracking, Google Maps API integration.
- **AI Itinerary Generation:** LLM-powered trip suggestions.
- **Shared Media Gallery:** High-res photo uploads and intelligent storage lifecycle.
- **OCR Receipt Scanning:** Automatic expense categorization.
- **Parallel Web Client:** React/Next.js frontend.
- **GraphQL API:** Alongside the REST/Realtime backend.
- **Enterprise Infrastructure:** Migration from managed Supabase to self-hosted Kubernetes, microservices, and multi-region Disaster Recovery.

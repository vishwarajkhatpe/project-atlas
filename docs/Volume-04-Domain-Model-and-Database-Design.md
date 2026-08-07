# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# ==============================================================================
#
# PART 01
#
# DOMAIN MODELING PHILOSOPHY
#
# PROJECT ATLAS
#
# Collaborative Travel Operating System
#
# Version 1.0
#
# ==============================================================================

# 1. Purpose

This document establishes the domain modeling philosophy for Project Atlas.

Rather than starting with database tables, APIs, or UI screens, the platform is modeled around real-world business entities and the relationships between them.

Every subsequent document in Volume 04 builds upon the principles defined here.

This document acts as the foundation for:

- Database Design
- API Design
- Knowledge Graph
- AI Context
- Realtime Events
- Analytics
- Authorization
- User Experience

---

# 2. Why Domain-First Design?

Many software projects begin by creating database tables.

Example

users

trips

expenses

photos

messages

Although simple, this approach often leads to:

- Duplicate business logic
- Weak ownership boundaries
- Poor scalability
- Difficult maintenance
- Tight coupling
- Ambiguous responsibilities

Project Atlas instead models the real business.

The database becomes an implementation detail.

---

# 3. Business Domain Philosophy

Project Atlas is composed of independent business domains.

Each domain represents one real-world responsibility.

Examples

Identity

Trip Planning

Budget

Memory

Navigation

Communication

Analytics

Artificial Intelligence

Safety

Notifications

Storage

Each domain owns its own data, logic, events and APIs.

---

# 4. Domain Driven Design

Project Atlas follows Domain Driven Design (DDD).

Core Principles

Business First

Bounded Contexts

Aggregate Roots

Explicit Ownership

Rich Domain Models

Shared Ubiquitous Language

Clear Boundaries

---

# 5. Bounded Contexts

Every business capability exists inside a bounded context.

Identity Context

Trip Context

Planning Context

Budget Context

Consensus Context

Memory Context

Navigation Context

Communication Context

Analytics Context

AI Context

Notification Context

Safety Context

Storage Context

Administration Context

---

Each bounded context owns

Business Rules

Entities

Value Objects

Events

Repositories

Permissions

Validation

Database Schema

APIs

---

# 6. Entity Philosophy

Every entity exists because it represents a meaningful business concept.

Entities are NOT created because data needs somewhere to live.

Example

Expense

Exists because a financial transaction exists.

Photo

Exists because a memory exists.

Proposal

Exists because collaborative decision-making exists.

Trip

Exists because collaboration is centered around travel.

---

# 7. Entity Characteristics

Every entity must have

Business Purpose

Unique Identity

Owner Module

Lifecycle

State Machine

Relationships

Permissions

Events

Validation Rules

Audit Requirements

Retention Policy

---

No anonymous entities are allowed.

---

# 8. Aggregate Roots

An Aggregate Root controls consistency within its boundary.

Primary Aggregate Roots

User

Organization

Trip

Budget

Album

Conversation

Route

Proposal

Notification

Emergency

---

Child entities are modified through their Aggregate Root.

Example

Trip

owns

Activities

Members

Checklist

Templates

Settings

---

# 9. Entity Ownership

Every entity has exactly one owner.

Example

Trip

Owner

Trip Engine

Expense

Owner

Budget Engine

Message

Owner

Communication Engine

Media

Owner

Memory Engine

Route

Owner

Navigation Engine

---

Ownership never changes.

---

# 10. Entity Lifecycle

Every entity progresses through defined lifecycle states.

Example

Trip

Draft

↓

Planning

↓

Voting

↓

Confirmed

↓

Active

↓

Completed

↓

Archived

↓

Deleted

Each entity defines its own lifecycle independently.

---

# 11. State Machines

Every important entity owns a state machine.

Example

Expense

Draft

↓

OCR Processing

↓

Pending Review

↓

Verified

↓

Approved

↓

Settled

↓

Archived

State transitions must be validated.

Illegal transitions are rejected.

---

# 12. Relationships

Relationships describe business meaning.

Examples

Trip

HAS

Members

Member

CREATED

Expense

Expense

ATTACHED_TO

Receipt

Photo

CAPTURED_DURING

Activity

Proposal

APPROVED_BY

Member

---

Relationships exist both in

Relational Database

Knowledge Graph

---

# 13. Value Objects

Not every business concept deserves its own entity.

Value Objects

Money

Address

Coordinates

Date Range

Time Window

Color

Language

Currency

Distance

Temperature

Risk Score

Quality Score

---

Value Objects are immutable.

---

# 14. Business Events

Every significant change produces an immutable event.

Examples

TripCreated

ExpenseAdded

ProposalApproved

PhotoUploaded

JournalGenerated

SOSActivated

RouteChanged

GalleryCleaned

---

Events become

Realtime Updates

Audit Records

Knowledge Graph Updates

Analytics

Notifications

AI Context

---

# 15. Business Rules

Rules belong inside the owning domain.

Example

Budget Rule

Expenses cannot exceed remaining budget unless override is allowed.

Trip Rule

Trips cannot start without required approvals.

Gallery Rule

Original media cannot be modified.

AI Rule

Recommendations cannot modify business data automatically.

---

Rules never belong in the UI.

---

# 16. Invariants

An invariant is always true.

Examples

Every Expense belongs to one Budget.

Every Budget belongs to one Trip.

Every Trip has one Owner.

Every Proposal belongs to one Trip.

Every Media item belongs to one Trip.

Every Message belongs to one Conversation.

---

The platform must enforce invariants.

---

# 17. Domain Events vs System Events

Domain Events

Business Meaning

ExpenseCreated

TripCompleted

ProposalRejected

---

System Events

Infrastructure

BackupCompleted

WorkerStarted

DeploymentFinished

CacheCleared

---

These remain separate.

---

# 18. Entity Versioning

Mutable entities maintain versions.

Examples

Trip

Budget

Proposal

Checklist

Route

Settings

Versioning enables

History

Rollback

Audit

AI Analysis

Conflict Resolution

---

# 19. Soft Delete Strategy

Business entities are rarely deleted immediately.

Lifecycle

Active

↓

Archived

↓

Soft Deleted

↓

Retention Review

↓

Permanent Deletion (if applicable)

---

Critical entities retain audit history.

---

# 20. Entity Card Standard

Every business entity documented later in this volume follows one standard format.

Each Entity Card contains:

- Business Purpose
- Owner Module
- Aggregate Root
- Lifecycle
- State Machine
- Relationships
- Value Objects
- Business Rules
- Validation Rules
- Permissions
- Events
- Knowledge Graph Representation
- AI Context Usage
- Database Schema
- API Contracts
- Search Support
- Realtime Support
- Audit Strategy
- Retention Policy
- Performance Considerations
- Future Evolution

This becomes the canonical specification for every entity in Project Atlas.

---

# 21. AI Integration

Every entity explicitly declares whether it participates in AI workflows.

Possible Uses

Semantic Search

Knowledge Graph

Recommendation Engine

RAG Context

Analytics

Prediction

OCR

Vision

Embeddings

Conversation Memory

---

Example

Expense

AI Enabled

Yes

Reason

Budget Analysis

Forecasting

Receipt OCR

Semantic Search

---

# 22. Knowledge Graph Integration

Each entity specifies

Graph Node

Relationship Types

Embedding

Traversal Rules

Visibility

Graph Ownership

This ensures every domain participates consistently in the Unified Atlas Knowledge Network.

---

# 23. Entity Classification

Entities are categorized by responsibility.

Core Entities

Trip

User

Organization

Operational Entities

Expense

Activity

Route

Media

Collaborative Entities

Proposal

Vote

Message

Task

Intelligence Entities

Embedding

Recommendation

Prompt

Analytics Entities

Report

Metric

Score

Infrastructure Entities

Notification

Audit Event

Feature Flag

---

# 24. Success Criteria

A domain model is considered complete when:

✓ Every business concept has a clearly defined owner.

✓ Every entity has an explicit lifecycle.

✓ Aggregate boundaries are respected.

✓ Business rules are documented.

✓ Relationships are well defined.

✓ Events are identified.

✓ AI participation is documented.

✓ Knowledge Graph participation is defined.

✓ Database implementation becomes straightforward.

---

# 25. Summary

Project Atlas is modeled around business entities rather than database tables.

This approach creates a stable domain model that remains valid regardless of future implementation changes.

Databases, APIs, AI systems, realtime events, and user interfaces all become different representations of the same underlying business model.

The Entity Card introduced in this volume becomes the single source of truth for every persistent object in the platform.

---

# Next Part

Volume 04

Part 02

Identity Domain

Entities Covered

- User
- Identity
- Organization
- Membership
- Role
- Permission
- Session
- Trusted Device
- Invitation
- Profile
- User Preferences

Each entity will include complete Entity Cards, lifecycle diagrams, state machines, relationships, validation rules, database schema, API contracts, events, Knowledge Graph mapping, AI integration, indexes, and implementation guidance.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-001
#
# USER
#
# =============================================================================

# Entity Information

Entity ID

ENT-001

---

Entity Name

User

---

Owner Module

Core Platform

---

Bounded Context

Identity Domain

---

Aggregate Root

Yes

The User entity is the aggregate root for all identity-related operations.

---

# Business Purpose

The User entity represents a person registered on Project Atlas.

A User is the highest-level identity within the platform and serves as the foundation for authentication, authorization, memberships, preferences, achievements, analytics, and collaboration.

Every action inside Project Atlas is ultimately associated with exactly one User.

---

# Responsibilities

The User entity is responsible for:

Identity

Authentication ownership

Platform profile

Account lifecycle

Organization membership

Trip membership

Notification preferences

Privacy preferences

AI personalization

Travel history

Statistics

Achievements

Audit ownership

---

# Does NOT Own

Trips

Expenses

Photos

Messages

Budgets

Routes

Organizations

Notifications

These belong to their respective modules.

---

# Lifecycle

Registered

↓

Email Verification

↓

Active

↓

Suspended

↓

Deactivated

↓

Deleted

---

Allowed Transitions

Registered

↓

Active

Active

↓

Suspended

Suspended

↓

Active

Active

↓

Deactivated

Deactivated

↓

Active

Active

↓

Deleted

---

Deleted users follow retention policy.

---

# State Machine

STATE_REGISTERED

↓

STATE_PENDING_VERIFICATION

↓

STATE_ACTIVE

↓

STATE_SUSPENDED

↓

STATE_DEACTIVATED

↓

STATE_SOFT_DELETED

↓

STATE_PURGED

---

State changes require authorization.

---

# Business Rules

A user must have one verified identity.

A user may belong to multiple organizations.

A user may participate in multiple trips.

A user owns one preference profile.

Deleting a user never removes audit history.

Users cannot permanently delete data owned by organizations without policy approval.

Platform administrators may suspend users.

---

# Relationships

One User

↓

Many Organizations

Many Trips

Many Sessions

Many Devices

Many Notifications

Many Messages

Many Expenses

Many Photos

Many AI Memories

Many Audit Events

---

Relationship Summary

User

1:N

Organization Membership

User

1:N

Trip Membership

User

1:N

Session

User

1:N

Trusted Device

User

1:N

Notification

User

1:N

Message

User

1:N

Expense

User

1:N

Media Upload

---

# Value Objects

Display Name

Avatar URL

Language

Timezone

Country

Travel Preferences

Notification Settings

Privacy Settings

Theme Preference

Accessibility Preferences

---

# Required Fields

User ID

Email

Display Name

Account Status

Created At

Updated At

---

# Optional Fields

Phone

Profile Picture

Bio

Date of Birth (Optional)

Emergency Contact Reference

Social Links

Website

Preferred Language

Preferred Currency

Preferred Distance Unit

Preferred Temperature Unit

---

# Permissions

The User entity controls

Profile Management

Password Management

Privacy Settings

Notification Preferences

Language

Appearance

Session Management

Connected Accounts

Device Management

---

# Authorization Rules

Users may modify their own profile.

Platform admins may suspend accounts.

Organization admins cannot modify platform user identities.

Trip owners cannot modify user accounts.

---

# Events

UserRegistered

UserVerified

UserActivated

UserSuspended

UserReactivated

UserDeactivated

UserDeleted

ProfileUpdated

AvatarChanged

PreferenceUpdated

---

Events are immutable.

---

# Knowledge Graph

Graph Node

Yes

---

Node Type

User

---

Relationships

MEMBER_OF

CREATED

UPLOADED

PARTICIPATED_IN

APPROVED

COMMENTED

VISITED

RELATED_TO

---

Embedding

No

The User itself is not embedded.

Preferences and behavior are analyzed separately.

---

# AI Integration

AI Uses

Personalization

Recommendation

Travel Style

Budget Prediction

Activity Suggestions

Language Preferences

Notification Timing

Conversation Context

---

AI never stores sensitive identity information inside prompts.

---

# Search Support

Supported

Display Name

Username (Future)

Email (Admin Only)

Organizations

Trip Participation

Achievements

---

Search Visibility

Controlled by privacy settings.

---

# Realtime Support

Presence

Online

Offline

Busy

Away

Typing

Generating AI

Emergency

---

Realtime Events

UserOnline

UserOffline

ProfileUpdated

PreferenceUpdated

---

# Audit Strategy

Every important user action is audited.

Examples

Login

Logout

Password Change

Session Revoked

Profile Updated

Privacy Changed

Device Added

Role Granted

---

Audit records are immutable.

---

# Retention Policy

User Account

Soft Deleted

↓

Retention Period

↓

Permanent Purge

---

Audit History

Permanent

---

Trip Contributions

Retained

---

Organization Records

Retained

---

# Security Requirements

Email Verification

Encrypted Password

JWT Authentication

Refresh Token Rotation

Optional MFA

Rate Limiting

Device Tracking

Session Revocation

---

# Validation Rules

Display Name

3–50 Characters

Email

RFC-Compliant

Phone

International Format

Avatar

Image Only

Language

Supported Locale

Timezone

Valid IANA Timezone

---

# Database Ownership

Schema

core

---

Table

users

---

Primary Key

UUID v7

---

Indexes

Email

Status

Created At

Last Login

Country

---

Unique Constraints

Email

---

# Database Columns

user_id

email

email_verified

display_name

avatar_url

phone

status

preferred_language

preferred_currency

timezone

country

privacy_settings

notification_settings

created_at

updated_at

deleted_at

metadata

---

# API Endpoints

GET

/users/me

PATCH

/users/me

GET

/users/{id}

(Admin)

DELETE

/users/me

GET

/users/me/preferences

PATCH

/users/me/preferences

GET

/users/me/sessions

DELETE

/users/me/sessions/{sessionId}

---

# Performance Requirements

Lookup

<20 ms

Profile Update

<150 ms

Preference Update

<100 ms

Session Lookup

<50 ms

---

# Testing Requirements

Unit Tests

Validation

Lifecycle

Permissions

API

Integration

Audit

Security

Performance

---

# Future Evolution

Passkeys

Multiple Profiles

Travel Reputation

Verified Traveler

Community Profile

AI Travel Persona

Cross-Platform Identity

Enterprise Federation

---

# Entity Summary

ENT-001 (User) is the foundational identity entity of Project Atlas.

It represents the human participant behind every trip, collaboration, AI interaction, and business event.

The entity is intentionally lightweight, while operational data is delegated to specialized modules.

This separation keeps the identity model secure, scalable, and maintainable while supporting future expansion into organizations, enterprise collaboration, and federated identity.

---

# Next Entity

ENT-002

Identity

This entity defines authentication providers, login methods, linked accounts, credentials, verification status, and authentication lifecycle independently from the User entity.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-002
#
# IDENTITY
#
# =============================================================================

# Entity Information

Entity ID

ENT-002

---

Entity Name

Identity

---

Owner Module

Core Platform

---

Bounded Context

Identity Domain

---

Aggregate Root

No

Parent Aggregate

User (ENT-001)

---

# Business Purpose

The Identity entity represents a single authentication method associated with a User.

It defines how a user proves ownership of their account.

A single user may own multiple identities simultaneously.

Examples

Email & Password

Google OAuth

Apple Sign-In

GitHub (Future)

Microsoft (Future)

Passkey (Future)

Enterprise SSO (Future)

Phone OTP (Future)

Identity is authentication only.

It does not contain profile information.

---

# Responsibilities

Authentication Provider

Credential Reference

Verification Status

Authentication Metadata

Provider Account ID

Authentication Lifecycle

Security Policies

Last Login

Failed Login Tracking

Provider Tokens (Encrypted)

---

# Does NOT Own

Profile

Preferences

Sessions

Trips

Organizations

Permissions

Messages

Expenses

Photos

Those belong to other entities.

---

# Lifecycle

Created

↓

Pending Verification

↓

Verified

↓

Active

↓

Disabled

↓

Revoked

↓

Deleted

---

# State Machine

STATE_CREATED

↓

STATE_PENDING_VERIFICATION

↓

STATE_VERIFIED

↓

STATE_ACTIVE

↓

STATE_DISABLED

↓

STATE_REVOKED

↓

STATE_PURGED

---

Only verified identities may authenticate.

---

# Business Rules

Every Identity belongs to exactly one User.

A User must always have at least one active Identity.

Multiple identities may point to the same User.

Provider Account IDs must be globally unique.

Disabled identities cannot authenticate.

Revoked identities permanently lose authentication privileges.

Deleting an Identity never deletes the User.

---

# Relationships

Identity

N:1

User

Identity

1:N

Authentication Events

Identity

1:N

Sessions

Identity

1:N

Trusted Devices

Identity

1:N

Audit Records

---

# Value Objects

Provider

Provider User ID

Provider Email

Verification Timestamp

Authentication Method

Risk Level

Credential Metadata

Security Policy

---

# Required Fields

Identity ID

User ID

Provider

Provider Account ID

Status

Created At

Updated At

---

# Optional Fields

Last Login

Last Failed Login

Failure Count

Recovery Email

Phone Number

Passkey Reference

OAuth Metadata

Provider Avatar

Provider Username

---

# Supported Providers

Native Email

Google

Apple

Microsoft

GitHub

Phone OTP

Passkey

Enterprise SSO

Custom Identity Provider

---

# Authentication Types

Password

OAuth

OIDC

SAML

Passkey

OTP

Magic Link (Future)

Certificate (Future)

---

# Security Rules

Passwords are never stored in plain text.

OAuth tokens remain encrypted.

Refresh tokens are encrypted.

Secrets are never logged.

Passkey credentials remain platform-managed.

Authentication attempts are rate limited.

---

# Authentication Workflow

Authentication Request

↓

Provider Validation

↓

Identity Lookup

↓

Verification Check

↓

Risk Evaluation

↓

Session Creation

↓

JWT Issued

↓

Audit Logged

---

# Verification Methods

Email Link

OAuth Verification

SMS OTP

Authenticator App (Future)

Passkey Verification

Enterprise Verification

---

# Events

IdentityCreated

IdentityVerified

IdentityActivated

IdentityDisabled

IdentityRevoked

ProviderLinked

ProviderUnlinked

AuthenticationSucceeded

AuthenticationFailed

PasswordChanged

PasskeyRegistered

---

# Knowledge Graph

Graph Node

No

Identity is infrastructure.

It is intentionally excluded from the business Knowledge Graph.

---

# AI Integration

None

Identity data must never be exposed to AI models.

Authentication metadata is excluded from prompts.

Only high-level user preferences may be consumed by AI through ENT-004.

---

# Search Support

Admin Only

Provider

Email

Provider Account ID

Verification Status

Authentication Status

---

Normal users cannot search identities.

---

# Realtime Support

Identity events broadcast only to the authenticated user's active sessions.

Examples

Password Changed

Identity Revoked

New Login Detected

Passkey Added

---

# Audit Strategy

Every authentication event recorded.

Examples

Login Success

Login Failure

Provider Linked

Provider Removed

Password Reset

Identity Disabled

Verification Completed

---

Audit records immutable.

---

# Retention Policy

Deleted identities remain archived according to security policy.

Authentication history retained.

Audit records permanent.

Provider metadata minimized after deletion.

---

# Validation Rules

Provider

Known Provider Enum

Provider Account ID

Required

Email

RFC-Compliant

Phone

International Format

Password

Platform Policy

Passkey

WebAuthn Compliant

---

# Database Ownership

Schema

core

---

Table

identities

---

Primary Key

UUID v7

---

Indexes

User ID

Provider

Provider Account ID

Status

Verification Status

Last Login

---

Unique Constraints

Provider + Provider Account ID

---

# Database Columns

identity_id

user_id

provider

provider_account_id

provider_email

status

verification_status

credential_reference

provider_metadata

last_login_at

last_failed_login_at

failed_attempt_count

security_flags

created_at

updated_at

deleted_at

metadata

---

# API Endpoints

GET

/users/me/identities

POST

/users/me/identities

DELETE

/users/me/identities/{identityId}

POST

/auth/login

POST

/auth/logout

POST

/auth/refresh

POST

/auth/verify

POST

/auth/link-provider

POST

/auth/unlink-provider

---

# Performance Requirements

Identity Lookup

<20 ms

Authentication

<300 ms

Verification

<500 ms

Provider Linking

<500 ms

---

# Testing Requirements

Authentication

Verification

Provider Linking

Revocation

Security

Performance

Rate Limiting

Failure Recovery

---

# Future Evolution

Passkeys

Enterprise Federation

Cross-Device Authentication

Risk-Based Authentication

Passwordless Login

Biometric Authentication

Decentralized Identity (Future)

Hardware Security Keys

---

# Entity Summary

ENT-002 (Identity) represents authentication, not the person.

By separating authentication from the User entity, Project Atlas gains a flexible identity system capable of supporting multiple authentication providers, enterprise integrations, and future passwordless technologies without modifying the core user model.

Identity remains a secure infrastructure entity, isolated from business data and excluded from AI reasoning.

---

# Next Entity

ENT-003

Profile

The Profile entity stores all user-facing information such as avatar, biography, public details, travel statistics, achievements, and personalization separate from authentication and core identity.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-003
#
# PROFILE
#
# =============================================================================

# Entity Information

Entity ID

ENT-003

---

Entity Name

Profile

---

Owner Module

Core Platform

---

Bounded Context

Identity Domain

---

Aggregate Root

No

Parent Aggregate

User (ENT-001)

---

# Business Purpose

The Profile entity stores all user-facing information that represents a person within Project Atlas.

Unlike the User entity, which defines identity and ownership, the Profile defines presentation.

It contains the information other members may see depending on privacy settings.

The Profile is responsible for personalizing the collaborative experience without exposing authentication or security information.

---

# Responsibilities

Display Information

Avatar

Biography

Travel Statistics

Achievements

Public Preferences

Languages

Profile Visibility

Social Information

Travel Reputation

Community Identity (Future)

---

# Does NOT Own

Authentication

Passwords

Sessions

Organizations

Trips

Expenses

Messages

Permissions

These belong to other entities.

---

# Lifecycle

Created

↓

Visible

↓

Updated

↓

Hidden

↓

Archived

↓

Deleted

---

Profiles are created automatically when a User account is created.

---

# State Machine

STATE_CREATED

↓

STATE_VISIBLE

↓

STATE_PRIVATE

↓

STATE_HIDDEN

↓

STATE_ARCHIVED

↓

STATE_DELETED

---

Visibility changes never affect the User entity.

---

# Business Rules

Every User owns exactly one Profile.

Profiles may be public, friends-only, trip-only, or private.

Deleting a User archives the associated Profile.

Profiles cannot exist without a User.

Authentication information is never stored in Profile.

---

# Relationships

Profile

1:1

User

Profile

1:N

Achievements

Profile

1:N

Travel Badges

Profile

1:N

Public Albums (Future)

Profile

1:N

Community Reviews (Future)

---

# Value Objects

Display Name

Avatar

Cover Image

Bio

Languages

Country

City (Optional)

Travel Style

Favorite Activities

Preferred Transportation

Preferred Accommodation

Public Statistics

---

# Required Fields

Profile ID

User ID

Display Name

Visibility

Created At

Updated At

---

# Optional Fields

Avatar URL

Cover Image

Bio

Website

Instagram (Optional)

LinkedIn (Optional)

GitHub (Optional)

Favorite Destinations

Travel Motto

Interests

Languages

Occupation (Optional)

---

# Visibility Levels

Public

Visible to everyone.

---

Trip Members

Visible only to members of shared trips.

---

Connections (Future)

Visible to approved contacts.

---

Private

Visible only to the owner.

---

# Travel Statistics

Trips Completed

Countries Visited

Cities Visited

Distance Traveled

Photos Uploaded

Expenses Recorded

Average Budget

AI Planning Score

Safety Score

Contribution Score

---

Statistics are calculated by Analytics Engine.

---

# Achievements

Explorer

Budget Master

Road Warrior

Photographer

Planner

Navigator

Early Bird

Adventure Seeker

Safe Traveler

Team Player

---

Achievements remain immutable once earned.

---

# Reputation System (Future)

Contribution Score

Planning Score

Reliability Score

Collaboration Score

Safety Participation

Community Rating

---

No public ranking in Version 1.

---

# Personalization

Travel Style

Adventure

Luxury

Budget

Road Trip

Backpacking

Camping

Business

Family

---

Food Preferences

Cuisine Interests

Dietary Restrictions

Favorite Activities

---

Used by Atlas AI for recommendations.

---

# AI Integration

AI Consumes

Travel Style

Favorite Activities

Preferred Budget

Preferred Pace

Favorite Destinations

Language

Previous Trips

---

AI Never Consumes

Private Notes

Authentication Data

Hidden Fields

---

# Knowledge Graph

Graph Node

Yes

Node Type

Profile

---

Relationships

PREFERS

VISITED

PARTICIPATED_IN

LIKES

CREATED

CONTRIBUTED_TO

---

Embeddings

Generated from non-sensitive profile information only.

---

# Search Support

Searchable Fields

Display Name

Country

Languages

Achievements

Travel Style

Favorite Activities

---

Private profiles excluded from search.

---

# Realtime Support

Realtime Events

ProfileUpdated

AvatarChanged

AchievementUnlocked

VisibilityChanged

TravelStatsUpdated

---

# Audit Strategy

Tracked

Avatar Changes

Bio Updates

Visibility Changes

Achievement Unlocks

Public Preference Changes

---

Audit entries immutable.

---

# Retention Policy

Profiles archived with User.

Achievements retained.

Travel statistics preserved unless account is permanently purged.

---

# Validation Rules

Display Name

3–50 Characters

Bio

Maximum 500 Characters

Avatar

Supported Image Types

Languages

ISO Language Codes

Country

ISO Country Code

Travel Style

Supported Enum

---

# Database Ownership

Schema

core

---

Table

profiles

---

Primary Key

UUID v7

---

Indexes

User ID

Display Name

Visibility

Country

Travel Style

Created At

---

Unique Constraints

User ID

---

# Database Columns

profile_id

user_id

display_name

avatar_url

cover_image_url

bio

visibility

country

city

languages

travel_style

favorite_activities

travel_statistics

achievement_summary

social_links

created_at

updated_at

deleted_at

metadata

---

# API Endpoints

GET

/profiles/{profileId}

GET

/users/me/profile

PATCH

/users/me/profile

POST

/users/me/avatar

DELETE

/users/me/avatar

GET

/profiles/search

---

# Performance Requirements

Profile Lookup

<20 ms

Profile Update

<150 ms

Avatar Update

<2 sec

Search

<100 ms

---

# Testing Requirements

Visibility Rules

Privacy

Validation

Search

Achievements

Travel Statistics

Realtime Updates

API Integration

---

# Future Evolution

Community Profiles

Verified Traveler Badge

Travel Reputation

Public Journals

Shared Albums

Travel Followers

Travel Portfolio

Profile Themes

Custom URLs

---

# Entity Summary

ENT-003 (Profile) represents the public identity of a user within Project Atlas.

It intentionally separates presentation from authentication and core identity, enabling rich personalization, community features, AI recommendations, and travel reputation while maintaining strong security boundaries.

The Profile entity serves as the foundation for future social and community capabilities without increasing the complexity of the User or Identity entities.

---

# Next Entity

ENT-004

Preferences

The Preferences entity stores all configurable user behavior, including notifications, appearance, localization, AI settings, privacy defaults, accessibility options, and application preferences independently from the Profile.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-004
#
# PREFERENCES
#
# =============================================================================

# Entity Information

Entity ID

ENT-004

---

Entity Name

Preferences

---

Owner Module

Core Platform

---

Bounded Context

Identity Domain

---

Aggregate Root

No

Parent Aggregate

User (ENT-001)

---

# Business Purpose

The Preferences entity stores every configurable behavior of Project Atlas that belongs to a user.

Unlike Profile, which defines how a user appears, Preferences define how the platform behaves for that specific user.

Preferences are synchronized across every device connected to the account.

---

# Responsibilities

Application Settings

Notification Settings

Localization

Accessibility

Privacy Defaults

AI Personalization

Travel Defaults

Map Preferences

Dashboard Preferences

Media Preferences

Developer Settings (Future)

---

# Does NOT Own

Authentication

Profile

Trips

Expenses

Messages

Organizations

Permissions

Statistics

Achievements

---

# Lifecycle

Created

↓

Initialized

↓

Customized

↓

Updated

↓

Reset

↓

Archived

---

A Preferences record is automatically created when a User account is created.

---

# Business Rules

Every User owns exactly one Preferences entity.

Preferences synchronize across all authenticated devices.

Resetting preferences never affects business data.

Preference updates are versioned.

Organization policies may override selected preferences.

---

# Relationships

Preferences

1:1

User

Preferences

1:N

Preference History

Preferences

1:N

Device Overrides (Future)

Preferences

1:N

Organization Overrides (Future)

---

# Preference Categories

General

Notifications

Appearance

Localization

Accessibility

Privacy

Artificial Intelligence

Travel

Maps

Gallery

Dashboard

Developer

---

# General Settings

Application Language

Time Zone

Date Format

Time Format

Start Screen

Auto Update

Offline Sync

Analytics Consent

Crash Reporting

---

# Notification Preferences

Trip Updates

Budget Alerts

Proposal Requests

Mentions

Messages

Safety Alerts

Weather Alerts

AI Suggestions

Reminders

Marketing

System Updates

---

Each notification type supports

Push

Email

In-App

Digest

Mute

---

# Appearance

Theme

System

Light

Dark

---

Accent Color

Font Scale

Animation Level

High Contrast

Compact Mode

Large Text

---

# Localization

Language

Currency

Distance Unit

Temperature Unit

Time Format

Week Start Day

Calendar Format

Number Format

---

# Accessibility

Screen Reader Mode

Reduced Motion

Large Controls

High Contrast

Voice Feedback

Caption Preferences

Gesture Assistance

Keyboard Navigation

---

# Privacy Defaults

Profile Visibility

Trip Visibility

Location Sharing

Activity Sharing

Photo Sharing

Analytics Sharing

AI Learning Consent

Search Visibility

---

# Artificial Intelligence

Enable AI Assistant

Personalized Recommendations

Travel DNA Participation

Memory Summaries

Automatic Journals

Receipt OCR

Smart Categorization

Semantic Search

AI Voice (Future)

---

Every AI option requires explicit consent where applicable.

---

# Travel Defaults

Default Budget Currency

Preferred Accommodation

Preferred Transport

Packing Checklist Template

Trip Template

Default Reminder Schedule

Preferred Activity Level

---

# Map Preferences

Default Map Type

Traffic Layer

Terrain Layer

Satellite Layer

Offline Maps

Navigation Voice

Preferred Route Type

Avoid Tolls

Avoid Ferries

Avoid Highways

EV Friendly Routes

---

# Gallery Preferences

Auto Upload

Upload Quality

Wi-Fi Only Upload

Duplicate Detection

Blur Detection

AI Highlight Generation

Retention Reminder

Album Sorting

---

# Dashboard Preferences

Default Dashboard

Favorite Widgets

Chart Preferences

Quick Actions

Pinned Trips

Recent Activity

Travel Readiness Card

Analytics Visibility

---

# Developer Settings (Future)

Debug Logging

Experimental Features

Beta Features

Telemetry

Performance Metrics

Feature Preview

---

# Value Objects

Language

Currency

Units

Theme

Privacy Policy

Accessibility Profile

Notification Policy

Travel Template

---

# AI Integration

AI Reads

Language

Travel Style

Notification Timing

Dashboard Layout

Accessibility

Travel Preferences

Recommendation Consent

---

AI Never Reads

Private disabled settings

Authentication configuration

Hidden developer settings

---

# Knowledge Graph

Graph Node

No

Preferences remain configuration data.

AI consumes selected preference values through controlled interfaces.

---

# Search Support

Not searchable.

Accessible only to the authenticated owner and authorized administrators where necessary.

---

# Realtime Support

Preference updates synchronize to all active devices.

Realtime Events

PreferencesUpdated

ThemeChanged

LanguageChanged

NotificationSettingsChanged

PrivacyChanged

AISettingsChanged

---

# Audit Strategy

Track

Preference Changes

Privacy Changes

AI Consent

Notification Changes

Accessibility Changes

Reset Operations

---

Every update records

Timestamp

Previous Value

New Value

Actor

Device

---

# Retention Policy

Preferences remain until account deletion.

Historical versions retained according to audit policy.

Preference history may be anonymized after account purge.

---

# Validation Rules

Language

Supported Locale

Currency

ISO 4217

Theme

Supported Enum

Distance Unit

Metric / Imperial

Notification Types

Supported Enum

Privacy Levels

Supported Enum

---

# Database Ownership

Schema

core

---

Table

preferences

---

Primary Key

UUID v7

---

Indexes

User ID

Updated At

Preference Version

---

Unique Constraints

User ID

---

# Database Columns

preferences_id

user_id

language

timezone

currency

theme

notification_settings

privacy_settings

ai_settings

travel_settings

map_settings

gallery_settings

dashboard_settings

accessibility_settings

developer_settings

version

created_at

updated_at

deleted_at

metadata

---

# API Endpoints

GET

/users/me/preferences

PATCH

/users/me/preferences

POST

/users/me/preferences/reset

GET

/users/me/preferences/history

---

# Performance Requirements

Preference Lookup

<20 ms

Preference Update

<100 ms

Cross-Device Sync

<500 ms

Theme Change

Immediate

Language Change

<1 sec

---

# Testing Requirements

Validation

Localization

Accessibility

Synchronization

Privacy

AI Consent

Notification Routing

Versioning

---

# Future Evolution

Per-Trip Preferences

Per-Organization Preferences

Context-Aware Preferences

Adaptive UI

AI Preference Suggestions

Cross-Platform Sync

Smart Accessibility Profiles

Preference Import / Export

---

# Entity Summary

ENT-004 (Preferences) defines how Project Atlas behaves for each individual user.

By separating configuration from identity and profile data, the platform gains a flexible, versioned, and extensible preference system that supports personalization, accessibility, localization, AI customization, and future enterprise policy overrides.

Preferences become a reusable configuration layer consumed consistently across every module without increasing the complexity of the core User model.

---

# Next Entity

ENT-005

Session

The Session entity manages authenticated user sessions, active devices, token lifecycles, login history, and security controls across all platforms.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-005
#
# SESSION
#
# =============================================================================

# Entity Information

Entity ID

ENT-005

---

Entity Name

Session

---

Owner Module

Core Platform

---

Bounded Context

Identity Domain

---

Aggregate Root

No

Parent Aggregate

Identity (ENT-002)

---

# Business Purpose

The Session entity represents one authenticated interaction between a user and Project Atlas.

A session begins after successful authentication and ends when it expires, is revoked, or the user logs out.

Sessions are independent of authentication providers and provide a secure foundation for multi-device access, token management, activity tracking, and security auditing.

---

# Responsibilities

Authentication State

Access Token Lifecycle

Refresh Token Lifecycle

Device Association

Session Activity

Security Tracking

Session Revocation

Risk Evaluation

Login History

Realtime Presence

---

# Does NOT Own

User

Profile

Preferences

Permissions

Organizations

Trips

Messages

Expenses

Authentication Credentials

---

# Lifecycle

Created

↓

Authenticated

↓

Active

↓

Idle

↓

Expired

↓

Revoked

↓

Archived

---

Sessions may also terminate due to:

Password Change

Identity Revocation

Security Policy

Administrator Action

Suspicious Activity

---

# State Machine

STATE_CREATED

↓

STATE_AUTHENTICATED

↓

STATE_ACTIVE

↓

STATE_IDLE

↓

STATE_EXPIRED

↓

STATE_REVOKED

↓

STATE_ARCHIVED

---

Illegal transitions are rejected.

Example

Expired → Active

Not Allowed

---

# Business Rules

Every session belongs to exactly one Identity.

Every session belongs to exactly one User.

Multiple active sessions are allowed.

Sessions remain independent.

Revoking one session does not affect others unless explicitly requested.

Refresh tokens rotate after every successful refresh.

---

# Relationships

Session

N:1

Identity

Session

N:1

User

Session

1:1

Trusted Device (Optional)

Session

1:N

Authentication Events

Session

1:N

Audit Records

---

# Value Objects

Session Token

Refresh Token

Device Fingerprint

Platform

Browser

Operating System

IP Metadata

Risk Score

Last Activity

Expiration Policy

---

# Required Fields

Session ID

Identity ID

User ID

Status

Created At

Expires At

---

# Optional Fields

Device Name

Platform

Browser

OS Version

IP Address (Policy Controlled)

Approximate Location

Last Activity

Refresh Count

Risk Flags

---

# Session Types

Mobile

Web

Tablet

Desktop

Admin Console

API (Future)

Service Session (Future)

---

# Authentication Tokens

Access Token

JWT

Short-lived

Stateless

---

Refresh Token

Encrypted

Database-backed

Rotating

Revocable

---

Session Token

Internal Identifier

Never exposed publicly.

---

# Session Activity

Tracked Information

Login Time

Last Activity

Heartbeat

Logout Time

Refresh Events

Device Changes

Security Events

---

# Idle Policy

Example

15 Minutes

↓

Idle

↓

Notification (Optional)

↓

Expiration

Policy configurable.

---

# Security Policies

Maximum Session Lifetime

Configurable

Concurrent Session Limit

Configurable

Force Logout

Supported

Global Logout

Supported

Admin Revocation

Supported

---

# Risk Evaluation

Signals

New Device

Unusual Location

Impossible Travel

Token Reuse

Rapid Failures

Compromised Credential Alert

Device Reputation

---

Risk Levels

Low

Medium

High

Critical

---

# Session Recovery

Reconnect

↓

Refresh Token

↓

New Access Token

↓

Resume Session

---

Expired refresh tokens require re-authentication.

---

# Realtime Integration

Presence State

Online

Offline

Away

Busy

Typing

Generating AI

Emergency

---

Realtime events update session activity.

---

# Events

SessionCreated

SessionAuthenticated

SessionRefreshed

SessionExpired

SessionRevoked

SessionLoggedOut

SessionHeartbeat

RiskDetected

GlobalLogout

---

# Knowledge Graph

Graph Node

No

Session data remains operational infrastructure.

---

# AI Integration

None

AI never receives session identifiers, IP information, refresh tokens, or authentication metadata.

Only anonymized aggregate analytics may be used to improve platform performance.

---

# Search Support

Administrator Only

Session ID

User

Identity

Status

Platform

Device

Risk Level

Last Activity

---

# Audit Strategy

Record

Login

Logout

Refresh

Revocation

Heartbeat

Policy Changes

Risk Events

Token Rotation

---

Immutable audit records.

---

# Retention Policy

Active Sessions

Live

Expired Sessions

Archived

Revoked Sessions

Retained

Audit Records

Permanent

---

# Validation Rules

Expiration Time

Future Timestamp

Refresh Count

Non-negative

Platform

Supported Enum

Browser

Known Browser

Risk Score

Supported Range

---

# Database Ownership

Schema

core

---

Table

sessions

---

Primary Key

UUID v7

---

Indexes

User ID

Identity ID

Status

Expires At

Last Activity

Risk Level

---

Unique Constraints

Refresh Token Identifier

---

# Database Columns

session_id

identity_id

user_id

status

access_token_version

refresh_token_id

device_id

platform

browser

operating_system

device_name

ip_metadata

risk_score

last_activity_at

expires_at

revoked_at

created_at

updated_at

metadata

---

# API Endpoints

GET

/users/me/sessions

DELETE

/users/me/sessions/{sessionId}

DELETE

/users/me/sessions

POST

/auth/logout

POST

/auth/refresh

GET

/users/me/security

---

# Performance Requirements

Session Lookup

<20 ms

Refresh Token

<150 ms

Heartbeat

<50 ms

Session Revocation

<100 ms

Global Logout

<500 ms

---

# Testing Requirements

Token Rotation

Session Expiration

Concurrent Sessions

Revocation

Risk Detection

Heartbeat

Authorization

Security

Performance

---

# Future Evolution

Adaptive Session Lifetime

Passwordless Sessions

Hardware-Bound Sessions

Enterprise Session Policies

Continuous Authentication

Behavioral Authentication

Offline Session Sync

Cross-Platform Handoff

---

# Entity Summary

ENT-005 (Session) represents one authenticated interaction between a user and the Project Atlas platform.

It provides secure lifecycle management for authentication, multi-device access, token rotation, activity tracking, and session revocation while remaining independent from both user identity and business data.

The Session entity serves as the operational foundation for platform security and realtime presence.

---

# Next Entity

ENT-006

Trusted Device

The Trusted Device entity stores information about recognized devices, trust relationships, biometric capabilities, passkey associations, and device-level security policies independently from active sessions.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-006
#
# TRUSTED DEVICE
#
# =============================================================================

# Entity Information

Entity ID

ENT-006

---

Entity Name

Trusted Device

---

Owner Module

Core Platform

---

Bounded Context

Identity Domain

---

Aggregate Root

No

Parent Aggregate

Identity (ENT-002)

---

# Business Purpose

The Trusted Device entity represents a physical device that has been explicitly trusted by a user for authentication and secure access.

Unlike a Session, which is temporary, a Trusted Device persists across multiple sessions and allows the platform to recognize returning devices, apply device-specific security policies, support passwordless authentication, and improve user experience.

A trusted device does not automatically bypass authentication, but it may reduce friction based on configured security policies.

---

# Responsibilities

Device Registration

Trust Management

Device Identification

Security Metadata

Passkey Association

Biometric Capability

Push Notification Registration

Device Revocation

Device Health

Device Analytics

---

# Does NOT Own

User

Identity

Sessions

Authentication Tokens

Permissions

Trips

Messages

Expenses

Notifications

---

# Lifecycle

Registered

↓

Pending Trust

↓

Trusted

↓

Active

↓

Inactive

↓

Revoked

↓

Archived

↓

Deleted

---

# State Machine

STATE_REGISTERED

↓

STATE_PENDING_TRUST

↓

STATE_TRUSTED

↓

STATE_ACTIVE

↓

STATE_INACTIVE

↓

STATE_REVOKED

↓

STATE_ARCHIVED

↓

STATE_PURGED

---

Trust status changes require user confirmation or administrator action.

---

# Business Rules

Every Trusted Device belongs to exactly one Identity.

A device may have multiple Sessions over time.

Trust can be revoked independently of Sessions.

Revoking a device invalidates all active sessions associated with that device.

One physical device cannot simultaneously belong to multiple identities without explicit support (Future shared-device policies).

---

# Relationships

Trusted Device

N:1

Identity

Trusted Device

N:1

User

Trusted Device

1:N

Sessions

Trusted Device

1:N

Authentication Events

Trusted Device

1:N

Push Notification Tokens

---

# Value Objects

Device Name

Platform

Operating System

Device Fingerprint

Hardware Identifier (Policy Dependent)

Passkey Reference

Biometric Capability

Push Token

Security Level

Last Seen

Trust Expiration

---

# Required Fields

Device ID

Identity ID

User ID

Platform

Fingerprint

Trust Status

Created At

Updated At

---

# Optional Fields

Friendly Name

Manufacturer

Model

OS Version

App Version

Last Known IP (Policy Controlled)

Approximate Location

Battery Capability (Future)

Secure Enclave Support

Trusted Network (Future)

---

# Supported Platforms

Android

iOS

Web Browser

Windows

macOS

Linux

Future

Wearables

Vehicle Systems

Smart Glasses

---

# Authentication Features

Password

OAuth

Passkey

Biometric Unlock

Face Recognition

Fingerprint

PIN

Future Hardware Keys

---

# Security Features

Device Fingerprinting

Passkey Binding

Biometric Availability

Secure Storage Validation

Device Integrity Check

Root/Jailbreak Detection (Future)

App Attestation (Future)

---

# Trust Policies

Always Require Password

Remember Device

Require MFA Every 30 Days

Require Biometric Confirmation

Enterprise Policy Override

High-Risk Login Confirmation

---

# Device Activity

Tracked Information

Registration Date

Last Login

Last Seen

Session Count

Trust Changes

Security Events

Push Registration

App Version

---

# Device Health

Indicators

Active

Outdated App

Outdated OS

Passkey Missing

Push Disabled

Security Warning

---

Health Status

Healthy

Warning

Critical

---

# Realtime Integration

Device events synchronize across all active sessions.

Examples

New Device Registered

Device Renamed

Trust Revoked

Passkey Added

Push Token Updated

---

# Events

DeviceRegistered

DeviceTrusted

DeviceRenamed

DeviceRevoked

PasskeyLinked

PasskeyRemoved

BiometricEnabled

BiometricDisabled

DeviceHealthChanged

PushTokenUpdated

---

# Knowledge Graph

Graph Node

No

Trusted Devices remain operational infrastructure and are excluded from the business Knowledge Graph.

---

# AI Integration

None

AI must never receive device fingerprints, passkey references, hardware identifiers, or trust metadata.

Only anonymized device statistics may be used for operational analytics.

---

# Search Support

Administrator Only

Device ID

User

Platform

Model

Trust Status

Health Status

Last Seen

---

End users may view only their own devices.

---

# Audit Strategy

Record

Device Registration

Trust Granted

Trust Revoked

Rename

Passkey Changes

Biometric Changes

Push Token Updates

Security Alerts

---

Audit records immutable.

---

# Retention Policy

Revoked devices retained for security history.

Deleted devices anonymized after retention period.

Audit history permanent.

---

# Validation Rules

Platform

Supported Enum

Fingerprint

Unique Per Identity

Friendly Name

1–100 Characters

OS Version

Supported Format

Trust Status

Supported Enum

---

# Database Ownership

Schema

core

---

Table

trusted_devices

---

Primary Key

UUID v7

---

Indexes

User ID

Identity ID

Fingerprint

Platform

Trust Status

Last Seen

Health Status

---

Unique Constraints

Identity ID + Device Fingerprint

---

# Database Columns

device_id

identity_id

user_id

friendly_name

platform

manufacturer

model

os_version

app_version

device_fingerprint

trust_status

health_status

passkey_reference

biometric_capabilities

push_token

last_seen_at

last_login_at

created_at

updated_at

deleted_at

metadata

---

# API Endpoints

GET

/users/me/devices

GET

/users/me/devices/{deviceId}

PATCH

/users/me/devices/{deviceId}

DELETE

/users/me/devices/{deviceId}

POST

/users/me/devices/{deviceId}/trust

POST

/users/me/devices/{deviceId}/revoke

POST

/users/me/devices/{deviceId}/rename

---

# Performance Requirements

Device Lookup

<20 ms

Trust Update

<100 ms

Passkey Association

<300 ms

Device Revocation

<150 ms

Realtime Sync

<500 ms

---

# Testing Requirements

Registration

Trust Flow

Revocation

Passkey Association

Biometric Support

Validation

Authorization

Performance

---

# Future Evolution

Shared Device Support

Enterprise Device Management

Hardware Security Keys

Device Risk Scoring

Trusted Networks

Offline Device Verification

Cross-Device Session Transfer

Wearable Authentication

---

# Entity Summary

ENT-006 (Trusted Device) represents a long-term trusted relationship between a user's account and a physical device.

It enables secure multi-device authentication, passkeys, biometric capabilities, device management, and advanced security policies while remaining independent from temporary sessions.

By separating Trusted Devices from Sessions, Project Atlas gains a scalable security architecture that supports future passwordless authentication, enterprise device policies, and intelligent risk management.

---

# Next Entity

ENT-007

Organization Membership

This entity defines a user's relationship with an organization, including membership status, organizational roles, permissions, invitation history, and policy inheritance.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-007
#
# ORGANIZATION MEMBERSHIP
#
# =============================================================================

# Entity Information

Entity ID

ENT-007

---

Entity Name

Organization Membership

---

Owner Module

Core Platform

---

Bounded Context

Identity Domain

---

Aggregate Root

No

Parent Aggregate

Organization (ENT-020 Future)

---

# Business Purpose

The Organization Membership entity represents the relationship between a User and an Organization.

It defines how a user participates inside an organization, what responsibilities they have, which policies apply to them, and how long that relationship exists.

Organization Membership is independent from Trip Membership.

A user may belong to multiple organizations simultaneously.

---

# Responsibilities

Organization Association

Role Assignment

Permission Inheritance

Membership Lifecycle

Invitation Tracking

Policy Enforcement

Activity Tracking

Organizational Visibility

Audit Ownership

---

# Does NOT Own

User

Organization

Trips

Expenses

Projects

Messages

Authentication

Sessions

Preferences

---

# Lifecycle

Invited

↓

Pending Acceptance

↓

Accepted

↓

Active

↓

Suspended

↓

Inactive

↓

Removed

↓

Archived

---

# State Machine

STATE_INVITED

↓

STATE_PENDING

↓

STATE_ACTIVE

↓

STATE_SUSPENDED

↓

STATE_INACTIVE

↓

STATE_REMOVED

↓

STATE_ARCHIVED

---

Membership history is preserved after removal.

---

# Business Rules

Every membership belongs to one User.

Every membership belongs to one Organization.

One user may have multiple memberships across organizations.

A user may have only one active membership per organization.

Removing a membership never deletes historical audit records.

Organization policies override selected user preferences while inside organizational workspaces.

---

# Relationships

Membership

N:1

User

Membership

N:1

Organization

Membership

1:N

Role Assignments

Membership

1:N

Permission Grants

Membership

1:N

Audit Events

Membership

1:N

Invitation History

---

# Value Objects

Membership Status

Join Date

Leave Date

Organization Role

Policy Version

Invitation Source

Visibility Level

Department (Future)

Team (Future)

---

# Required Fields

Membership ID

Organization ID

User ID

Role

Status

Joined At

Created At

---

# Optional Fields

Invited By

Accepted At

Removed At

Removal Reason

Notes

Department

Employee ID (Future)

Manager Reference (Future)

---

# Membership Roles

Owner

Administrator

Manager

Planner

Finance Manager

Safety Lead

Member

Guest

Observer

Custom Role (Future)

---

# Permission Model

Permissions are inherited from:

Organization Default Policies

↓

Assigned Roles

↓

Explicit Permission Grants

↓

Temporary Overrides

↓

Runtime Evaluation

---

# Organization Policies

Examples

Require MFA

Restrict AI Features

Restrict Public Sharing

Mandatory Expense Categories

Mandatory Audit

Retention Policies

Approved Storage Regions

Working Hours (Future)

---

Policies are versioned.

---

# Invitation Workflow

Organization Invitation

↓

Email Sent

↓

Viewed

↓

Accepted

↓

Membership Created

↓

Policies Applied

↓

Audit Recorded

---

Expired invitations cannot create memberships.

---

# Membership Activity

Tracked

Login

Organization Access

Trip Creation

Administrative Actions

Permission Changes

Policy Acceptance

Role Changes

---

# Visibility

Membership visibility determines whether other members can discover this user inside the organization.

Levels

Visible

Limited

Private

Administrative Only

---

# Realtime Integration

Realtime Events

MemberJoined

MemberRemoved

RoleChanged

MembershipSuspended

MembershipActivated

PolicyUpdated

InvitationAccepted

---

Organization dashboards update automatically.

---

# Events

MembershipCreated

MembershipAccepted

MembershipActivated

MembershipSuspended

MembershipRemoved

MembershipArchived

RoleAssigned

RoleRevoked

PolicyApplied

PermissionGranted

PermissionRevoked

---

# Knowledge Graph

Graph Node

Yes

Node Type

OrganizationMembership

---

Relationships

MEMBER_OF

REPORTS_TO (Future)

ASSIGNED_ROLE

BELONGS_TO_TEAM (Future)

PARTICIPATES_IN

---

Embeddings

No

Membership remains structural rather than semantic.

---

# AI Integration

AI Uses

Organization Context

Applicable Policies

Allowed Features

Workspace Preferences

Language

Timezone

Compliance Rules

---

AI never bypasses organization restrictions.

---

# Search Support

Organization Administrators

Search By

User

Role

Department

Status

Join Date

Employee ID (Future)

---

# Audit Strategy

Track

Invitation

Acceptance

Role Changes

Policy Changes

Permission Grants

Removal

Suspension

Reactivation

---

Audit history immutable.

---

# Retention Policy

Removed memberships retained.

Historical permissions preserved.

Audit records permanent.

Organization analytics anonymized after retention period if required by policy.

---

# Validation Rules

Role

Supported Enum

Status

Supported Enum

Organization Exists

Required

User Exists

Required

One Active Membership Per Organization

Enforced

---

# Database Ownership

Schema

core

---

Table

organization_memberships

---

Primary Key

UUID v7

---

Indexes

Organization ID

User ID

Role

Status

Joined At

Created At

---

Unique Constraints

Organization ID + User ID

(Only one active membership)

---

# Database Columns

membership_id

organization_id

user_id

role

status

invited_by

joined_at

accepted_at

removed_at

policy_version

visibility

notes

metadata

created_at

updated_at

deleted_at

---

# API Endpoints

GET

/organizations/{organizationId}/members

GET

/organizations/{organizationId}/members/{membershipId}

POST

/organizations/{organizationId}/invite

PATCH

/organizations/{organizationId}/members/{membershipId}

DELETE

/organizations/{organizationId}/members/{membershipId}

POST

/organizations/{organizationId}/members/{membershipId}/suspend

POST

/organizations/{organizationId}/members/{membershipId}/activate

---

# Performance Requirements

Membership Lookup

<20 ms

Role Update

<100 ms

Invitation Acceptance

<300 ms

Policy Resolution

<100 ms

Realtime Update

<500 ms

---

# Testing Requirements

Membership Lifecycle

Invitation Flow

Policy Inheritance

Role Changes

Permission Evaluation

Audit

Realtime

Performance

---

# Future Evolution

Nested Organizations

Departments

Teams

Delegated Administration

Contractors

External Collaborators

Federated Organizations

Organization-to-Organization Collaboration

---

# Entity Summary

ENT-007 (Organization Membership) defines the formal relationship between a User and an Organization.

By treating membership as an independent business entity rather than a simple join table, Project Atlas gains support for enterprise collaboration, policy inheritance, role management, auditing, and future organizational structures without complicating the User or Organization entities.

---

# Next Entity

ENT-008

Trip Membership

The Trip Membership entity defines a user's participation within a specific trip, including trip-specific roles, approval status, voting rights, permissions, responsibilities, and collaborative history.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-008
#
# TRIP MEMBERSHIP
#
# =============================================================================

# Entity Information

Entity ID

ENT-008

---

Entity Name

Trip Membership

---

Owner Module

Trip Engine

---

Bounded Context

Trip Domain

---

Aggregate Root

No

Parent Aggregate

Trip (ENT-100 Future)

---

# Business Purpose

The Trip Membership entity represents the relationship between a User and a specific Trip.

Unlike Organization Membership, Trip Membership models temporary collaboration around a single journey.

It defines participation, responsibilities, permissions, approvals, voting rights, contribution history, and presence throughout the entire lifecycle of the trip.

Every collaborative feature in Project Atlas is built upon this entity.

---

# Responsibilities

Trip Participation

Invitation Lifecycle

Role Assignment

Consensus Participation

Voting Rights

Permission Resolution

Presence Tracking

Contribution Tracking

Activity Participation

Trip History

---

# Does NOT Own

Trip

User

Expenses

Media

Routes

Messages

Budget

Proposals

Tasks

These are owned by their respective modules.

---

# Lifecycle

Invited

↓

Pending Response

↓

Accepted

↓

Planning

↓

Confirmed

↓

Active

↓

Completed

↓

Archived

↓

Removed

---

# State Machine

STATE_INVITED

↓

STATE_PENDING

↓

STATE_ACCEPTED

↓

STATE_PLANNING

↓

STATE_CONFIRMED

↓

STATE_ACTIVE

↓

STATE_COMPLETED

↓

STATE_ARCHIVED

↓

STATE_REMOVED

---

Historical memberships remain preserved after removal.

---

# Business Rules

Every membership belongs to exactly one User.

Every membership belongs to exactly one Trip.

A user may have only one active membership per trip.

Every trip must have at least one Owner.

Removing an Owner requires ownership transfer.

Voting permissions depend on role and membership status.

Archived memberships remain immutable.

---

# Relationships

Trip Membership

N:1

Trip

Trip Membership

N:1

User

Trip Membership

1:N

Votes

Trip Membership

1:N

Expenses Created

Trip Membership

1:N

Media Uploaded

Trip Membership

1:N

Messages

Trip Membership

1:N

Tasks

Trip Membership

1:N

Audit Events

---

# Value Objects

Role

Membership Status

Approval Status

Voting Rights

Presence State

Contribution Score

Joined Date

Departure Date

Emergency Contact Override

Travel Preferences Override

---

# Required Fields

Membership ID

Trip ID

User ID

Role

Status

Joined At

Created At

---

# Optional Fields

Invited By

Accepted At

Removed At

Removal Reason

Nickname

Trip Notes

Custom Permissions

Emergency Contact

Arrival Time

Departure Time

---

# Trip Roles

Owner

Co-Owner

Planner

Treasurer

Navigator

Photographer

Safety Lead

Member

Guest

Observer

---

Multiple roles may be supported in the future.

---

# Permission Model

Permissions are resolved from

Platform Rules

↓

Trip Rules

↓

Role

↓

Explicit Permission Grants

↓

Current Trip State

↓

Runtime Context

---

# Consensus Participation

Every membership specifies

Can Vote

Can Propose

Can Approve

Can Reject

Can Delegate Vote (Future)

Vote Weight (Future)

---

This powers Atlas' unanimous approval workflow.

---

# Approval Status

Pending

Approved

Rejected

Withdrawn

Expired

---

Planning workflows depend on approval state.

---

# Presence

Offline

Online

Viewing Trip

Editing Itinerary

Voting

Uploading Photos

Adding Expenses

Navigating

Emergency

---

Presence is realtime.

---

# Contribution Metrics

Trips Joined

Planning Actions

Votes Cast

Expenses Added

Photos Uploaded

Tasks Completed

Messages Sent

Checklists Completed

Safety Check-ins

---

Used by Analytics Engine.

---

# Invitation Workflow

Trip Invitation

↓

Notification Sent

↓

Viewed

↓

Accepted

↓

Membership Created

↓

Role Assigned

↓

Realtime Broadcast

↓

Dashboard Updated

---

# Realtime Integration

Realtime Events

MemberJoined

MemberLeft

RoleChanged

PresenceChanged

ApprovalChanged

VoteSubmitted

MemberTyping

MemberUploading

---

# Events

TripMembershipCreated

TripInvitationSent

TripInvitationAccepted

TripInvitationDeclined

RoleAssigned

RoleRevoked

ApprovalGranted

ApprovalRevoked

MemberRemoved

PresenceUpdated

---

# Knowledge Graph

Graph Node

Yes

Node Type

TripMembership

---

Relationships

PARTICIPATES_IN

APPROVED

VOTED_FOR

UPLOADED

CREATED

ASSIGNED_ROLE

ATTENDED

---

Embeddings

No

The membership itself is structural.

Behavioral analytics are derived separately.

---

# AI Integration

AI Uses

Role

Participation History

Travel Preferences Override

Contribution Patterns

Planning Activity

Approval History

Availability

Language

---

AI never modifies membership permissions.

---

# Search Support

Trip Administrators

Search By

User

Role

Status

Approval State

Joined Date

Presence

Contribution Score

---

# Audit Strategy

Track

Invitation

Acceptance

Role Changes

Approvals

Permission Changes

Removal

Presence Updates (Aggregated)

Emergency Role Changes

---

Audit history immutable.

---

# Retention Policy

Completed trip memberships retained permanently.

Removed memberships archived.

Contribution history preserved.

Presence history summarized after trip completion.

---

# Validation Rules

One Active Membership Per User Per Trip

Required

Trip Exists

Required

User Exists

Required

Role

Supported Enum

Approval Status

Supported Enum

---

# Database Ownership

Schema

trip

---

Table

trip_memberships

---

Primary Key

UUID v7

---

Indexes

Trip ID

User ID

Role

Status

Approval Status

Presence

Joined At

---

Unique Constraints

Trip ID + User ID

(Only one active membership)

---

# Database Columns

membership_id

trip_id

user_id

role

status

approval_status

presence

joined_at

accepted_at

removed_at

nickname

custom_permissions

travel_preferences_override

contribution_score

metadata

created_at

updated_at

deleted_at

---

# API Endpoints

GET

/trips/{tripId}/members

GET

/trips/{tripId}/members/{membershipId}

POST

/trips/{tripId}/invite

PATCH

/trips/{tripId}/members/{membershipId}

DELETE

/trips/{tripId}/members/{membershipId}

POST

/trips/{tripId}/members/{membershipId}/approve

POST

/trips/{tripId}/members/{membershipId}/reject

POST

/trips/{tripId}/members/{membershipId}/transfer-ownership

---

# Performance Requirements

Membership Lookup

<20 ms

Approval Update

<100 ms

Presence Update

<100 ms

Invitation Acceptance

<300 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Invitation Flow

Approval Workflow

Role Assignment

Permission Resolution

Consensus Rules

Presence

Realtime

Audit

Performance

---

# Future Evolution

Dynamic Role Templates

Delegated Voting

Temporary Permissions

Guest Check-in Links

Family Membership Groups

AI Collaboration Assistant

Shared Device Support

Cross-Trip Reputation

---

# Entity Summary

ENT-008 (Trip Membership) is the foundational collaboration entity of Project Atlas.

It models not only who participates in a trip, but also how they contribute, collaborate, vote, approve, communicate, and interact throughout the trip lifecycle.

By treating Trip Membership as a first-class business entity instead of a simple relationship table, Project Atlas gains a powerful and extensible foundation for collaborative planning, consensus-driven decision making, realtime synchronization, analytics, and AI-assisted travel management.

---

# Next Entity

ENT-009

Role Assignment

This entity manages granular permission assignments, temporary role delegation, custom permissions, scoped access control, and future policy extensions independently of membership entities.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-009
#
# INVITATION
#
# =============================================================================

# Entity Information

Entity ID

ENT-009

---

Entity Name

Invitation

---

Owner Module

Core Platform

---

Bounded Context

Identity Domain

---

Aggregate Root

No

---

# Business Purpose

The Invitation entity represents a request for a user to join a collaborative resource inside Project Atlas.

Rather than having different invitation systems for Trips, Organizations, Teams, Albums, and future modules, Atlas provides one reusable Invitation model.

Every invitation follows the same lifecycle.

Only the target resource changes.

---

# Supported Invitation Targets

Trip

Organization

Shared Album (Future)

Planning Template (Future)

Workspace (Future)

Community (Future)

Event (Future)

---

# Responsibilities

Invitation Delivery

Invitation Acceptance

Invitation Rejection

Expiration

Revocation

Tracking

Audit

Permission Bootstrap

Realtime Notifications

---

# Does NOT Own

User

Trip

Organization

Membership

Roles

Permissions

---

# Lifecycle

Draft

↓

Created

↓

Sent

↓

Viewed

↓

Pending

↓

Accepted

↓

Completed

OR

Rejected

Expired

Revoked

---

# State Machine

STATE_DRAFT

↓

STATE_CREATED

↓

STATE_SENT

↓

STATE_VIEWED

↓

STATE_PENDING

↓

STATE_ACCEPTED

↓

STATE_COMPLETED

↓

STATE_ARCHIVED

---

Alternative

Rejected

Expired

Revoked

---

# Business Rules

Every invitation has exactly one sender.

Every invitation has exactly one target.

A recipient may have multiple invitations.

Only one active invitation per target.

Expired invitations cannot be accepted.

Accepted invitations create memberships.

Rejected invitations remain auditable.

---

# Relationships

Invitation

↓

Sender (User)

Invitation

↓

Recipient

Invitation

↓

Target Resource

Invitation

↓

Membership

Invitation

↓

Audit Events

---

# Invitation Types

Trip

Organization

Admin

Guest

Observer

Temporary

Public Link (Future)

QR Code (Future)

---

# Delivery Methods

Email

Push Notification

In-App Notification

Share Link

QR Code

SMS (Future)

---

# Required Fields

Invitation ID

Sender ID

Recipient ID

Target Type

Target ID

Status

Expiration Time

Created At

---

# Optional Fields

Message

Role

Custom Permissions

Invitation Code

Deep Link

Metadata

---

# Security

Signed Invitation Tokens

One-Time Acceptance

Expiration

Revocation

Rate Limiting

Replay Protection

---

# Events

InvitationCreated

InvitationSent

InvitationViewed

InvitationAccepted

InvitationRejected

InvitationExpired

InvitationRevoked

MembershipCreated

---

# Realtime

Invitation Received

Invitation Viewed

Invitation Accepted

Invitation Revoked

Invitation Expired

---

# Knowledge Graph

Graph Node

Yes

Relationships

INVITED

JOINED

DECLINED

REFERRED_BY

---

Embeddings

No

---

# AI Integration

AI Uses

Pending invitations

Trip planning status

Incomplete memberships

Recommendation timing

---

AI cannot automatically accept invitations.

---

# Database Ownership

Schema

core

---

Table

invitations

---

Indexes

Recipient ID

Sender ID

Target Type

Target ID

Status

Expiration

---

# API Endpoints

POST

/invitations

GET

/invitations

POST

/invitations/{id}/accept

POST

/invitations/{id}/reject

POST

/invitations/{id}/revoke

---

# Summary

The Invitation entity provides a reusable invitation system for every collaborative feature in Project Atlas.

Instead of building invitation logic repeatedly across multiple modules, the platform centralizes invitations into a single audited, secure, extensible business entity.

---

# Next Entity

ENT-010

Permission Override

Defines temporary or exceptional permissions granted beyond role-based policies.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 02
#
# IDENTITY DOMAIN
#
# ENTITY CARD
#
# ENT-010
#
# EMERGENCY CONTACT
#
# =============================================================================

# Entity Information

Entity ID

ENT-010

---

Entity Name

Emergency Contact

---

Owner Module

Safety Platform

---

Bounded Context

Identity Domain

---

Aggregate Root

No

Parent Aggregate

User (ENT-001)

---

# Business Purpose

The Emergency Contact entity stores trusted individuals who may be contacted in emergency situations during trips.

These contacts are reusable across all trips and may be selectively enabled or disabled for individual trips.

Emergency Contacts support Atlas' safety features including SOS alerts, emergency notifications, live location sharing, medical incidents, and missed check-ins.

---

# Responsibilities

Emergency Contact Information

Relationship Definition

Priority Order

Verification Status

Notification Preferences

Trip Availability

Medical Notification Permissions

SOS Routing

Safety Integration

---

# Does NOT Own

User

Trips

Medical Profile

Location History

Messages

Sessions

Permissions

---

# Lifecycle

Created

↓

Verified

↓

Active

↓

Inactive

↓

Archived

↓

Deleted

---

Verification is optional in Version 1.

---

# Business Rules

Every contact belongs to exactly one User.

A User may have multiple emergency contacts.

Priority values must be unique per user.

At least one emergency contact is recommended before starting a trip.

Contacts may be enabled or disabled for individual trips.

Deleting a contact never removes historical emergency records.

---

# Relationships

Emergency Contact

N:1

User

Emergency Contact

1:N

Emergency Incidents

Emergency Contact

1:N

Trip Overrides

Emergency Contact

1:N

Notification History

---

# Contact Information

Full Name

Relationship

Phone Number

Email (Optional)

Country

Preferred Language

Time Zone

Priority

Verification Status

---

# Relationship Types

Parent

Sibling

Partner

Friend

Relative

Guardian

Doctor

Employer

Other

---

# Required Fields

Contact ID

User ID

Full Name

Primary Phone

Relationship

Priority

Created At

---

# Optional Fields

Email

Secondary Phone

Address

Preferred Language

Notes

Medical Awareness

Photo

---

# Notification Permissions

SOS

Medical Emergency

Location Sharing

Trip Delay

Missed Check-in

Manual Contact

Trip Completion

---

Each notification type can be enabled or disabled independently.

---

# Trip Overrides

A user may override

Enabled

Priority

Notification Types

Contact Visibility

for a specific trip.

---

# Security

Emergency contacts are private.

Only the owner and authorized safety workflows may access them.

Trip members cannot view emergency contacts unless explicitly shared.

---

# Events

EmergencyContactCreated

EmergencyContactUpdated

EmergencyContactVerified

EmergencyContactRemoved

EmergencyNotificationSent

EmergencyNotificationAcknowledged

---

# Realtime

SOS Triggered

Emergency Contact Notified

Acknowledgement Received

Safety Status Updated

---

# Knowledge Graph

Graph Node

Yes

Node Type

EmergencyContact

Relationships

CONTACT_FOR

NOTIFIED_IN

RELATED_TO

---

Embeddings

No

---

# AI Integration

AI Uses

Preferred Contact Order

Language

Time Zone

Notification Timing

---

AI Never Accesses

Phone Numbers

Email Addresses

Addresses

Private Notes

---

# Database Ownership

Schema

safety

---

Table

emergency_contacts

---

Indexes

User ID

Priority

Relationship

Verification Status

Created At

---

# API Endpoints

GET

/users/me/emergency-contacts

POST

/users/me/emergency-contacts

PATCH

/users/me/emergency-contacts/{id}

DELETE

/users/me/emergency-contacts/{id}

---

# Performance Requirements

Lookup

<20 ms

Create

<100 ms

SOS Notification Initiation

<500 ms

---

# Testing Requirements

Validation

Notification Routing

Priority Ordering

Trip Overrides

Privacy

Audit

Realtime

---

# Future Evolution

Verified Contacts

Shared Family Groups

Emergency Contact Portal

Medical Responders

Satellite SOS

International Emergency Routing

Wearable Integration

Vehicle Crash Detection

---

# Entity Summary

ENT-010 (Emergency Contact) provides a reusable safety profile for each user.

Rather than being tied to a single trip, emergency contacts become part of the user's long-term safety identity, enabling rapid emergency response, reusable safety workflows, and future advanced traveler protection capabilities.

---

# End of Identity Domain

Identity Domain Entities

✓ ENT-001 User

✓ ENT-002 Identity

✓ ENT-003 Profile

✓ ENT-004 Preferences

✓ ENT-005 Session

✓ ENT-006 Trusted Device

✓ ENT-007 Organization Membership

✓ ENT-008 Trip Membership

✓ ENT-009 Invitation

✓ ENT-010 Emergency Contact

---

# Next Volume 04 Part

Part 03

Trip Domain

Entities

ENT-100 Trip

ENT-101 Trip Settings

ENT-102 Trip Template

ENT-103 Destination

ENT-104 Activity

ENT-105 Day Plan

ENT-106 Itinerary

ENT-107 Checklist

ENT-108 Packing List

ENT-109 Travel Companion

ENT-110 Trip Timeline

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-100
#
# TRIP
#
# =============================================================================

# Entity Information

Entity ID

ENT-100

---

Entity Name

Trip

---

Owner Module

Trip Engine

---

Bounded Context

Trip Domain

---

Aggregate Root

Yes

The Trip is the Aggregate Root for every collaborative travel workspace.

---

# Business Purpose

The Trip entity represents a complete collaborative travel workspace.

Unlike traditional travel applications that treat a trip as a simple itinerary, Project Atlas models every trip as an intelligent collaboration environment.

A Trip owns planning, budgeting, approvals, communication, navigation, memories, AI context, analytics, safety, and every other feature related to a journey.

Every collaborative activity inside Atlas ultimately belongs to exactly one Trip.

---

# Responsibilities

Trip Lifecycle

Workspace Ownership

Member Coordination

Planning State

Collaboration Context

Module Integration

AI Context Root

Knowledge Graph Root

Timeline Root

Analytics Root

Retention Ownership

---

# Does NOT Own

Users

Organizations

Sessions

Identities

System Settings

Platform Notifications

Global Analytics

---

# Aggregate Children

Trip Memberships

Trip Settings

Activities

Day Plans

Itinerary

Budget

Proposals

Routes

Albums

Messages

Timeline

Tasks

Packing Lists

Checklists

Reports

Safety Incidents

AI Context

---

Every child entity is modified through the Trip Aggregate.

---

# Lifecycle

Draft

↓

Planning

↓

Voting

↓

Confirmed

↓

Ready

↓

Active

↓

Completed

↓

Archived

↓

Deleted

---

# State Machine

STATE_DRAFT

↓

STATE_PLANNING

↓

STATE_VOTING

↓

STATE_CONFIRMED

↓

STATE_READY

↓

STATE_ACTIVE

↓

STATE_COMPLETED

↓

STATE_ARCHIVED

↓

STATE_SOFT_DELETED

↓

STATE_PURGED

---

State transitions require validation.

Example

Completed

↓

Planning

Not Allowed

---

# Business Rules

Every Trip has exactly one Owner.

Every Trip has at least one Member.

Every Trip has one Dashboard.

Every Trip owns one Timeline.

Every Trip owns one AI Context.

A Trip cannot become Active until required approvals are complete.

Archived Trips become read-only.

Deleted Trips follow retention policy.

---

# Relationships

Trip

1:N

Trip Memberships

Trip

1:1

Trip Settings

Trip

1:N

Activities

Trip

1:N

Expenses

Trip

1:N

Albums

Trip

1:N

Routes

Trip

1:N

Messages

Trip

1:N

Proposals

Trip

1:N

Timeline Events

Trip

1:N

Safety Incidents

Trip

1:N

Notifications

Trip

1:N

Analytics Reports

Trip

1:1

AI Context

---

# Value Objects

Trip Name

Description

Destination Summary

Trip Dates

Trip Visibility

Trip Theme

Trip Status

Trip Category

Trip Currency

Timezone

Default Language

---

# Required Fields

Trip ID

Owner ID

Title

Status

Start Date

End Date

Created At

---

# Optional Fields

Description

Cover Image

Banner

Theme Color

Default Currency

Primary Destination

Trip Icon

Notes

Tags

Estimated Budget

Maximum Members

---

# Trip Types

Road Trip

Backpacking

Family

Business

Adventure

Weekend

Camping

Motorcycle

Cycling

Cruise

International

Custom

---

# Visibility

Private

Invite Only

Organization

Public (Future)

Community (Future)

---

# Planning Status

Draft

Planning

Awaiting Approval

Ready

Locked

Completed

---

Planning status is independent from trip lifecycle.

---

# Workspace Modules

Trip

↓

Planning

↓

Consensus

↓

Budget

↓

Gallery

↓

Navigation

↓

Chat

↓

Dashboard

↓

AI

↓

Safety

↓

Analytics

↓

Documents (Future)

---

Modules can be enabled or disabled depending on trip configuration.

---

# AI Integration

AI Uses

Entire Trip Context

Timeline

Members

Budget

Routes

Gallery

Chat

Weather

Preferences

Knowledge Graph

Analytics

---

The Trip is the root context supplied to Atlas AI.

---

# Knowledge Graph

Graph Node

Yes

Node Type

Trip

---

Relationships

HAS_MEMBER

HAS_ACTIVITY

HAS_EXPENSE

HAS_MEDIA

HAS_ROUTE

HAS_TIMELINE

HAS_CHAT

GENERATED_JOURNAL

USES_AI

---

Trip is the root node of every trip graph.

---

# Search Support

Search By

Title

Destination

Tags

Owner

Status

Dates

Members

Trip Type

---

Semantic Search

Supported

---

# Realtime Support

Realtime Events

TripUpdated

TripStatusChanged

MemberJoined

PlanningStarted

ApprovalCompleted

TripActivated

TripCompleted

TripArchived

---

# Timeline

Every significant event automatically contributes to the Universal Timeline Engine.

Examples

Trip Created

Member Joined

Expense Added

Proposal Approved

Photo Uploaded

Location Checked-In

AI Journal Generated

---

# Audit Strategy

Track

Creation

Updates

Ownership Transfer

Status Changes

Visibility Changes

Deletion

Archival

---

Audit immutable.

---

# Retention Policy

Completed Trips

Retained

Archived Trips

Read-only

Deleted Trips

Retention Window

↓

Permanent Purge

Audit retained permanently.

---

# Validation Rules

Trip Name

3–150 Characters

Start Date

Before End Date

Owner Exists

Required

Maximum Members

Positive Integer

Currency

ISO 4217

Timezone

IANA Timezone

---

# Database Ownership

Schema

trip

---

Table

trips

---

Primary Key

UUID v7

---

Indexes

Owner ID

Status

Start Date

End Date

Trip Type

Visibility

Created At

---

# Database Columns

trip_id

owner_id

title

description

status

planning_status

trip_type

visibility

cover_image_url

banner_image_url

default_currency

timezone

start_date

end_date

estimated_budget

maximum_members

metadata

created_at

updated_at

deleted_at

---

# API Endpoints

GET

/trips

POST

/trips

GET

/trips/{tripId}

PATCH

/trips/{tripId}

DELETE

/trips/{tripId}

POST

/trips/{tripId}/archive

POST

/trips/{tripId}/restore

GET

/trips/{tripId}/workspace

---

# Performance Requirements

Trip Lookup

<20 ms

Workspace Load

<500 ms

Trip Update

<150 ms

Trip Search

<300 ms

Semantic Search

<400 ms

---

# Testing Requirements

Lifecycle

Workspace Creation

Permissions

Ownership Transfer

Validation

Realtime

Knowledge Graph

AI Context

Performance

---

# Future Evolution

Recurring Trips

Trip Templates

Cross-Trip Linking

Multi-Destination Expeditions

Organization-Owned Trips

Offline Workspaces

Trip Cloning

Marketplace Templates

Trip Versioning

---

# Entity Summary

ENT-100 (Trip) is the foundational aggregate root of Project Atlas.

It is not merely a travel plan—it is an intelligent collaborative workspace that coordinates every planning, budgeting, communication, navigation, AI, safety, and memory capability within the platform.

By modeling the Trip as the central workspace rather than a simple itinerary, Project Atlas gains a scalable architecture capable of supporting both current and future collaboration features without fundamentally changing the domain model.

---

# Next Entity

ENT-101

Trip Settings

This entity defines configurable behavior for a specific trip, including enabled modules, consensus rules, privacy, AI settings, media retention, notification policies, budget defaults, navigation preferences, and workspace customization.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-101
#
# TRIP SETTINGS
#
# =============================================================================

# Entity Information

Entity ID

ENT-101

---

Entity Name

Trip Settings

---

Owner Module

Trip Engine

---

Bounded Context

Trip Domain

---

Aggregate Root

No

Parent Aggregate

Trip (ENT-100)

---

# Business Purpose

The Trip Settings entity defines the operational behavior of a Trip Workspace.

Rather than storing miscellaneous configuration values, Trip Settings controls how every enabled module behaves throughout the lifecycle of the trip.

It acts as the runtime configuration source for the workspace.

---

# Responsibilities

Workspace Configuration

Module Enablement

Planning Rules

Consensus Rules

Budget Configuration

Media Policies

Notification Rules

Navigation Preferences

AI Configuration

Privacy Rules

Retention Policies

Workspace Branding

---

# Does NOT Own

Trip

Members

Budget

Photos

Messages

Routes

Expenses

Activities

Timeline

Analytics

---

# Lifecycle

Created

↓

Initialized

↓

Configured

↓

Updated

↓

Locked

↓

Archived

---

Settings are automatically created when a Trip is created.

---

# Business Rules

Every Trip owns exactly one Trip Settings entity.

Only authorized members may modify settings.

Some settings become locked after the trip enters the Active state.

Organization-owned trips may inherit organization policies.

Workspace settings override platform defaults but do not override mandatory organization policies.

---

# Relationships

Trip Settings

1:1

Trip

Trip Settings

1:N

Workspace Capabilities

Trip Settings

1:N

Configuration History

Trip Settings

1:N

Audit Events

---

# Configuration Categories

General

Workspace Capabilities

Consensus

Budget

Navigation

Gallery

Notifications

Privacy

Artificial Intelligence

Safety

Analytics

Retention

Developer (Future)

---

# General Configuration

Trip Name Format

Workspace Theme

Primary Language

Currency

Timezone

Maximum Members

Default Permissions

---

# Workspace Capabilities

Enabled Modules

Planning

Budget

Gallery

Navigation

Consensus

Chat

AI Assistant

Dashboard

Safety

Analytics

Documents (Future)

Marketplace (Future)

---

Disabled modules are hidden from both UI and API.

---

# Consensus Configuration

Require Unanimous Approval

Minimum Approval Percentage

Voting Deadline

Anonymous Voting

Proposal Editing

Vote Changes Allowed

Automatic Approval Timeout

---

# Budget Configuration

Default Currency

Expense Approval Required

Receipt Required

Split Method

Settlement Method

Budget Alerts

Daily Budget Limit

---

# Navigation Configuration

Preferred Route Type

Avoid Highways

Avoid Tolls

Avoid Ferries

Offline Maps

Live Location

GPS Sharing

Meeting Point Rules

---

# Gallery Configuration

Photo Upload Enabled

Video Upload Enabled

Auto Compression

Duplicate Detection

Blur Detection

AI Highlights

Retention Window

Download Policy

Album Visibility

---

# Notification Configuration

Trip Updates

Budget Alerts

Proposal Requests

Mentions

Messages

Safety Alerts

Weather Alerts

Daily Digest

Push

Email

In-App

---

# Privacy Configuration

Trip Visibility

Member Visibility

Live Location

Photo Sharing

Activity Visibility

Analytics Sharing

AI Data Usage

Search Visibility

---

# Artificial Intelligence

Enable AI

AI Planner

AI Budget Assistant

AI Journal

Memory Engine

Smart Recommendations

Semantic Search

OCR

Vision Processing

Travel DNA Integration

---

Each AI capability may be enabled independently.

---

# Safety Configuration

Emergency Contacts Required

Mandatory Check-ins

SOS Enabled

Medical Profiles

Live Tracking

Risk Alerts

Weather Alerts

Emergency Broadcast

---

# Analytics Configuration

Trip Metrics

Contribution Scores

Budget Reports

Timeline Analysis

Travel Statistics

Planning Insights

AI Analytics

Export Support

---

# Retention Policies

Photos

Originals

Highlights

Messages

Timeline

Receipts

Analytics

AI Memories

Audit History

---

Retention policies are configurable within platform limits.

---

# Value Objects

Theme

Currency

Language

Capabilities

Policy Version

Retention Policy

Privacy Level

Notification Profile

---

# AI Integration

AI Reads

Workspace Capabilities

Consensus Rules

Budget Policies

Travel Preferences

Privacy Rules

Retention Rules

Notification Timing

---

AI cannot modify settings without explicit user approval.

---

# Knowledge Graph

Graph Node

Yes

Node Type

TripSettings

---

Relationships

CONFIGURES

ENABLES

DISABLES

REQUIRES

---

Embeddings

No

Configuration remains structural.

---

# Search Support

Not publicly searchable.

Accessible only to authorized trip members.

---

# Realtime Support

Configuration updates broadcast to all active trip members.

Realtime Events

SettingsUpdated

CapabilityEnabled

CapabilityDisabled

PolicyChanged

ThemeChanged

RetentionChanged

---

# Audit Strategy

Track

Configuration Changes

Capability Changes

Policy Changes

AI Changes

Privacy Changes

Retention Updates

Role-Based Modifications

---

Every change records

Previous Value

New Value

Actor

Timestamp

Reason (Optional)

---

# Retention Policy

Configuration history retained permanently.

Previous versions remain available for audit and rollback.

---

# Validation Rules

Currency

ISO 4217

Timezone

IANA

Language

Supported Locale

Capabilities

Known Module Enum

Approval Percentage

0–100

Retention

Within Platform Limits

---

# Database Ownership

Schema

trip

---

Table

trip_settings

---

Primary Key

UUID v7

---

Indexes

Trip ID

Updated At

Policy Version

---

Unique Constraints

Trip ID

---

# Database Columns

settings_id

trip_id

workspace_capabilities

general_settings

consensus_settings

budget_settings

navigation_settings

gallery_settings

notification_settings

privacy_settings

ai_settings

safety_settings

analytics_settings

retention_settings

version

created_at

updated_at

metadata

---

# API Endpoints

GET

/trips/{tripId}/settings

PATCH

/trips/{tripId}/settings

GET

/trips/{tripId}/capabilities

PATCH

/trips/{tripId}/capabilities

GET

/trips/{tripId}/settings/history

POST

/trips/{tripId}/settings/restore

---

# Performance Requirements

Settings Lookup

<20 ms

Capability Check

<10 ms

Settings Update

<150 ms

Realtime Broadcast

<250 ms

Workspace Initialization

<300 ms

---

# Testing Requirements

Validation

Policy Resolution

Capability Enablement

Realtime Synchronization

Permission Enforcement

Rollback

Audit

Performance

---

# Future Evolution

Custom Workspace Modules

Marketplace Extensions

Enterprise Policy Packs

Template-Based Configuration

Dynamic Capabilities

Per-Day Settings

Context-Aware Policies

AI Configuration Profiles

---

# Entity Summary

ENT-101 (Trip Settings) defines how a Trip Workspace operates.

Rather than being a simple settings table, it acts as the central configuration engine consumed by every module, ensuring consistent behavior, policy enforcement, feature enablement, and workspace customization throughout the lifecycle of a trip.

---

# Next Entity

ENT-102

Trip Template

A reusable blueprint containing predefined settings, itineraries, checklists, budgets, packing lists, and workspace configurations that can be used to create new trips quickly and consistently.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-102
#
# TRIP TEMPLATE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-102

---

Entity Name

Trip Template

---

Owner Module

Trip Engine

---

Bounded Context

Trip Domain

---

Aggregate Root

No

Parent Aggregate

Trip (ENT-100)

---

# Business Purpose

A Trip Template is a reusable blueprint that defines how a new Trip Workspace should be created.

Unlike traditional templates that simply copy data, Atlas Templates define the complete structure, behavior, configuration, and initial state of a workspace.

Templates dramatically reduce planning time while ensuring consistency across similar trips.

---

# Responsibilities

Workspace Blueprint

Module Configuration

Activity Templates

Budget Templates

Checklist Templates

Packing Templates

Safety Configuration

AI Configuration

Timeline Generation

Dashboard Layout

Notification Rules

Travel Defaults

---

# Does NOT Own

Trips

Members

Expenses

Media

Messages

Routes

Organizations

Users

---

# Lifecycle

Draft

↓

Under Review

↓

Published

↓

Deprecated

↓

Archived

↓

Deleted

---

Published templates remain immutable.

New changes create a new template version.

---

# Business Rules

Every template has one owner.

Templates may be Public or Private.

Templates are versioned.

Templates never modify existing trips.

Creating a trip from a template generates new entities.

Templates are immutable after publication.

---

# Relationships

Trip Template

↓

Activities

Trip Template

↓

Packing Lists

Trip Template

↓

Budget Categories

Trip Template

↓

Trip Settings

Trip Template

↓

Dashboard Layout

Trip Template

↓

Routes (Optional)

Trip Template

↓

Checklists

Trip Template

↓

Safety Rules

Trip Template

↓

AI Configuration

---

# Template Categories

Road Trip

Weekend

International

Backpacking

Business

Camping

Motorcycle

Family

Luxury

Adventure

Festival

Pilgrimage

Educational

Custom

---

# Template Scope

Private

Organization

Marketplace

Public

Official Atlas

---

# Included Components

Workspace Settings

Trip Theme

Budget Categories

Packing Lists

Activities

Timeline Milestones

Dashboard Widgets

Notification Rules

AI Suggestions

Safety Rules

Documents

Gallery Settings

Navigation Defaults

Consensus Rules

---

# Generated Assets

When a template creates a trip

↓

Trip

↓

Trip Settings

↓

Checklist

↓

Packing List

↓

Activities

↓

Timeline

↓

Budget

↓

Dashboard

↓

AI Context

↓

Notifications

---

Every generated entity receives new IDs.

Nothing is shared with the template.

---

# AI Integration

Templates may include

Planning Prompts

Budget Recommendations

Packing Suggestions

Destination Tips

Travel Warnings

Risk Profiles

Emergency Suggestions

Journal Prompts

Photo Challenges

Trip Goals

---

AI prompts are version controlled.

---

# Template Variables

Templates support placeholders.

Examples

Trip Name

Destination

Dates

Member Count

Currency

Transportation

Accommodation

Weather

Budget

Travel Style

---

Variables are resolved during workspace creation.

---

# Workspace Initialization

User

↓

Select Template

↓

Provide Variables

↓

Validation

↓

Generate Workspace

↓

Initialize Modules

↓

Create Dashboard

↓

Generate AI Context

↓

Ready

---

# Knowledge Graph

Graph Node

Yes

Node Type

TripTemplate

---

Relationships

GENERATES

BASED_ON

RECOMMENDS

ENABLES

CONFIGURES

---

Embeddings

Yes

Used for semantic template discovery.

---

# Search Support

Search By

Category

Destination

Travel Style

Duration

Budget

Activities

Popularity

Organization

Semantic Search

---

# Realtime Support

Template updates notify subscribers.

Marketplace templates support update notifications.

---

# Events

TemplateCreated

TemplatePublished

TemplateDeprecated

TemplateArchived

TripGenerated

TemplateDownloaded

TemplateShared

TemplateForked

---

# Audit Strategy

Track

Creation

Publication

Version Changes

Downloads

Usage

Sharing

Deprecation

Deletion

---

# Retention Policy

Published templates retained permanently.

Deprecated templates remain available for historical trips.

Archived templates remain searchable by administrators.

---

# Validation Rules

Name

3–150 Characters

Category

Supported Enum

Version

Semantic Versioning

Variables

Unique Names

Configuration

Valid JSON Schema

---

# Database Ownership

Schema

trip

---

Table

trip_templates

---

Primary Key

UUID v7

---

Indexes

Category

Owner

Visibility

Published

Version

Popularity

Created At

---

# Database Columns

template_id

owner_id

name

description

category

visibility

version

workspace_blueprint

activity_templates

budget_templates

packing_templates

dashboard_template

ai_configuration

variables

usage_count

rating

created_at

updated_at

metadata

---

# API Endpoints

GET

/templates

GET

/templates/{templateId}

POST

/templates

PATCH

/templates/{templateId}

POST

/templates/{templateId}/publish

POST

/templates/{templateId}/generate-trip

POST

/templates/{templateId}/fork

---

# Performance Requirements

Template Search

<200 ms

Trip Generation

<2 sec

Workspace Initialization

<5 sec

Semantic Search

<400 ms

---

# Testing Requirements

Blueprint Validation

Variable Resolution

Workspace Generation

Versioning

Permission Enforcement

AI Configuration

Performance

---

# Future Evolution

Marketplace Templates

Community Templates

Paid Templates

AI-Generated Templates

Organization Libraries

Template Collections

Regional Templates

Collaborative Templates

---

# Entity Summary

ENT-102 (Trip Template) is an executable blueprint for creating complete Trip Workspaces.

Rather than storing reusable data alone, it defines the initial structure, behavior, configuration, and intelligence of a trip, enabling rapid creation of rich collaborative workspaces while maintaining consistency and flexibility.

---

# Next Entity

ENT-103

Destination

Represents a geographic location, stop, attraction, city, region, or point of interest that forms part of a Trip Workspace. Destinations provide geographic context for planning, navigation, budgeting, scheduling, weather, memories, and AI recommendations.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-103
#
# DESTINATION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-103

---

Entity Name

Destination

---

Owner Module

Trip Engine

---

Bounded Context

Trip Domain

---

Aggregate Root

No

Parent Aggregate

Trip (ENT-100)

---

# Business Purpose

A Destination represents a major geographical area that forms part of a Trip.

Destinations divide a journey into meaningful travel regions.

Examples include:

Cities

States

Countries

National Parks

Mountain Regions

Islands

Tourism Regions

Every destination acts as a container for multiple Locations.

---

# Responsibilities

Travel Geography

Destination Planning

Regional Analytics

Regional Budgeting

Weather Context

Timeline Organization

Navigation Context

Gallery Organization

AI Context

Travel Statistics

---

# Does NOT Own

Trip

Locations

Expenses

Routes

Members

Media

Messages

---

# Lifecycle

Added

↓

Planning

↓

Confirmed

↓

Visited

↓

Completed

↓

Archived

---

# Business Rules

Every Destination belongs to one Trip.

A Trip contains one or more Destinations.

Destinations may contain multiple Locations.

Destinations are ordered.

Deleting a destination never deletes historical memories.

---

# Relationships

Destination

↓

Trip

Destination

↓

Locations

Destination

↓

Activities

Destination

↓

Routes

Destination

↓

Expenses

Destination

↓

Albums

Destination

↓

Timeline Events

Destination

↓

Weather Snapshots

Destination

↓

AI Recommendations

---

# Destination Types

City

Town

Village

State

Country

Island

Mountain

National Park

Region

Festival Area

Custom

---

# Value Objects

Name

Country

State

Latitude

Longitude

Bounding Box

Arrival Date

Departure Date

Expected Budget

Priority

Visit Status

---

# Required Fields

Destination ID

Trip ID

Name

Type

Display Order

---

# Optional Fields

Description

Cover Image

Country

State

Arrival Date

Departure Date

Expected Budget

Coordinates

Travel Notes

---

# Geographic Data

Country

State

Timezone

Currency

Language

Climate Zone

Driving Side

Emergency Numbers

Voltage

Internet Availability

---

# Travel Statistics

Days Planned

Days Stayed

Locations Visited

Distance Covered

Money Spent

Photos Taken

Activities Completed

Average Rating

---

Calculated automatically.

---

# Weather

Historical Weather

Forecast

Rain Probability

Temperature

Wind

Sunrise

Sunset

---

Weather snapshots archived.

---

# AI Integration

AI Uses

Regional Planning

Weather

Destination Knowledge

Packing Advice

Local Customs

Travel Alerts

Language

Safety

Budget

Food

Hidden Gems

---

# Knowledge Graph

Graph Node

Yes

Node Type

Destination

---

Relationships

CONTAINS

CONNECTED_TO

VISITED

RECOMMENDS

PART_OF

---

Embeddings

Generated

Used for semantic destination search.

---

# Search Support

Search By

Name

Country

Region

Trip

Tags

Popularity

Semantic Search

---

# Realtime

Destination Added

Destination Updated

Destination Removed

Destination Reordered

Weather Updated

---

# Events

DestinationCreated

DestinationUpdated

DestinationRemoved

DestinationVisited

DestinationCompleted

WeatherSynced

---

# Audit

Track

Creation

Updates

Reordering

Deletion

Visit Completion

---

# Database Ownership

Schema

trip

---

Table

destinations

---

Primary Key

UUID v7

---

Indexes

Trip ID

Country

Type

Order

Created At

---

# Database Columns

destination_id

trip_id

name

type

country

state

coordinates

bounding_box

arrival_date

departure_date

display_order

expected_budget

status

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/destinations

POST

/trips/{tripId}/destinations

PATCH

/trips/{tripId}/destinations/{destinationId}

DELETE

/trips/{tripId}/destinations/{destinationId}

---

# Performance Requirements

Lookup

<20 ms

Reorder

<100 ms

Weather Sync

<2 sec

Destination Search

<200 ms

---

# Testing Requirements

Ordering

Weather

Search

Validation

Analytics

Realtime

---

# Future Evolution

Multi-Country Trips

Automatic Destination Detection

AI Destination Suggestions

Offline Destination Packs

Community Destination Guides

Destination Marketplace

---

# Entity Summary

ENT-103 (Destination) represents a major geographical region inside a Trip Workspace.

It provides the high-level geographic structure of a journey and acts as the organizational parent for detailed Locations, enabling better planning, navigation, analytics, AI recommendations, weather integration, and travel memories.

---

# Next Entity

ENT-104

Location

Represents an exact place visited during a trip such as a hotel, restaurant, attraction, fuel station, parking area, hospital, viewpoint, beach, or any GPS point.

Locations become one of the most frequently used entities throughout Project Atlas.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-104
#
# LOCATION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-104

---

Entity Name

Location

---

Owner Module

Navigation Engine

---

Bounded Context

Navigation Domain

---

Aggregate Root

No

Parent Aggregate

Destination (ENT-103)

---

# Business Purpose

A Location represents one real-world place that is referenced throughout Project Atlas.

Unlike Destinations, which represent broad geographic regions, a Location identifies an exact place that users visit, navigate to, spend money at, capture memories in, or interact with during a trip.

A Location becomes the single source of truth for all geographic information within a Trip Workspace.

---

# Responsibilities

Geographic Identity

Place Metadata

Navigation Context

Meeting Points

Expense Location

Photo Location

Check-ins

Weather Context

Timeline References

Knowledge Graph Node

---

# Does NOT Own

Trips

Members

Routes

Expenses

Photos

Activities

Timeline

Messages

These entities reference Locations.

---

# Lifecycle

Created

↓

Verified

↓

Visited

↓

Referenced

↓

Archived

↓

Deleted

---

Locations remain reusable even after a trip ends.

---

# Business Rules

Every Location belongs to one Destination.

A Location may be referenced by many entities.

Coordinates remain immutable after verification.

Locations may exist without internet connectivity.

Offline-created locations synchronize later.

---

# Relationships

Location

↓

Destination

Location

↓

Activities

Location

↓

Expenses

Location

↓

Media

Location

↓

Timeline

Location

↓

Weather

Location

↓

Routes

Location

↓

Check-ins

Location

↓

Meeting Points

Location

↓

Parking

Location

↓

Fuel Stops

Location

↓

Emergency Incidents

---

# Location Categories

Accommodation

Restaurant

Cafe

Beach

Mountain

Museum

Temple

Fuel Station

Parking

Airport

Railway Station

Bus Stop

Shopping

Hospital

ATM

Police Station

Viewpoint

Trail

Camp

Border

Custom

---

# Value Objects

Name

Latitude

Longitude

Elevation

Address

Google Place ID

OpenStreetMap ID

Timezone

Country

State

City

Postal Code

Phone Number

Website

Opening Hours

---

# Required Fields

Location ID

Destination ID

Name

Latitude

Longitude

Category

Created At

---

# Optional Fields

Description

Address

Photos

Rating

Website

Phone

Opening Hours

Tags

Accessibility

Pet Friendly

Wheelchair Access

EV Charging

Wi-Fi

Restrooms

Parking Availability

---

# Geographic Information

Latitude

Longitude

Elevation

Bounding Radius

Timezone

Country

Region

Administrative Area

Postal Code

Plus Code

---

# Offline Support

Offline Map Tile

Cached Metadata

Offline Search

Offline Routing

Offline Photos

Sync Status

---

Offline-first architecture.

---

# Weather Integration

Current Weather

Forecast

Historical Weather

Temperature

Rain

Wind

Humidity

UV Index

---

Weather snapshots linked to Location.

---

# AI Integration

AI Uses

Semantic Search

Recommendation Engine

Hidden Gems

Nearby Suggestions

Budget Analysis

Photo Grouping

Travel Journals

Timeline Summaries

Restaurant Suggestions

Fuel Optimization

---

# Knowledge Graph

Graph Node

Yes

Node Type

Location

---

Relationships

LOCATED_IN

VISITED

CONNECTED_TO

NEAR

CAPTURED_AT

SPENT_AT

CHECKED_IN

START_OF

END_OF

---

Embeddings

Generated

Used for semantic place understanding.

---

# Search Support

Search By

Name

Address

Category

Tags

Coordinates

Place ID

Semantic Search

Nearby Search

---

# Realtime Support

Location Added

Location Updated

Location Visited

Weather Updated

Meeting Point Changed

---

# Events

LocationCreated

LocationUpdated

LocationVisited

WeatherSynced

LocationArchived

MeetingPointAssigned

---

# Audit Strategy

Track

Creation

Verification

Metadata Updates

Category Changes

Reference Count

---

# Database Ownership

Schema

navigation

---

Table

locations

---

Primary Key

UUID v7

---

Indexes

Destination ID

Latitude

Longitude

Category

Google Place ID

OpenStreetMap ID

Created At

---

Unique Constraints

Google Place ID

(Optional)

OpenStreetMap ID

(Optional)

---

# Database Columns

location_id

destination_id

name

category

latitude

longitude

elevation

address

country

state

city

postal_code

timezone

google_place_id

osm_place_id

rating

metadata

created_at

updated_at

---

# API Endpoints

GET

/locations

GET

/locations/{locationId}

POST

/locations

PATCH

/locations/{locationId}

GET

/locations/search

GET

/locations/nearby

---

# Performance Requirements

Lookup

<10 ms

Nearby Search

<100 ms

Reverse Geocoding

<300 ms

Offline Lookup

<50 ms

Weather Sync

<2 sec

---

# Testing Requirements

Geospatial Queries

Offline Sync

Search

Weather

Navigation

Validation

Performance

---

# Future Evolution

Indoor Maps

AR Navigation

Crowdsourced Notes

Accessibility Maps

EV Charging Status

Live Crowd Density

Drone Landing Zones

Satellite Imagery

---

# Entity Summary

ENT-104 (Location) represents a reusable digital representation of a real-world place.

It serves as the central geographic entity for Project Atlas, allowing every module—including Navigation, Budget, Timeline, Gallery, AI, Weather, and Analytics—to reference a common location instead of duplicating coordinates.

By treating locations as first-class entities rather than simple latitude/longitude values, Atlas enables richer geospatial intelligence, semantic reasoning, offline support, and future map-based innovations.

---

# Next Entity

ENT-105

Activity

Represents a planned or completed action during a trip such as visiting an attraction, eating at a restaurant, hiking, checking into a hotel, shopping, attending an event, or any scheduled experience within the itinerary.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-105
#
# ACTIVITY
#
# ==============================================================================

# Entity Information

Entity ID

ENT-105

---

Entity Name

Activity

---

Owner Module

Planning Engine

---

Bounded Context

Planning Domain

---

Aggregate Root

No

Parent Aggregate

Trip (ENT-100)

---

# Business Purpose

An Activity represents one atomic action occurring within a Trip Workspace.

Every meaningful event during a trip is modeled as an Activity.

Activities provide the foundation for planning, scheduling, navigation, budgeting, collaboration, memories, analytics, AI reasoning, and timeline generation.

Rather than treating sightseeing, meals, travel, accommodation, and expenses as separate concepts, Atlas unifies them under a common Activity model.

---

# Responsibilities

Planning

Scheduling

Navigation

Budget Context

Timeline Generation

AI Context

Gallery Association

Task Assignment

Progress Tracking

Notifications

---

# Does NOT Own

Trips

Members

Locations

Expenses

Media

Messages

Routes

These entities reference Activities.

---

# Lifecycle

Draft

↓

Planned

↓

Approved

↓

Scheduled

↓

Active

↓

Completed

↓

Skipped

↓

Cancelled

↓

Archived

---

# State Machine

STATE_DRAFT

↓

STATE_PLANNED

↓

STATE_APPROVED

↓

STATE_SCHEDULED

↓

STATE_ACTIVE

↓

STATE_COMPLETED

↓

STATE_ARCHIVED

---

Alternative States

Cancelled

Skipped

Postponed

---

# Business Rules

Every Activity belongs to one Trip.

Activities may reference one Location.

Activities may contain many Tasks.

Activities may generate Expenses.

Activities may generate Timeline Events.

Completed Activities become immutable except for administrative corrections.

---

# Relationships

Activity

↓

Trip

Activity

↓

Location

Activity

↓

Expenses

Activity

↓

Media

Activity

↓

Timeline

Activity

↓

Tasks

Activity

↓

Checklist

Activity

↓

Weather Snapshot

Activity

↓

Navigation Segment

Activity

↓

AI Notes

---

# Activity Types

Transportation

Accommodation

Meal

Sightseeing

Shopping

Fuel

Parking

Rest

Photography

Adventure

Entertainment

Emergency

Meeting

Checkpoint

Border Crossing

Medical

Custom

---

# Value Objects

Title

Description

Priority

Start Time

End Time

Estimated Duration

Estimated Cost

Category

Status

Travel Time

Buffer Time

Risk Level

---

# Required Fields

Activity ID

Trip ID

Title

Type

Status

Display Order

Created At

---

# Optional Fields

Location ID

Assigned Members

Notes

Attachments

Weather Requirement

Dress Code

Expected Cost

Reservation Number

Booking URL

External Reference

---

# Scheduling

Estimated Start

Estimated End

Actual Start

Actual End

Travel Time

Buffer Time

Arrival Window

Departure Window

---

Scheduling is timezone-aware.

---

# Assignment

Activities may be assigned to

One Member

Multiple Members

Entire Group

Role

AI (Future Automation)

---

# Progress

Not Started

Preparing

In Progress

Waiting

Completed

Cancelled

Skipped

Blocked

---

Progress is independent of lifecycle.

---

# Budget Integration

Activity Budget

Estimated Cost

Actual Cost

Expense References

Budget Variance

Settlement Status

---

# Navigation Integration

Start Location

Destination

Distance

Estimated Travel Time

Preferred Route

Vehicle

Offline Route

---

# Gallery Integration

Photos

Videos

Documents

Voice Notes

AI Memories

Highlights

---

Automatically grouped by Activity.

---

# AI Integration

AI Uses

Planning

Optimization

Conflict Detection

Schedule Suggestions

Weather Adaptation

Budget Analysis

Packing Advice

Travel Journals

Photo Captions

Memory Generation

---

# Knowledge Graph

Graph Node

Yes

Node Type

Activity

---

Relationships

LOCATED_AT

NEXT_ACTIVITY

REQUIRES

GENERATED

ATTENDED_BY

CONNECTED_TO

PART_OF_DAY

---

Embeddings

Generated

Used for semantic planning and recommendations.

---

# Search Support

Search By

Title

Location

Category

Assigned Member

Date

Priority

Tags

Semantic Search

---

# Realtime Support

Activity Created

Activity Updated

Activity Started

Activity Completed

Activity Cancelled

Activity Reordered

Activity Assigned

---

# Events

ActivityCreated

ActivityScheduled

ActivityStarted

ActivityCompleted

ActivitySkipped

ActivityCancelled

ActivityReordered

ActivityAssigned

WeatherImpactDetected

---

# Audit Strategy

Track

Creation

Schedule Changes

Assignments

Status Changes

Reordering

Deletion

AI Suggestions

---

# Database Ownership

Schema

planning

---

Table

activities

---

Primary Key

UUID v7

---

Indexes

Trip ID

Location ID

Start Time

Category

Status

Priority

Display Order

---

# Database Columns

activity_id

trip_id

location_id

title

description

activity_type

status

priority

estimated_start

estimated_end

actual_start

actual_end

estimated_cost

display_order

assigned_members

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/activities

POST

/trips/{tripId}/activities

PATCH

/trips/{tripId}/activities/{activityId}

DELETE

/trips/{tripId}/activities/{activityId}

POST

/trips/{tripId}/activities/reorder

---

# Performance Requirements

Lookup

<20 ms

Schedule Update

<100 ms

Reorder

<100 ms

Search

<200 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Scheduling

Assignments

Budget Integration

Navigation

Gallery

AI

Realtime

Validation

Performance

---

# Future Evolution

Recurring Activities

Activity Templates

AI Auto-Planner

Calendar Synchronization

External Booking Integration

Smart Rescheduling

Wearable Check-ins

Live Activity Tracking

---

# Entity Summary

ENT-105 (Activity) is the fundamental operational unit of a Trip Workspace.

Rather than representing only attractions or itinerary items, Activities model every meaningful action that occurs during a trip, creating a unified abstraction consumed by planning, navigation, budgeting, memories, analytics, AI, and collaboration.

This design dramatically reduces duplication across modules and establishes Activities as the central operational entity of Project Atlas.

---

# Next Entity

ENT-106

Day Plan

Represents a structured schedule grouping Activities into calendar days, balancing time, travel, budget, member availability, and dependencies while providing the primary planning interface for users.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-106
#
# DAY PLAN
#
# ==============================================================================

# Entity Information

Entity ID

ENT-106

---

Entity Name

Day Plan

---

Owner Module

Planning Engine

---

Bounded Context

Planning Domain

---

Aggregate Root

No

Parent Aggregate

Trip (ENT-100)

---

# Business Purpose

A Day Plan represents one calendar day within a Trip Workspace.

It groups Activities, Time Blocks, travel segments, weather, budgets, and member schedules into one coherent planning unit.

Rather than managing an itinerary as one long chronological list, Atlas organizes planning around Day Plans, making scheduling more understandable and easier to optimize.

---

# Responsibilities

Daily Schedule

Activity Organization

Time Block Management

Daily Budget

Daily Timeline

Daily Navigation

Weather Context

Member Availability

Daily Analytics

AI Planning Context

---

# Does NOT Own

Trip

Activities

Expenses

Media

Routes

Messages

Members

---

# Lifecycle

Created

↓

Planning

↓

Approved

↓

Locked

↓

In Progress

↓

Completed

↓

Archived

---

Day Plans may be reopened while the Trip is still in Planning.

---

# Business Rules

Every Day Plan belongs to one Trip.

Every Activity belongs to exactly one Day Plan.

Day Plans are sequential.

Day numbers remain unique.

Dates cannot overlap.

Completed Day Plans become read-only unless reopened by an administrator.

---

# Relationships

Day Plan

↓

Trip

Day Plan

↓

Activities

Day Plan

↓

Time Blocks

Day Plan

↓

Daily Budget

Day Plan

↓

Weather Snapshot

Day Plan

↓

Navigation Summary

Day Plan

↓

Timeline Events

Day Plan

↓

Daily Journal

---

# Value Objects

Day Number

Calendar Date

Theme

Daily Goal

Start Time

End Time

Total Distance

Total Budget

Completion Percentage

Weather Summary

Risk Score

---

# Required Fields

Day Plan ID

Trip ID

Day Number

Calendar Date

Created At

---

# Optional Fields

Title

Description

Daily Theme

Notes

Accommodation

Daily Goal

Sunrise

Sunset

Expected Weather

---

# Daily Structure

Morning

Afternoon

Evening

Night

OR

Dynamic Time Blocks

Platform uses Time Blocks internally.

Traditional labels are generated for display.

---

# Time Blocks

Examples

06:00–08:00

Preparation

08:00–11:00

Travel

11:00–13:00

Exploration

13:00–14:00

Lunch

14:00–17:00

Adventure

17:00–19:00

Rest

19:00–22:00

Dinner

---

Time Blocks contain Activities.

---

# Daily Budget

Estimated Spend

Actual Spend

Remaining Budget

Expense Count

Budget Alerts

Settlement Status

---

# Daily Navigation

Distance

Driving Time

Walking Time

Stops

Traffic Summary

Offline Maps

Fuel Estimate

Parking

---

# Weather

Current

Forecast

Rain

Temperature

Humidity

Wind

UV Index

Sunrise

Sunset

---

Weather automatically linked to activities.

---

# AI Integration

AI Uses

Schedule Optimization

Conflict Detection

Weather Adaptation

Travel Time

Meal Suggestions

Break Recommendations

Budget Forecast

Journal Generation

Photo Recommendations

---

# Knowledge Graph

Graph Node

Yes

Node Type

DayPlan

---

Relationships

CONTAINS

NEXT_DAY

PREVIOUS_DAY

HAS_ACTIVITY

GENERATED_JOURNAL

---

Embeddings

Generated

Supports semantic trip search.

---

# Search Support

Search By

Date

Day Number

Activities

Destination

Weather

Semantic Search

---

# Realtime Support

Day Plan Updated

Activities Reordered

Weather Updated

Budget Updated

Completion Updated

---

# Events

DayPlanCreated

DayPlanUpdated

DayStarted

DayCompleted

WeatherChanged

BudgetExceeded

ScheduleOptimized

---

# Audit Strategy

Track

Schedule Changes

Activity Movement

Time Block Changes

Budget Updates

AI Suggestions

Weather Updates

---

# Database Ownership

Schema

planning

---

Table

day_plans

---

Primary Key

UUID v7

---

Indexes

Trip ID

Day Number

Calendar Date

Created At

---

Unique Constraints

Trip ID + Day Number

Trip ID + Calendar Date

---

# Database Columns

day_plan_id

trip_id

day_number

calendar_date

title

description

daily_goal

weather_summary

estimated_budget

actual_budget

distance

completion_percentage

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/days

GET

/trips/{tripId}/days/{dayPlanId}

POST

/trips/{tripId}/days

PATCH

/trips/{tripId}/days/{dayPlanId}

DELETE

/trips/{tripId}/days/{dayPlanId}

---

# Performance Requirements

Lookup

<20 ms

Schedule Update

<150 ms

Activity Reordering

<100 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Scheduling

Time Blocks

Budget Integration

Navigation

Weather

Realtime

Validation

Performance

---

# Future Evolution

AI Auto-Day Planning

Calendar Sync

Smart Time Blocking

Energy-Based Scheduling

Offline Planning

Shared Calendar Export

Adaptive Scheduling

Wearable Integration

---

# Entity Summary

ENT-106 (Day Plan) organizes a Trip into structured daily workspaces.

It groups activities, time blocks, navigation, weather, budgets, and AI context into a coherent daily schedule, enabling flexible planning, intelligent optimization, and a significantly better user experience than a simple chronological itinerary.

---

# Next Entity

ENT-107

Time Block

Represents a contiguous period within a Day Plan that groups related Activities. Time Blocks enable intelligent scheduling, drag-and-drop planning, dependency management, AI optimization, and dynamic itinerary adjustments.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-107
#
# TIME BLOCK
#
# ==============================================================================

# Entity Information

Entity ID

ENT-107

---

Entity Name

Time Block

---

Owner Module

Planning Engine

---

Bounded Context

Planning Domain

---

Aggregate Root

No

Parent Aggregate

Day Plan (ENT-106)

---

# Business Purpose

A Time Block represents a continuous scheduling window within a Day Plan.

Rather than organizing a day solely by Activities, Atlas groups related Activities into Time Blocks, creating meaningful planning units.

Time Blocks improve visualization, scheduling, optimization, conflict detection, travel planning, and AI reasoning.

They provide a balance between rigid calendar events and flexible itinerary planning.

---

# Responsibilities

Schedule Container

Activity Grouping

Travel Buffer Management

Weather Context

Budget Context

Navigation Context

AI Planning Unit

Timeline Grouping

Conflict Resolution

Progress Tracking

---

# Does NOT Own

Trip

Day Plan

Activities

Expenses

Routes

Media

Members

Timeline

---

# Lifecycle

Draft

↓

Planned

↓

Optimized

↓

Locked

↓

Active

↓

Completed

↓

Archived

---

# Business Rules

Every Time Block belongs to one Day Plan.

Every Activity belongs to one Time Block.

Time Blocks cannot overlap.

Start time must precede end time.

Activities must fall within the Time Block window.

Locked blocks cannot be reordered without authorization.

---

# Relationships

Time Block

↓

Day Plan

Time Block

↓

Activities

Time Block

↓

Navigation Segment

Time Block

↓

Weather Snapshot

Time Block

↓

Budget Summary

Time Block

↓

Timeline Events

Time Block

↓

AI Notes

---

# Time Block Types

Travel

Exploration

Accommodation

Meal

Adventure

Shopping

Free Time

Rest

Transit

Emergency

Custom

---

# Value Objects

Title

Description

Start Time

End Time

Estimated Duration

Priority

Travel Buffer

Energy Level

Weather Dependency

Risk Level

---

# Required Fields

Time Block ID

Day Plan ID

Title

Start Time

End Time

Created At

---

# Optional Fields

Description

Color

Theme

Notes

Travel Buffer

Expected Cost

Expected Distance

Expected Energy

Weather Dependency

Tags

---

# Scheduling

Start Time

End Time

Duration

Travel Buffer

Preparation Buffer

Cleanup Buffer

Maximum Delay

---

Scheduling is timezone-aware.

---

# Capacity

Activities

Unlimited (configurable)

Members

Unlimited

Parallel Activities

Supported

Dependencies

Supported

---

# Progress

Not Started

Preparing

In Progress

Delayed

Completed

Skipped

Cancelled

---

Progress derived from child activities.

---

# Budget Integration

Estimated Cost

Actual Cost

Budget Variance

Expense Count

Remaining Budget

---

Aggregated from activities.

---

# Navigation Integration

Distance

Travel Time

Traffic

Route

Vehicle

Fuel Estimate

Parking

Meeting Point

---

# Weather Integration

Current Weather

Forecast

Rain Probability

Temperature

Wind

Sunrise

Sunset

---

Weather updates may trigger AI rescheduling.

---

# AI Integration

AI Uses

Schedule Optimization

Conflict Detection

Buffer Recommendations

Weather Adaptation

Energy Optimization

Travel Suggestions

Risk Assessment

Meal Timing

Rest Recommendations

Photo Opportunities

---

# Knowledge Graph

Graph Node

Yes

Node Type

TimeBlock

---

Relationships

CONTAINS

NEXT_BLOCK

PREVIOUS_BLOCK

DEPENDS_ON

GENERATES

---

Embeddings

Generated

Supports semantic planning.

---

# Search Support

Search By

Date

Time

Title

Activity

Tags

Semantic Search

---

# Realtime Support

Block Updated

Block Reordered

Block Delayed

Block Started

Block Completed

Weather Updated

AI Optimization Available

---

# Events

TimeBlockCreated

TimeBlockUpdated

TimeBlockStarted

TimeBlockCompleted

TimeBlockDelayed

ActivitiesMoved

WeatherChanged

OptimizationSuggested

---

# Audit Strategy

Track

Creation

Schedule Changes

Activity Movement

Delay

AI Optimization

Weather Updates

Manual Overrides

---

# Database Ownership

Schema

planning

---

Table

time_blocks

---

Primary Key

UUID v7

---

Indexes

Day Plan ID

Start Time

End Time

Priority

Created At

---

Unique Constraints

Day Plan ID + Start Time

---

# Database Columns

time_block_id

day_plan_id

title

description

block_type

start_time

end_time

priority

travel_buffer

estimated_cost

estimated_distance

expected_energy

weather_dependency

status

metadata

created_at

updated_at

---

# API Endpoints

GET

/day-plans/{dayPlanId}/time-blocks

POST

/day-plans/{dayPlanId}/time-blocks

PATCH

/time-blocks/{timeBlockId}

DELETE

/time-blocks/{timeBlockId}

POST

/time-blocks/{timeBlockId}/optimize

---

# Performance Requirements

Lookup

<20 ms

Reorder

<100 ms

Optimization

<500 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Scheduling

Overlap Detection

Dependency Validation

Budget Aggregation

Navigation

Weather

Realtime

Performance

---

# Future Evolution

AI Auto-Blocking

Energy-Based Planning

Weather-Aware Scheduling

Parallel Planning

Calendar Integration

Drag-and-Drop Planner

Wearable Schedule Sync

Adaptive Time Blocks

---

# Entity Summary

ENT-107 (Time Block) is the primary scheduling container within a Day Plan.

Rather than acting as a simple time range, it groups Activities into meaningful planning units enriched with travel, weather, budget, navigation, and AI context.

This design enables flexible itinerary management, intelligent optimization, and a much richer planning experience than traditional calendar-based travel applications.

---

# Next Entity

ENT-108

Checklist

Represents reusable and trip-specific checklists used throughout the journey, including preparation, documentation, vehicle inspection, accommodation, shopping, departure, arrival, and custom workflows.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-108
#
# CHECKLIST
#
# ==============================================================================

# Entity Information

Entity ID

ENT-108

---

Entity Name

Checklist

---

Owner Module

Planning Engine

---

Bounded Context

Planning Domain

---

Aggregate Root

No

Parent Aggregate

Trip (ENT-100)

---

# Business Purpose

A Checklist represents a structured collection of tasks that must be completed before, during, or after a Trip.

Unlike Activities, which represent scheduled events, Checklists ensure preparation, verification, compliance, and execution of required actions.

Checklists help reduce forgotten items and improve trip readiness.

---

# Responsibilities

Preparation

Verification

Task Tracking

Progress Monitoring

Assignment

Completion Validation

Notifications

AI Suggestions

Analytics

---

# Does NOT Own

Trip

Members

Activities

Expenses

Messages

Media

Routes

---

# Lifecycle

Draft

↓

Prepared

↓

Assigned

↓

Active

↓

Completed

↓

Archived

---

# Business Rules

Every Checklist belongs to one Trip.

Checklist Items belong to one Checklist.

Items may be assigned to members.

Completion may require verification.

Archived checklists are read-only.

---

# Relationships

Checklist

↓

Trip

Checklist

↓

Checklist Items

Checklist

↓

Assigned Members

Checklist

↓

Timeline Events

Checklist

↓

AI Suggestions

Checklist

↓

Audit Events

---

# Checklist Types

Pre-Trip

Departure

Arrival

Accommodation

Vehicle

Camping

Shopping

Emergency

Medical

Documentation

Photography

Custom

---

# Value Objects

Title

Description

Priority

Due Date

Progress

Completion Rule

Category

---

# Required Fields

Checklist ID

Trip ID

Title

Type

Created At

---

# Optional Fields

Description

Color

Icon

Notes

Due Date

Template Reference

Tags

---

# Progress

Not Started

In Progress

Completed

Blocked

Cancelled

---

Calculated from Checklist Items.

---

# Assignment

Checklist

↓

Entire Group

OR

↓

Specific Members

OR

↓

Specific Roles

---

# Completion Rules

Any Member

All Assigned Members

Owner Only

Manual Verification

AI Verification (Future)

---

# Notifications

Upcoming Due Date

Incomplete Items

Overdue

Completion

Reminder

---

# AI Integration

AI Uses

Suggest Missing Items

Trip Type

Destination

Weather

Travel Duration

Transportation

Previous Trips

Travel DNA

---

AI Suggestions

Passport

Rain Gear

Medicines

Fuel Check

Offline Maps

Emergency Kit

Local Currency

Power Adapter

---

# Knowledge Graph

Graph Node

Yes

Node Type

Checklist

---

Relationships

CONTAINS

ASSIGNED_TO

GENERATED_FROM

REQUIRES

PART_OF

---

Embeddings

Generated

Supports semantic planning.

---

# Search Support

Search By

Title

Category

Assigned Member

Status

Tags

Semantic Search

---

# Realtime Support

Checklist Updated

Item Completed

Assignment Changed

Reminder Triggered

AI Suggestions Added

---

# Events

ChecklistCreated

ChecklistAssigned

ChecklistCompleted

ChecklistArchived

ItemCompleted

ReminderSent

SuggestionAccepted

---

# Audit Strategy

Track

Creation

Assignment

Completion

Verification

AI Suggestions

Manual Changes

---

# Database Ownership

Schema

planning

---

Table

checklists

---

Primary Key

UUID v7

---

Indexes

Trip ID

Category

Status

Due Date

Created At

---

# Database Columns

checklist_id

trip_id

title

description

checklist_type

status

progress

due_date

completion_rule

template_id

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/checklists

POST

/trips/{tripId}/checklists

PATCH

/checklists/{checklistId}

DELETE

/checklists/{checklistId}

POST

/checklists/{checklistId}/complete

---

# Performance Requirements

Lookup

<20 ms

Progress Update

<50 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Assignment

Progress

Completion Rules

AI Suggestions

Realtime

Validation

Performance

---

# Future Evolution

Recurring Checklists

Conditional Checklists

AI Auto-Generated Checklists

Marketplace Templates

Voice Completion

Photo Verification

Smart Dependencies

Offline Completion

---

# Entity Summary

ENT-108 (Checklist) provides structured preparation and verification workflows throughout the trip lifecycle.

By separating operational tasks from scheduled Activities, Atlas ensures that preparation, compliance, and readiness remain visible, collaborative, and measurable without cluttering the itinerary.

---

# Next Entity

ENT-109

Checklist Item

Represents an individual actionable item within a Checklist, including assignments, completion status, verification, attachments, dependencies, and AI recommendations.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# TRIP DOMAIN
#
# ENTITY CARD
#
# ENT-109
#
# PACKING LIST
#
# ==============================================================================

# Entity Information

Entity ID

ENT-109

---

Entity Name

Packing List

---

Owner Module

Planning Engine

---

Bounded Context

Planning Domain

---

Aggregate Root

No

Parent Aggregate

Trip (ENT-100)

---

# Business Purpose

The Packing List represents all physical items that should be carried during a Trip.

Unlike a Checklist, which verifies actions, a Packing List manages inventory planning.

It helps distribute equipment across members, reduce duplicate items, optimize luggage, and ensure every required item is packed before departure.

---

# Responsibilities

Packing Planning

Inventory

Weight Distribution

Bag Assignment

Ownership

Packing Progress

AI Recommendations

Shopping Detection

Duplicate Prevention

Analytics

---

# Does NOT Own

Trip

Members

Shopping Lists

Expenses

Activities

Messages

---

# Lifecycle

Created

↓

Generated

↓

Preparing

↓

Packing

↓

Verified

↓

Ready

↓

Completed

↓

Archived

---

# Business Rules

Every Packing List belongs to one Trip.

Packing Items belong to one Packing List.

Packing Lists may be personal or shared.

Items may be assigned to members.

Packed items become immutable after verification unless unlocked.

---

# Relationships

Packing List

↓

Trip

Packing List

↓

Packing Items

Packing List

↓

Members

Packing List

↓

Shopping Suggestions

Packing List

↓

AI Recommendations

Packing List

↓

Audit Events

---

# Packing Types

Personal

Shared

Vehicle

Camping

Photography

Medical

Emergency

Food

Electronics

Custom

---

# Value Objects

Title

Description

Weight

Volume

Progress

Bag Count

Owner

Priority

---

# Required Fields

Packing List ID

Trip ID

Title

Packing Type

Created At

---

# Optional Fields

Description

Notes

Color

Template

Tags

Maximum Weight

Maximum Volume

---

# Packing Categories

Clothing

Documents

Electronics

Food

Camping

Medical

Photography

Vehicle

Toiletries

Emergency

Sports

Custom

---

# Weight Management

Estimated Weight

Packed Weight

Maximum Weight

Bag Distribution

Weight Per Member

Vehicle Capacity

---

Supports future luggage optimization.

---

# Bag Assignment

Carry-on

Checked Bag

Backpack

Camera Bag

Vehicle Storage

Shared Storage

Custom

---

# Packing Progress

Not Packed

Partially Packed

Packed

Verified

Missing

Purchased

Unavailable

---

# Shopping Detection

Missing Items

↓

Shopping Suggestions

↓

Budget Impact

↓

Purchase Tracking

---

Integrated with Shopping module.

---

# AI Integration

AI Uses

Destination

Weather

Trip Type

Duration

Activities

Travel DNA

Previous Trips

Transportation

Accommodation

Local Climate

---

AI Suggestions

Rain Jacket

Power Bank

Passport

First Aid Kit

Beach Towel

Camping Stove

Universal Adapter

Sunscreen

Offline Maps

---

# Knowledge Graph

Graph Node

Yes

Node Type

PackingList

---

Relationships

CONTAINS

ASSIGNED_TO

RECOMMENDS

GENERATED_FROM

---

Embeddings

Generated

Supports semantic recommendations.

---

# Search Support

Search By

Category

Item

Owner

Bag

Status

Semantic Search

---

# Realtime Support

Item Packed

Item Assigned

Weight Updated

Shopping Suggested

AI Recommendation Added

---

# Events

PackingListCreated

PackingStarted

PackingCompleted

ItemPacked

ItemRemoved

BagAssigned

RecommendationAccepted

---

# Audit Strategy

Track

Creation

Assignments

Packing

Verification

Weight Changes

AI Suggestions

---

# Database Ownership

Schema

planning

---

Table

packing_lists

---

Primary Key

UUID v7

---

Indexes

Trip ID

Packing Type

Status

Created At

---

# Database Columns

packing_list_id

trip_id

title

description

packing_type

status

maximum_weight

maximum_volume

progress

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/packing-lists

POST

/trips/{tripId}/packing-lists

PATCH

/packing-lists/{packingListId}

DELETE

/packing-lists/{packingListId}

POST

/packing-lists/{packingListId}/generate

---

# Performance Requirements

Lookup

<20 ms

Progress Update

<50 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Packing Progress

Weight

Assignments

AI Suggestions

Realtime

Validation

Performance

---

# Future Evolution

AI Luggage Optimization

Airline Weight Rules

RFID Tracking

Smart Suitcase Integration

Offline Packing

Barcode Support

Shared Family Packing

Photo Verification

---

# Entity Summary

ENT-109 (Packing List) is the inventory planning system of Project Atlas.

Rather than verifying completed actions, it manages physical equipment, luggage, ownership, and packing progress while leveraging AI to recommend items, optimize weight distribution, and reduce forgotten essentials.

---

# Next Entity

ENT-110

Packing Item

Represents an individual item within a Packing List, including ownership, quantity, weight, verification, bag assignment, purchase status, AI recommendations, and inventory tracking.



# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 03
#
# PLANNING DOMAIN
#
# ENTITY CARD
#
# ENT-110
#
# INVENTORY ITEM
#
# ==============================================================================

# Entity Information

Entity ID

ENT-110

---

Entity Name

Inventory Item

---

Owner Module

Inventory Engine

---

Bounded Context

Planning Domain

---

Aggregate Root

No

Parent Aggregate

Packing List (ENT-109)

Can also belong to:

Shopping List

Vehicle Kit

Medical Kit

Emergency Kit

Food Supplies

Future Inventory Collections

---

# Business Purpose

An Inventory Item represents one physical object tracked within Project Atlas.

It provides a reusable inventory model that powers packing, shopping, emergency preparedness, vehicle equipment, camping gear, photography equipment, and future inventory-based modules.

Inventory Items allow Atlas to reason about physical assets instead of treating every list independently.

---

# Responsibilities

Inventory Tracking

Ownership

Quantity Management

Weight Tracking

Volume Tracking

Bag Assignment

Purchase Tracking

Packing Status

Condition Tracking

AI Recommendations

---

# Does NOT Own

Packing Lists

Shopping Lists

Trips

Members

Expenses

Messages

Activities

---

# Lifecycle

Created

↓

Suggested

↓

Added

↓

Purchased

↓

Packed

↓

Verified

↓

Used

↓

Returned

↓

Archived

---

Alternative States

Missing

Lost

Damaged

Expired

Disposed

---

# Business Rules

Every Inventory Item belongs to exactly one inventory collection.

Items may be shared across members.

Quantities must be non-negative.

Weight cannot be negative.

Assigned bags must exist.

Verified items require confirmation.

---

# Relationships

Inventory Item

↓

Packing List

Inventory Item

↓

Owner

Inventory Item

↓

Assigned Member

Inventory Item

↓

Bag

Inventory Item

↓

Shopping Suggestions

Inventory Item

↓

AI Recommendations

Inventory Item

↓

Timeline Events

---

# Item Categories

Clothing

Electronics

Medical

Camping

Photography

Vehicle

Food

Documents

Personal Care

Sports

Tools

Emergency

Pets

Custom

---

# Value Objects

Item Name

Description

Quantity

Weight

Volume

Priority

Condition

Packing Status

Purchase Status

Verification Status

Expiry Date

---

# Required Fields

Item ID

Collection ID

Name

Category

Quantity

Created At

---

# Optional Fields

Description

Weight

Volume

Brand

Model

Serial Number

Expiry Date

Purchase Link

Photo

Notes

Barcode

QR Code

---

# Quantity

Required

Packed

Remaining

Reserved

Consumed

---

# Weight

Per Item

Total Weight

Bag Weight

Member Weight

Vehicle Weight

---

# Ownership

Personal

Shared

Organization

Rental

Borrowed

Vehicle

---

# Packing Status

Not Packed

Packed

Verified

Missing

Delayed

Unavailable

---

# Purchase Status

Already Owned

Need To Buy

Ordered

Purchased

Delivered

Unavailable

---

# Condition

New

Good

Used

Needs Repair

Expired

Broken

Lost

---

# AI Integration

AI Uses

Destination

Weather

Trip Duration

Activities

Travel Style

Travel DNA

Transportation

Accommodation

Past Trips

Group Size

---

AI Suggestions

Quantity

Alternative Items

Lighter Equipment

Rental Recommendation

Weather Gear

Safety Equipment

Duplicate Detection

---

# Knowledge Graph

Graph Node

Yes

Node Type

InventoryItem

---

Relationships

BELONGS_TO

ASSIGNED_TO

PACKED_IN

PURCHASED_FOR

USED_IN

RELATED_TO

---

Embeddings

Generated

Supports semantic inventory search.

---

# Search Support

Search By

Name

Category

Owner

Status

Barcode

Tags

Semantic Search

---

# Realtime Support

Item Added

Item Packed

Item Assigned

Quantity Updated

Purchase Completed

Verification Completed

---

# Events

InventoryItemCreated

InventoryItemPacked

InventoryItemVerified

InventoryItemPurchased

InventoryItemAssigned

InventoryItemMissing

InventoryItemConsumed

InventoryItemArchived

---

# Audit Strategy

Track

Creation

Assignments

Packing

Purchases

Verification

Condition Changes

AI Suggestions

---

# Database Ownership

Schema

inventory

---

Table

inventory_items

---

Primary Key

UUID v7

---

Indexes

Collection ID

Category

Status

Owner

Created At

Barcode

---

# Database Columns

item_id

collection_id

name

description

category

quantity

weight

volume

condition

packing_status

purchase_status

owner_type

assigned_member

bag_reference

expiry_date

barcode

metadata

created_at

updated_at

---

# API Endpoints

GET

/inventory

GET

/inventory/{itemId}

POST

/inventory

PATCH

/inventory/{itemId}

DELETE

/inventory/{itemId}

POST

/inventory/{itemId}/verify

POST

/inventory/{itemId}/pack

---

# Performance Requirements

Lookup

<20 ms

Status Update

<50 ms

Realtime Broadcast

<250 ms

Semantic Search

<300 ms

---

# Testing Requirements

Validation

Quantity

Weight

Ownership

Packing

Realtime

AI Suggestions

Performance

---

# Future Evolution

RFID Integration

Smart Luggage

Barcode Scanner

NFC Tags

Rental Marketplace

Inventory Sharing

Wearable Integration

Smart Cabinets

Automatic Weight Detection

---

# Entity Summary

ENT-110 (Inventory Item) is the foundational entity of the Atlas Inventory Engine.

Rather than creating separate item models for packing, shopping, camping, medical supplies, and equipment, Atlas uses a single reusable inventory abstraction that supports every inventory-based workflow while remaining extensible for future hardware integrations and AI-powered recommendations.

---

# End of Planning Domain (Phase 1)

Planning Domain Entities

✓ ENT-100 Trip

✓ ENT-101 Trip Settings

✓ ENT-102 Trip Template

✓ ENT-103 Destination

✓ ENT-104 Location

✓ ENT-105 Activity

✓ ENT-106 Day Plan

✓ ENT-107 Time Block

✓ ENT-108 Checklist

✓ ENT-109 Packing List

✓ ENT-110 Inventory Item

---

# Next Part

Volume 04

Part 04

Consensus Domain

Entities

ENT-200 Proposal

ENT-201 Vote

ENT-202 Decision

ENT-203 Approval Rule

ENT-204 Consensus Session

ENT-205 Discussion Context

This domain implements one of Atlas' core differentiators: collaborative decision-making where plans advance only after satisfying configurable approval rules, including your original requirement that every member must agree before certain planning stages can proceed.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 04
#
# CONSENSUS DOMAIN
#
# ENTITY CARD
#
# ENT-200
#
# PROPOSAL
#
# ==============================================================================

# Entity Information

Entity ID

ENT-200

---

Entity Name

Proposal

---

Owner Module

Consensus Engine

---

Bounded Context

Consensus Domain

---

Aggregate Root

Yes

Proposal is the aggregate root for collaborative decision making.

---

# Business Purpose

A Proposal represents a suggested change within a Trip Workspace.

Rather than immediately modifying trip data, Atlas creates a Proposal that members can discuss, revise, analyze, and approve through the Consensus Engine.

Every important collaborative change should originate from a Proposal.

---

# Responsibilities

Proposal Creation

Revision Tracking

Consensus Coordination

Approval Workflow

Discussion Context

AI Analysis

Workflow Trigger

Audit

Timeline

---

# Does NOT Own

Trip

Activities

Budget

Members

Votes

Messages

Timeline

Proposal references these entities.

---

# Lifecycle

Draft

↓

Submitted

↓

Discussion

↓

Revised

↓

Voting

↓

Approved

↓

Executed

↓

Archived

---

Alternative States

Rejected

Expired

Cancelled

Withdrawn

---

# State Machine

STATE_DRAFT

↓

STATE_SUBMITTED

↓

STATE_DISCUSSION

↓

STATE_REVISION

↓

STATE_VOTING

↓

STATE_APPROVED

↓

STATE_EXECUTED

↓

STATE_ARCHIVED

---

Illegal Transition

Executed

↓

Discussion

Not Allowed

---

# Business Rules

Every Proposal belongs to one Trip.

Every Proposal has one creator.

Every Proposal references at least one target entity.

Execution occurs only after the Decision Engine approves it.

Executed proposals become immutable.

Revisions create new proposal versions.

---

# Relationships

Proposal

↓

Trip

Proposal

↓

Creator

Proposal

↓

Votes

Proposal

↓

Decision

Proposal

↓

Discussion Thread

Proposal

↓

Approval Rule

Proposal

↓

Timeline

Proposal

↓

AI Analysis

Proposal

↓

Target Entity

---

# Proposal Types

Activity Change

Budget Change

Expense Approval

Destination Change

Route Change

Schedule Change

Member Invitation

Role Change

Checklist Change

Packing Change

Safety Rule

Trip Settings

Custom

---

# Value Objects

Title

Description

Reason

Priority

Deadline

Proposal Version

Consensus Status

Execution Status

Impact Level

---

# Required Fields

Proposal ID

Trip ID

Creator ID

Proposal Type

Status

Created At

---

# Optional Fields

Summary

Attachments

AI Summary

Due Date

Execution Time

Tags

Related Proposal

Parent Proposal

---

# Proposal Scope

Single Activity

Entire Day

Entire Trip

Budget

Gallery

Navigation

Members

Safety

Workspace

---

# Revision System

Version 1

↓

Discussion

↓

Revision

↓

Version 2

↓

Discussion

↓

Approval

---

Previous versions remain immutable.

---

# AI Integration

AI Uses

Proposal Summary

Impact Analysis

Budget Effect

Schedule Effect

Conflict Detection

Alternative Suggestions

Risk Assessment

Travel Time

Weather

Dependencies

---

AI may recommend revisions.

AI never approves proposals.

---

# Knowledge Graph

Graph Node

Yes

Node Type

Proposal

---

Relationships

MODIFIES

REFERENCES

DEPENDS_ON

GENERATED_BY

APPROVED_BY

EXECUTES

---

Embeddings

Generated

Supports semantic proposal search.

---

# Search Support

Search By

Title

Creator

Type

Status

Target

Date

Semantic Search

---

# Realtime Support

Proposal Created

Proposal Updated

Proposal Revised

Discussion Started

Voting Started

Proposal Approved

Proposal Executed

---

# Events

ProposalCreated

ProposalSubmitted

ProposalRevised

DiscussionStarted

VotingOpened

ProposalApproved

ProposalRejected

ProposalExecuted

ProposalArchived

---

# Audit Strategy

Track

Creation

Edits

Revision

Approval

Execution

Cancellation

AI Suggestions

---

# Database Ownership

Schema

consensus

---

Table

proposals

---

Primary Key

UUID v7

---

Indexes

Trip ID

Creator ID

Proposal Type

Status

Deadline

Created At

---

# Database Columns

proposal_id

trip_id

creator_id

proposal_type

status

title

description

version

deadline

impact_level

target_entity

execution_status

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/proposals

GET

/proposals/{proposalId}

POST

/trips/{tripId}/proposals

PATCH

/proposals/{proposalId}

DELETE

/proposals/{proposalId}

POST

/proposals/{proposalId}/submit

POST

/proposals/{proposalId}/execute

---

# Performance Requirements

Lookup

<20 ms

Create

<100 ms

Execution

<300 ms

Realtime Broadcast

<250 ms

Semantic Search

<300 ms

---

# Testing Requirements

Lifecycle

Revision

Execution

Permissions

AI Analysis

Realtime

Validation

Performance

---

# Future Evolution

Proposal Templates

AI Drafting

Bulk Proposals

Linked Proposals

Scheduled Execution

Marketplace Actions

Cross-Trip Proposals

Organization Policies

---

# Entity Summary

ENT-200 (Proposal) is the foundational entity of the Atlas Consensus Engine.

Instead of directly modifying trip data, every important collaborative change is represented as a Proposal that can be discussed, revised, analyzed, approved, and safely executed.

This approach provides transparency, auditability, AI-assisted planning, and a structured decision-making process that distinguishes Atlas from traditional travel planning applications.

---

# Next Entity

ENT-201

Vote

Represents an individual member's response to a Proposal, including approval, rejection, abstention, reasoning, voting history, deadlines, delegation (future), and audit information.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 04
#
# CONSENSUS DOMAIN
#
# ENTITY CARD
#
# ENT-201
#
# VOTE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-201

---

Entity Name

Vote

---

Owner Module

Consensus Engine

---

Bounded Context

Consensus Domain

---

Aggregate Root

No

Parent Aggregate

Proposal (ENT-200)

---

# Business Purpose

A Vote represents one member's structured response to a Proposal.

Unlike traditional voting systems, Atlas Votes capture decisions, reasoning, conditions, confidence, and suggested improvements.

Votes help the group move toward consensus rather than simply counting approvals.

---

# Responsibilities

Decision Recording

Consensus Feedback

Conditions

Reasoning

Revision Suggestions

Confidence Tracking

Audit

Realtime Updates

---

# Does NOT Own

Proposal

Trip

Members

Discussion

Decision

---

# Lifecycle

Created

↓

Submitted

↓

Updated

↓

Locked

↓

Archived

---

Votes become locked once the Proposal reaches a final decision unless administrators reopen voting.

---

# Business Rules

Each eligible member may submit one active vote per proposal.

Votes may be updated until the voting period closes.

Votes are immutable after locking.

Votes can include optional conditions and comments.

Anonymous voting is supported if enabled by the Approval Rule.

---

# Relationships

Vote

↓

Proposal

Vote

↓

Trip Membership

Vote

↓

Decision

Vote

↓

Discussion Context

Vote

↓

Audit Events

---

# Vote Decisions

Approve

Approve With Conditions

Reject

Abstain

Need More Information

Delegate (Future)

---

# Confidence Levels

Very Low

Low

Medium

High

Very High

---

# Required Fields

Vote ID

Proposal ID

Member ID

Decision

Submitted At

---

# Optional Fields

Reason

Conditions

Suggested Changes

Confidence

Attachments

AI Summary

Edited At

---

# Conditional Approval

Examples

Approve if

Budget ≤ ₹20,000

Approve if

Hotel Rating ≥ 4.5

Approve if

Travel starts after 8 AM

Approve if

Everyone agrees

---

Conditions are evaluated by the Decision Engine.

---

# Suggested Changes

Members may suggest

Alternative Hotel

Different Route

Lower Budget

Different Date

Additional Activity

Reduced Cost

Extra Rest Stop

Custom Suggestions

---

# Confidence

Measures how strongly the member supports the decision.

Can be used by AI to detect uncertainty.

---

# AI Integration

AI Uses

Vote Reasons

Conditions

Confidence

Suggested Changes

Proposal Context

Discussion History

---

AI Can

Summarize objections

Identify common concerns

Suggest compromise options

Group similar feedback

Highlight conflicting conditions

---

AI Never

Cast votes

Modify votes

Override member decisions

---

# Knowledge Graph

Graph Node

Yes

Node Type

Vote

---

Relationships

CAST_BY

RESPONDS_TO

SUPPORTS

REJECTS

CONDITIONS

SUGGESTS

---

Embeddings

Generated

Used for semantic analysis of voting patterns.

---

# Search Support

Search By

Proposal

Member

Decision

Conditions

Confidence

Semantic Search

---

# Realtime Support

Vote Submitted

Vote Updated

Vote Locked

Consensus Progress Updated

AI Summary Updated

---

# Events

VoteCreated

VoteSubmitted

VoteUpdated

VoteLocked

VoteWithdrawn

ConsensusThresholdReached

---

# Audit Strategy

Track

Submission

Edits

Conditions

Reason Changes

Confidence Changes

Locking

---

# Database Ownership

Schema

consensus

---

Table

votes

---

Primary Key

UUID v7

---

Indexes

Proposal ID

Member ID

Decision

Submitted At

---

Unique Constraints

Proposal ID + Member ID

---

# Database Columns

vote_id

proposal_id

member_id

decision

confidence

reason

conditions

suggested_changes

ai_summary

submitted_at

updated_at

locked_at

metadata

---

# API Endpoints

GET

/proposals/{proposalId}/votes

POST

/proposals/{proposalId}/votes

PATCH

/votes/{voteId}

DELETE

/votes/{voteId}

POST

/votes/{voteId}/lock

---

# Performance Requirements

Vote Submission

<100 ms

Vote Update

<100 ms

Consensus Progress

<200 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Decision Validation

Conditions

Confidence

Permission Checks

Realtime Updates

Audit

Performance

---

# Future Evolution

Weighted Votes

Delegated Voting

Proxy Voting

Biometric Confirmation

Offline Voting

Cross-Organization Voting

Voice Voting

AI-Assisted Drafting (User Approval Required)

---

# Entity Summary

ENT-201 (Vote) captures a member's structured response to a Proposal.

Rather than reducing collaboration to simple approval or rejection, Atlas records decisions, confidence, reasoning, and conditions, enabling richer consensus workflows, AI-assisted compromise suggestions, and transparent decision making.

---

# Next Entity

ENT-202

Decision

Represents the final outcome produced by the Decision Engine after evaluating all votes, approval rules, deadlines, dependencies, and proposal revisions. It records the authoritative result and triggers execution of approved Change Sets.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 04
#
# CONSENSUS DOMAIN
#
# ENTITY CARD
#
# ENT-202
#
# DECISION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-202

---

Entity Name

Decision

---

Owner Module

Decision Engine

---

Bounded Context

Consensus Domain

---

Aggregate Root

No

Parent Aggregate

Proposal (ENT-200)

---

# Business Purpose

The Decision entity represents the official outcome of a Proposal after evaluation by the Decision Engine.

Unlike Votes, which express member opinions, a Decision is the authoritative system-generated result that determines whether a Proposal may be executed.

Every Proposal can produce one final Decision.

---

# Responsibilities

Decision Recording

Approval Result

Execution Authorization

Validation Results

Policy Enforcement

Audit

Workflow Trigger

Timeline Integration

---

# Does NOT Own

Proposal

Votes

Members

Trips

Activities

Budget

Change Sets

---

# Lifecycle

Pending

↓

Evaluating

↓

Resolved

↓

Executed

↓

Archived

---

Alternative Outcomes

Rejected

Expired

Cancelled

Superseded

---

# Business Rules

Each Proposal produces at most one active Decision.

A Decision becomes immutable once finalized.

Approved Decisions authorize Change Set execution.

Rejected Decisions never modify Trip data.

Superseded Decisions remain in history.

---

# Relationships

Decision

↓

Proposal

Decision

↓

Votes

Decision

↓

Approval Rule

Decision

↓

Change Set

Decision

↓

Timeline

Decision

↓

Audit Events

---

# Decision Outcomes

Approved

Rejected

Partially Approved (Future)

Expired

Cancelled

Needs Revision

Blocked

Deferred

---

# Required Fields

Decision ID

Proposal ID

Outcome

Created At

Resolved At

---

# Optional Fields

Reason

Evaluation Summary

Consensus Score

Execution Time

Failure Reason

Superseded By

AI Explanation

---

# Decision Evaluation

Inputs

Votes

Approval Rules

Proposal Version

Dependencies

Deadlines

Business Policies

Current Trip State

Organization Policies

---

Outputs

Decision

Execution Authorization

Failure Reason

Recommended Actions

Timeline Event

---

# Validation Rules

Decision evaluation checks

Required Participation

Approval Threshold

Role Requirements

Trip Status

Proposal Version

Dependency Completion

Policy Compliance

Time Constraints

---

If any validation fails

↓

Decision becomes

Blocked

or

Needs Revision

---

# Execution Authorization

Approved Decision

↓

Generate Execution Token

↓

Execute Change Set

↓

Commit Changes

↓

Record Timeline Event

↓

Archive Decision

---

Execution is atomic.

---

# AI Integration

AI Uses

Proposal

Votes

Discussion

Conditions

Dependencies

Trip Context

Policy Context

---

AI Can

Explain outcome

Summarize objections

Recommend revisions

Predict approval probability

Suggest compromise

---

AI Never

Override Decision

Approve proposals

Reject proposals

Ignore policies

---

# Knowledge Graph

Graph Node

Yes

Node Type

Decision

---

Relationships

RESOLVES

EXECUTES

REJECTS

APPROVES

GENERATES

REFERENCES

---

Embeddings

Generated

Supports semantic analysis of historical decisions.

---

# Search Support

Search By

Proposal

Outcome

Date

Consensus Score

Execution Status

Semantic Search

---

# Realtime Support

Decision Created

Decision Updated

Decision Finalized

Execution Started

Execution Completed

Execution Failed

---

# Events

DecisionCreated

DecisionResolved

DecisionApproved

DecisionRejected

ExecutionAuthorized

ExecutionCompleted

ExecutionFailed

---

# Audit Strategy

Track

Evaluation

Validation Results

Outcome

Execution

Failure

Rollback

AI Explanation

---

# Database Ownership

Schema

consensus

---

Table

decisions

---

Primary Key

UUID v7

---

Indexes

Proposal ID

Outcome

Execution Status

Resolved At

Created At

---

Unique Constraints

Proposal ID

---

# Database Columns

decision_id

proposal_id

outcome

consensus_score

evaluation_summary

validation_result

execution_status

failure_reason

resolved_at

created_at

updated_at

metadata

---

# API Endpoints

GET

/proposals/{proposalId}/decision

GET

/decisions/{decisionId}

POST

/decisions/{decisionId}/re-evaluate

GET

/decisions/history

---

# Performance Requirements

Decision Evaluation

<500 ms

Validation

<200 ms

Execution Authorization

<100 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Rule Evaluation

Validation

Execution Authorization

Rollback

Realtime

Audit

Performance

---

# Future Evolution

Multi-Stage Decisions

Cross-Trip Decisions

Organization Governance

Emergency Overrides

Delegated Decision Chains

Policy Simulation

Decision Replay

AI Decision Insights

---

# Entity Summary

ENT-202 (Decision) represents the authoritative outcome of a Proposal.

It is produced by the Decision Engine after evaluating votes, approval rules, dependencies, policies, deadlines, and business validations.

By separating Decisions from Votes, Atlas creates a deterministic, auditable, and extensible decision-making model that safely controls when collaborative changes are applied to a Trip Workspace.

---

# Next Entity

ENT-203

Approval Rule

Defines the policy used by the Decision Engine to determine whether a Proposal is approved, rejected, blocked, or requires revision. Rules support unanimous approval, majority voting, role-based approvals, deadlines, dependencies, and future custom strategies.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 04
#
# CONSENSUS DOMAIN
#
# ENTITY CARD
#
# ENT-203
#
# APPROVAL RULE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-203

---

Entity Name

Approval Rule

---

Owner Module

Rule Engine

---

Bounded Context

Consensus Domain

---

Aggregate Root

No

Parent Aggregate

Proposal (ENT-200)

May also inherit defaults from Trip Settings.

---

# Business Purpose

The Approval Rule defines how the Decision Engine evaluates a Proposal.

Rather than hardcoding approval logic, Atlas models decision policies as reusable Approval Rules.

These rules determine whether a Proposal is approved, rejected, blocked, expired, or requires revision.

---

# Responsibilities

Decision Policy

Threshold Evaluation

Role Validation

Dependency Validation

Deadline Enforcement

Participation Validation

Execution Authorization

Audit

---

# Does NOT Own

Proposal

Votes

Members

Decision

Trip

Timeline

---

# Lifecycle

Created

↓

Activated

↓

Evaluated

↓

Satisfied

↓

Archived

---

Rules are immutable while attached to an active Proposal.

---

# Business Rules

Every Proposal has one effective Approval Rule.

Rules may inherit defaults from Trip Settings.

Proposal-specific rules override trip defaults.

Organization policies override trip rules when required.

Rule evaluation must be deterministic.

---

# Relationships

Approval Rule

↓

Proposal

Approval Rule

↓

Decision

Approval Rule

↓

Votes

Approval Rule

↓

Trip Settings

Approval Rule

↓

Audit Events

---

# Rule Types

Unanimous

Simple Majority

Qualified Majority

Percentage Threshold

Role Based

Weighted (Future)

Time Limited

Sequential

Hybrid

Custom

---

# Required Fields

Rule ID

Proposal ID

Rule Type

Created At

---

# Optional Fields

Description

Approval Percentage

Required Roles

Voting Deadline

Minimum Participation

Dependency Rules

Custom Parameters

Priority

---

# Rule Configuration

Approval Threshold

Example

100%

75%

66%

51%

---

Minimum Participation

Example

100%

80%

50%

---

Voting Deadline

Absolute Date

Relative Duration

No Deadline

---

Required Roles

Owner

Treasurer

Planner

Safety Lead

Navigator

Custom Roles

---

# Dependency Rules

Proposal Dependencies

Activity Dependencies

Budget Dependencies

Checklist Dependencies

Trip Status

Weather Constraints

Custom Rules

---

Example

Adventure Activity

↓

Medical Checklist Completed

↓

Weather Safe

↓

Budget Available

↓

All Members Approved

---

# Deadline Policies

Expire Proposal

Auto Reject

Notify Members

Escalate

Reopen Voting

Extend Deadline

---

# Evaluation Inputs

Votes

Trip State

Proposal Version

Dependencies

Policies

Deadlines

Member Eligibility

Role Assignments

---

# Evaluation Outputs

Approved

Rejected

Blocked

Needs Revision

Expired

Cancelled

Waiting

---

# AI Integration

AI Uses

Approval History

Rule Performance

Proposal Context

Participation

Deadlines

Dependencies

---

AI Can

Predict approval likelihood

Recommend rule adjustments

Identify missing participants

Suggest deadline extensions

Explain failures

---

AI Never

Modify rules

Approve proposals

Bypass required approvals

---

# Knowledge Graph

Graph Node

Yes

Node Type

ApprovalRule

---

Relationships

APPLIES_TO

EVALUATES

REQUIRES

DEPENDS_ON

CONFIGURES

---

Embeddings

No

Rules remain deterministic configuration.

---

# Search Support

Search By

Rule Type

Threshold

Proposal

Trip

Status

---

# Realtime Support

Rule Activated

Rule Evaluated

Threshold Reached

Deadline Warning

Deadline Expired

Evaluation Completed

---

# Events

ApprovalRuleCreated

ApprovalRuleActivated

ThresholdReached

DeadlineApproaching

DeadlineExpired

EvaluationCompleted

RuleArchived

---

# Audit Strategy

Track

Rule Creation

Configuration

Evaluation

Threshold Changes

Deadline Events

Execution Authorization

---

# Database Ownership

Schema

consensus

---

Table

approval_rules

---

Primary Key

UUID v7

---

Indexes

Proposal ID

Rule Type

Created At

Deadline

---

Unique Constraints

Proposal ID

---

# Database Columns

rule_id

proposal_id

rule_type

approval_threshold

minimum_participation

required_roles

deadline

dependency_rules

priority

status

metadata

created_at

updated_at

---

# API Endpoints

GET

/proposals/{proposalId}/approval-rule

PATCH

/proposals/{proposalId}/approval-rule

POST

/proposals/{proposalId}/approval-rule/evaluate

GET

/approval-rules/templates

---

# Performance Requirements

Rule Evaluation

<200 ms

Threshold Calculation

<100 ms

Dependency Validation

<150 ms

Realtime Update

<250 ms

---

# Testing Requirements

Threshold Logic

Role Validation

Dependency Checks

Deadline Handling

Deterministic Evaluation

Performance

---

# Future Evolution

Visual Rule Builder

Organization Policy Packs

Conditional Rules

Marketplace Rule Templates

Simulation Mode

AI Rule Advisor

Versioned Rule Libraries

---

# Entity Summary

ENT-203 (Approval Rule) defines the policy used by the Decision Engine to evaluate collaborative proposals.

By modeling approval logic as configurable rules instead of application code, Atlas supports unanimous approval, majority voting, role-based governance, and future custom decision strategies while keeping the platform extensible and consistent.

---

# Next Entity

ENT-204

Consensus Session

Represents the active collaborative decision-making process for a Proposal, coordinating discussion, voting, realtime presence, deadlines, reminders, AI facilitation, and overall progress toward consensus.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 04
#
# CONSENSUS DOMAIN
#
# ENTITY CARD
#
# ENT-204
#
# CONSENSUS SESSION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-204

---

Entity Name

Consensus Session

---

Owner Module

Consensus Engine

---

Bounded Context

Consensus Domain

---

Aggregate Root

No

Parent Aggregate

Proposal (ENT-200)

---

# Business Purpose

A Consensus Session represents the active collaborative decision-making process surrounding a Proposal.

Unlike Chat, which is continuous, a Consensus Session exists only while members are working toward a decision.

It coordinates discussions, revisions, reminders, realtime collaboration, AI facilitation, voting, and decision progress.

---

# Responsibilities

Consensus Coordination

Realtime Collaboration

Discussion Context

Progress Tracking

Revision Coordination

Reminder Scheduling

Deadline Management

AI Facilitation

Session Analytics

---

# Does NOT Own

Proposal

Votes

Messages

Members

Decision

Timeline

---

# Lifecycle

Created

↓

Opened

↓

Discussion

↓

Voting

↓

Evaluating

↓

Completed

↓

Closed

↓

Archived

---

Alternative States

Expired

Cancelled

Paused

---

# Business Rules

Each Proposal has one active Consensus Session.

Only active members may participate.

Closed sessions become read-only.

Votes cannot be submitted after the session closes.

Proposal revisions reopen the session.

---

# Relationships

Consensus Session

↓

Proposal

Consensus Session

↓

Votes

Consensus Session

↓

Discussion Context

Consensus Session

↓

Timeline

Consensus Session

↓

Decision

Consensus Session

↓

AI Analysis

---

# Session States

Preparing

Discussion

Revision

Voting

Waiting

Evaluating

Completed

Closed

---

# Required Fields

Session ID

Proposal ID

Status

Opened At

Created At

---

# Optional Fields

Deadline

Description

Facilitator

AI Summary

Reminder Policy

Priority

Session Notes

---

# Participation

Session tracks

Active Members

Online Members

Members Yet To Respond

Observers

Moderators

AI Assistant

---

# Progress Tracking

Discussion Progress

Participation Rate

Voting Progress

Consensus Score

Pending Members

Deadline Remaining

Revision Count

---

Displayed live.

---

# Reminder Policies

Manual

Automatic

Daily

Hourly

Before Deadline

Escalation

Custom

---

# Deadline Management

Session Deadline

↓

Reminder

↓

Grace Period

↓

Automatic Evaluation

↓

Close Session

---

# AI Integration

AI Facilitates

Summarize discussion

Detect repeated arguments

Suggest compromise

Identify unanswered questions

Recommend proposal revisions

Highlight blockers

Generate meeting summary

---

AI cannot

Vote

Approve

Reject

Close the session

Override members

---

# Knowledge Graph

Graph Node

Yes

Node Type

ConsensusSession

---

Relationships

CONTAINS

FACILITATES

LEADS_TO

GENERATES

HAS_DECISION

---

Embeddings

Generated

Used for historical collaboration analysis.

---

# Search Support

Search By

Proposal

Status

Participants

Deadline

Consensus Score

Semantic Search

---

# Realtime Support

Session Opened

Member Joined

Member Left

Discussion Updated

Reminder Sent

Voting Started

Consensus Updated

Session Closed

---

# Events

ConsensusSessionCreated

ConsensusSessionOpened

DiscussionStarted

VotingOpened

ConsensusProgressUpdated

ReminderTriggered

SessionCompleted

SessionClosed

---

# Audit Strategy

Track

Session Open

Participation

Discussion Start

Voting Start

Deadlines

Reminders

Closure

AI Summaries

---

# Database Ownership

Schema

consensus

---

Table

consensus_sessions

---

Primary Key

UUID v7

---

Indexes

Proposal ID

Status

Deadline

Opened At

Created At

---

Unique Constraints

Proposal ID

---

# Database Columns

session_id

proposal_id

status

deadline

opened_at

closed_at

consensus_score

participation_rate

discussion_summary

ai_summary

metadata

created_at

updated_at

---

# API Endpoints

GET

/proposals/{proposalId}/session

POST

/proposals/{proposalId}/session/open

POST

/proposals/{proposalId}/session/close

PATCH

/proposals/{proposalId}/session

GET

/proposals/{proposalId}/session/progress

---

# Performance Requirements

Session Lookup

<20 ms

Progress Update

<100 ms

Realtime Broadcast

<200 ms

Consensus Calculation

<300 ms

---

# Testing Requirements

Lifecycle

Realtime

Participation

Deadlines

Reminders

AI Summaries

Validation

Performance

---

# Future Evolution

Voice Discussions

Live Whiteboards

Video Rooms

AI Moderation

Meeting Minutes

Scheduled Consensus Sessions

Cross-Trip Sessions

Organization Governance Sessions

---

# Entity Summary

ENT-204 (Consensus Session) represents the active collaboration workspace where members work toward a shared decision.

Rather than treating voting as an isolated action, Atlas models consensus as a structured process that includes discussion, revisions, AI facilitation, reminders, and realtime participation before a final Decision is produced.

---

# Next Entity

ENT-205

Discussion Context

Represents the structured conversation associated with a Proposal, including threaded discussions, mentions, attachments, AI summaries, reactions, and revision history while remaining independent from the general Trip Chat.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 04
#
# CONSENSUS DOMAIN
#
# ENTITY CARD
#
# ENT-205
#
# PROPOSAL DISCUSSION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-205

---

Entity Name

Proposal Discussion

---

Owner Module

Consensus Engine

---

Bounded Context

Consensus Domain

---

Aggregate Root

No

Parent Aggregate

Consensus Session (ENT-204)

---

# Business Purpose

Proposal Discussion represents the structured conversation surrounding a Proposal.

Unlike the Trip Chat, which supports casual communication, Proposal Discussions are purpose-built for collaborative decision-making.

Every discussion is permanently linked to one Proposal and captures the complete reasoning behind the final decision.

---

# Responsibilities

Discussion

Threading

Mentions

Attachments

Proposal Feedback

AI Summaries

Decision Context

Revision Suggestions

Audit

Knowledge Capture

---

# Does NOT Own

Proposal

Votes

Decision

Trip

Messages

Timeline

Members

---

# Lifecycle

Created

↓

Open

↓

Active

↓

Resolved

↓

Locked

↓

Archived

---

Proposal Discussions reopen automatically when a Proposal is revised.

---

# Business Rules

Each Proposal has one Discussion.

Discussion is read-only after Proposal execution.

Members may edit their own comments for a configurable time.

Administrators may moderate discussions.

Attachments remain linked permanently.

---

# Relationships

Proposal Discussion

↓

Proposal

Proposal Discussion

↓

Consensus Session

Proposal Discussion

↓

Discussion Comments

Proposal Discussion

↓

AI Summaries

Proposal Discussion

↓

Timeline

Proposal Discussion

↓

Decision

---

# Discussion Components

Comments

Replies

Mentions

Attachments

Reactions

Resolution Notes

Pinned Comments

Decision Highlights

AI Summaries

---

# Required Fields

Discussion ID

Proposal ID

Session ID

Created At

---

# Optional Fields

Title

Summary

Pinned Comment

Resolution Note

Last Activity

Discussion Tags

---

# Threading

Unlimited reply depth

Quote support

Resolved threads

Pinned threads

Hidden moderator notes

Future collaborative editing

---

# Mentions

Individual Member

Role

Entire Group

Trip Owner

Planner

Treasurer

Safety Lead

Future AI Assistant

---

# Attachments

Images

PDF

Receipts

Maps

Route Screenshots

Budget Files

Videos

Voice Notes

Future 3D Models

---

# Reactions

Approve 👍

Concern ⚠️

Question ❓

Idea 💡

Love ❤️

Important 📌

Custom (Future)

---

# Resolution Notes

Discussion may conclude with

Accepted

Rejected

Deferred

Needs More Information

Merged Into Another Proposal

Cancelled

---

# AI Integration

AI Uses

Entire Discussion

Proposal History

Vote Reasons

Attachments

Revision History

Member Feedback

---

AI Can

Summarize discussion

Highlight unanswered questions

Cluster similar comments

Suggest revisions

Detect repeated concerns

Generate executive summary

Extract action items

---

AI Never

Delete comments

Modify messages

Vote

Approve proposals

---

# Knowledge Graph

Graph Node

Yes

Node Type

ProposalDiscussion

---

Relationships

DISCUSSES

SUPPORTS

QUESTIONS

MENTIONS

REFERENCES

GENERATES

---

Embeddings

Generated

Entire discussion embedded for semantic search.

---

# Search Support

Search By

Proposal

Comment

Author

Mention

Attachment

Semantic Search

Natural Language Search

---

# Realtime Support

Comment Added

Reply Added

Reaction Added

Mention Triggered

AI Summary Updated

Discussion Locked

---

# Events

DiscussionCreated

CommentAdded

CommentEdited

CommentDeleted

ReactionAdded

MentionCreated

SummaryGenerated

DiscussionResolved

DiscussionLocked

---

# Audit Strategy

Track

Comments

Edits

Mentions

Attachments

Moderation

AI Summaries

Resolution

---

# Database Ownership

Schema

consensus

---

Table

proposal_discussions

---

Primary Key

UUID v7

---

Indexes

Proposal ID

Session ID

Last Activity

Created At

---

Unique Constraints

Proposal ID

---

# Database Columns

discussion_id

proposal_id

session_id

title

summary

resolution_note

last_activity

comment_count

ai_summary

metadata

created_at

updated_at

---

# API Endpoints

GET

/proposals/{proposalId}/discussion

POST

/proposals/{proposalId}/discussion/comments

PATCH

/discussions/{discussionId}

GET

/discussions/{discussionId}/summary

POST

/discussions/{discussionId}/resolve

---

# Performance Requirements

Discussion Load

<200 ms

Comment Creation

<100 ms

Realtime Broadcast

<200 ms

AI Summary

<2 sec

Semantic Search

<400 ms

---

# Testing Requirements

Threading

Mentions

Attachments

Realtime

AI Summaries

Moderation

Validation

Performance

---

# Future Evolution

Collaborative Editing

Voice Threads

Video Discussions

Live Whiteboard

Translation

Cross-Proposal References

AI Debate Assistant

Meeting Transcripts

---

# Entity Summary

ENT-205 (Proposal Discussion) provides the structured collaboration space where members explain opinions, negotiate changes, ask questions, and build consensus before a Proposal is decided.

Unlike general chat, Proposal Discussions permanently preserve the reasoning behind collaborative decisions, creating valuable organizational knowledge for future planning, AI analysis, and auditing.

---

# End of Consensus Domain

Consensus Domain Entities

✓ ENT-200 Proposal

✓ ENT-201 Vote

✓ ENT-202 Decision

✓ ENT-203 Approval Rule

✓ ENT-204 Consensus Session

✓ ENT-205 Proposal Discussion

---

# Next Part

Volume 04

Part 05

Financial Domain

Entities

ENT-300 Budget

ENT-301 Expense

ENT-302 Expense Split

ENT-303 Settlement

ENT-304 Receipt

ENT-305 Currency Exchange

ENT-306 Financial Report

This domain will integrate directly with your OCR receipt scanning, duplicate bill detection, AI expense categorization, and group settlement ideas.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 05
#
# FINANCIAL DOMAIN
#
# ENTITY CARD
#
# ENT-300
#
# BUDGET
#
# ==============================================================================

# Entity Information

Entity ID

ENT-300

---

Entity Name

Budget

---

Owner Module

Financial Engine

---

Bounded Context

Financial Domain

---

Aggregate Root

Yes

Budget is the aggregate root for every financial entity within a Trip.

---

# Business Purpose

The Budget represents the financial workspace of a Trip.

Rather than being a simple spending limit, Atlas models the Budget as a living financial system that continuously tracks planned spending, actual spending, settlements, forecasts, receipts, AI recommendations, and financial health.

Every financial operation performed during a Trip ultimately belongs to exactly one Budget.

---

# Responsibilities

Budget Planning

Expense Management

Financial Forecasting

Currency Management

Settlement Coordination

Financial Analytics

AI Budget Assistant

Alerts

Reporting

Audit

---

# Does NOT Own

Trip

Members

Activities

Receipts

Expenses

These reference the Budget.

---

# Lifecycle

Draft

↓

Planned

↓

Approved

↓

Active

↓

Monitoring

↓

Closed

↓

Archived

---

Alternative

Cancelled

---

# Business Rules

Every Trip owns exactly one Budget.

Budgets cannot exist independently.

Budget currency becomes immutable after activation.

Closing the Budget requires all settlements to be resolved or explicitly waived.

Budget history remains immutable after archival.

---

# Relationships

Budget

↓

Trip

Budget

↓

Expenses

Budget

↓

Expense Splits

Budget

↓

Settlements

Budget

↓

Receipts

Budget

↓

Financial Reports

Budget

↓

Currency Rates

Budget

↓

Timeline

Budget

↓

AI Insights

---

# Budget Categories

Accommodation

Transportation

Food

Fuel

Shopping

Activities

Entertainment

Emergency

Medical

Miscellaneous

Custom

---

Categories are configurable.

---

# Value Objects

Budget Name

Currency

Estimated Budget

Actual Spend

Remaining Budget

Spent Percentage

Risk Score

Forecast

Status

---

# Required Fields

Budget ID

Trip ID

Currency

Created At

---

# Optional Fields

Title

Description

Emergency Reserve

Maximum Spend

Daily Limit

Warning Threshold

Critical Threshold

Notes

---

# Budget Metrics

Estimated Budget

Allocated Budget

Actual Spend

Remaining

Committed Spend

Pending Spend

Forecast Spend

Average Daily Spend

Burn Rate

Savings

---

Calculated continuously.

---

# Budget States

Healthy

Warning

Critical

Exceeded

Closed

---

State updates automatically.

---

# Category Allocation

Accommodation

₹25,000

Food

₹12,000

Fuel

₹8,000

Activities

₹10,000

Emergency

₹5,000

Shopping

₹6,000

---

Configurable by users.

---

# Daily Budget

Daily Limit

Daily Spend

Remaining Today

Forecast Today

Budget Trend

---

Supports Day Plans.

---

# Financial Health

Inputs

Expenses

Receipts

Forecast

Remaining Days

Weather

Activities

Currency Changes

---

Outputs

Health Score

Risk Score

Recommendations

Warnings

---

# AI Integration

AI Uses

Expenses

Receipts

Trip Plan

Activities

Member Spending

Weather

Destination

Remaining Days

Budget History

Travel DNA

---

AI Can

Predict overspending

Suggest savings

Recommend cheaper alternatives

Suggest budget redistribution

Detect unusual spending

Recommend emergency reserve

Estimate remaining costs

---

AI Never

Modify financial records

Approve settlements

Delete expenses

---

# Knowledge Graph

Graph Node

Yes

Node Type

Budget

---

Relationships

CONTAINS

ALLOCATES

TRACKS

FUNDS

GENERATES

REPORTS

---

Embeddings

Generated

Supports semantic financial analysis.

---

# Search Support

Search By

Trip

Category

Currency

Status

Date

Semantic Search

---

# Realtime Support

Budget Updated

Threshold Reached

Expense Added

Forecast Changed

Health Score Updated

Settlement Completed

---

# Events

BudgetCreated

BudgetApproved

BudgetUpdated

BudgetExceeded

BudgetClosed

ForecastUpdated

HealthScoreChanged

---

# Audit Strategy

Track

Creation

Allocation

Threshold Changes

Forecast Updates

Closing

AI Recommendations

---

# Database Ownership

Schema

finance

---

Table

budgets

---

Primary Key

UUID v7

---

Indexes

Trip ID

Currency

Status

Created At

---

Unique Constraints

Trip ID

---

# Database Columns

budget_id

trip_id

currency

estimated_budget

allocated_budget

actual_spend

remaining_budget

emergency_reserve

warning_threshold

critical_threshold

health_score

forecast_amount

status

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/budget

POST

/trips/{tripId}/budget

PATCH

/trips/{tripId}/budget

POST

/trips/{tripId}/budget/close

GET

/trips/{tripId}/budget/forecast

GET

/trips/{tripId}/budget/analytics

---

# Performance Requirements

Budget Lookup

<20 ms

Health Calculation

<150 ms

Forecast Update

<300 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Budget Calculations

Forecasting

Threshold Alerts

Currency Handling

Realtime

Audit

Performance

---

# Future Evolution

Multi-Currency Budgets

Shared Organization Budgets

Predictive Budgeting

Investment Trips

Corporate Expense Policies

Budget Templates

Offline Financial Sync

Smart Contracts (Future)

---

# Entity Summary

ENT-300 (Budget) is the financial aggregate root of Project Atlas.

Instead of merely storing spending limits, it provides a comprehensive financial workspace that coordinates expenses, receipts, settlements, analytics, forecasting, and AI-driven recommendations throughout the lifecycle of a Trip.

---

# Next Entity

ENT-301

Expense

Represents a single financial transaction associated with a Trip, including OCR receipt ingestion, AI categorization, duplicate detection, member attribution, activity linkage, location linkage, and settlement information.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 05
#
# FINANCIAL DOMAIN
#
# ENTITY CARD
#
# ENT-301
#
# EXPENSE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-301

---

Entity Name

Expense

---

Owner Module

Financial Engine

---

Bounded Context

Financial Domain

---

Aggregate Root

No

Parent Aggregate

Budget (ENT-300)

---

# Business Purpose

An Expense represents one verified financial transaction that occurred during a Trip.

Rather than storing only monetary values, Atlas models an Expense as a complete financial event enriched with receipt intelligence, AI categorization, duplicate detection, geolocation, activity context, member attribution, and settlement information.

Every Expense contributes to budgeting, analytics, reimbursements, AI recommendations, and financial history.

---

# Responsibilities

Transaction Recording

Receipt Association

OCR Results

Duplicate Detection

AI Categorization

Settlement Tracking

Budget Updates

Financial Analytics

Audit

Timeline

---

# Does NOT Own

Budget

Receipts

Members

Activities

Locations

Currency Rates

Settlements

---

# Lifecycle

Captured

↓

OCR Processed

↓

Verified

↓

Categorized

↓

Split

↓

Settled

↓

Archived

---

Alternative

Rejected

Duplicate

Cancelled

Refunded

---

# Business Rules

Every Expense belongs to one Budget.

Every Expense has one payer.

Expenses may belong to one Activity.

Expenses may reference one Location.

Duplicate expenses cannot be finalized.

Verified expenses become immutable except through adjustment records.

---

# Relationships

Expense

↓

Budget

Expense

↓

Receipt

Expense

↓

Activity

Expense

↓

Location

Expense

↓

Expense Split

Expense

↓

Settlement

Expense

↓

Timeline

Expense

↓

AI Analysis

---

# Expense Categories

Accommodation

Food

Fuel

Transportation

Shopping

Entertainment

Medical

Emergency

Parking

Toll

Tickets

Miscellaneous

Custom

---

# Value Objects

Amount

Currency

Tax

Discount

Tip

Payment Method

Merchant

Category

Confidence Score

Duplicate Score

Verification Status

---

# Required Fields

Expense ID

Budget ID

Payer ID

Amount

Currency

Created At

---

# Optional Fields

Receipt ID

Activity ID

Location ID

Merchant Name

Notes

Tax

Discount

Tip

Invoice Number

Payment Reference

Tags

---

# Payment Methods

Cash

Credit Card

Debit Card

UPI

Bank Transfer

Wallet

Corporate Card

Other

---

# Verification

Manual

OCR

AI Assisted

Verified

Rejected

Duplicate

---

# Duplicate Detection

Signals

Receipt Hash

Merchant

Amount

Timestamp

OCR Similarity

Image Hash

Location

---

Duplicate Score

0–100

---

# OCR Pipeline

Receipt Image

↓

OCR

↓

Merchant Extraction

↓

Amount

↓

Date

↓

Tax

↓

Invoice Number

↓

Confidence

↓

User Review

---

# AI Integration

AI Uses

Receipt OCR

Category Prediction

Merchant Detection

Duplicate Detection

Budget Impact

Spending Trends

Anomaly Detection

Forecasting

---

AI Can

Suggest category

Extract merchant

Identify duplicate

Detect suspicious amount

Recommend split

Suggest activity

---

AI Never

Approve transactions

Modify amounts automatically

Delete expenses

---

# Knowledge Graph

Graph Node

Yes

Node Type

Expense

---

Relationships

PAID_BY

BELONGS_TO

OCCURRED_AT

FUNDS

REFERENCES

GENERATED_FROM_RECEIPT

---

Embeddings

Generated

Supports semantic financial search.

---

# Search Support

Search By

Merchant

Amount

Category

Member

Date

Location

Activity

Semantic Search

---

# Realtime Support

Expense Added

Expense Verified

Duplicate Found

Receipt Linked

Settlement Updated

Budget Updated

---

# Events

ExpenseCreated

ReceiptProcessed

ExpenseVerified

ExpenseCategorized

DuplicateDetected

ExpenseSplit

ExpenseSettled

ExpenseArchived

---

# Audit Strategy

Track

Creation

OCR Results

Verification

Category Changes

Splits

Settlement

Adjustments

---

# Database Ownership

Schema

finance

---

Table

expenses

---

Primary Key

UUID v7

---

Indexes

Budget ID

Payer ID

Category

Merchant

Expense Date

Activity ID

Location ID

---

# Database Columns

expense_id

budget_id

payer_id

receipt_id

activity_id

location_id

amount

currency

tax

discount

tip

merchant_name

category

payment_method

duplicate_score

confidence_score

verification_status

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/expenses

GET

/expenses/{expenseId}

POST

/trips/{tripId}/expenses

PATCH

/expenses/{expenseId}

POST

/expenses/{expenseId}/verify

POST

/expenses/{expenseId}/split

GET

/expenses/search

---

# Performance Requirements

Expense Creation

<150 ms

OCR Processing

<5 sec

Duplicate Detection

<500 ms

Category Prediction

<500 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

OCR

Duplicate Detection

Verification

Budget Updates

Settlement

Realtime

Performance

---

# Future Evolution

Automatic Bank Import

Card Statement Matching

GST/VAT Extraction

Corporate Expense Policies

Offline OCR

Multi-Receipt Expenses

Recurring Expenses

Smart Reimbursements

---

# Entity Summary

ENT-301 (Expense) represents the fundamental financial event within Project Atlas.

It combines transaction data with receipt intelligence, AI-powered categorization, duplicate detection, location and activity context, and settlement tracking, creating a comprehensive financial record that powers budgeting, analytics, reimbursements, and AI recommendations.

---

# Next Entity

ENT-302

Expense Split

Represents how an Expense is distributed among trip members, supporting equal splits, percentage-based allocation, exact amounts, weighted shares, exclusions, custom rules, and future advanced settlement strategies.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 05
#
# FINANCIAL DOMAIN
#
# ENTITY CARD
#
# ENT-302
#
# EXPENSE SPLIT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-302

---

Entity Name

Expense Split

---

Owner Module

Settlement Engine

---

Bounded Context

Financial Domain

---

Aggregate Root

No

Parent Aggregate

Expense (ENT-301)

---

# Business Purpose

Expense Split defines how the financial responsibility of an Expense is allocated among Trip Members.

Rather than storing only calculated amounts, Atlas records the allocation strategy, calculation inputs, adjustments, and resulting obligations.

This enables transparent, flexible, and auditable cost sharing.

---

# Responsibilities

Cost Allocation

Split Strategy

Member Responsibility

Settlement Preparation

Balance Calculation

AI Recommendations

Audit

Financial Analytics

---

# Does NOT Own

Expense

Budget

Members

Settlements

Receipts

---

# Lifecycle

Created

↓

Calculated

↓

Reviewed

↓

Confirmed

↓

Settled

↓

Archived

---

Alternative

Recalculated

Cancelled

---

# Business Rules

Every Expense has one Split.

Every Split contains one or more Member Allocations.

Allocated amounts must equal the Expense total.

Recalculation creates a new split version.

Confirmed splits cannot be edited directly.

---

# Relationships

Expense Split

↓

Expense

Expense Split

↓

Member Allocations

Expense Split

↓

Settlement

Expense Split

↓

AI Analysis

Expense Split

↓

Audit Events

---

# Split Strategies

Equal

Exact Amount

Percentage

Weighted

Shares

Category Based

Role Based

Custom Formula

Excluded Members

Hybrid

---

# Examples

Equal

₹4,000

↓

₹1,000 × 4

---

Percentage

40%

30%

20%

10%

---

Weighted

Driver

40%

Passengers

20%

20%

20%

---

Exact Amount

Rahul

₹700

Vish

₹1,100

Others

Remaining

---

Hybrid

Accommodation

Equal

Fuel

Passengers

Parking

Driver

Meals

Custom

---

# Required Fields

Split ID

Expense ID

Strategy

Created At

---

# Optional Fields

Description

Notes

Calculation Version

AI Recommendation

Approval Status

Tags

---

# Member Allocation

Each Allocation contains

Member

Allocated Amount

Paid Amount

Outstanding

Status

Reason

Weight

Adjustment

---

# Validation Rules

Allocated Total

=

Expense Total

No Negative Allocation

No Duplicate Members

Valid Percentages

Valid Shares

---

# Recalculation

Allowed Until

Settlement Begins

Every recalculation creates

New Version

Audit Entry

Timeline Event

---

# Settlement Integration

Each Allocation generates

Financial Obligation

↓

Settlement Ledger

↓

Member Balance

↓

Final Settlement

---

# AI Integration

AI Uses

Trip History

Member Preferences

Expense Category

Past Splits

Transportation

Activities

Travel Style

---

AI Can

Recommend fair split

Detect imbalance

Suggest simplification

Reduce settlement count

Optimize reimbursements

Identify anomalies

---

AI Never

Modify confirmed allocations

Transfer money

Override user approval

---

# Knowledge Graph

Graph Node

Yes

Node Type

ExpenseSplit

---

Relationships

ALLOCATES

GENERATES

ASSIGNED_TO

SETTLED_BY

REFERENCES

---

Embeddings

Generated

Supports semantic financial analysis.

---

# Search Support

Search By

Expense

Member

Strategy

Outstanding Balance

Date

Semantic Search

---

# Realtime Support

Split Calculated

Split Updated

Allocation Changed

Settlement Updated

AI Recommendation

---

# Events

ExpenseSplitCreated

SplitCalculated

SplitConfirmed

SplitRecalculated

SettlementGenerated

AllocationUpdated

---

# Audit Strategy

Track

Strategy Changes

Allocation Changes

Recalculations

AI Suggestions

Confirmations

Settlement Generation

---

# Database Ownership

Schema

finance

---

Table

expense_splits

---

Primary Key

UUID v7

---

Indexes

Expense ID

Strategy

Created At

---

# Database Columns

split_id

expense_id

strategy

calculation_version

approval_status

ai_recommendation

metadata

created_at

updated_at

---

Child Table

member_allocations

Columns

allocation_id

split_id

member_id

allocated_amount

paid_amount

outstanding_amount

weight

adjustment

status

reason

created_at

updated_at

---

# API Endpoints

GET

/expenses/{expenseId}/split

POST

/expenses/{expenseId}/split

PATCH

/splits/{splitId}

POST

/splits/{splitId}/recalculate

GET

/splits/{splitId}/allocations

---

# Performance Requirements

Split Calculation

<100 ms

Recalculation

<200 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Allocation Validation

Strategy Logic

Recalculation

Settlement Generation

Realtime

Performance

---

# Future Evolution

Rule-Based Splits

AI Cost Optimizer

Automatic Passenger Detection

Vehicle Occupancy Integration

Corporate Cost Centers

Dynamic Shared Expenses

Tax Allocation Rules

---

# Entity Summary

ENT-302 (Expense Split) defines how the financial responsibility of an Expense is distributed among Trip Members.

By modeling allocation strategies rather than only final amounts, Atlas supports flexible cost sharing, transparent calculations, simplified settlements, and AI-assisted optimization while maintaining a complete audit history.

---

# Next Entity

ENT-303

Settlement

Represents the resolution of outstanding balances between members by calculating the minimum number of transactions required to settle all financial obligations within a Trip.


# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 05
#
# FINANCIAL DOMAIN
#
# ENTITY CARD
#
# ENT-303
#
# SETTLEMENT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-303

---

Entity Name

Settlement

---

Owner Module

Settlement Engine

---

Bounded Context

Financial Domain

---

Aggregate Root

No

Parent Aggregate

Budget (ENT-300)

---

# Business Purpose

A Settlement represents the process of resolving outstanding financial obligations between Trip Members.

Rather than recording a simple payment, Atlas models settlements as optimized financial resolutions that reduce the total number of transactions while maintaining complete financial accuracy and auditability.

---

# Responsibilities

Balance Resolution

Transaction Optimization

Payment Tracking

Settlement Verification

Ledger Updates

Audit

Financial History

AI Recommendations

---

# Does NOT Own

Budget

Expenses

Expense Splits

Members

Receipts

---

# Lifecycle

Generated

↓

Pending

↓

Scheduled

↓

In Progress

↓

Verified

↓

Completed

↓

Archived

---

Alternative States

Cancelled

Expired

Failed

Disputed

Partially Completed

---

# Business Rules

Every Settlement belongs to one Budget.

A Settlement may resolve multiple Expense Splits.

A Settlement may include multiple payment instructions.

Verified Settlements become immutable.

Failed Settlements never modify balances.

---

# Relationships

Settlement

↓

Budget

Settlement

↓

Expense Splits

Settlement

↓

Payment Instructions

Settlement

↓

Members

Settlement

↓

Financial Timeline

Settlement

↓

Audit Events

---

# Settlement Types

UPI

Cash

Bank Transfer

Wallet

Credit Adjustment

Refund

Mixed

Custom

---

# Required Fields

Settlement ID

Budget ID

Settlement Type

Created At

---

# Optional Fields

Description

Reference Number

Verification Method

Settlement Notes

AI Recommendation

Due Date

Tags

---

# Settlement States

Pending

Scheduled

Processing

Awaiting Verification

Completed

Partially Completed

Failed

Cancelled

Disputed

---

# Payment Instructions

Each Settlement contains

Payer

Receiver

Amount

Method

Reference

Status

Verification

---

One Settlement

↓

Multiple Payments

Supported

---

# Optimization

Settlement Engine minimizes

Number of Transactions

↓

Maintains

Financial Accuracy

↓

Produces

Payment Plan

---

# Verification

Manual

Payment Screenshot

Transaction ID

Bank Reference

Future API Verification

QR Confirmation

---

# Partial Settlements

Supported

Example

Debt

₹2,000

↓

Paid

₹1,000

↓

Remaining

₹1,000

---

# AI Integration

AI Uses

Outstanding Balances

Member History

Settlement Patterns

Trip Timeline

Travel Schedule

Departure Dates

---

AI Can

Recommend settlement timing

Reduce transactions

Detect unusual settlements

Predict disputes

Suggest payment grouping

Recommend payment methods

---

AI Never

Transfer money

Verify payments automatically

Modify balances

---

# Knowledge Graph

Graph Node

Yes

Node Type

Settlement

---

Relationships

RESOLVES

PAYS

RECEIVES

GENERATES

VERIFIED_BY

---

Embeddings

Generated

Supports financial reasoning.

---

# Search Support

Search By

Member

Settlement Status

Amount

Payment Method

Date

Semantic Search

---

# Realtime Support

Settlement Generated

Payment Completed

Verification Requested

Settlement Verified

Settlement Failed

---

# Events

SettlementCreated

SettlementOptimized

PaymentScheduled

PaymentCompleted

SettlementVerified

SettlementDisputed

SettlementClosed

---

# Audit Strategy

Track

Generation

Optimization

Payments

Verification

Disputes

Adjustments

Completion

---

# Database Ownership

Schema

finance

---

Table

settlements

---

Primary Key

UUID v7

---

Indexes

Budget ID

Settlement Status

Settlement Type

Created At

---

# Database Columns

settlement_id

budget_id

settlement_type

status

total_amount

optimization_score

verification_method

due_date

metadata

created_at

updated_at

---

Child Table

payment_instructions

Columns

instruction_id

settlement_id

payer_id

receiver_id

amount

payment_method

transaction_reference

verification_status

completed_at

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/settlements

GET

/settlements/{settlementId}

POST

/settlements/generate

POST

/settlements/{settlementId}/verify

PATCH

/payment-instructions/{instructionId}

---

# Performance Requirements

Settlement Generation

<300 ms

Optimization

<500 ms

Verification

<150 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

Optimization

Partial Payments

Verification

Ledger Accuracy

Realtime

Performance

---

# Future Evolution

UPI API Integration

Open Banking

Automatic Verification

Installment Settlements

Cross-Trip Settlements

Corporate Reimbursements

Blockchain Audit Trail

---

# Entity Summary

ENT-303 (Settlement) represents the optimized financial resolution of outstanding obligations between Trip Members.

Instead of simply recording payments, Atlas calculates the smallest set of transactions needed to settle balances, supports multiple payment methods and verification workflows, and maintains a complete financial audit trail.

---

# Next Entity

ENT-304

Receipt

Represents the original financial evidence associated with an Expense, including scanned images, OCR extraction, merchant detection, duplicate detection, AI analysis, verification status, and archival metadata.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 05
#
# FINANCIAL DOMAIN
#
# ENTITY CARD
#
# ENT-304
#
# RECEIPT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-304

---

Entity Name

Receipt

---

Owner Module

Receipt Intelligence Engine

---

Bounded Context

Financial Domain

---

Aggregate Root

No

Parent Aggregate

Expense (ENT-301)

---

# Business Purpose

A Receipt represents the original documentary evidence of a financial transaction.

Unlike traditional expense applications that treat receipts as image attachments, Atlas models Receipts as intelligent financial documents containing structured information extracted through OCR, AI analysis, and document processing.

Receipts provide traceability, verification, auditing, analytics, and automatic expense generation.

---

# Responsibilities

Document Storage

OCR Processing

Merchant Detection

Line Item Extraction

Tax Extraction

Duplicate Detection

Fraud Detection

Expense Generation

Verification

Archive

---

# Does NOT Own

Expense

Budget

Members

Settlements

Reports

---

# Lifecycle

Captured

↓

Uploaded

↓

Image Enhanced

↓

OCR Processed

↓

AI Analyzed

↓

Verified

↓

Linked

↓

Archived

---

Alternative

Rejected

Duplicate

Unreadable

Corrupted

Fraud Suspected

---

# Business Rules

Every Receipt belongs to one Expense.

Receipt images remain immutable.

OCR may be reprocessed.

Verification history is preserved.

Duplicate receipts cannot create new expenses without confirmation.

---

# Relationships

Receipt

↓

Expense

Receipt

↓

OCR Result

Receipt

↓

AI Analysis

Receipt

↓

Duplicate Detection

Receipt

↓

Timeline

Receipt

↓

Audit Events

---

# Receipt Types

Retail

Restaurant

Fuel

Hotel

Parking

Toll

Medical

Transport

Shopping

Invoice

Custom

---

# Required Fields

Receipt ID

Expense ID

Captured At

Original Image

Created At

---

# Optional Fields

Thumbnail

Merchant Logo

Notes

GPS Location

Camera Metadata

Scan Quality

Document Language

Tags

---

# OCR Extraction

Merchant

Invoice Number

Date

Time

Subtotal

Tax

Discount

Tip

Grand Total

Currency

Payment Method

Phone

Address

Website

GST/VAT Number

Line Items

---

Each extracted field includes

Confidence Score

---

# Line Items

Name

Quantity

Unit Price

Discount

Tax

Total

Category

Confidence

---

Supports future analytics.

---

# Image Processing

Auto Crop

Perspective Correction

Noise Removal

Brightness

Contrast

Sharpening

Compression

Quality Score

---

# Duplicate Detection

Checks

Image Hash

OCR Similarity

Merchant

Invoice Number

Amount

Timestamp

GPS

---

Outputs

Duplicate Score

0–100

---

# Fraud Detection

Suspicious Total

Repeated Invoice

Edited Image

Invalid Tax

Impossible Timestamp

Merchant Mismatch

---

Produces

Risk Score

---

# Verification

Automatic

Manual

AI Assisted

Rejected

Needs Review

Verified

---

# AI Integration

AI Uses

OCR

Merchant Database

Trip Context

Budget

Location

Activities

Past Receipts

Spending Patterns

---

AI Can

Categorize merchant

Extract fields

Identify duplicates

Estimate missing values

Detect fraud

Generate expense draft

Suggest category

---

AI Never

Modify verified receipt

Approve fraudulent data

Delete documents

---

# Knowledge Graph

Graph Node

Yes

Node Type

Receipt

---

Relationships

GENERATED

PROVES

BELONGS_TO

SCANNED_AT

REFERENCES

---

Embeddings

Generated

Supports semantic receipt search.

---

# Search Support

Search By

Merchant

Invoice Number

Amount

Date

Category

OCR Text

Semantic Search

---

# Realtime Support

Receipt Uploaded

OCR Completed

Duplicate Found

Verification Requested

Expense Generated

Receipt Archived

---

# Events

ReceiptCaptured

ReceiptUploaded

OCRCompleted

ReceiptVerified

DuplicateDetected

ExpenseGenerated

ReceiptArchived

---

# Audit Strategy

Track

Upload

OCR Versions

Verification

Duplicate Detection

Fraud Detection

Expense Linking

Archive

---

# Database Ownership

Schema

finance

---

Table

receipts

---

Primary Key

UUID v7

---

Indexes

Expense ID

Merchant

Invoice Number

Captured At

Verification Status

---

# Database Columns

receipt_id

expense_id

original_image

thumbnail

merchant_name

invoice_number

receipt_type

captured_at

ocr_status

verification_status

duplicate_score

fraud_score

quality_score

metadata

created_at

updated_at

---

Child Table

receipt_line_items

Columns

line_item_id

receipt_id

name

quantity

unit_price

discount

tax

total

category

confidence

created_at

updated_at

---

# API Endpoints

GET

/receipts/{receiptId}

POST

/receipts/upload

POST

/receipts/{receiptId}/ocr

POST

/receipts/{receiptId}/verify

GET

/receipts/search

GET

/receipts/{receiptId}/line-items

---

# Performance Requirements

Upload

<2 sec

OCR

<5 sec

Duplicate Detection

<500 ms

Fraud Detection

<500 ms

Expense Generation

<300 ms

Realtime Broadcast

<250 ms

---

# Testing Requirements

OCR Accuracy

Line Item Extraction

Duplicate Detection

Fraud Detection

Verification

Performance

---

# Future Evolution

Multi-Page Receipts

Digital Receipts

Email Receipt Import

Bank Statement Matching

GST Invoice Validation

Warranty Tracking

Carbon Footprint Estimation

Receipt Translation

---

# Entity Summary

ENT-304 (Receipt) represents the intelligent financial document underlying an Expense.

By combining image processing, OCR, AI analysis, duplicate detection, fraud detection, and structured financial extraction, Atlas transforms receipts from passive attachments into rich sources of financial intelligence that power budgeting, analytics, auditing, and automation.

---

# Next Entity

ENT-305

Currency Exchange

Represents exchange rates, currency conversions, historical rates, and multi-currency calculations used throughout the financial system to ensure consistent budgeting, expense tracking, settlements, and reporting across international trips.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 05
#
# FINANCIAL DOMAIN
#
# ENTITY CARD
#
# ENT-305
#
# CURRENCY EXCHANGE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-305

---

Entity Name

Currency Exchange

---

Owner Module

Currency Intelligence Engine

---

Bounded Context

Financial Domain

---

Aggregate Root

No

Parent Aggregate

Budget (ENT-300)

---

# Business Purpose

Currency Exchange manages every currency conversion performed inside Project Atlas.

Rather than simply converting monetary values, Atlas records historical exchange rates, conversion sources, timestamps, confidence, and conversion metadata to ensure financial consistency across budgeting, expenses, settlements, reporting, and analytics.

Every conversion remains reproducible regardless of future market changes.

---

# Responsibilities

Exchange Rate Management

Historical Conversion

Live Conversion

Budget Normalization

Settlement Normalization

Financial Reporting

AI Currency Analysis

Audit

---

# Does NOT Own

Budget

Expenses

Settlements

Receipts

Reports

---

# Lifecycle

Rate Imported

↓

Validated

↓

Published

↓

Used

↓

Archived

---

Historical rates are never modified.

Corrections create new records.

---

# Business Rules

Every Trip has one Base Currency.

Every converted value references the exchange rate used.

Historical rates remain immutable.

Live rates never overwrite historical rates.

Offline trips may use cached exchange rates.

---

# Relationships

Currency Exchange

↓

Budget

Currency Exchange

↓

Expenses

Currency Exchange

↓

Settlements

Currency Exchange

↓

Financial Reports

Currency Exchange

↓

Audit Events

---

# Exchange Sources

Central Bank

Commercial API

Manual Entry

Corporate Policy

Offline Cache

Custom Source

---

# Required Fields

Exchange ID

Source Currency

Target Currency

Exchange Rate

Effective Time

Created At

---

# Optional Fields

Source

Confidence

Provider

Market Timestamp

Expiration

Import Batch

Notes

---

# Conversion Strategy

Original Amount

↓

Historical Rate

↓

Trip Base Currency

↓

Reporting Currency

↓

Analytics Currency

---

Supports

Multiple reporting currencies.

---

# Supported Currencies

ISO 4217

Examples

INR

USD

EUR

JPY

GBP

AUD

CAD

AED

CHF

SGD

Custom (Future)

---

# Historical Conversion

Every Expense stores

Original Amount

Original Currency

Historical Rate

Converted Amount

Rate Timestamp

---

Historical reports always reproduce correctly.

---

# Rate Freshness

Live

Cached

Historical

Manual

Expired

Unknown

---

# Offline Support

Cached Rates

Manual Override

Deferred Synchronization

Conflict Detection

---

# AI Integration

AI Uses

Exchange Trends

Trip Destination

Budget

Forecast

Historical Rates

Inflation

Regional Pricing

---

AI Can

Predict currency impact

Warn about volatility

Recommend exchange timing

Estimate future spending

Suggest reserve budget

---

AI Never

Modify financial history

Replace historical rates

---

# Knowledge Graph

Graph Node

Yes

Node Type

CurrencyExchange

---

Relationships

CONVERTS

NORMALIZES

REFERENCES

GENERATED_BY

---

Embeddings

No

Exchange rates remain deterministic numeric data.

---

# Search Support

Search By

Currency Pair

Date

Provider

Trip

Historical Period

---

# Realtime Support

Rate Updated

Cache Refreshed

Manual Override

Rate Expired

Conversion Completed

---

# Events

ExchangeRateImported

ExchangeRateValidated

ConversionPerformed

RateExpired

ManualRateApplied

HistoricalRateArchived

---

# Audit Strategy

Track

Imports

Corrections

Conversions

Manual Overrides

Cache Usage

Provider Changes

---

# Database Ownership

Schema

finance

---

Table

currency_exchange_rates

---

Primary Key

UUID v7

---

Indexes

Source Currency

Target Currency

Effective Time

Provider

Created At

---

Unique Constraints

Source Currency

Target Currency

Effective Time

---

# Database Columns

exchange_id

source_currency

target_currency

exchange_rate

provider

confidence

effective_time

expiration_time

source_type

metadata

created_at

updated_at

---

# API Endpoints

GET

/currency/rates

GET

/currency/convert

POST

/currency/import

GET

/currency/history

GET

/currency/providers

---

# Performance Requirements

Conversion

<20 ms

Historical Lookup

<50 ms

Batch Import

<3 sec

Realtime Update

<250 ms

---

# Testing Requirements

Historical Accuracy

Conversion Precision

Offline Cache

Provider Validation

Performance

---

# Future Evolution

Cryptocurrency Support

Central Bank APIs

Corporate Rates

Predictive FX

Travel Card Rates

Cash vs Card Comparison

Regional Purchasing Power Index

---

# Entity Summary

ENT-305 (Currency Exchange) provides the financial normalization layer for Project Atlas.

By preserving historical exchange rates, supporting live and offline conversions, and maintaining reproducible financial calculations, Atlas ensures that budgeting, settlements, analytics, and reporting remain accurate even across multi-country trips and changing exchange markets.

---

# Next Entity

ENT-306

Financial Report

Represents aggregated financial insights generated from Budgets, Expenses, Receipts, Settlements, and Currency Exchange data, providing dashboards, analytics, AI summaries, forecasts, and exportable financial statements.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 05
#
# FINANCIAL DOMAIN
#
# ENTITY CARD
#
# ENT-306
#
# FINANCIAL REPORT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-306

---

Entity Name

Financial Report

---

Owner Module

Financial Intelligence Engine

---

Bounded Context

Financial Domain

---

Aggregate Root

No

Parent Aggregate

Budget (ENT-300)

---

# Business Purpose

A Financial Report represents an aggregated analytical view of a Trip's financial activity.

Unlike traditional expense summaries, Atlas Financial Reports combine budgeting, expenses, receipts, settlements, forecasts, AI insights, exchange rates, and financial trends into a comprehensive decision-support document.

Reports are generated on demand or continuously updated throughout the lifecycle of the Trip.

---

# Responsibilities

Financial Analytics

Budget Reporting

Forecasting

Settlement Analysis

Expense Trends

Category Analysis

Currency Normalization

AI Insights

Export

Audit

---

# Does NOT Own

Budget

Expenses

Receipts

Settlements

Currency Exchange

Members

---

# Lifecycle

Generated

↓

Published

↓

Viewed

↓

Exported

↓

Archived

---

Reports are immutable once published.

New reports generate new versions.

---

# Business Rules

Every report references exactly one Budget.

Reports never modify financial data.

Historical reports always use historical exchange rates.

AI insights are advisory only.

Reports are reproducible.

---

# Relationships

Financial Report

↓

Budget

Financial Report

↓

Expenses

Financial Report

↓

Settlements

Financial Report

↓

Currency Exchange

Financial Report

↓

AI Insights

Financial Report

↓

Timeline

---

# Report Types

Trip Summary

Daily Report

Category Analysis

Member Contributions

Settlement Report

Budget Health

Forecast

Executive Summary

Audit Report

Custom

---

# Required Fields

Report ID

Budget ID

Report Type

Generated At

Created At

---

# Optional Fields

Title

Description

Reporting Period

Author

Version

Filters

Tags

Export Format

---

# Core Metrics

Estimated Budget

Actual Spend

Remaining Budget

Forecast Spend

Savings

Overspend

Emergency Reserve

Budget Utilization

Average Daily Spend

Burn Rate

---

# Category Analytics

Accommodation

Food

Transportation

Fuel

Shopping

Activities

Medical

Emergency

Custom Categories

---

Each category reports

Allocated

Spent

Remaining

Forecast

Variance

---

# Member Analytics

Paid

Owed

Received

Outstanding

Contribution %

Settlement Status

Average Spend

Expense Count

---

# Timeline Analytics

Daily Spend

Weekly Spend

Destination Spend

Activity Spend

Travel Day Cost

Peak Spending Day

Lowest Spending Day

---

# Settlement Analytics

Outstanding Balance

Completed Settlements

Pending Settlements

Failed Settlements

Average Settlement Time

Optimization Savings

---

# Forecasting

Remaining Trip Cost

Expected Daily Spend

Budget Exhaustion Date

Risk Probability

Confidence Score

Recommended Reserve

---

# AI Integration

AI Uses

Budget

Expenses

Receipts

Trip Plan

Activities

Weather

Currency Trends

Travel History

Travel DNA

---

AI Generates

Executive Summary

Budget Health

Savings Suggestions

Overspending Alerts

Category Insights

Member Spending Trends

Financial Risks

Recommendations

---

AI Never

Modify reports

Alter financial records

Approve transactions

---

# Knowledge Graph

Graph Node

Yes

Node Type

FinancialReport

---

Relationships

SUMMARIZES

ANALYZES

GENERATES

REPORTS_ON

REFERENCES

---

Embeddings

Generated

Supports semantic financial search and report comparison.

---

# Search Support

Search By

Trip

Report Type

Date

Category

Member

Semantic Search

---

# Realtime Support

Report Generated

Forecast Updated

AI Insight Updated

Budget Health Changed

Export Completed

---

# Events

FinancialReportGenerated

ForecastUpdated

BudgetRiskDetected

AIInsightGenerated

ReportExported

ReportArchived

---

# Audit Strategy

Track

Generation

Publication

Exports

AI Insights

Version Changes

Access History

---

# Database Ownership

Schema

finance

---

Table

financial_reports

---

Primary Key

UUID v7

---

Indexes

Budget ID

Report Type

Reporting Period

Generated At

Created At

---

# Database Columns

report_id

budget_id

report_type

report_version

reporting_period

budget_health_score

forecast_amount

risk_score

ai_summary

export_formats

metadata

generated_at

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/reports

GET

/reports/{reportId}

POST

/reports/generate

GET

/reports/{reportId}/export

GET

/reports/{reportId}/analytics

---

# Performance Requirements

Generate Summary

<2 sec

Forecast

<500 ms

Analytics Refresh

<1 sec

Export PDF

<5 sec

Realtime Update

<250 ms

---

# Testing Requirements

Analytics Accuracy

Historical Consistency

Forecasting

Currency Normalization

Exports

Performance

---

# Future Evolution

Interactive Dashboards

Scheduled Reports

Cross-Trip Analytics

Organization Reporting

Tax Reports

Carbon Footprint Reports

Open Financial API

Business Intelligence Connectors

---

# Entity Summary

ENT-306 (Financial Report) is the analytical output of the Atlas Financial Intelligence Engine.

Rather than serving as a static expense summary, it combines budgeting, spending, settlements, forecasting, exchange rates, and AI-generated insights into a comprehensive financial analysis that helps travelers understand, optimize, and review the financial performance of their trips.

---

# End of Financial Domain

Financial Domain Entities

✓ ENT-300 Budget

✓ ENT-301 Expense

✓ ENT-302 Expense Split

✓ ENT-303 Settlement

✓ ENT-304 Receipt

✓ ENT-305 Currency Exchange

✓ ENT-306 Financial Report

---

# Next Part

Volume 04

Part 06

Communication Domain

Entities

ENT-400 Chat Channel

ENT-401 Message

ENT-402 Attachment

ENT-403 Mention

ENT-404 Reaction

ENT-405 Notification

ENT-406 Announcement

The Communication Domain will power trip chat, proposal discussions, AI conversations, system notifications, announcements, mentions, media sharing, and realtime collaboration while remaining separate from the Consensus Domain.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 06
#
# COMMUNICATION DOMAIN
#
# ENTITY CARD
#
# ENT-400
#
# CONVERSATION
#
# =============================================================================

# Entity Information

Entity ID

ENT-400

---

Entity Name

Conversation

---

Owner Module

Conversation Engine

---

Bounded Context

Communication Domain

---

Aggregate Root

Yes

Conversation is the aggregate root for all communication.

---

# Business Purpose

A Conversation represents a structured communication space inside Project Atlas.

Rather than implementing separate chat systems for trip chat, proposal discussions, AI conversations, and announcements, Atlas models every communication channel as a specialized Conversation.

This creates one reusable communication platform for the entire application.

---

# Responsibilities

Communication

Realtime Messaging

Conversation Context

Permissions

History

Member Presence

Unread Tracking

Search

Synchronization

Audit

---

# Does NOT Own

Trip

Members

Activities

Proposals

Budget

Messages

Notifications

Attachments

---

# Lifecycle

Created

↓

Active

↓

Muted

↓

Archived

↓

Deleted

---

Alternative

Locked

Read Only

Hidden

---

# Business Rules

Every Conversation belongs to exactly one Workspace.

Conversation type cannot change after creation.

Messages belong to exactly one Conversation.

Archived conversations become read-only.

Permissions inherit from the parent workspace unless overridden.

---

# Relationships

Conversation

↓

Messages

Conversation

↓

Participants

Conversation

↓

Attachments

Conversation

↓

Mentions

Conversation

↓

Notifications

Conversation

↓

Read Receipts

Conversation

↓

Presence

Conversation

↓

Timeline

---

# Conversation Types

General

Proposal

AI Assistant

Budget

Activity

Emergency

Announcement

System

Support

Private (Future)

Custom

---

# Required Fields

Conversation ID

Trip ID

Conversation Type

Created At

---

# Optional Fields

Title

Description

Icon

Color

Parent Entity

Last Message

Last Activity

Pinned Message

Tags

---

# Parent Entity

A Conversation may belong to

Trip

Activity

Proposal

Budget

Settlement

Emergency

Announcement

System

Future Module

---

# Permissions

Everyone

Read Only

Owner Only

Role Based

Custom Members

Inherited

---

# Conversation States

Active

Muted

Archived

Locked

Read Only

Hidden

---

# Member Features

Unread Count

Typing Status

Online Status

Pinned Messages

Message Drafts

Bookmarks

Notification Preferences

---

# Realtime

Typing

Presence

Delivery

Read Receipts

Message Editing

Message Deletion

Live Synchronization

---

# AI Integration

AI Uses

Conversation History

Trip Context

Proposal Context

Activities

Budget

Timeline

Knowledge Graph

---

AI Can

Summarize conversations

Answer questions

Suggest replies

Find messages

Generate announcements

Extract action items

Translate messages

---

AI Never

Send messages automatically

Delete conversations

Modify history

Impersonate members

---

# Knowledge Graph

Graph Node

Yes

Node Type

Conversation

---

Relationships

CONTAINS

BELONGS_TO

REFERENCES

GENERATES

MENTIONS

---

Embeddings

Generated

Entire conversations indexed for semantic search.

---

# Search Support

Search By

Title

Message

Member

Date

Attachment

Semantic Search

Natural Language Search

---

# Realtime Support

Conversation Created

Conversation Updated

Conversation Archived

Member Joined

Member Left

Typing Started

Typing Stopped

Unread Updated

---

# Events

ConversationCreated

ConversationArchived

ConversationMuted

ParticipantJoined

ParticipantLeft

ConversationLocked

ConversationDeleted

---

# Audit Strategy

Track

Creation

Permission Changes

Membership

Archival

Deletion

Locking

AI Summaries

---

# Database Ownership

Schema

communication

---

Table

conversations

---

Primary Key

UUID v7

---

Indexes

Trip ID

Conversation Type

Last Activity

Created At

---

# Database Columns

conversation_id

trip_id

conversation_type

title

description

parent_entity_type

parent_entity_id

status

last_message_id

last_activity

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/conversations

GET

/conversations/{conversationId}

POST

/trips/{tripId}/conversations

PATCH

/conversations/{conversationId}

DELETE

/conversations/{conversationId}

---

# Performance Requirements

Conversation Load

<150 ms

Creation

<100 ms

Realtime Broadcast

<150 ms

Semantic Search

<300 ms

---

# Testing Requirements

Permissions

Realtime

Unread Counts

Search

Synchronization

Performance

Validation

---

# Future Evolution

Voice Conversations

Video Conversations

Collaborative Whiteboards

Live Translation

Conversation Templates

Cross-Trip Conversations

Organization Channels

Federated Messaging

---

# Entity Summary

ENT-400 (Conversation) is the communication aggregate root of Project Atlas.

Rather than implementing multiple disconnected chat systems, Atlas models every communication channel as a specialized Conversation. This unified architecture powers general trip discussions, proposal collaboration, AI interactions, budget conversations, emergency coordination, and future communication features through a single extensible platform.

---

# Next Entity

ENT-401

Message

Represents an individual communication event within a Conversation, supporting rich text, attachments, replies, edits, reactions, mentions, AI assistance, structured message types, delivery tracking, and realtime synchronization.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 06
#
# COMMUNICATION DOMAIN
#
# ENTITY CARD
#
# ENT-401
#
# MESSAGE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-401

---

Entity Name

Message

---

Owner Module

Conversation Engine

---

Bounded Context

Communication Domain

---

Aggregate Root

No

Parent Aggregate

Conversation (ENT-400)

---

# Business Purpose

A Message represents one communication event inside a Conversation.

Unlike traditional messaging systems where a message is primarily text, Atlas models Messages as structured content containers composed of reusable Content Blocks.

This enables rich collaboration between members, AI assistants, financial workflows, planning modules, navigation, and future platform capabilities.

---

# Responsibilities

Communication

Structured Content

Replies

Editing

Delivery Tracking

Read Tracking

Realtime Synchronization

Message Search

AI Context

Audit

---

# Does NOT Own

Conversation

Members

Attachments

Mentions

Reactions

Notifications

---

# Lifecycle

Draft

↓

Sending

↓

Delivered

↓

Read

↓

Edited

↓

Archived

↓

Deleted

---

Alternative

Failed

Hidden

Restored

Expired

---

# Business Rules

Every Message belongs to one Conversation.

Messages are immutable except through versioned edits.

Deleted messages remain recoverable for audit according to retention policies.

Each Message contains one or more Content Blocks.

---

# Relationships

Message

↓

Conversation

Message

↓

Sender

Message

↓

Replies

Message

↓

Attachments

Message

↓

Mentions

Message

↓

Reactions

Message

↓

Read Receipts

Message

↓

Timeline

---

# Message Types

User

AI

System

Announcement

Proposal

Expense

Budget

Navigation

Weather

Emergency

Activity

Reminder

Custom

---

# Required Fields

Message ID

Conversation ID

Sender ID

Message Type

Created At

---

# Optional Fields

Parent Message

Reply Count

Pinned

Edited At

Deleted At

Importance

Expiration

Metadata

---

# Content Block Types

Rich Text

Markdown

Image

Gallery

Video

Audio

Voice Note

Document

Map

Live Location

Expense Card

Receipt Card

Proposal Card

Budget Card

Activity Card

Poll

Checklist

Button Group

Timeline Event

Alert Banner

Divider

Code Block

Custom Widget

---

# Rich Content

Messages may contain multiple blocks.

Example

Rich Text

↓

Map

↓

Expense Card

↓

Button

↓

Poll

---

Rendering order preserved.

---

# Reply System

Replies

↓

Nested Thread

↓

Unlimited Depth

↓

Future Thread Summaries

---

# Delivery States

Pending

Sending

Delivered

Read

Failed

Deleted

Edited

---

# Editing

Version History

Edit Timestamp

Edit Reason

Original Content

Edited Content

Audit Trail

---

# AI Integration

AI Uses

Conversation Context

Trip Context

Proposal Context

Timeline

Budget

Activities

Knowledge Graph

---

AI Can

Generate replies

Summarize threads

Translate

Extract action items

Recommend responses

Create structured cards

---

AI Never

Impersonate users

Delete messages

Modify history

Send automatically

---

# Knowledge Graph

Graph Node

Yes

Node Type

Message

---

Relationships

SENT_BY

BELONGS_TO

REFERENCES

REPLIES_TO

GENERATES

MENTIONS

---

Embeddings

Generated

Every message embedded for semantic search.

---

# Search Support

Search By

Text

Author

Conversation

Message Type

Attachment

Date

Semantic Search

Natural Language Search

---

# Realtime Support

Message Sent

Delivered

Read

Edited

Deleted

Typing

Presence

Reaction Added

Reply Added

---

# Events

MessageCreated

MessageDelivered

MessageRead

MessageEdited

MessageDeleted

MessageRestored

ReplyCreated

ThreadResolved

---

# Audit Strategy

Track

Creation

Edits

Deletion

Restoration

Delivery

Reads

AI Generation

---

# Database Ownership

Schema

communication

---

Table

messages

---

Primary Key

UUID v7

---

Indexes

Conversation ID

Sender ID

Created At

Message Type

Parent Message

---

# Database Columns

message_id

conversation_id

sender_id

message_type

status

content_blocks

reply_to

edited_at

deleted_at

importance

metadata

created_at

updated_at

---

# API Endpoints

GET

/conversations/{conversationId}/messages

GET

/messages/{messageId}

POST

/conversations/{conversationId}/messages

PATCH

/messages/{messageId}

DELETE

/messages/{messageId}

POST

/messages/{messageId}/reply

---

# Performance Requirements

Message Send

<100 ms

Realtime Delivery

<150 ms

Search

<300 ms

Attachment Rendering

<500 ms

---

# Testing Requirements

Content Blocks

Replies

Realtime

Editing

Search

Permissions

Performance

---

# Future Evolution

Collaborative Messages

Live Documents

Interactive Forms

AI Widgets

Workflow Messages

Live Dashboards

Embedded Apps

Plugin Blocks

---

# Entity Summary

ENT-401 (Message) is the fundamental communication entity of Project Atlas.

Instead of treating messages as plain text, Atlas models them as structured content containers capable of rendering rich interactive experiences such as expense cards, maps, AI responses, proposal previews, and workflow actions while maintaining a unified communication architecture.

---

# Next Entity

ENT-402

Attachment

Represents any binary or external resource associated with a Message, including images, videos, documents, audio, voice notes, maps, receipts, AI-generated media, and future asset types.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 06
#
# COMMUNICATION DOMAIN
#
# ENTITY CARD
#
# ENT-402
#
# ATTACHMENT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-402

---

Entity Name

Attachment

---

Owner Module

Asset Intelligence Engine

---

Bounded Context

Communication Domain

---

Aggregate Root

No

Parent Aggregate

Message (ENT-401)

---

# Business Purpose

An Attachment represents any binary or external digital asset shared within Project Atlas.

Rather than functioning as a simple uploaded file, every Attachment becomes an intelligent asset enriched with metadata, previews, AI analysis, security information, version history, and searchable content.

Attachments support collaboration across planning, finance, navigation, communication, and future platform capabilities.

---

# Responsibilities

Asset Storage

Metadata

Preview Generation

AI Analysis

Versioning

Security

Search

Sharing

Lifecycle Management

Audit

---

# Does NOT Own

Messages

Trips

Members

Activities

Expenses

Receipts

Documents

---

# Lifecycle

Uploaded

↓

Processing

↓

Indexed

↓

Available

↓

Referenced

↓

Archived

↓

Deleted

---

Alternative

Failed

Quarantined

Corrupted

Restored

---

# Business Rules

Every Attachment belongs to one Message.

Attachments may be referenced by multiple entities.

Original files remain immutable.

New versions create new Attachment Versions.

Virus scanning completes before availability.

---

# Relationships

Attachment

↓

Message

Attachment

↓

Uploader

Attachment

↓

Preview

Attachment

↓

AI Analysis

Attachment

↓

Knowledge Graph

Attachment

↓

Timeline

Attachment

↓

Audit Events

---

# Attachment Types

Image

Video

Audio

Voice Note

Document

PDF

Spreadsheet

Presentation

Map

GPX Route

Receipt

Ticket

Passport

Visa

Insurance

Archive

Custom

---

# Required Fields

Attachment ID

Message ID

Uploader ID

Attachment Type

Created At

---

# Optional Fields

Title

Description

Thumbnail

Preview

Mime Type

Extension

Checksum

Encryption Key

Version

Tags

---

# File Metadata

Original Name

Display Name

Size

Mime Type

Extension

Checksum

Resolution

Duration

Dimensions

Language

Encoding

Creation Device

---

# Processing Pipeline

Upload

↓

Virus Scan

↓

Integrity Check

↓

Metadata Extraction

↓

Thumbnail Generation

↓

AI Analysis

↓

Embedding Generation

↓

Indexing

↓

Available

---

# Preview Generation

Images

Videos

PDF

Audio Waveform

Maps

3D Models (Future)

Office Documents

Text Preview

---

# AI Integration

AI Uses

OCR

Image Recognition

Scene Detection

Object Detection

Face Clustering

Document Classification

Speech-to-Text

Semantic Embeddings

---

AI Can

Generate captions

Extract keywords

Summarize documents

Detect landmarks

Classify assets

Identify duplicate files

Generate accessibility descriptions

---

AI Never

Modify originals

Delete assets

Share assets automatically

---

# Security

Virus Scan

Malware Detection

Encryption

Signed URLs

Access Control

Audit Logging

Retention Rules

Watermarking (Future)

---

# Versioning

Original Version

↓

Edited Version

↓

Compressed Version

↓

AI Enhanced Version

↓

Archived Version

---

Previous versions remain available.

---

# Knowledge Graph

Graph Node

Yes

Node Type

Attachment

---

Relationships

UPLOADED_BY

REFERENCES

GENERATED_FROM

CONTAINS

RELATED_TO

USED_IN

---

Embeddings

Generated

Supports semantic asset search.

---

# Search Support

Search By

Filename

Content

OCR Text

Tags

Uploader

Date

Attachment Type

Semantic Search

Image Search

---

# Realtime Support

Attachment Uploaded

Processing Started

Preview Generated

AI Analysis Completed

Attachment Shared

Attachment Deleted

---

# Events

AttachmentUploaded

AttachmentProcessed

AttachmentIndexed

PreviewGenerated

AIAnalysisCompleted

AttachmentArchived

AttachmentDeleted

---

# Audit Strategy

Track

Upload

Downloads

Preview Access

Sharing

Version Creation

Deletion

Security Events

---

# Database Ownership

Schema

communication

---

Table

attachments

---

Primary Key

UUID v7

---

Indexes

Message ID

Uploader ID

Attachment Type

Created At

Checksum

---

# Database Columns

attachment_id

message_id

uploader_id

attachment_type

storage_uri

thumbnail_uri

preview_uri

mime_type

file_size

checksum

version

processing_status

security_status

metadata

created_at

updated_at

---

# API Endpoints

POST

/attachments/upload

GET

/attachments/{attachmentId}

PATCH

/attachments/{attachmentId}

DELETE

/attachments/{attachmentId}

GET

/attachments/search

GET

/attachments/{attachmentId}/preview

---

# Performance Requirements

Upload

<3 sec

Preview Generation

<2 sec

Metadata Extraction

<500 ms

Semantic Search

<300 ms

Realtime Notification

<250 ms

---

# Testing Requirements

Uploads

Virus Scanning

Metadata Extraction

Preview Generation

AI Analysis

Search

Permissions

Performance

---

# Future Evolution

Cloud Drive Integration

AR Assets

3D Models

Collaborative Documents

Digital Signatures

Content Moderation

Satellite Imagery

External Asset References

---

# Entity Summary

ENT-402 (Attachment) represents the intelligent asset management layer of Project Atlas.

Instead of treating uploaded files as passive storage objects, Atlas enriches every asset with metadata, previews, AI analysis, semantic indexing, security validation, and lifecycle management, making attachments searchable, reusable, and deeply integrated across the platform.

---

# Next Entity

ENT-403

Mention

Represents an explicit reference to a member, role, AI assistant, or system entity within a Message, triggering notifications, contextual linking, and collaborative workflows.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 06
#
# COMMUNICATION DOMAIN
#
# ENTITY CARD
#
# ENT-403
#
# MENTION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-403

---

Entity Name

Mention

---

Owner Module

Context Engine

---

Bounded Context

Communication Domain

---

Aggregate Root

No

Parent Aggregate

Message (ENT-401)

---

# Business Purpose

A Mention represents an explicit contextual reference embedded inside a Message.

Unlike traditional @mentions that only notify users, Atlas Mentions connect people, roles, AI assistants, and domain entities into the platform's Knowledge Graph, enabling richer collaboration, navigation, search, and contextual AI reasoning.

---

# Responsibilities

Context Linking

Notifications

Knowledge Graph Linking

Navigation

Search

Permissions

AI Context

Audit

---

# Does NOT Own

Messages

Members

Activities

Budgets

Expenses

Proposals

Locations

Documents

---

# Lifecycle

Detected

↓

Validated

↓

Resolved

↓

Indexed

↓

Archived

---

Alternative

Broken

Invalid

Permission Denied

---

# Business Rules

Mentions are immutable after message publication.

Mention targets must exist and be accessible to the sender.

Broken references remain visible but are marked accordingly.

Permissions are checked before navigation.

---

# Relationships

Mention

↓

Message

Mention

↓

Target Entity

Mention

↓

Notification

Mention

↓

Knowledge Graph

Mention

↓

Audit Events

---

# Mention Targets

Member

Role

Conversation

Trip

Activity

Proposal

Budget

Expense

Receipt

Settlement

Document

Location

Route

Checklist

Packing List

Inventory Item

AI Assistant

System

Custom

---

# Required Fields

Mention ID

Message ID

Target Type

Target ID

Created At

---

# Optional Fields

Display Label

Resolved Name

Resolved URL

Resolution Status

Metadata

---

# Mention Resolution

Message Parsed

↓

Mention Detected

↓

Target Lookup

↓

Permission Validation

↓

Knowledge Graph Link

↓

Notification

↓

Indexed

---

# Smart Mentions

Supported

@Owner

@Planner

@Everyone

@Today

@Tomorrow

@Emergency

@AI

@PendingExpenses

Future

Dynamic Queries

---

# Navigation

Selecting a Mention opens

Member Profile

Proposal

Expense

Map

Document

Activity

Budget

Conversation

---

# AI Integration

AI Uses

Mention Graph

Conversation Context

Knowledge Graph

Trip Context

Timeline

---

AI Can

Resolve ambiguous mentions

Suggest mentions

Expand references

Recommend related entities

Summarize linked context

---

AI Never

Create hidden mentions

Modify permissions

Expose private entities

---

# Knowledge Graph

Graph Node

Yes

Node Type

Mention

---

Relationships

MENTIONS

REFERENCES

POINTS_TO

LINKS

GENERATED_FROM

---

Embeddings

Generated

Supports semantic context retrieval.

---

# Search Support

Search By

Mention Text

Target

Message

Author

Date

Semantic Search

---

# Realtime Support

Mention Detected

Mention Resolved

Notification Triggered

Permission Updated

Broken Link Detected

---

# Events

MentionCreated

MentionResolved

MentionIndexed

NotificationQueued

MentionBroken

MentionArchived

---

# Audit Strategy

Track

Creation

Resolution

Permission Checks

Broken References

Notification Delivery

---

# Database Ownership

Schema

communication

---

Table

mentions

---

Primary Key

UUID v7

---

Indexes

Message ID

Target Type

Target ID

Created At

---

# Database Columns

mention_id

message_id

target_type

target_id

display_label

resolution_status

notification_status

metadata

created_at

updated_at

---

# API Endpoints

GET

/messages/{messageId}/mentions

POST

/messages/{messageId}/mentions

GET

/mentions/search

GET

/mentions/{mentionId}/resolve

---

# Performance Requirements

Resolution

<50 ms

Navigation

<100 ms

Notification Queue

<100 ms

Realtime Update

<150 ms

---

# Testing Requirements

Resolution

Permissions

Notifications

Broken References

Navigation

Performance

---

# Future Evolution

Cross-Workspace Mentions

External Entity Mentions

Voice Mentions

AR Object Mentions

AI Semantic Mentions

Universal Entity References

---

# Entity Summary

ENT-403 (Mention) transforms simple @mentions into structured contextual references across the Atlas platform.

By linking members, roles, AI assistants, and domain entities through the Knowledge Graph, Mentions improve collaboration, navigation, semantic search, and AI understanding while providing a consistent mechanism for contextual communication.

---

# Next Entity

ENT-404

Reaction

Represents lightweight structured feedback on Messages using emojis, predefined reactions, acknowledgements, approvals, and future custom interaction types while supporting analytics and realtime collaboration.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 06
#
# COMMUNICATION DOMAIN
#
# ENTITY CARD
#
# ENT-404
#
# REACTION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-404

---

Entity Name

Reaction

---

Owner Module

Reaction Engine

---

Bounded Context

Communication Domain

---

Aggregate Root

No

Parent Aggregate

Message (ENT-401)

---

# Business Purpose

A Reaction represents lightweight structured feedback associated with a Message.

Unlike simple emoji reactions, Atlas Reactions carry contextual meaning depending on the parent Conversation and referenced domain entity.

They provide fast collaboration signals, workflow acknowledgements, analytics, and AI context.

---

# Responsibilities

Lightweight Feedback

Acknowledgements

Workflow Signals

Realtime Updates

Analytics

Notification Triggering

AI Context

Audit

---

# Does NOT Own

Messages

Members

Conversations

Notifications

---

# Lifecycle

Added

↓

Visible

↓

Updated

↓

Removed

↓

Archived

---

# Business Rules

Each member may have one active reaction of a given type per message.

Changing a reaction replaces the previous one.

Removed reactions remain in audit history.

Context determines semantic meaning.

---

# Relationships

Reaction

↓

Message

Reaction

↓

Member

Reaction

↓

Conversation

Reaction

↓

Notification

Reaction

↓

Analytics

---

# Reaction Types

Like

Support

Approve

Concern

Question

Celebrate

Thank You

Important

Bookmark

Verified

Acknowledged

Custom

---

# Visual Representation

Emoji

Icon

Badge

Future Animated Reactions

---

# Required Fields

Reaction ID

Message ID

Member ID

Reaction Type

Created At

---

# Optional Fields

Emoji

Context Meaning

Notes

Metadata

---

# Context Mapping

General Conversation

👍

Like

---

Proposal

👍

Support

---

Checklist

✅

Verified

---

Expense

💰

Approved

---

Emergency

👀

Seen

---

Announcement

📌

Acknowledged

---

# Notifications

Optional

Reaction Added

Reaction Changed

Important Reaction

Workflow Trigger

---

Configurable.

---

# AI Integration

AI Uses

Reaction Trends

Sentiment

Consensus

Conversation Health

Participation

---

AI Can

Summarize reactions

Detect disagreement

Estimate proposal support

Identify ignored announcements

Recommend follow-up

---

AI Never

Create reactions

Modify reactions

Vote on behalf of users

---

# Knowledge Graph

Graph Node

Yes

Node Type

Reaction

---

Relationships

REACTS_TO

EXPRESSES

SUPPORTS

ACKNOWLEDGES

---

Embeddings

No

Reactions remain structured categorical data.

---

# Search Support

Search By

Member

Reaction Type

Conversation

Message

Date

---

# Realtime Support

Reaction Added

Reaction Removed

Reaction Changed

Counters Updated

Notification Triggered

---

# Events

ReactionAdded

ReactionRemoved

ReactionChanged

ReactionCountUpdated

WorkflowAcknowledged

---

# Audit Strategy

Track

Creation

Removal

Changes

Workflow Usage

Analytics

---

# Database Ownership

Schema

communication

---

Table

reactions

---

Primary Key

UUID v7

---

Indexes

Message ID

Member ID

Reaction Type

Created At

---

Unique Constraints

Message ID

Member ID

Reaction Type

---

# Database Columns

reaction_id

message_id

member_id

reaction_type

emoji

context_meaning

metadata

created_at

updated_at

---

# API Endpoints

POST

/messages/{messageId}/reactions

DELETE

/messages/{messageId}/reactions/{reactionId}

GET

/messages/{messageId}/reactions

GET

/reactions/analytics

---

# Performance Requirements

Reaction

<50 ms

Realtime Broadcast

<100 ms

Analytics Refresh

<200 ms

---

# Testing Requirements

Uniqueness

Realtime

Notifications

Context Mapping

Analytics

Performance

---

# Future Evolution

Reaction Packs

Custom Organization Reactions

Animated Reactions

Voice Reactions

AI Suggested Reactions

Workflow Reactions

Accessibility Reactions

---

# Entity Summary

ENT-404 (Reaction) provides lightweight structured feedback across the Atlas platform.

By interpreting reactions within the context of conversations and domain entities, Atlas transforms simple emoji interactions into meaningful collaboration signals that support workflows, analytics, and AI understanding while keeping user interaction fast and intuitive.

---

# Next Entity

ENT-405

Notification

Represents a structured event delivered to one or more members, originating from any Atlas domain, with support for priorities, channels, delivery tracking, user preferences, grouping, and actionable interactions.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 06
#
# COMMUNICATION DOMAIN
#
# ENTITY CARD
#
# ENT-405
#
# NOTIFICATION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-405

---

Entity Name

Notification

---

Owner Module

Notification Engine

---

Bounded Context

Communication Domain

---

Aggregate Root

No

Parent Aggregate

Conversation (Optional)

Notifications may also originate directly from platform events.

---

# Business Purpose

A Notification represents the delivery of important information to one or more members.

Rather than functioning as a simple push message, Atlas Notifications are policy-driven delivery workflows that respect user preferences, priorities, schedules, channels, and contextual relevance.

Every Atlas domain can publish notification events without needing to understand delivery logic.

---

# Responsibilities

Event Delivery

Priority Management

Channel Routing

Scheduling

Grouping

Reminder Management

Delivery Tracking

Preferences

Analytics

Audit

---

# Does NOT Own

Messages

Members

Trips

Activities

Expenses

Proposals

System Events

---

# Lifecycle

Generated

↓

Queued

↓

Scheduled

↓

Delivered

↓

Seen

↓

Acknowledged

↓

Archived

---

Alternative

Suppressed

Expired

Failed

Cancelled

---

# Business Rules

Every Notification originates from one platform event.

Delivery respects user notification preferences.

Notifications may be grouped.

Critical notifications bypass quiet hours if configured.

Expired notifications are never delivered.

---

# Relationships

Notification

↓

Recipient

Notification

↓

Platform Event

Notification

↓

Conversation

Notification

↓

Delivery Records

Notification

↓

Audit Events

---

# Notification Categories

Planning

Budget

Expense

Settlement

Proposal

Navigation

Emergency

Weather

Reminder

Announcement

AI Insight

System

Security

Custom

---

# Priority Levels

Low

Normal

High

Critical

Emergency

---

# Required Fields

Notification ID

Recipient ID

Category

Priority

Created At

---

# Optional Fields

Title

Body

Deep Link

Expiration

Grouping Key

Delivery Policy

Metadata

---

# Delivery Channels

In-App

Push

Email

SMS

Desktop

Wearable

Webhook (Future)

Voice Assistant (Future)

---

# Scheduling

Immediate

Delayed

Scheduled Time

Recurring

Digest

Timezone Aware

---

# User Preferences

Per Category

Per Channel

Quiet Hours

Digest Mode

Emergency Override

Mute Rules

Vacation Mode

---

# Grouping

Budget Alerts

↓

One Notification

instead of

10 Notifications

---

Proposal Updates

↓

Grouped Timeline

---

Expense Added

↓

Daily Digest

---

# Delivery Tracking

Queued

Sent

Delivered

Opened

Clicked

Acknowledged

Expired

Failed

---

# AI Integration

AI Uses

Notification History

User Preferences

Engagement

Trip Timeline

Importance

Behavior Patterns

---

AI Can

Reduce notification fatigue

Choose optimal delivery time

Group similar notifications

Prioritize alerts

Generate summaries

Recommend reminders

---

AI Never

Override emergency policy

Ignore user privacy settings

Send without authorization

---

# Knowledge Graph

Graph Node

No

Notifications are transient delivery artifacts.

---

# Search Support

Search By

Category

Priority

Recipient

Date

Delivery Status

---

# Realtime Support

Notification Generated

Queued

Delivered

Seen

Acknowledged

Suppressed

---

# Events

NotificationGenerated

NotificationQueued

NotificationDelivered

NotificationSeen

NotificationAcknowledged

NotificationSuppressed

NotificationExpired

---

# Audit Strategy

Track

Generation

Routing

Delivery

Acknowledgement

Suppression

Preference Evaluation

---

# Database Ownership

Schema

communication

---

Table

notifications

---

Primary Key

UUID v7

---

Indexes

Recipient ID

Priority

Category

Delivery Status

Created At

---

# Database Columns

notification_id

recipient_id

category

priority

title

body

deep_link

delivery_channel

delivery_status

grouping_key

expiration_time

metadata

created_at

updated_at

---

Child Table

notification_deliveries

Columns

delivery_id

notification_id

channel

status

sent_at

delivered_at

opened_at

acknowledged_at

failure_reason

created_at

updated_at

---

# API Endpoints

GET

/users/me/notifications

PATCH

/notifications/{notificationId}/read

PATCH

/notifications/{notificationId}/acknowledge

DELETE

/notifications/{notificationId}

GET

/notifications/preferences

PATCH

/notifications/preferences

---

# Performance Requirements

Notification Creation

<50 ms

Queue Processing

<100 ms

Push Delivery

<2 sec

Preference Evaluation

<20 ms

Realtime Update

<150 ms

---

# Testing Requirements

Preference Rules

Grouping

Scheduling

Delivery Tracking

Retries

Performance

---

# Future Evolution

Cross-Device Sync

Smart Digests

AI Priority Ranking

Rich Interactive Notifications

Calendar Integration

External Notification Providers

Adaptive Quiet Hours

---

# Entity Summary

ENT-405 (Notification) is the delivery orchestration layer of Project Atlas.

Rather than simply sending push messages, it evaluates user preferences, priorities, schedules, and delivery channels to ensure that important information reaches the right member at the right time while minimizing notification fatigue.

---

# Next Entity

ENT-406

Announcement

Represents an official broadcast communication within a Trip Workspace, supporting audience targeting, scheduling, acknowledgements, rich content, attachments, AI summaries, and organization-wide communication policies.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 06
#
# COMMUNICATION DOMAIN
#
# ENTITY CARD
#
# ENT-406
#
# ANNOUNCEMENT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-406

---

Entity Name

Announcement

---

Owner Module

Announcement Engine

---

Bounded Context

Communication Domain

---

Aggregate Root

No

Parent Aggregate

Conversation (ENT-400)

---

# Business Purpose

An Announcement represents an official broadcast communication intended for a defined audience within a Trip Workspace.

Unlike ordinary Messages, Announcements support scheduling, acknowledgements, audience targeting, reminders, escalation, and delivery analytics.

They are intended for operational communications that require visibility and, optionally, confirmation from recipients.

---

# Responsibilities

Broadcast Communication

Audience Management

Scheduling

Acknowledgement Tracking

Reminder Management

Delivery Analytics

Priority Handling

Audit

---

# Does NOT Own

Conversation

Messages

Notifications

Members

Trips

Activities

---

# Lifecycle

Draft

↓

Scheduled

↓

Published

↓

Delivered

↓

Acknowledged

↓

Archived

---

Alternative

Cancelled

Expired

Superseded

---

# Business Rules

Announcements belong to one Conversation.

Announcements may require acknowledgements.

Scheduled announcements publish automatically.

Archived announcements remain immutable.

Only authorized members may publish announcements.

---

# Relationships

Announcement

↓

Conversation

Announcement

↓

Audience

Announcement

↓

Notifications

Announcement

↓

Attachments

Announcement

↓

Acknowledgements

Announcement

↓

Timeline

Announcement

↓

Audit Events

---

# Announcement Types

General

Schedule Change

Safety

Emergency

Budget

Planning

Reminder

Weather

Transportation

Accommodation

System

Custom

---

# Priority Levels

Low

Normal

High

Critical

Emergency

---

# Required Fields

Announcement ID

Conversation ID

Author ID

Announcement Type

Created At

---

# Optional Fields

Title

Summary

Scheduled Time

Expiration

Acknowledgement Required

Reminder Policy

Audience Filter

Attachments

Metadata

---

# Audience

Entire Trip

Selected Members

Role

Subgroup

Activity Participants

Vehicle Group

Custom Query

---

# Scheduling

Publish Immediately

Scheduled Date

Recurring

Relative Time

Timezone Aware

---

# Acknowledgements

Required

Optional

Not Required

---

Tracks

Seen

Acknowledged

Pending

Declined (Future)

---

# Reminder Policies

None

Once

Periodic

Escalating

Before Deadline

Manual

---

# Delivery Analytics

Recipients

Delivered

Opened

Acknowledged

Pending

Failed

Average Response Time

---

# AI Integration

AI Uses

Announcement Content

Trip Timeline

Audience

Priority

Weather

Activities

Travel Context

---

AI Can

Generate summaries

Rewrite for clarity

Translate

Estimate urgency

Recommend reminder schedule

Identify affected members

---

AI Never

Publish announcements

Override recipients

Modify acknowledgements

---

# Knowledge Graph

Graph Node

Yes

Node Type

Announcement

---

Relationships

ANNOUNCES

TARGETS

NOTIFIES

REFERENCES

GENERATES

---

Embeddings

Generated

Supports semantic retrieval of operational communications.

---

# Search Support

Search By

Title

Type

Priority

Audience

Date

Semantic Search

---

# Realtime Support

Announcement Published

Acknowledgement Received

Reminder Sent

Announcement Updated

Announcement Archived

---

# Events

AnnouncementCreated

AnnouncementScheduled

AnnouncementPublished

AcknowledgementReceived

ReminderTriggered

AnnouncementArchived

---

# Audit Strategy

Track

Creation

Publication

Audience Changes

Acknowledgements

Reminders

Archival

---

# Database Ownership

Schema

communication

---

Table

announcements

---

Primary Key

UUID v7

---

Indexes

Conversation ID

Announcement Type

Priority

Scheduled Time

Created At

---

# Database Columns

announcement_id

conversation_id

author_id

announcement_type

priority

title

summary

scheduled_time

expiration_time

acknowledgement_required

reminder_policy

audience_filter

metadata

created_at

updated_at

---

Child Table

announcement_acknowledgements

Columns

acknowledgement_id

announcement_id

member_id

status

seen_at

acknowledged_at

created_at

updated_at

---

# API Endpoints

GET

/conversations/{conversationId}/announcements

POST

/conversations/{conversationId}/announcements

PATCH

/announcements/{announcementId}

POST

/announcements/{announcementId}/publish

POST

/announcements/{announcementId}/acknowledge

GET

/announcements/{announcementId}/analytics

---

# Performance Requirements

Publication

<200 ms

Acknowledgement

<100 ms

Reminder Scheduling

<100 ms

Realtime Broadcast

<150 ms

---

# Testing Requirements

Scheduling

Audience Targeting

Acknowledgements

Reminders

Analytics

Performance

---

# Future Evolution

Organization Broadcasts

Cross-Trip Announcements

Geo-Fenced Announcements

Voice Announcements

Video Announcements

AI Briefings

Multi-Language Broadcasts

---

# Entity Summary

ENT-406 (Announcement) provides the official broadcast communication capability within Project Atlas.

By combining audience targeting, scheduling, acknowledgements, reminders, and analytics, Announcements become operational communication workflows rather than simple broadcast messages, ensuring that important information reaches the right members and is acted upon.

---

# End of Communication Domain

Communication Domain Entities

✓ ENT-400 Conversation

✓ ENT-401 Message

✓ ENT-402 Attachment

✓ ENT-403 Mention

✓ ENT-404 Reaction

✓ ENT-405 Notification

✓ ENT-406 Announcement

---

# Next Part

Volume 04

Part 07

Navigation Domain

Entities

ENT-500 Route

ENT-501 Waypoint

ENT-502 Navigation Session

ENT-503 Live Location

ENT-504 Geofence

ENT-505 Traffic Event

ENT-506 Navigation Event

The Navigation Domain will power route planning, live tracking, convoy travel, offline navigation support, geofencing, traffic awareness, ETA prediction, and AI-assisted route optimization while integrating with Planning, Safety, Communication, and Finance.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 07
#
# NAVIGATION DOMAIN
#
# ENTITY CARD
#
# ENT-500
#
# ROUTE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-500

---

Entity Name

Route

---

Owner Module

Navigation Engine

---

Bounded Context

Navigation Domain

---

Aggregate Root

Yes

Route is the aggregate root for navigation planning.

---

# Business Purpose

A Route represents the planned or optimized path between one or more destinations within a Trip.

Rather than depending on a single mapping provider, Atlas models Routes independently and enriches them with traffic, weather, safety, fuel estimates, checkpoints, offline data, and AI optimization.

Routes serve as the foundation for live navigation, convoy travel, ETA prediction, and itinerary execution.

---

# Responsibilities

Route Planning

Optimization

Distance Calculation

ETA Prediction

Waypoint Management

Traffic Awareness

Offline Support

Fuel Estimation

Safety Integration

AI Optimization

---

# Does NOT Own

Trips

Locations

Activities

Weather

Traffic

Navigation Sessions

---

# Lifecycle

Draft

↓

Generated

↓

Optimized

↓

Approved

↓

Active

↓

Completed

↓

Archived

---

Alternative

Cancelled

Expired

Recalculated

---

# Business Rules

Every Route belongs to one Trip.

Routes contain one or more Waypoints.

Historical routes remain immutable.

Route recalculation creates a new version.

Provider-specific data is abstracted behind the Navigation Engine.

---

# Relationships

Route

↓

Trip

Route

↓

Waypoints

Route

↓

Navigation Session

Route

↓

Traffic Events

Route

↓

Weather

Route

↓

Timeline

Route

↓

AI Recommendations

---

# Route Types

Driving

Walking

Cycling

Motorcycle

Public Transport

Convoy

Hiking

Off-Road

Boating

Custom

---

# Required Fields

Route ID

Trip ID

Route Type

Created At

---

# Optional Fields

Title

Description

Provider

Estimated Distance

Estimated Duration

Fuel Estimate

Toll Estimate

Polyline

Offline Package

Metadata

---

# Core Metrics

Distance

Duration

ETA

Average Speed

Elevation Gain

Fuel Estimate

Toll Cost

Carbon Estimate

---

# Optimization Modes

Fastest

Shortest

Scenic

Economical

Fuel Efficient

Avoid Tolls

Avoid Highways

Accessible

Custom

---

# Routing Providers

Google Maps

Mapbox

OpenStreetMap

HERE

Offline Engine

Custom Provider

---

Provider abstraction prevents vendor lock-in.

---

# AI Integration

AI Uses

Weather

Traffic

Trip Plan

Activities

Fuel Prices

Road Conditions

Historical Routes

Group Preferences

---

AI Can

Recommend routes

Predict delays

Suggest rest stops

Estimate fuel

Optimize multi-stop trips

Recommend departure time

---

AI Never

Ignore user safety preferences

Override manual route selection

---

# Knowledge Graph

Graph Node

Yes

Node Type

Route

---

Relationships

CONNECTS

CONTAINS

OPTIMIZES

SERVES

REFERENCES

---

Embeddings

Generated

Supports semantic route search.

---

# Search Support

Search By

Origin

Destination

Waypoint

Distance

Route Type

Semantic Search

---

# Realtime Support

Route Generated

Route Updated

Traffic Changed

ETA Updated

Route Recalculated

---

# Events

RouteCreated

RouteOptimized

RouteActivated

RouteRecalculated

RouteCompleted

RouteArchived

---

# Audit Strategy

Track

Generation

Optimization

Provider Changes

Recalculations

AI Suggestions

---

# Database Ownership

Schema

navigation

---

Table

routes

---

Primary Key

UUID v7

---

Indexes

Trip ID

Route Type

Provider

Created At

---

# Database Columns

route_id

trip_id

route_type

provider

distance

duration

estimated_eta

fuel_estimate

toll_estimate

polyline

status

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/routes

GET

/routes/{routeId}

POST

/trips/{tripId}/routes

PATCH

/routes/{routeId}

POST

/routes/{routeId}/optimize

POST

/routes/{routeId}/recalculate

---

# Performance Requirements

Route Generation

<3 sec

ETA Update

<300 ms

Recalculation

<2 sec

Realtime Broadcast

<250 ms

---

# Testing Requirements

Provider Abstraction

Optimization

ETA Accuracy

Offline Support

Performance

---

# Future Evolution

Electric Vehicle Routing

Drone Routes

AR Navigation

Satellite Navigation

Offline AI Routing

Autonomous Vehicle Integration

---

# Entity Summary

ENT-500 (Route) is the navigation aggregate root of Project Atlas.

Rather than depending on a single mapping provider, Atlas models routes as provider-independent navigation plans enriched with traffic, weather, safety, fuel estimation, AI optimization, and offline capabilities, enabling intelligent navigation across diverse travel scenarios.

---

# Next Entity

ENT-501

Waypoint

Represents an intermediate or destination point within a Route, supporting scheduled stops, activities, checkpoints, fuel stations, accommodations, scenic viewpoints, safety checkpoints, and AI-generated recommendations.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 07
#
# NAVIGATION DOMAIN
#
# ENTITY CARD
#
# ENT-501
#
# WAYPOINT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-501

---

Entity Name

Waypoint

---

Owner Module

Navigation Engine

---

Bounded Context

Navigation Domain

---

Aggregate Root

No

Parent Aggregate

Route (ENT-500)

---

# Business Purpose

A Waypoint represents a significant point along a Route.

Unlike simple map coordinates, Atlas Waypoints encapsulate location, purpose, schedule, operational context, safety information, activities, and AI recommendations.

Waypoints provide the structure for executing a journey rather than merely displaying navigation instructions.

---

# Responsibilities

Journey Stops

Navigation

Scheduling

Arrival Tracking

Departure Tracking

Checkpoint Management

Activity Association

Safety Context

AI Recommendations

Audit

---

# Does NOT Own

Routes

Activities

Locations

Members

Expenses

Navigation Sessions

---

# Lifecycle

Planned

↓

Confirmed

↓

Approaching

↓

Arrived

↓

Active

↓

Departed

↓

Completed

↓

Archived

---

Alternative

Skipped

Cancelled

Delayed

---

# Business Rules

Every Waypoint belongs to one Route.

Waypoint ordering is deterministic.

Arrival must occur before departure.

Historical waypoints remain immutable.

Skipping a waypoint may trigger route recalculation.

---

# Relationships

Waypoint

↓

Route

Waypoint

↓

Location

Waypoint

↓

Activities

Waypoint

↓

Traffic Events

Waypoint

↓

Weather

Waypoint

↓

Timeline

Waypoint

↓

AI Recommendations

---

# Waypoint Types

Origin

Destination

Hotel

Restaurant

Fuel Station

Charging Station

Parking

Checkpoint

Scenic View

Medical

Emergency Shelter

Border Crossing

Camp Site

Rest Stop

Meeting Point

Custom

---

# Required Fields

Waypoint ID

Route ID

Sequence Number

Location

Created At

---

# Optional Fields

Title

Description

Estimated Arrival

Estimated Departure

Actual Arrival

Actual Departure

Expected Duration

Notes

Priority

Metadata

---

# Journey Metrics

Distance From Previous

Distance To Next

Travel Time

Stop Duration

Delay

Average Speed

Fuel Remaining

ETA

---

# Scheduling

Estimated Arrival

Actual Arrival

Estimated Departure

Actual Departure

Grace Period

Delay Reason

---

# Activities

A Waypoint may contain

Sightseeing

Meal

Fuel

Accommodation

Rest

Shopping

Photography

Meeting

Custom Activities

---

# Safety Integration

Emergency Contacts

Nearest Hospital

Weather Alerts

Road Hazards

Safe Meeting Point

Emergency Exit Route

---

# AI Integration

AI Uses

Weather

Traffic

Activities

Fuel

Trip Timeline

Historical Delays

Budget

Safety

---

AI Can

Recommend stop duration

Suggest alternate stops

Recommend restaurants

Recommend fuel stations

Predict delays

Suggest departure time

Recommend scenic detours

---

AI Never

Automatically skip waypoints

Override safety decisions

---

# Knowledge Graph

Graph Node

Yes

Node Type

Waypoint

---

Relationships

PART_OF

LOCATED_AT

HOSTS

PRECEDES

FOLLOWS

REFERENCES

---

Embeddings

Generated

Supports semantic location search.

---

# Search Support

Search By

Name

Type

Location

Activity

Arrival Time

Semantic Search

---

# Realtime Support

Approaching

Arrived

Departed

Delayed

Skipped

Route Updated

---

# Events

WaypointCreated

WaypointUpdated

WaypointApproaching

WaypointArrived

WaypointDeparted

WaypointSkipped

WaypointCompleted

---

# Audit Strategy

Track

Creation

Ordering

Arrival

Departure

Delay

AI Suggestions

---

# Database Ownership

Schema

navigation

---

Table

waypoints

---

Primary Key

UUID v7

---

Indexes

Route ID

Sequence Number

Waypoint Type

Estimated Arrival

Created At

---

# Database Columns

waypoint_id

route_id

sequence_number

waypoint_type

location_id

estimated_arrival

estimated_departure

actual_arrival

actual_departure

expected_duration

status

metadata

created_at

updated_at

---

# API Endpoints

GET

/routes/{routeId}/waypoints

GET

/waypoints/{waypointId}

POST

/routes/{routeId}/waypoints

PATCH

/waypoints/{waypointId}

POST

/waypoints/{waypointId}/arrive

POST

/waypoints/{waypointId}/depart

---

# Performance Requirements

Waypoint Lookup

<20 ms

Arrival Update

<100 ms

Realtime Broadcast

<150 ms

ETA Refresh

<300 ms

---

# Testing Requirements

Ordering

Arrival Logic

Departure Logic

Realtime

Route Recalculation

Performance

---

# Future Evolution

Indoor Waypoints

AR Waypoints

Beacon Integration

Drone Landing Points

Smart Parking

Autonomous Vehicle Stops

Geospatial AI Recommendations

---

# Entity Summary

ENT-501 (Waypoint) represents meaningful operational stops within a Route.

Rather than functioning as simple geographic coordinates, Waypoints combine navigation, scheduling, activities, safety, and AI-driven recommendations to guide travelers through each stage of a journey while maintaining strong integration with the broader Atlas platform.

---

# Next Entity

ENT-502

Navigation Session

Represents the live execution of a Route, tracking realtime navigation, ETA updates, rerouting, member progress, convoy coordination, offline navigation state, and integration with traffic, weather, and safety services.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 07
#
# NAVIGATION DOMAIN
#
# ENTITY CARD
#
# ENT-502
#
# NAVIGATION SESSION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-502

---

Entity Name

Navigation Session

---

Owner Module

Navigation Engine

---

Bounded Context

Navigation Domain

---

Aggregate Root

No

Parent Aggregate

Route (ENT-500)

---

# Business Purpose

A Navigation Session represents the live execution of a Route.

Unlike the Route, which stores the planned journey, a Navigation Session captures the realtime state of travel including GPS updates, ETA changes, rerouting, convoy coordination, weather impacts, traffic conditions, and member progress.

It provides the operational view of navigation throughout the Trip.

---

# Responsibilities

Live Navigation

GPS Tracking

ETA Calculation

Realtime Route Monitoring

Rerouting

Convoy Coordination

Offline Navigation

AI Recommendations

Timeline Recording

Audit

---

# Does NOT Own

Routes

Waypoints

Members

Traffic Events

Weather

Live Locations

Expenses

Activities

---

# Lifecycle

Created

↓

Starting

↓

Active

↓

Paused

↓

Resumed

↓

Completed

↓

Archived

---

Alternative

Cancelled

Interrupted

Emergency

Offline

---

# Business Rules

Every Navigation Session belongs to one Route.

Only one active Navigation Session may exist for a Route.

Session history is immutable after completion.

GPS updates are append-only.

Offline synchronization preserves chronological order.

---

# Relationships

Navigation Session

↓

Route

Navigation Session

↓

Waypoints

Navigation Session

↓

Live Locations

Navigation Session

↓

Traffic Events

Navigation Session

↓

Navigation Events

Navigation Session

↓

Timeline

Navigation Session

↓

AI Recommendations

---

# Session States

Preparing

Active

Paused

Offline

Rerouting

Emergency

Completed

Cancelled

---

# Required Fields

Session ID

Route ID

Started At

Created At

---

# Optional Fields

Ended At

Current ETA

Distance Remaining

Current Speed

Average Speed

Delay Duration

Offline State

Metadata

---

# Live Metrics

Current Position

Distance Traveled

Distance Remaining

Current ETA

Average Speed

Maximum Speed

Moving Time

Stopped Time

Fuel Estimate

Battery Estimate (Future)

---

# GPS Tracking

Latitude

Longitude

Heading

Altitude

Accuracy

Speed

Timestamp

Provider

---

Stored as a time-series stream.

---

# Route Monitoring

Current Waypoint

Next Waypoint

Skipped Waypoints

Completed Waypoints

Deviation Distance

Alternative Route

---

# Convoy Support

Leader Position

Follower Positions

Maximum Separation

Estimated Regroup Time

Convoy Health

---

# Offline Support

Cached Maps

Offline Route

Deferred Sync

Conflict Resolution

Session Recovery

---

# AI Integration

AI Uses

Traffic

Weather

Historical Travel

Member Locations

Fuel

Activities

Safety

Trip Timeline

---

AI Can

Predict delays

Recommend rerouting

Estimate arrival

Suggest rest stops

Detect unusual movement

Recommend fuel stops

Estimate daylight arrival

---

AI Never

Take control of navigation

Override driver decisions

---

# Knowledge Graph

Graph Node

Yes

Node Type

NavigationSession

---

Relationships

EXECUTES

TRACKS

FOLLOWS

GENERATES

REFERENCES

---

Embeddings

Generated

Supports semantic journey analysis.

---

# Search Support

Search By

Route

Trip

Date

Waypoint

Navigation State

Semantic Search

---

# Realtime Support

GPS Updated

ETA Changed

Route Recalculated

Waypoint Arrived

Offline Mode

Session Completed

---

# Events

NavigationSessionStarted

GPSUpdated

ETAUpdated

RouteRecalculated

WaypointReached

SessionPaused

SessionResumed

NavigationCompleted

---

# Audit Strategy

Track

Session Start

GPS Stream

Rerouting

Offline Recovery

Completion

AI Suggestions

---

# Database Ownership

Schema

navigation

---

Table

navigation_sessions

---

Primary Key

UUID v7

---

Indexes

Route ID

Started At

Session Status

Created At

---

# Database Columns

session_id

route_id

status

started_at

ended_at

current_eta

distance_remaining

average_speed

delay_duration

offline_state

metadata

created_at

updated_at

---

Child Table

gps_track_points

Columns

track_point_id

session_id

latitude

longitude

heading

speed

accuracy

altitude

recorded_at

provider

---

# API Endpoints

GET

/navigation/sessions/{sessionId}

POST

/routes/{routeId}/start-navigation

PATCH

/navigation/sessions/{sessionId}

POST

/navigation/sessions/{sessionId}/pause

POST

/navigation/sessions/{sessionId}/resume

POST

/navigation/sessions/{sessionId}/complete

---

# Performance Requirements

GPS Ingestion

<50 ms

ETA Refresh

<200 ms

Realtime Broadcast

<150 ms

Offline Recovery

<2 sec

---

# Testing Requirements

GPS Tracking

ETA Updates

Offline Recovery

Convoy Support

Realtime

Performance

---

# Future Evolution

Satellite Messaging

AR Navigation

Autonomous Vehicle Support

EV Battery Optimization

Smart Helmet Integration

Wearable Navigation

Drone Escort Mode

---

# Entity Summary

ENT-502 (Navigation Session) represents the realtime execution of a planned Route.

By separating operational navigation from route planning, Atlas captures GPS history, ETA evolution, traffic impacts, convoy coordination, offline recovery, and AI-assisted navigation while preserving a complete historical record of how the journey actually unfolded.

---

# Next Entity

ENT-503

Live Location

Represents the realtime geographic position of a Trip Member, supporting location sharing, convoy tracking, proximity alerts, emergency response, geofencing, privacy controls, and offline synchronization.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 07
#
# NAVIGATION DOMAIN
#
# ENTITY CARD
#
# ENT-503
#
# LIVE LOCATION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-503

---

Entity Name

Live Location

---

Owner Module

Presence Engine

---

Bounded Context

Navigation Domain

---

Aggregate Root

No

Parent Aggregate

Navigation Session (ENT-502)

---

# Business Purpose

Live Location represents the realtime geographic presence of a Trip Member during an active Navigation Session.

Unlike simple GPS tracking, Atlas models Live Location as a privacy-aware presence service that supports realtime collaboration, convoy travel, emergency response, geofencing, AI predictions, and configurable sharing policies.

---

# Responsibilities

Location Sharing

Presence

Privacy Enforcement

Realtime Synchronization

Geofence Evaluation

Emergency Support

Convoy Tracking

AI Context

Audit

---

# Does NOT Own

Navigation Sessions

Members

Routes

Geofences

Traffic

Weather

Trips

---

# Lifecycle

Created

↓

Sharing Enabled

↓

Streaming

↓

Paused

↓

Resumed

↓

Stopped

↓

Archived

---

Alternative

Offline

Emergency

Privacy Locked

---

# Business Rules

Every Live Location belongs to one Navigation Session.

Location updates are append-only.

Visibility follows privacy policies.

Sharing automatically stops when the session ends unless explicitly extended.

Historical locations follow configurable retention policies.

---

# Relationships

Live Location

↓

Navigation Session

Live Location

↓

Member

Live Location

↓

Geofence

Live Location

↓

Traffic Events

Live Location

↓

Safety Events

Live Location

↓

Timeline

---

# Sharing Modes

Private

Trip Members

Selected Members

Convoy

Emergency Contacts

Public Link (Optional)

Hidden

---

# Required Fields

Location ID

Session ID

Member ID

Latitude

Longitude

Recorded At

---

# Optional Fields

Altitude

Heading

Speed

Accuracy

Battery Level

Visibility

Sharing Mode

Metadata

---

# Presence States

Online

Moving

Stationary

Offline

Hidden

Emergency

Unknown

---

# GPS Metrics

Latitude

Longitude

Heading

Speed

Altitude

Accuracy

Bearing

Timestamp

Provider

---

# Privacy Controls

Share Precise Location

Approximate Location

Hide Speed

Hide Battery

Time-Limited Sharing

Auto Stop

Per-Member Visibility

Emergency Override

---

# Convoy Features

Leader Tracking

Member Distance

Maximum Separation

Regroup Suggestions

Estimated Catch-up Time

Lost Member Detection

---

# Offline Support

Local Buffer

Deferred Sync

Conflict Resolution

Gap Detection

Recovery

---

# AI Integration

AI Uses

Movement Patterns

Traffic

Weather

Activities

Safety

Convoy State

Trip Timeline

---

AI Can

Predict arrival

Detect unusual stops

Recommend regrouping

Suggest breaks

Estimate delays

Identify separation risk

---

AI Never

Override privacy settings

Share hidden locations

Track outside authorized sessions

---

# Knowledge Graph

Graph Node

No

Live locations are ephemeral operational data.

Historical summaries may be linked separately.

---

# Search Support

Search By

Member

Session

Date

Waypoint

Trip

---

# Realtime Support

Location Updated

Sharing Enabled

Sharing Disabled

Presence Changed

Offline Detected

Emergency Activated

---

# Events

LocationShared

LocationUpdated

PresenceChanged

SharingStopped

EmergencyLocationShared

OfflineDetected

---

# Audit Strategy

Track

Sharing State

Visibility Changes

Privacy Changes

Emergency Sharing

Retention

---

# Database Ownership

Schema

navigation

---

Table

live_locations

---

Primary Key

UUID v7

---

Indexes

Session ID

Member ID

Recorded At

Sharing Mode

---

# Database Columns

location_id

session_id

member_id

latitude

longitude

altitude

speed

heading

accuracy

battery_level

sharing_mode

visibility

recorded_at

metadata

---

# API Endpoints

GET

/navigation/live/{memberId}

POST

/navigation/location

PATCH

/navigation/location/privacy

POST

/navigation/location/stop

GET

/navigation/convoy

---

# Performance Requirements

Location Update

<50 ms

Realtime Broadcast

<150 ms

Privacy Evaluation

<20 ms

Geofence Check

<100 ms

---

# Testing Requirements

Privacy Rules

Realtime Sync

Offline Recovery

Convoy Tracking

Performance

---

# Future Evolution

Satellite Location

Indoor Positioning

Ultra-Wideband

Wearable Tracking

Vehicle Telemetry

Drone Tracking

AR Presence

---

# Entity Summary

ENT-503 (Live Location) provides privacy-aware realtime presence for Trip Members.

Rather than functioning as a simple GPS tracker, Atlas combines configurable sharing policies, convoy support, emergency capabilities, geofencing, and AI-assisted movement analysis while ensuring users retain control over who can see their location and when.

---

# Next Entity

ENT-504

Geofence

Represents a virtual geographic boundary used to trigger automated workflows such as arrival detection, safety alerts, activity activation, reminders, convoy coordination, and AI-assisted contextual automation.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 07
#
# NAVIGATION DOMAIN
#
# ENTITY CARD
#
# ENT-504
#
# GEOFENCE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-504

---

Entity Name

Geofence

---

Owner Module

Geofence Engine

---

Bounded Context

Navigation Domain

---

Aggregate Root

No

Parent Aggregate

Route (ENT-500)

---

# Business Purpose

A Geofence represents a virtual geographic boundary that automatically detects when members enter, exit, or remain within a defined area.

Rather than serving only notification purposes, Atlas uses Geofences to automate planning, navigation, safety, communication, budgeting, and AI-driven workflows based on geographic context.

---

# Responsibilities

Boundary Detection

Automation Triggering

Arrival Detection

Departure Detection

Safety Monitoring

Workflow Activation

AI Context

Audit

---

# Does NOT Own

Routes

Waypoints

Live Locations

Activities

Notifications

Safety Events

---

# Lifecycle

Created

↓

Active

↓

Triggered

↓

Completed

↓

Archived

---

Alternative

Disabled

Expired

Cancelled

---

# Business Rules

Every Geofence belongs to one Route or Trip context.

Geofences may overlap.

Trigger evaluation is deterministic.

Repeated triggers follow configured cooldown policies.

Historical trigger events remain immutable.

---

# Relationships

Geofence

↓

Route

Geofence

↓

Waypoint

Geofence

↓

Live Location

Geofence

↓

Navigation Events

Geofence

↓

Timeline

Geofence

↓

Automation Rules

---

# Geofence Types

Arrival

Departure

Checkpoint

Hotel

Fuel Station

Parking

Activity Area

Danger Zone

Safe Zone

Border Crossing

Meeting Point

Camp Site

Custom

---

# Required Fields

Geofence ID

Center Location

Radius

Type

Created At

---

# Optional Fields

Name

Description

Activation Window

Trigger Policy

Cooldown

Priority

Metadata

---

# Boundary Shapes

Circle

Polygon

Route Corridor

Future 3D Volume

---

# Trigger Types

Enter

Exit

Dwell

Pass Through

Approach

Leave Radius

---

# Trigger Conditions

Any Member

Specific Member

Entire Group

Role Based

Convoy Leader

Custom Rule

---

# Automation Examples

Hotel

↓

Open Check-in Details

---

Fuel Station

↓

Show Fuel Budget

---

Restaurant

↓

Display Reservation

---

Scenic View

↓

Photo Reminder

---

Camp Site

↓

Activate Safety Checklist

---

Border

↓

Currency Exchange Reminder

---

# AI Integration

AI Uses

Current Location

Traffic

Weather

Activities

Time

Budget

Safety

Trip Timeline

---

AI Can

Suggest automation

Recommend radius

Reduce false triggers

Predict arrival

Recommend reminders

Optimize trigger timing

---

AI Never

Override emergency rules

Modify location history

---

# Knowledge Graph

Graph Node

Yes

Node Type

Geofence

---

Relationships

SURROUNDS

TRIGGERS

MONITORS

PROTECTS

REFERENCES

---

Embeddings

Generated

Supports semantic location reasoning.

---

# Search Support

Search By

Type

Waypoint

Radius

Trip

Automation

Semantic Search

---

# Realtime Support

Entered

Exited

Approaching

Dwell Triggered

Automation Started

Automation Completed

---

# Events

GeofenceCreated

GeofenceTriggered

EnteredArea

ExitedArea

AutomationExecuted

GeofenceArchived

---

# Audit Strategy

Track

Creation

Trigger Events

Automation

Radius Changes

Trigger Policy

AI Suggestions

---

# Database Ownership

Schema

navigation

---

Table

geofences

---

Primary Key

UUID v7

---

Indexes

Route ID

Waypoint ID

Type

Created At

---

# Database Columns

geofence_id

route_id

waypoint_id

geofence_type

center_latitude

center_longitude

radius

trigger_policy

cooldown

status

metadata

created_at

updated_at

---

# API Endpoints

GET

/routes/{routeId}/geofences

POST

/routes/{routeId}/geofences

PATCH

/geofences/{geofenceId}

DELETE

/geofences/{geofenceId}

GET

/geofences/{geofenceId}/events

---

# Performance Requirements

Trigger Evaluation

<100 ms

Automation Dispatch

<150 ms

Realtime Broadcast

<150 ms

---

# Testing Requirements

Boundary Detection

Trigger Accuracy

Automation Rules

Cooldown Logic

Realtime

Performance

---

# Future Evolution

Indoor Geofences

Beacon Integration

AR Geofences

Vehicle-Based Geofences

Dynamic Geofences

Predictive Geofences

---

# Entity Summary

ENT-504 (Geofence) provides geographic automation capabilities for Project Atlas.

By combining virtual boundaries with workflow automation, planning context, safety logic, and AI recommendations, Geofences transform location awareness into actionable travel intelligence that automatically assists travelers throughout their journey.

---

# Next Entity

ENT-505

Traffic Event

Represents realtime and historical traffic conditions affecting a Route or Navigation Session, including congestion, accidents, closures, delays, construction, weather impacts, and AI-generated rerouting recommendations.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 07
#
# NAVIGATION DOMAIN
#
# ENTITY CARD
#
# ENT-505
#
# TRAFFIC EVENT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-505

---

Entity Name

Traffic Event

---

Owner Module

Traffic Intelligence Engine

---

Bounded Context

Navigation Domain

---

Aggregate Root

No

Parent Aggregate

Navigation Session (ENT-502)

---

# Business Purpose

A Traffic Event represents any realtime or historical road condition that impacts travel.

Unlike simple congestion indicators, Atlas models Traffic Events as structured operational events that influence navigation, planning, budgeting, safety, and AI decision-making across the platform.

Traffic Events help explain why a journey changed—not just that it changed.

---

# Responsibilities

Traffic Monitoring

Delay Analysis

Route Impact

ETA Updates

Rerouting Support

Historical Analysis

AI Context

Audit

---

# Does NOT Own

Routes

Navigation Sessions

Waypoints

Weather

Safety Events

Members

---

# Lifecycle

Detected

↓

Validated

↓

Active

↓

Updated

↓

Resolved

↓

Archived

---

Alternative

Ignored

Expired

False Positive

---

# Business Rules

Traffic Events are immutable once archived.

Events may affect multiple Routes.

Events are timestamped and versioned.

Historical events remain available for analytics.

---

# Relationships

Traffic Event

↓

Navigation Session

Traffic Event

↓

Route

Traffic Event

↓

Waypoints

Traffic Event

↓

Timeline

Traffic Event

↓

AI Recommendations

---

# Traffic Types

Congestion

Accident

Road Closure

Construction

Flooding

Landslide

Police Checkpoint

Toll Queue

Bridge Restriction

Weather Impact

Event Traffic

Custom

---

# Severity Levels

Low

Moderate

High

Critical

Emergency

---

# Required Fields

Traffic Event ID

Type

Severity

Detected At

Created At

---

# Optional Fields

Description

Affected Segment

Estimated Delay

Expected Resolution

Provider

Confidence

Metadata

---

# Core Metrics

Average Speed

Delay

Queue Length

Affected Distance

Expected Clearance

Confidence Score

Historical Frequency

---

# Detection Sources

Google Maps

Mapbox

HERE

OpenStreetMap

Government Feeds

Crowdsourcing

AI Prediction

Manual Report

---

# Route Impact

ETA Increase

Fuel Increase

Toll Impact

Budget Impact

Activity Delay

Hotel Check-in Risk

Reservation Risk

---

# AI Integration

AI Uses

Traffic

Weather

Historical Routes

Time of Day

Events

Trip Plan

Budget

---

AI Can

Predict congestion

Recommend reroutes

Estimate impact

Suggest departure changes

Identify recurring delays

Recommend alternate stops

---

AI Never

Ignore safety warnings

Hide critical events

---

# Knowledge Graph

Graph Node

Yes

Node Type

TrafficEvent

---

Relationships

AFFECTS

DELAYS

BLOCKS

IMPACTS

GENERATES

---

Embeddings

Generated

Supports semantic transportation analysis.

---

# Search Support

Search By

Route

Severity

Road

Date

Traffic Type

Semantic Search

---

# Realtime Support

Traffic Detected

Traffic Updated

Traffic Cleared

ETA Changed

Route Recalculated

---

# Events

TrafficEventDetected

TrafficUpdated

TrafficResolved

RouteImpacted

DelayCalculated

RerouteSuggested

---

# Audit Strategy

Track

Detection

Severity Changes

Provider Updates

Route Impact

AI Recommendations

---

# Database Ownership

Schema

navigation

---

Table

traffic_events

---

Primary Key

UUID v7

---

Indexes

Navigation Session ID

Severity

Traffic Type

Detected At

---

# Database Columns

traffic_event_id

session_id

route_id

traffic_type

severity

estimated_delay

affected_segment

provider

confidence

status

metadata

detected_at

updated_at

---

# API Endpoints

GET

/navigation/traffic

GET

/traffic/{trafficEventId}

POST

/traffic/report

PATCH

/traffic/{trafficEventId}

GET

/routes/{routeId}/traffic

---

# Performance Requirements

Traffic Update

<150 ms

ETA Recalculation

<300 ms

Realtime Broadcast

<200 ms

---

# Testing Requirements

Detection

Impact Analysis

ETA Updates

Provider Integration

Realtime

Performance

---

# Future Evolution

Vehicle Telemetry

Government API Integration

Predictive Congestion

Crowdsourced Validation

Satellite Traffic

AI Incident Detection

Smart City Integration

---

# Entity Summary

ENT-505 (Traffic Event) models traffic as a structured operational event rather than a passive map overlay.

By capturing congestion, incidents, closures, weather impacts, and their effects on navigation, planning, budgets, and safety, Atlas enables intelligent travel decisions and richer post-trip analysis.

---

# Next Entity

ENT-506

Navigation Event

Represents significant operational events that occur during a Navigation Session, such as rerouting, waypoint arrivals, deviations, emergency stops, fuel stops, convoy regrouping, and AI-generated navigation decisions, forming the complete execution history of a journey.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 07
#
# NAVIGATION DOMAIN
#
# ENTITY CARD
#
# ENT-506
#
# NAVIGATION EVENT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-506

---

Entity Name

Navigation Event

---

Owner Module

Journey Event Engine

---

Bounded Context

Navigation Domain

---

Aggregate Root

No

Parent Aggregate

Navigation Session (ENT-502)

---

# Business Purpose

A Navigation Event represents a significant operational event that occurs during the execution of a Navigation Session.

Unlike raw GPS data, Navigation Events capture meaningful milestones, decisions, deviations, and incidents that explain how the journey unfolded.

Together, these events form the operational history of a Trip and support analytics, AI learning, auditing, and journey replay.

---

# Responsibilities

Journey History

Operational Timeline

Milestone Tracking

Navigation Analytics

Journey Replay

AI Context

Audit

---

# Does NOT Own

Navigation Sessions

Routes

Waypoints

Traffic Events

Members

Activities

Expenses

---

# Lifecycle

Generated

↓

Validated

↓

Recorded

↓

Indexed

↓

Archived

---

Navigation Events are immutable.

Corrections generate compensating events rather than modifying history.

---

# Business Rules

Every Navigation Event belongs to one Navigation Session.

Events are append-only.

Events preserve chronological order.

Events may reference other domain entities.

---

# Relationships

Navigation Event

↓

Navigation Session

Navigation Event

↓

Waypoint

Navigation Event

↓

Traffic Event

Navigation Event

↓

Timeline

Navigation Event

↓

Knowledge Graph

Navigation Event

↓

AI Analysis

---

# Event Types

Navigation Started

Waypoint Reached

Waypoint Skipped

Departure

Arrival

Pause

Resume

Traffic Delay

Reroute

Fuel Stop

Rest Stop

Photo Captured

Activity Started

Activity Completed

Weather Impact

Emergency Stop

Convoy Regroup

Border Crossing

Navigation Completed

Custom

---

# Required Fields

Event ID

Session ID

Event Type

Occurred At

Created At

---

# Optional Fields

Waypoint ID

Traffic Event ID

Related Entity

Latitude

Longitude

Description

AI Summary

Metadata

---

# Event Attributes

Timestamp

Location

Duration

Delay

Reason

Severity

Source

Confidence

---

# Operational Metrics

Distance Covered

Remaining Distance

ETA

Average Speed

Fuel Estimate

Delay

Stop Duration

---

# Replay Support

Every event is replayable.

Supports

Timeline Playback

Map Animation

Journey Story

AI Summaries

---

# AI Integration

AI Uses

GPS Stream

Traffic

Weather

Activities

Photos

Expenses

Timeline

Historical Trips

---

AI Can

Summarize journey

Explain delays

Recommend improvements

Detect unusual events

Generate travel journal

Estimate recurring issues

---

AI Never

Modify event history

Delete operational events

---

# Knowledge Graph

Graph Node

Yes

Node Type

NavigationEvent

---

Relationships

OCCURRED_DURING

REFERENCES

GENERATED

EXPLAINS

LINKS

---

Embeddings

Generated

Supports semantic journey analysis.

---

# Search Support

Search By

Event Type

Waypoint

Date

Trip

Location

Semantic Search

---

# Realtime Support

Event Generated

Timeline Updated

Replay Updated

AI Summary Updated

---

# Events

NavigationEventCreated

JourneyMilestoneRecorded

ReplayUpdated

JourneyCompleted

AIJourneySummaryGenerated

---

# Audit Strategy

Track

Creation

References

Replay

AI Summaries

Timeline Integration

---

# Database Ownership

Schema

navigation

---

Table

navigation_events

---

Primary Key

UUID v7

---

Indexes

Session ID

Event Type

Occurred At

Waypoint ID

---

# Database Columns

event_id

session_id

event_type

waypoint_id

traffic_event_id

related_entity_type

related_entity_id

latitude

longitude

description

ai_summary

metadata

occurred_at

created_at

---

# API Endpoints

GET

/navigation/sessions/{sessionId}/events

POST

/navigation/events

GET

/navigation/events/{eventId}

GET

/navigation/sessions/{sessionId}/replay

GET

/navigation/sessions/{sessionId}/timeline

---

# Performance Requirements

Event Recording

<50 ms

Replay Generation

<500 ms

Timeline Refresh

<200 ms

Realtime Broadcast

<150 ms

---

# Testing Requirements

Chronological Ordering

Replay Accuracy

Timeline Integration

References

Performance

---

# Future Evolution

3D Journey Replay

AR Playback

AI Travel Narratives

Vehicle Telemetry Integration

Drone Footage Synchronization

Wearable Sensor Events

---

# Entity Summary

ENT-506 (Navigation Event) captures the meaningful operational history of a Navigation Session.

By recording milestones, rerouting decisions, delays, stops, weather impacts, and other journey events as immutable structured records, Atlas transforms navigation history into a rich source of analytics, replay, AI learning, and travel storytelling.

---

# End of Navigation Domain

Navigation Domain Entities

✓ ENT-500 Route

✓ ENT-501 Waypoint

✓ ENT-502 Navigation Session

✓ ENT-503 Live Location

✓ ENT-504 Geofence

✓ ENT-505 Traffic Event

✓ ENT-506 Navigation Event

---

# Next Part

Volume 04

Part 08

Safety Domain

Entities

ENT-600 Emergency Contact

ENT-601 Emergency Event

ENT-602 Safety Check-in

ENT-603 Incident Report

ENT-604 Medical Profile

ENT-605 Risk Assessment

ENT-606 Safety Recommendation

The Safety Domain will provide emergency response, incident management, medical preparedness, proactive risk analysis, check-in workflows, and AI-assisted safety guidance while integrating with Navigation, Communication, Planning, and Member Management.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 08
#
# SAFETY DOMAIN
#
# ENTITY CARD
#
# ENT-600
#
# EMERGENCY CONTACT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-600

---

Entity Name

Emergency Contact

---

Owner Module

Safety Engine

---

Bounded Context

Safety Domain

---

Aggregate Root

Yes

Emergency Contact is the aggregate root for emergency communication.

---

# Business Purpose

An Emergency Contact represents a trusted individual or organization that may be contacted during emergencies occurring before, during, or after a Trip.

Atlas models Emergency Contacts as verified safety relationships rather than simple phone numbers, enabling context-aware emergency workflows while respecting user privacy and consent.

---

# Responsibilities

Emergency Communication

Verification

Priority Management

Relationship Tracking

Availability

Escalation

Localization

Audit

---

# Does NOT Own

Members

Trips

Medical Profiles

Emergency Events

Notifications

---

# Lifecycle

Created

↓

Verified

↓

Active

↓

Inactive

↓

Archived

---

Alternative

Revoked

Expired

---

# Business Rules

Every Member may register multiple Emergency Contacts.

Priority order must be unique per Member.

Verification is recommended before use.

Contacts may be temporarily disabled.

Emergency contacts are private by default.

---

# Relationships

Emergency Contact

↓

Member

Emergency Contact

↓

Emergency Events

Emergency Contact

↓

Medical Profile

Emergency Contact

↓

Notifications

Emergency Contact

↓

Timeline

---

# Contact Types

Family

Friend

Guardian

Doctor

Travel Coordinator

Embassy

Insurance

Local Guide

Organization

Custom

---

# Required Fields

Emergency Contact ID

Member ID

Name

Relationship

Primary Contact Method

Created At

---

# Optional Fields

Phone Number

Email

Preferred Language

Country

Timezone

Priority

Verification Status

Notes

Metadata

---

# Communication Methods

Phone

SMS

Email

WhatsApp (Future)

Satellite Message (Future)

Emergency API (Future)

---

# Availability

Always Available

Business Hours

Timezone Aware

Custom Schedule

Unknown

---

# Verification

Unverified

Verified

Expired

Revoked

---

# Escalation

Primary Contact

↓

Secondary Contact

↓

Organization

↓

Emergency Services

---

Configurable.

---

# Privacy

Only accessible

During authorized safety workflows.

Access is fully audited.

---

# AI Integration

AI Uses

Location

Emergency Severity

Medical Profile

Trip Context

Language

Country

---

AI Can

Recommend contact order

Suggest local emergency organizations

Translate emergency summaries

Prepare incident briefings

---

AI Never

Contact anyone automatically without explicit policy or user authorization

Expose private contact information

Modify emergency contacts

---

# Knowledge Graph

Graph Node

Yes

Node Type

EmergencyContact

---

Relationships

CONTACTS

PROTECTS

RELATED_TO

NOTIFIED_DURING

---

Embeddings

No

Structured safety data.

---

# Search Support

Search By

Member

Relationship

Priority

Verification Status

Country

---

# Realtime Support

Contact Verified

Priority Changed

Emergency Triggered

Escalation Started

---

# Events

EmergencyContactCreated

EmergencyContactVerified

EmergencyEscalationStarted

EmergencyContactNotified

EmergencyContactArchived

---

# Audit Strategy

Track

Creation

Verification

Access

Emergency Usage

Escalation

---

# Database Ownership

Schema

safety

---

Table

emergency_contacts

---

Primary Key

UUID v7

---

Indexes

Member ID

Priority

Relationship

Verification Status

---

# Database Columns

contact_id

member_id

name

relationship

phone

email

country

timezone

priority

verification_status

metadata

created_at

updated_at

---

# API Endpoints

GET

/members/{memberId}/emergency-contacts

POST

/members/{memberId}/emergency-contacts

PATCH

/emergency-contacts/{contactId}

DELETE

/emergency-contacts/{contactId}

POST

/emergency-contacts/{contactId}/verify

---

# Performance Requirements

Lookup

<20 ms

Emergency Retrieval

<50 ms

Escalation

<100 ms

---

# Testing Requirements

Verification

Priority

Privacy

Escalation

Localization

Performance

---

# Future Evolution

Government Emergency Integration

Embassy Directory

Satellite Emergency Contacts

Smart Wearable Alerts

Travel Insurance APIs

Medical Organization Registry

---

# Entity Summary

ENT-600 (Emergency Contact) provides the trusted communication foundation for Atlas' Safety Domain.

Rather than storing static contact information, it models verified emergency relationships, escalation priorities, localization, and privacy-aware communication policies, enabling coordinated responses during incidents while integrating with medical, navigation, and emergency workflows.

---

# Next Entity

ENT-601

Emergency Event

Represents an active or historical emergency occurring during a Trip, including medical incidents, accidents, lost members, severe weather, security threats, vehicle breakdowns, and coordinated emergency response workflows.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 08
#
# SAFETY DOMAIN
#
# ENTITY CARD
#
# ENT-601
#
# EMERGENCY EVENT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-601

---

Entity Name

Emergency Event

---

Owner Module

Emergency Response Engine

---

Bounded Context

Safety Domain

---

Aggregate Root

Yes

Emergency Event is the aggregate root for all emergency response workflows.

---

# Business Purpose

An Emergency Event represents any incident requiring immediate or coordinated response during a Trip.

Rather than functioning as a simple SOS alert, Atlas models emergencies as structured operational workflows that coordinate members, navigation, communication, medical information, emergency contacts, AI assistance, and post-incident analysis.

---

# Responsibilities

Incident Management

Emergency Coordination

Severity Assessment

Response Tracking

Escalation

Communication

Navigation Support

Medical Integration

Timeline

Audit

---

# Does NOT Own

Members

Trips

Emergency Contacts

Medical Profiles

Navigation Sessions

Notifications

---

# Lifecycle

Detected

↓

Verified

↓

Classified

↓

Response Active

↓

Contained

↓

Resolved

↓

Closed

↓

Archived

---

Alternative

False Alarm

Cancelled

---

# Business Rules

Every Emergency Event belongs to one Trip.

Emergency Events are immutable after closure.

Severity determines response workflows.

Critical emergencies bypass notification preferences.

Emergency history is retained according to configured policies.

---

# Relationships

Emergency Event

↓

Trip

Emergency Event

↓

Members

Emergency Event

↓

Emergency Contacts

Emergency Event

↓

Medical Profile

Emergency Event

↓

Navigation Session

Emergency Event

↓

Timeline

Emergency Event

↓

Incident Report

---

# Emergency Types

Medical

Vehicle Breakdown

Accident

Lost Member

Security Threat

Natural Disaster

Fire

Flood

Wildlife Encounter

Equipment Failure

Custom

---

# Severity Levels

Low

Moderate

High

Critical

Life Threatening

---

# Required Fields

Emergency Event ID

Trip ID

Emergency Type

Severity

Detected At

Created At

---

# Optional Fields

Description

Current Location

Affected Members

Response Status

Assigned Coordinator

Resolution Summary

Metadata

---

# Response Workflow

Detect

↓

Verify

↓

Classify

↓

Notify

↓

Navigate

↓

Coordinate

↓

Resolve

↓

Review

---

# Escalation

Trip Members

↓

Emergency Contacts

↓

Local Emergency Services

↓

Embassy (International Trips)

↓

Insurance Provider

---

Policy driven.

---

# AI Integration

AI Uses

Location

Weather

Medical Profiles

Traffic

Trip Context

Emergency Contacts

Language

---

AI Can

Summarize the incident

Recommend nearby hospitals or safe locations

Translate emergency information

Suggest evacuation routes

Generate incident timelines

Recommend next actions

---

AI Never

Automatically contact emergency services without configured policy or explicit authorization

Make medical diagnoses

Override emergency coordinators

---

# Knowledge Graph

Graph Node

Yes

Node Type

EmergencyEvent

---

Relationships

AFFECTS

INVOLVES

ESCALATES_TO

GENERATES

REFERENCES

---

Embeddings

Generated

Supports semantic incident analysis.

---

# Search Support

Search By

Trip

Emergency Type

Severity

Member

Date

Semantic Search

---

# Realtime Support

Emergency Detected

Severity Changed

Responder Assigned

Escalation Started

Incident Resolved

---

# Events

EmergencyDetected

EmergencyVerified

EmergencyEscalated

EmergencyResolved

EmergencyClosed

IncidentReportGenerated

---

# Audit Strategy

Track

Detection

Classification

Escalation

Notifications

Response Timeline

Resolution

---

# Database Ownership

Schema

safety

---

Table

emergency_events

---

Primary Key

UUID v7

---

Indexes

Trip ID

Emergency Type

Severity

Status

Detected At

---

# Database Columns

emergency_event_id

trip_id

emergency_type

severity

status

current_location

affected_members

assigned_coordinator

resolution_summary

metadata

detected_at

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/emergencies

GET

/emergencies/{emergencyEventId}

POST

/trips/{tripId}/emergencies

PATCH

/emergencies/{emergencyEventId}

POST

/emergencies/{emergencyEventId}/escalate

POST

/emergencies/{emergencyEventId}/resolve

---

# Performance Requirements

Emergency Creation

<100 ms

Escalation

<200 ms

Realtime Broadcast

<100 ms

Location Update

<100 ms

---

# Testing Requirements

Escalation

Severity Rules

Notifications

Response Workflow

Timeline

Performance

---

# Future Evolution

Satellite SOS

Government Emergency APIs

Automatic Crash Detection

Wearable Device Integration

Drone Assistance

International Emergency Services Directory

---

# Entity Summary

ENT-601 (Emergency Event) represents the operational management of emergencies within Project Atlas.

By coordinating navigation, communication, medical information, emergency contacts, AI assistance, and structured response workflows, Atlas transforms isolated emergency alerts into comprehensive incident management processes that improve coordination, traceability, and post-incident analysis.

---

# Next Entity

ENT-602

Safety Check-in

Represents periodic or event-driven confirmations of a member's wellbeing during a Trip, supporting scheduled check-ins, geofence-triggered prompts, missed check-in detection, escalation policies, and AI-assisted safety monitoring.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 08
#
# SAFETY DOMAIN
#
# ENTITY CARD
#
# ENT-602
#
# SAFETY CHECK-IN
#
# ==============================================================================

# Entity Information

Entity ID

ENT-602

---

Entity Name

Safety Check-in

---

Owner Module

Safety Monitoring Engine

---

Bounded Context

Safety Domain

---

Aggregate Root

No

Parent Aggregate

Emergency Event (Optional)

---

# Business Purpose

A Safety Check-in represents a structured confirmation of a member's wellbeing during a Trip.

Unlike simple reminders, Atlas Safety Check-ins combine schedules, risk assessments, geofences, activities, and environmental context to proactively monitor traveler safety and trigger escalation workflows when necessary.

---

# Responsibilities

Wellbeing Monitoring

Scheduled Check-ins

Context-Aware Prompts

Escalation

Safety Analytics

AI Monitoring

Audit

---

# Does NOT Own

Members

Trips

Emergency Events

Navigation Sessions

Medical Profiles

Notifications

---

# Lifecycle

Scheduled

↓

Pending

↓

Delivered

↓

Responded

↓

Verified

↓

Closed

↓

Archived

---

Alternative

Missed

Expired

Escalated

Cancelled

---

# Business Rules

Check-ins may be scheduled or event-driven.

Missed check-ins follow configurable escalation policies.

Responses are timestamped.

Historical check-ins remain immutable.

Emergency workflows may generate immediate check-ins.

---

# Relationships

Safety Check-in

↓

Member

Safety Check-in

↓

Trip

Safety Check-in

↓

Emergency Event

Safety Check-in

↓

Navigation Session

Safety Check-in

↓

Timeline

Safety Check-in

↓

Risk Assessment

---

# Check-in Types

Scheduled

Arrival

Departure

Waypoint

Geofence

Weather

Manual

Emergency

High Risk

Custom

---

# Required Fields

Check-in ID

Member ID

Trip ID

Check-in Type

Scheduled Time

Created At

---

# Optional Fields

Response

Current Location

Battery Level

Network Status

Notes

Escalation Policy

Metadata

---

# Response States

Pending

Safe

Need Assistance

Emergency

No Response

Cancelled

---

# Trigger Sources

Time Schedule

Waypoint Arrival

Geofence

Weather Alert

Risk Score

Emergency Event

Manual Request

---

# Escalation

Missed Check-in

↓

Reminder

↓

Group Notification

↓

Emergency Contact

↓

Emergency Event

---

Configurable.

---

# AI Integration

AI Uses

Location

Navigation

Weather

Medical Profile

Risk Level

Trip Context

Historical Responses

---

AI Can

Adjust check-in frequency

Predict missed check-ins

Recommend escalation

Summarize wellbeing trends

Suggest safer schedules

---

AI Never

Report false emergencies as confirmed facts

Override user privacy policies

Contact emergency services without configured authorization

---

# Knowledge Graph

Graph Node

Yes

Node Type

SafetyCheckIn

---

Relationships

CONFIRMS

MONITORS

GENERATES

REFERENCES

---

Embeddings

Generated

Supports semantic safety history.

---

# Search Support

Search By

Member

Trip

Check-in Type

Status

Date

---

# Realtime Support

Check-in Scheduled

Reminder Sent

Response Received

Escalation Triggered

Check-in Closed

---

# Events

SafetyCheckInScheduled

ReminderSent

CheckInResponded

CheckInMissed

EscalationStarted

CheckInClosed

---

# Audit Strategy

Track

Scheduling

Reminders

Responses

Escalations

AI Adjustments

---

# Database Ownership

Schema

safety

---

Table

safety_checkins

---

Primary Key

UUID v7

---

Indexes

Member ID

Trip ID

Scheduled Time

Status

---

# Database Columns

checkin_id

member_id

trip_id

checkin_type

status

scheduled_time

response

current_location

battery_level

network_status

escalation_policy

metadata

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/check-ins

POST

/trips/{tripId}/check-ins

PATCH

/check-ins/{checkInId}

POST

/check-ins/{checkInId}/respond

POST

/check-ins/{checkInId}/escalate

---

# Performance Requirements

Scheduling

<100 ms

Reminder Dispatch

<150 ms

Response Processing

<100 ms

Realtime Update

<150 ms

---

# Testing Requirements

Scheduling

Escalation

Reminder Logic

Realtime

Performance

Privacy

---

# Future Evolution

Wearable Integration

Satellite Check-ins

Voice Check-ins

Biometric Confirmation

Vehicle Telemetry Check-ins

Offline Mesh Networking

---

# Entity Summary

ENT-602 (Safety Check-in) provides proactive wellbeing monitoring for Project Atlas.

By combining scheduled and context-aware check-ins with configurable escalation policies, navigation context, and AI-assisted monitoring, Atlas helps groups maintain awareness of member safety while minimizing unnecessary interruptions.

---

# Next Entity

ENT-603

Incident Report

Represents the structured documentation of safety incidents, capturing facts, evidence, timelines, involved members, response actions, and outcomes for auditing, learning, insurance, and post-trip review.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 08
#
# SAFETY DOMAIN
#
# ENTITY CARD
#
# ENT-603
#
# INCIDENT REPORT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-603

---

Entity Name

Incident Report

---

Owner Module

Incident Intelligence Engine

---

Bounded Context

Safety Domain

---

Aggregate Root

No

Parent Aggregate

Emergency Event (ENT-601)

---

# Business Purpose

An Incident Report documents the factual record of a safety-related event that occurred during a Trip.

Rather than storing only a narrative description, Atlas structures incident reports with timelines, evidence, participants, actions, outcomes, and lessons learned to support review, insurance, analytics, and continuous safety improvement.

---

# Responsibilities

Incident Documentation

Evidence Collection

Timeline Recording

Participant Tracking

Response Documentation

Lessons Learned

AI Analysis

Audit

---

# Does NOT Own

Emergency Events

Members

Trips

Attachments

Medical Profiles

Navigation Sessions

---

# Lifecycle

Draft

↓

In Progress

↓

Submitted

↓

Reviewed

↓

Closed

↓

Archived

---

Alternative

Cancelled

Superseded

---

# Business Rules

Every Incident Report belongs to one Emergency Event.

Reports are versioned until submission.

Submitted reports become immutable.

Evidence references remain linked permanently.

---

# Relationships

Incident Report

↓

Emergency Event

Incident Report

↓

Members

Incident Report

↓

Attachments

Incident Report

↓

Navigation Session

Incident Report

↓

Timeline

Incident Report

↓

Knowledge Graph

---

# Report Types

Medical

Vehicle

Navigation

Equipment

Security

Environmental

Weather

Wildlife

Near Miss

Custom

---

# Required Fields

Incident Report ID

Emergency Event ID

Report Type

Occurred At

Created At

---

# Optional Fields

Summary

Detailed Description

Location

Severity

Reporter

Witnesses

Resolution

Lessons Learned

Metadata

---

# Report Structure

Incident Summary

↓

Timeline

↓

Evidence

↓

Participants

↓

Actions Taken

↓

Outcome

↓

Recommendations

↓

Lessons Learned

---

# Evidence

Photos

Videos

Audio

GPS Track

Weather Snapshot

Traffic Snapshot

Receipts

Documents

Witness Notes

---

# Participants

Affected Members

Responders

Witnesses

Emergency Contacts

Organizations

---

# Root Cause Analysis

Equipment Failure

Human Error

Weather

Road Conditions

Health

External Factors

Unknown

Multiple Causes

---

# AI Integration

AI Uses

Timeline

Navigation

Weather

Traffic

Evidence

Medical Data (where authorized)

Trip Context

---

AI Can

Generate summaries

Organize evidence

Suggest root causes

Identify recurring patterns

Recommend preventive actions

Produce insurance-friendly drafts

---

AI Never

Assign legal liability

Modify factual evidence

Fabricate missing details

---

# Knowledge Graph

Graph Node

Yes

Node Type

IncidentReport

---

Relationships

DOCUMENTS

REFERENCES

RESULTED_FROM

INVOLVES

GENERATES

---

Embeddings

Generated

Supports semantic incident search.

---

# Search Support

Search By

Trip

Incident Type

Severity

Location

Date

Semantic Search

---

# Realtime Support

Report Created

Evidence Added

Review Completed

Report Archived

---

# Events

IncidentReportCreated

EvidenceAttached

IncidentReviewed

IncidentClosed

LessonsLearnedPublished

---

# Audit Strategy

Track

Creation

Edits

Evidence

Reviews

Submission

Archival

---

# Database Ownership

Schema

safety

---

Table

incident_reports

---

Primary Key

UUID v7

---

Indexes

Emergency Event ID

Report Type

Severity

Occurred At

---

# Database Columns

incident_report_id

emergency_event_id

report_type

severity

summary

description

location

reporter_id

resolution

lessons_learned

metadata

occurred_at

created_at

updated_at

---

# API Endpoints

GET

/emergencies/{emergencyEventId}/report

POST

/emergencies/{emergencyEventId}/report

PATCH

/incident-reports/{incidentReportId}

POST

/incident-reports/{incidentReportId}/submit

GET

/incident-reports/search

---

# Performance Requirements

Report Save

<100 ms

Evidence Linking

<200 ms

Semantic Search

<300 ms

---

# Testing Requirements

Versioning

Evidence Integrity

Timeline Accuracy

Search

Performance

---

# Future Evolution

Insurance Claim Export

Regulatory Reporting

Anonymous Incident Sharing

Fleet Safety Analytics

AI Root Cause Assistance

Cross-Trip Safety Benchmarking

---

# Entity Summary

ENT-603 (Incident Report) captures structured documentation for safety-related incidents within Project Atlas.

By combining factual timelines, evidence, participants, response actions, outcomes, and lessons learned, Atlas transforms isolated incidents into reusable operational knowledge that improves future preparedness, reporting, and AI-assisted safety analysis.

---

# Next Entity

ENT-604

Medical Profile

Represents a member's optional medical and emergency health information, including allergies, medications, conditions, blood type, emergency instructions, and consent-controlled access for use during safety workflows.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 08
#
# SAFETY DOMAIN
#
# ENTITY CARD
#
# ENT-604
#
# MEDICAL PROFILE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-604

---

Entity Name

Medical Profile

---

Owner Module

Medical Safety Engine

---

Bounded Context

Safety Domain

---

Aggregate Root

No

Parent Aggregate

Member

---

# Business Purpose

A Medical Profile stores optional health information that may be used during authorized safety workflows.

Rather than acting as a complete medical record, Atlas models a concise emergency medical profile focused on improving preparedness and emergency response while maximizing privacy, user control, and consent.

---

# Responsibilities

Emergency Medical Information

Consent Management

Emergency Summary

Risk Context

Safety Recommendations

Audit

---

# Does NOT Own

Members

Trips

Emergency Events

Medical Documents

Emergency Contacts

---

# Lifecycle

Created

↓

Verified (Optional)

↓

Active

↓

Updated

↓

Archived

---

Alternative

Revoked

Deleted

---

# Business Rules

Medical Profiles are optional.

Access requires explicit consent or an authorized emergency workflow according to configured policies.

Sensitive fields are encrypted.

Every access is audited.

Historical versions are retained according to retention policies.

---

# Relationships

Medical Profile

↓

Member

Medical Profile

↓

Emergency Contact

Medical Profile

↓

Emergency Event

Medical Profile

↓

Medical Documents

Medical Profile

↓

Timeline

---

# Medical Categories

Blood Type

Allergies

Current Medications

Medical Conditions

Emergency Instructions

Mobility Considerations

Dietary Restrictions

Implants / Medical Devices

Primary Physician (Optional)

Insurance Information (Reference Only)

---

# Required Fields

Medical Profile ID

Member ID

Created At

---

# Optional Fields

Blood Type

Allergies

Conditions

Medications

Emergency Instructions

Preferred Hospital

Insurance Reference

Consent Policy

Metadata

---

# Emergency Summary

Blood Type

Critical Allergies

Critical Conditions

Current Medications

Emergency Contacts

Preferred Language

Emergency Instructions

---

Generated automatically.

---

# Consent Model

Owner Only

Trip Members (Specific Roles)

Emergency Coordinators

Emergency Workflow Only

Healthcare Provider Export (Future)

---

Fine-grained permissions.

---

# Privacy Controls

Encryption at Rest

Encryption in Transit

Field-Level Encryption

Consent Logging

Access Auditing

Data Minimization

Retention Policies

---

# AI Integration

AI Uses

Medical Profile (only when authorized)

Trip Activities

Weather

Altitude

Risk Assessment

Emergency Context

---

AI Can

Generate emergency summaries

Highlight activity-specific risks

Recommend preparation

Suggest medication reminders

Translate emergency instructions

---

AI Never

Diagnose conditions

Recommend prescription medications

Share medical information outside authorized workflows

Retain unauthorized copies of medical data

---

# Knowledge Graph

Graph Node

Restricted

Only minimal, non-sensitive relationships are represented.

Sensitive attributes are excluded.

---

# Search Support

Search By

Member

Blood Type

Emergency Flags

Consent Status

(Authorized users only)

---

# Realtime Support

Profile Updated

Consent Changed

Emergency Access Granted

Emergency Summary Generated

---

# Events

MedicalProfileCreated

MedicalProfileUpdated

ConsentGranted

ConsentRevoked

EmergencyMedicalAccessed

EmergencySummaryGenerated

---

# Audit Strategy

Track

Creation

Updates

Every Access

Consent Changes

Emergency Disclosure

---

# Database Ownership

Schema

safety

---

Table

medical_profiles

---

Primary Key

UUID v7

---

Indexes

Member ID

Consent Policy

Updated At

---

# Database Columns

medical_profile_id

member_id

blood_type

allergies_encrypted

conditions_encrypted

medications_encrypted

emergency_instructions_encrypted

consent_policy

preferred_hospital

metadata

created_at

updated_at

---

# API Endpoints

GET

/members/{memberId}/medical-profile

POST

/members/{memberId}/medical-profile

PATCH

/medical-profile/{medicalProfileId}

DELETE

/medical-profile/{medicalProfileId}

POST

/medical-profile/{medicalProfileId}/generate-summary

---

# Performance Requirements

Authorized Lookup

<100 ms

Emergency Summary

<300 ms

Consent Evaluation

<50 ms

---

# Testing Requirements

Encryption

Consent

Access Control

Audit

Emergency Summary

Performance

---

# Future Evolution

FHIR Healthcare Integration

Digital Health Wallet Support

Wearable Device Integration

Offline Emergency QR Card

Medical Translation Packs

Verified Clinical Documents

---

# Entity Summary

ENT-604 (Medical Profile) provides a privacy-first emergency health profile for Project Atlas.

By combining encrypted emergency information, fine-grained consent controls, audit logging, and AI-assisted emergency summaries, Atlas improves preparedness during travel while ensuring that sensitive medical information is only available through authorized workflows.

---

# Next Entity

ENT-605

Risk Assessment

Represents the continuously evaluated safety risk associated with a Trip, activity, route, member, or environment by combining weather, navigation, medical context, location, and operational factors to produce actionable safety guidance.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 08
#
# SAFETY DOMAIN
#
# ENTITY CARD
#
# ENT-605
#
# RISK ASSESSMENT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-605

---

Entity Name

Risk Assessment

---

Owner Module

Risk Intelligence Engine

---

Bounded Context

Safety Domain

---

Aggregate Root

No

Parent Aggregate

Trip

---

# Business Purpose

A Risk Assessment represents the continuously evaluated safety state of a Trip, Route, Activity, Member, or operational context.

Rather than relying on isolated warnings, Atlas combines multiple signals into a dynamic risk model that supports proactive decision-making, safety automation, and AI-assisted recommendations.

---

# Responsibilities

Risk Evaluation

Threat Detection

Risk Scoring

Trend Analysis

Safety Recommendations

Automation Triggers

Analytics

Audit

---

# Does NOT Own

Trips

Routes

Activities

Members

Medical Profiles

Weather

Traffic

Emergency Events

---

# Lifecycle

Initialized

↓

Evaluating

↓

Active

↓

Updated

↓

Resolved

↓

Archived

---

Risk assessments are continuously recalculated.

Historical assessments remain immutable.

---

# Business Rules

Every Risk Assessment references one evaluation scope.

Scores are reproducible from recorded inputs.

Changes generate new assessment versions.

Risk history is retained for analysis.

---

# Relationships

Risk Assessment

↓

Trip

Risk Assessment

↓

Route

Risk Assessment

↓

Activity

Risk Assessment

↓

Member

Risk Assessment

↓

Emergency Event

Risk Assessment

↓

Timeline

---

# Assessment Scopes

Trip

Route

Waypoint

Activity

Member

Vehicle

Destination

Environment

Custom

---

# Required Fields

Risk Assessment ID

Scope Type

Scope ID

Calculated At

Created At

---

# Optional Fields

Risk Score

Risk Level

Summary

Contributing Factors

Confidence

Recommendations

Metadata

---

# Risk Levels

Minimal

Low

Moderate

High

Critical

Extreme

---

# Risk Inputs

Weather

Traffic

Road Conditions

Medical Context

Altitude

Time of Day

Wildlife

Crime Advisories

Trip Progress

Member Separation

Network Coverage

Fatigue Indicators (Future)

---

# Risk Outputs

Overall Score

Category Scores

Trend

Confidence

Recommended Actions

Escalation Needed

---

# Risk Categories

Navigation

Weather

Medical

Security

Environmental

Vehicle

Communication

Financial

Operational

---

# AI Integration

AI Uses

Weather

Traffic

Navigation

Medical Context (when authorized)

Historical Trips

Emergency Events

Destination Knowledge

---

AI Can

Estimate risk

Explain contributing factors

Recommend mitigations

Predict risk trends

Identify recurring hazards

Suggest safer alternatives

---

AI Never

Guarantee safety

Replace official advisories

Override emergency services guidance

---

# Knowledge Graph

Graph Node

Yes

Node Type

RiskAssessment

---

Relationships

EVALUATES

AFFECTS

REFERENCES

GENERATES

MITIGATES

---

Embeddings

Generated

Supports semantic safety reasoning.

---

# Search Support

Search By

Scope

Risk Level

Category

Date

Semantic Search

---

# Realtime Support

Risk Updated

Threshold Exceeded

Recommendation Generated

Risk Resolved

---

# Events

RiskAssessmentCreated

RiskScoreUpdated

ThresholdExceeded

RecommendationIssued

RiskResolved

---

# Audit Strategy

Track

Inputs

Score Changes

Recommendations

Threshold Crossings

AI Explanations

---

# Database Ownership

Schema

safety

---

Table

risk_assessments

---

Primary Key

UUID v7

---

Indexes

Scope Type

Scope ID

Risk Level

Calculated At

---

# Database Columns

risk_assessment_id

scope_type

scope_id

risk_score

risk_level

confidence

summary

recommendations

metadata

calculated_at

created_at

updated_at

---

# API Endpoints

GET

/risk-assessments/{riskAssessmentId}

GET

/trips/{tripId}/risk

POST

/risk-assessments/recalculate

GET

/risk-assessments/history

---

# Performance Requirements

Risk Evaluation

<500 ms

Threshold Detection

<100 ms

Realtime Update

<150 ms

---

# Testing Requirements

Score Calculation

Threshold Rules

Trend Analysis

Recommendations

Performance

---

# Future Evolution

Machine Learning Risk Models

Satellite Hazard Feeds

Government Advisory Integration

Wearable Sensor Signals

Predictive Fatigue Detection

Regional Risk Intelligence

---

# Entity Summary

ENT-605 (Risk Assessment) provides continuous safety evaluation across Project Atlas.

By combining environmental, operational, medical, and navigational signals into dynamic risk assessments, Atlas enables proactive safety guidance, automated workflows, and AI-assisted decision support that helps travelers reduce risk before incidents occur.

---

# Next Entity

ENT-606

Safety Recommendation

Represents AI-assisted or rule-based guidance generated from Risk Assessments, Emergency Events, Navigation, Weather, Medical context, and Trip status, providing actionable recommendations to improve traveler safety.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 08
#
# SAFETY DOMAIN
#
# ENTITY CARD
#
# ENT-606
#
# SAFETY RECOMMENDATION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-606

---

Entity Name

Safety Recommendation

---

Owner Module

Safety Recommendation Engine

---

Bounded Context

Safety Domain

---

Aggregate Root

No

Parent Aggregate

Risk Assessment (ENT-605)

---

# Business Purpose

A Safety Recommendation represents actionable guidance generated from Risk Assessments, Emergency Events, Navigation, Weather, Medical context, and Trip state.

Rather than presenting warnings alone, Atlas provides prioritized recommendations that help travelers reduce risk, improve preparedness, and respond effectively to changing conditions.

Recommendations may be AI-assisted, rule-based, or hybrid.

---

# Responsibilities

Actionable Guidance

Recommendation Prioritization

Alternative Suggestions

Follow-up Tracking

Safety Automation

AI Assistance

Audit

---

# Does NOT Own

Risk Assessments

Emergency Events

Trips

Members

Navigation

Weather

Medical Profiles

---

# Lifecycle

Generated

↓

Reviewed

↓

Presented

↓

Accepted

↓

Completed

↓

Archived

---

Alternative

Dismissed

Expired

Superseded

---

# Business Rules

Every recommendation references one or more safety signals.

Recommendations never modify Trip state automatically.

Recommendations may expire.

Historical recommendations remain available for learning.

---

# Relationships

Safety Recommendation

↓

Risk Assessment

Safety Recommendation

↓

Emergency Event

Safety Recommendation

↓

Trip

Safety Recommendation

↓

Navigation Session

Safety Recommendation

↓

Timeline

Safety Recommendation

↓

Knowledge Graph

---

# Recommendation Types

Preventive

Corrective

Emergency

Medical

Navigation

Weather

Equipment

Communication

Operational

Custom

---

# Required Fields

Recommendation ID

Recommendation Type

Generated At

Created At

---

# Optional Fields

Priority

Confidence

Reason

Alternative Options

Expiration

Action Items

Metadata

---

# Priority Levels

Informational

Low

Medium

High

Critical

---

# Recommendation Structure

Recommendation

↓

Reason

↓

Expected Benefit

↓

Alternative

↓

Estimated Impact

↓

Confidence

---

# Action Examples

Delay Departure

Change Route

Increase Rest

Refuel

Seek Shelter

Contact Emergency Contact

Visit Hospital

Regroup Members

Download Offline Maps

Pause Activity

---

# AI Integration

AI Uses

Risk Assessments

Weather

Navigation

Medical Context (when authorized)

Traffic

Activities

Historical Trips

---

AI Can

Prioritize recommendations

Explain reasoning

Suggest alternatives

Estimate benefits

Adapt recommendations to trip context

Summarize safety situation

---

AI Never

Guarantee outcomes

Replace official emergency guidance

Issue medical diagnoses

Force user actions

---

# Knowledge Graph

Graph Node

Yes

Node Type

SafetyRecommendation

---

Relationships

MITIGATES

ADDRESSES

REFERENCES

GENERATED_FROM

---

Embeddings

Generated

Supports semantic recommendation retrieval.

---

# Search Support

Search By

Trip

Recommendation Type

Priority

Date

Semantic Search

---

# Realtime Support

Recommendation Generated

Recommendation Updated

Recommendation Accepted

Recommendation Expired

---

# Events

SafetyRecommendationGenerated

RecommendationPresented

RecommendationAccepted

RecommendationDismissed

RecommendationExpired

---

# Audit Strategy

Track

Generation

Presentation

Acceptance

Dismissal

Expiration

AI Explanation

---

# Database Ownership

Schema

safety

---

Table

safety_recommendations

---

Primary Key

UUID v7

---

Indexes

Trip ID

Priority

Recommendation Type

Generated At

---

# Database Columns

recommendation_id

trip_id

risk_assessment_id

recommendation_type

priority

confidence

reason

recommended_action

alternative_actions

expiration_time

metadata

generated_at

created_at

updated_at

---

# API Endpoints

GET

/trips/{tripId}/safety-recommendations

GET

/safety-recommendations/{recommendationId}

POST

/safety-recommendations/generate

PATCH

/safety-recommendations/{recommendationId}

POST

/safety-recommendations/{recommendationId}/accept

POST

/safety-recommendations/{recommendationId}/dismiss

---

# Performance Requirements

Recommendation Generation

<500 ms

Priority Evaluation

<100 ms

Realtime Broadcast

<150 ms

---

# Testing Requirements

Recommendation Logic

Prioritization

Expiration

AI Explanations

Performance

---

# Future Evolution

Predictive Safety Plans

Regional Safety Playbooks

Wearable-Based Guidance

Offline Recommendation Packs

Adaptive Learning Models

Community Safety Intelligence

---

# Entity Summary

ENT-606 (Safety Recommendation) provides actionable safety guidance for Project Atlas.

By combining risk assessments, environmental context, navigation, medical information, and AI-assisted reasoning, Atlas transforms safety analysis into practical recommendations that help travelers make informed decisions before incidents occur.

---

# End of Safety Domain

Safety Domain Entities

✓ ENT-600 Emergency Contact

✓ ENT-601 Emergency Event

✓ ENT-602 Safety Check-in

✓ ENT-603 Incident Report

✓ ENT-604 Medical Profile

✓ ENT-605 Risk Assessment

✓ ENT-606 Safety Recommendation

---

# Next Part

Volume 04

Part 09

Intelligence & AI Domain

Entities

ENT-700 AI Assistant

ENT-701 AI Memory

ENT-702 Recommendation

ENT-703 Prediction

ENT-704 Insight

ENT-705 Knowledge Node

ENT-706 Decision Explanation

The Intelligence & AI Domain will orchestrate the platform's reasoning capabilities, providing context-aware assistance, memory, recommendations, predictions, explainability, and continuous learning across every Atlas domain.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 09
#
# INTELLIGENCE & AI DOMAIN
#
# ENTITY CARD
#
# ENT-700
#
# AI ASSISTANT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-700

---

Entity Name

AI Assistant

---

Owner Module

AI Orchestration Engine

---

Bounded Context

Intelligence & AI Domain

---

Aggregate Root

Yes

AI Assistant is the aggregate root for conversational intelligence.

---

# Business Purpose

The AI Assistant represents the intelligent orchestration layer responsible for understanding user intent, gathering context, coordinating tools and domain services, generating responses, and explaining reasoning across the Atlas platform.

Rather than functioning as a standalone language model, Atlas AI operates as a context-aware decision-support system built on orchestrated reasoning.

---

# Responsibilities

Intent Understanding

Context Assembly

Tool Orchestration

Knowledge Retrieval

Reasoning

Response Generation

Explanation

Audit

---

# Does NOT Own

Trips

Members

Budgets

Navigation

Safety

Knowledge Graph

AI Memory

Recommendations

---

# Lifecycle

Initialized

↓

Context Loaded

↓

Reasoning

↓

Tool Execution

↓

Response Generated

↓

Verified

↓

Completed

---

Alternative

Cancelled

Failed

Timeout

Fallback

---

# Business Rules

Every AI interaction is linked to a user or workspace.

The assistant retrieves only authorized context.

Reasoning is reproducible from recorded inputs where practical.

Sensitive information follows consent policies.

---

# Relationships

AI Assistant

↓

AI Memory

AI Assistant

↓

Knowledge Graph

AI Assistant

↓

Recommendations

AI Assistant

↓

Predictions

AI Assistant

↓

Insights

AI Assistant

↓

Decision Explanations

AI Assistant

↓

Timeline

---

# Supported Capabilities

Trip Planning

Budget Assistance

Navigation

Safety Guidance

Conversation

Scheduling

Knowledge Retrieval

Decision Support

Summarization

Translation

Custom Skills

---

# Required Fields

Assistant ID

Interaction ID

Created At

---

# Optional Fields

Intent

Conversation Context

Tool Calls

Reasoning Summary

Confidence

Execution Time

Metadata

---

# Processing Pipeline

User Request

↓

Intent Detection

↓

Context Collection

↓

Permission Evaluation

↓

Knowledge Retrieval

↓

Tool Execution

↓

Reasoning

↓

Verification

↓

Response

↓

Explanation

---

# Context Sources

Trip

Planning

Navigation

Safety

Communication

Finance

Knowledge Graph

Timeline

Weather

Traffic

User Preferences

---

# Tool Categories

Planner

Navigator

Risk Engine

Budget Engine

Knowledge Search

Translation

Notification

Scheduling

Document Analysis

External APIs

---

# AI Integration

Primary LLM

Secondary LLM

Embedding Models

Classification Models

Prediction Models

Ranking Models

---

Supports multi-model orchestration.

---

# Knowledge Graph

Graph Node

Yes

Node Type

AIAssistant

---

Relationships

USES

QUERIES

GENERATES

EXPLAINS

ASSISTS

---

Embeddings

Generated

Supports semantic conversation continuity.

---

# Search Support

Search By

Intent

Trip

Workspace

Interaction

Date

Semantic Search

---

# Realtime Support

Context Updated

Tool Completed

Response Streaming

Reasoning Updated

---

# Events

AIInteractionStarted

ContextLoaded

ToolExecuted

ReasoningCompleted

ResponseGenerated

ExplanationGenerated

---

# Audit Strategy

Track

Inputs

Tools

Model Version

Execution

Context Sources

Explanation

---

# Database Ownership

Schema

intelligence

---

Table

ai_interactions

---

Primary Key

UUID v7

---

Indexes

Workspace ID

Interaction ID

Intent

Created At

---

# Database Columns

interaction_id

assistant_id

workspace_id

intent

reasoning_summary

confidence

tool_calls

execution_time

metadata

created_at

updated_at

---

# API Endpoints

POST

/ai/chat

GET

/ai/interactions/{interactionId}

GET

/ai/history

POST

/ai/explain

POST

/ai/retry

---

# Performance Requirements

Intent Detection

<100 ms

Context Assembly

<300 ms

Tool Coordination

<500 ms

Streaming Start

<1 sec

---

# Testing Requirements

Intent Recognition

Context Assembly

Permission Enforcement

Tool Routing

Explanation

Performance

---

# Future Evolution

Multi-Agent Collaboration

Offline AI

On-Device Models

Voice-First Assistant

Personalized Reasoning

Federated Learning

---

# Entity Summary

ENT-700 (AI Assistant) is the orchestration layer for intelligence across Project Atlas.

By coordinating context retrieval, domain services, tools, knowledge, and language models, it delivers explainable, context-aware assistance rather than isolated chatbot responses, enabling intelligent decision support throughout the platform.

---

# Next Entity

ENT-701

AI Memory

Represents structured long-term and session-scoped memory used by the AI Assistant to retain relevant context, preferences, and historical interactions while respecting privacy, consent, and retention policies.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 09
#
# INTELLIGENCE & AI DOMAIN
#
# ENTITY CARD
#
# ENT-701
#
# AI MEMORY
#
# ==============================================================================

# Entity Information

Entity ID

ENT-701

---

Entity Name

AI Memory

---

Owner Module

Memory Engine

---

Bounded Context

Intelligence & AI Domain

---

Aggregate Root

No

Parent Aggregate

AI Assistant (ENT-700)

---

# Business Purpose

AI Memory represents structured, permission-aware knowledge retained by the AI Assistant across interactions.

Unlike raw conversation history, Atlas Memory stores validated facts, preferences, patterns, and contextual knowledge that improve future reasoning while respecting privacy, consent, and retention policies.

---

# Responsibilities

Memory Storage

Knowledge Retention

Memory Retrieval

Importance Scoring

Validation

Forgetting Policies

Privacy Enforcement

Audit

---

# Does NOT Own

Users

Trips

Knowledge Graph

Recommendations

Predictions

---

# Lifecycle

Observed

↓

Candidate

↓

Validated

↓

Stored

↓

Retrieved

↓

Updated

↓

Archived

---

Alternative

Rejected

Expired

Forgotten

---

# Business Rules

Only validated information becomes long-term memory.

Every memory has a confidence score.

Conflicting memories are versioned rather than overwritten.

Sensitive memories require explicit consent.

Memory expiration follows configurable retention policies.

---

# Relationships

AI Memory

↓

AI Assistant

AI Memory

↓

Knowledge Graph

AI Memory

↓

Trips

AI Memory

↓

Recommendations

AI Memory

↓

Timeline

---

# Memory Types

Working Memory

Session Memory

Trip Memory

Preference Memory

Semantic Memory

Procedural Memory

Episodic Memory

Organizational Memory

Custom

---

# Required Fields

Memory ID

Memory Type

Created At

---

# Optional Fields

Subject

Category

Confidence

Importance

Expiration

Source

Summary

Metadata

---

# Memory Structure

Observation

↓

Classification

↓

Confidence

↓

Importance

↓

Retention Policy

↓

Knowledge Link

↓

Storage

---

# Memory Categories

Preferences

Facts

Goals

Habits

Constraints

Trip History

Decisions

AI Learnings

Custom

---

# Retrieval Strategy

Recent

Relevant

High Confidence

Permission Allowed

Context Matching

Semantic Similarity

---

# Forgetting Policies

Manual Removal

Expiration

Low Importance

Conflict Resolution

Consent Revocation

Retention Rules

---

# AI Integration

AI Uses

Conversation

Timeline

Knowledge Graph

Trip Context

Preferences

Historical Trips

Recommendations

---

AI Can

Retrieve relevant memories

Update confidence

Merge duplicates

Summarize history

Recommend retention

---

AI Never

Retain prohibited sensitive information without authorization

Invent memories

Ignore deletion requests

---

# Knowledge Graph

Graph Node

Yes

Node Type

Memory

---

Relationships

REMEMBERS

REFERENCES

SUPPORTS

GENERATED_FROM

---

Embeddings

Generated

Supports semantic memory retrieval.

---

# Search Support

Search By

Category

Subject

Trip

Importance

Semantic Search

---

# Realtime Support

Memory Stored

Memory Updated

Memory Expired

Memory Deleted

---

# Events

MemoryObserved

MemoryValidated

MemoryStored

MemoryUpdated

MemoryExpired

MemoryDeleted

---

# Audit Strategy

Track

Creation

Updates

Retrieval

Deletion

Consent Changes

---

# Database Ownership

Schema

intelligence

---

Table

ai_memories

---

Primary Key

UUID v7

---

Indexes

Memory Type

Importance

Confidence

Created At

---

# Database Columns

memory_id

memory_type

subject

category

confidence

importance

summary

retention_policy

expiration_time

source

metadata

created_at

updated_at

---

# API Endpoints

GET

/ai/memory

POST

/ai/memory

PATCH

/ai/memory/{memoryId}

DELETE

/ai/memory/{memoryId}

POST

/ai/memory/search

---

# Performance Requirements

Memory Retrieval

<100 ms

Semantic Search

<250 ms

Memory Storage

<150 ms

---

# Testing Requirements

Retrieval Accuracy

Retention Policies

Permission Enforcement

Conflict Resolution

Performance

---

# Future Evolution

Federated Memory

On-Device Memory

Cross-Workspace Memory

Adaptive Forgetting

Multi-Agent Shared Memory

Memory Distillation

---

# Entity Summary

ENT-701 (AI Memory) provides structured long-term knowledge for the Atlas AI Assistant.

By retaining validated preferences, facts, patterns, and contextual information instead of raw conversation logs, Atlas enables personalized, explainable, and privacy-aware intelligence that improves over time while respecting user control and retention policies.

---

# Next Entity

ENT-702

Recommendation

Represents personalized suggestions generated by the AI Assistant across planning, navigation, finance, safety, and collaboration domains based on context, goals, historical knowledge, and predictive analysis.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 09
#
# INTELLIGENCE & AI DOMAIN
#
# ENTITY CARD
#
# ENT-702
#
# RECOMMENDATION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-702

---

Entity Name

Recommendation

---

Owner Module

Recommendation Intelligence Engine

---

Bounded Context

Intelligence & AI Domain

---

Aggregate Root

No

Parent Aggregate

AI Assistant (ENT-700)

---

# Business Purpose

A Recommendation represents a personalized suggestion generated by the AI Assistant using contextual reasoning across Planning, Navigation, Finance, Safety, Communication, and historical knowledge.

Rather than producing generic suggestions, Atlas recommendations are explainable, context-aware, and tailored to current goals, constraints, and user preferences.

---

# Responsibilities

Recommendation Generation

Context Evaluation

Ranking

Alternative Generation

Explanation

Confidence Estimation

Feedback Collection

Audit

---

# Does NOT Own

Trips

Activities

Budgets

Routes

Members

AI Memory

Predictions

---

# Lifecycle

Generated

↓

Ranked

↓

Presented

↓

Accepted

↓

Applied

↓

Archived

---

Alternative

Rejected

Expired

Superseded

---

# Business Rules

Recommendations always include a rationale.

Recommendations may expire as context changes.

Recommendations are reproducible from recorded inputs where feasible.

User feedback influences future ranking models.

---

# Relationships

Recommendation

↓

Trip

Recommendation

↓

AI Memory

Recommendation

↓

Knowledge Graph

Recommendation

↓

Prediction

Recommendation

↓

Timeline

Recommendation

↓

Decision Explanation

---

# Recommendation Types

Activity

Restaurant

Accommodation

Route

Budget

Safety

Packing

Transportation

Schedule

Weather

Communication

Custom

---

# Required Fields

Recommendation ID

Recommendation Type

Generated At

Created At

---

# Optional Fields

Priority

Confidence

Reason

Alternatives

Expiration

Estimated Benefit

Metadata

---

# Recommendation Structure

Recommendation

↓

Supporting Evidence

↓

Expected Benefit

↓

Trade-offs

↓

Alternatives

↓

Confidence

---

# Context Sources

Trip Plan

Budget

Weather

Traffic

Navigation

Safety

Activities

Preferences

AI Memory

Knowledge Graph

Timeline

---

# Ranking Factors

Relevance

Cost

Time

Safety

Distance

Popularity

Historical Success

User Preferences

Group Consensus

---

# AI Integration

AI Uses

Memory

Knowledge Graph

Predictions

Navigation

Risk Assessments

Historical Trips

Group Preferences

---

AI Can

Rank recommendations

Explain reasoning

Adapt suggestions

Generate alternatives

Estimate benefits

Learn from feedback

---

AI Never

Present recommendations as guaranteed outcomes

Ignore explicit user constraints

Hide meaningful trade-offs

---

# Knowledge Graph

Graph Node

Yes

Node Type

Recommendation

---

Relationships

SUGGESTS

OPTIMIZES

REFERENCES

GENERATED_FROM

---

Embeddings

Generated

Supports semantic recommendation retrieval.

---

# Search Support

Search By

Recommendation Type

Trip

Priority

Confidence

Semantic Search

---

# Realtime Support

Recommendation Generated

Recommendation Updated

Recommendation Accepted

Recommendation Expired

---

# Events

RecommendationGenerated

RecommendationRanked

RecommendationPresented

RecommendationAccepted

RecommendationRejected

RecommendationExpired

---

# Audit Strategy

Track

Inputs

Ranking

Presentation

Acceptance

Feedback

Model Version

---

# Database Ownership

Schema

intelligence

---

Table

recommendations

---

Primary Key

UUID v7

---

Indexes

Recommendation Type

Priority

Confidence

Generated At

---

# Database Columns

recommendation_id

trip_id

recommendation_type

priority

confidence

reason

estimated_benefit

alternatives

expiration_time

metadata

generated_at

created_at

updated_at

---

# API Endpoints

GET

/ai/recommendations

GET

/recommendations/{recommendationId}

POST

/recommendations/generate

POST

/recommendations/{recommendationId}/accept

POST

/recommendations/{recommendationId}/reject

---

# Performance Requirements

Recommendation Generation

<500 ms

Ranking

<200 ms

Realtime Update

<150 ms

---

# Testing Requirements

Ranking

Context Evaluation

Explanations

Alternatives

Feedback

Performance

---

# Future Evolution

Reinforcement Learning

Community-Based Recommendations

Federated Personalization

Contextual Multi-Agent Planning

Cross-Trip Recommendation Models

---

# Entity Summary

ENT-702 (Recommendation) delivers personalized, explainable suggestions across the Atlas platform.

By combining contextual information, historical knowledge, AI memory, and predictive reasoning, Atlas generates recommendations that adapt to changing conditions while clearly communicating rationale, confidence, and available alternatives.

---

# Next Entity

ENT-703

Prediction

Represents AI-generated forecasts about future trip outcomes, such as arrival times, budget usage, weather impacts, activity completion, safety risks, delays, and resource consumption, enabling proactive decision-making.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 09
#
# INTELLIGENCE & AI DOMAIN
#
# ENTITY CARD
#
# ENT-703
#
# PREDICTION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-703

---

Entity Name

Prediction

---

Owner Module

Prediction Engine

---

Bounded Context

Intelligence & AI Domain

---

Aggregate Root

No

Parent Aggregate

AI Assistant (ENT-700)

---

# Business Purpose

A Prediction represents an AI-generated forecast about future states of a Trip, Route, Budget, Activity, Safety condition, or operational outcome.

Rather than presenting static estimates, Atlas Predictions combine historical behavior, realtime signals, contextual knowledge, and AI reasoning to anticipate likely future outcomes and support proactive decision-making.

---

# Responsibilities

Forecast Generation

Trend Analysis

Confidence Estimation

Scenario Evaluation

Outcome Projection

Explanation

Audit

---

# Does NOT Own

Trips

Recommendations

Risk Assessments

Budgets

Routes

Activities

---

# Lifecycle

Generated

↓

Validated

↓

Presented

↓

Updated

↓

Resolved

↓

Archived

---

Alternative

Expired

Superseded

---

# Business Rules

Predictions always include a confidence score.

Predictions reference supporting evidence.

Historical predictions remain available for accuracy evaluation.

Expired predictions are never overwritten.

---

# Relationships

Prediction

↓

Trip

Prediction

↓

Recommendation

Prediction

↓

Knowledge Graph

Prediction

↓

AI Memory

Prediction

↓

Timeline

Prediction

↓

Decision Explanation

---

# Prediction Types

ETA

Budget

Weather Impact

Traffic Delay

Risk Trend

Activity Completion

Fuel Usage

Battery Usage

Group Arrival

Reservation Timing

Custom

---

# Required Fields

Prediction ID

Prediction Type

Generated At

Created At

---

# Optional Fields

Confidence

Forecast Value

Forecast Window

Supporting Factors

Alternative Scenarios

Metadata

---

# Prediction Structure

Forecast

↓

Confidence

↓

Supporting Evidence

↓

Risk Factors

↓

Alternatives

↓

Expected Outcome

---

# Prediction Inputs

Historical Trips

Realtime Navigation

Weather

Traffic

Budget

Activities

AI Memory

Knowledge Graph

User Preferences

---

# Scenario Analysis

Best Case

Expected Case

Worst Case

Alternative Plan

---

# Accuracy Tracking

Predicted Value

↓

Actual Outcome

↓

Prediction Error

↓

Model Learning

---

# AI Integration

AI Uses

Historical Data

Current Context

Recommendations

Risk Assessments

Navigation

Budget

Timeline

---

AI Can

Predict delays

Forecast expenses

Estimate completion

Anticipate risks

Generate scenarios

Estimate confidence

---

AI Never

Present predictions as certainties

Suppress uncertainty

Ignore contradictory evidence

---

# Knowledge Graph

Graph Node

Yes

Node Type

Prediction

---

Relationships

FORECASTS

SUPPORTS

INFLUENCES

GENERATED_FROM

---

Embeddings

Generated

Supports semantic forecasting.

---

# Search Support

Search By

Prediction Type

Trip

Confidence

Date

Semantic Search

---

# Realtime Support

Prediction Generated

Prediction Updated

Prediction Resolved

Accuracy Recorded

---

# Events

PredictionGenerated

PredictionUpdated

PredictionResolved

PredictionEvaluated

AccuracyMeasured

---

# Audit Strategy

Track

Inputs

Model Version

Confidence

Updates

Accuracy

---

# Database Ownership

Schema

intelligence

---

Table

predictions

---

Primary Key

UUID v7

---

Indexes

Prediction Type

Confidence

Generated At

Trip ID

---

# Database Columns

prediction_id

trip_id

prediction_type

forecast_value

confidence

forecast_window

supporting_factors

actual_outcome

prediction_error

metadata

generated_at

created_at

updated_at

---

# API Endpoints

GET

/ai/predictions

GET

/predictions/{predictionId}

POST

/predictions/generate

GET

/predictions/history

POST

/predictions/evaluate

---

# Performance Requirements

Prediction Generation

<700 ms

Scenario Analysis

<1 sec

Accuracy Evaluation

<500 ms

Realtime Update

<200 ms

---

# Testing Requirements

Forecast Accuracy

Confidence Calibration

Scenario Analysis

Historical Evaluation

Performance

---

# Future Evolution

Online Learning Models

Federated Prediction

Simulation-Based Forecasting

Digital Twin Integration

Personalized Prediction Models

Cross-Trip Benchmarking

---

# Entity Summary

ENT-703 (Prediction) provides forward-looking intelligence for Project Atlas.

By combining historical knowledge, realtime context, AI reasoning, and scenario analysis, Atlas predicts future trip outcomes while communicating confidence, uncertainty, and alternative possibilities to support proactive planning and decision-making.

---

# Next Entity

ENT-704

Insight

Represents AI-generated observations, patterns, and synthesized knowledge derived from trips, events, finances, navigation, safety, and user behavior, helping users understand what has happened and why.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 09
#
# INTELLIGENCE & AI DOMAIN
#
# ENTITY CARD
#
# ENT-704
#
# INSIGHT
#
# ==============================================================================

# Entity Information

Entity ID

ENT-704

---

Entity Name

Insight

---

Owner Module

Insight Engine

---

Bounded Context

Intelligence & AI Domain

---

Aggregate Root

No

Parent Aggregate

AI Assistant (ENT-700)

---

# Business Purpose

An Insight represents AI-generated understanding derived from patterns, trends, relationships, and operational history across the Atlas platform.

Unlike Predictions or Recommendations, Insights explain what has happened, why it happened, and what recurring patterns exist, helping users improve future planning and decision-making.

---

# Responsibilities

Pattern Detection

Trend Analysis

Correlation Discovery

Root Cause Identification

Explanation

Knowledge Synthesis

Audit

---

# Does NOT Own

Trips

Recommendations

Predictions

Knowledge Graph

AI Memory

Timeline

---

# Lifecycle

Generated

↓

Validated

↓

Presented

↓

Accepted

↓

Archived

---

Alternative

Superseded

Expired

---

# Business Rules

Insights reference supporting evidence.

Insights include confidence estimates.

Insights never imply causation without supporting evidence.

Historical insights remain searchable.

---

# Relationships

Insight

↓

Trip

Insight

↓

Prediction

Insight

↓

Recommendation

Insight

↓

Knowledge Graph

Insight

↓

Timeline

Insight

↓

Decision Explanation

---

# Insight Types

Behavioral

Financial

Navigation

Safety

Operational

Travel Pattern

Collaboration

AI Learning

Custom

---

# Required Fields

Insight ID

Insight Type

Generated At

Created At

---

# Optional Fields

Summary

Supporting Evidence

Confidence

Trend

Impact

Recommendations

Metadata

---

# Insight Structure

Observation

↓

Evidence

↓

Pattern

↓

Explanation

↓

Implications

↓

Suggested Follow-up

---

# Sources

Timeline

Navigation Events

Financial Ledger

Safety Events

Recommendations

Predictions

AI Memory

Knowledge Graph

---

# Trend Analysis

Increasing

Stable

Decreasing

Seasonal

Recurring

Anomalous

---

# AI Integration

AI Uses

Historical Trips

Timeline

Knowledge Graph

Predictions

Recommendations

Risk Assessments

User Preferences

---

AI Can

Identify trends

Explain anomalies

Summarize operations

Detect recurring behaviors

Suggest optimizations

Connect related events

---

AI Never

Present weak correlations as proven facts

Hide contradictory evidence

---

# Knowledge Graph

Graph Node

Yes

Node Type

Insight

---

Relationships

EXPLAINS

IDENTIFIES

CONNECTS

GENERATED_FROM

---

Embeddings

Generated

Supports semantic knowledge retrieval.

---

# Search Support

Search By

Insight Type

Trip

Trend

Confidence

Semantic Search

---

# Realtime Support

Insight Generated

Insight Updated

Trend Changed

---

# Events

InsightGenerated

InsightValidated

InsightPublished

TrendUpdated

InsightArchived

---

# Audit Strategy

Track

Generation

Evidence

Confidence

Publication

Model Version

---

# Database Ownership

Schema

intelligence

---

Table

insights

---

Primary Key

UUID v7

---

Indexes

Insight Type

Confidence

Generated At

Trip ID

---

# Database Columns

insight_id

trip_id

insight_type

summary

confidence

trend

impact

supporting_evidence

metadata

generated_at

created_at

updated_at

---

# API Endpoints

GET

/ai/insights

GET

/insights/{insightId}

POST

/insights/generate

GET

/insights/history

---

# Performance Requirements

Insight Generation

<1 sec

Pattern Detection

<800 ms

Semantic Search

<300 ms

---

# Testing Requirements

Pattern Detection

Evidence Linking

Trend Analysis

Confidence

Performance

---

# Future Evolution

Cross-Organization Insights

Federated Learning

Community Benchmarking

Longitudinal Trend Analysis

Knowledge Distillation

Explainable Analytics

---

# Entity Summary

ENT-704 (Insight) captures synthesized understanding across Project Atlas.

By detecting recurring patterns, explaining historical outcomes, and linking evidence from multiple domains, Atlas transforms raw operational data into actionable knowledge that helps users understand and continuously improve their travel experiences.

---

# Next Entity

ENT-705

Knowledge Node

Represents a structured unit of knowledge within the Atlas Knowledge Graph, connecting entities, facts, relationships, and AI-generated understanding into a reusable semantic network that supports reasoning, search, and explainability.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 09
#
# INTELLIGENCE & AI DOMAIN
#
# ENTITY CARD
#
# ENT-705
#
# KNOWLEDGE NODE
#
# ==============================================================================

# Entity Information

Entity ID

ENT-705

---

Entity Name

Knowledge Node

---

Owner Module

Knowledge Graph Engine

---

Bounded Context

Intelligence & AI Domain

---

Aggregate Root

Yes

Knowledge Node is the aggregate root of the Knowledge Graph.

---

# Business Purpose

A Knowledge Node represents a semantic unit of knowledge within the Atlas Knowledge Graph.

Unlike relational records, Knowledge Nodes capture entities, concepts, relationships, facts, and AI-generated understanding, enabling semantic search, contextual reasoning, explainability, and intelligent traversal across the entire platform.

---

# Responsibilities

Knowledge Representation

Relationship Management

Semantic Search

Context Linking

Reasoning Support

Knowledge Evolution

Audit

---

# Does NOT Own

Trips

Members

Budgets

Activities

Routes

Predictions

Recommendations

Insights

---

# Lifecycle

Created

↓

Linked

↓

Validated

↓

Indexed

↓

Referenced

↓

Archived

---

Alternative

Merged

Deprecated

Superseded

---

# Business Rules

Every Knowledge Node has a globally unique identifier.

Relationships are typed and directional.

Nodes remain stable even if source entities change.

Knowledge evolution preserves history.

---

# Relationships

Knowledge Node

↓

Knowledge Node

Knowledge Node

↓

Trip

Knowledge Node

↓

Member

Knowledge Node

↓

Route

Knowledge Node

↓

Activity

Knowledge Node

↓

Insight

Knowledge Node

↓

Recommendation

---

# Node Types

Trip

Member

Activity

Budget

Expense

Location

Route

Waypoint

Photo

Document

Weather

Risk

Recommendation

Prediction

Insight

Concept

Custom

---

# Required Fields

Knowledge Node ID

Node Type

Created At

---

# Optional Fields

Title

Summary

Embedding

Confidence

Source

Metadata

---

# Relationship Types

PART_OF

CONNECTED_TO

DEPENDS_ON

GENERATED_FROM

LOCATED_AT

CAUSED_BY

MITIGATES

OPTIMIZES

SIMILAR_TO

RELATED_TO

---

# Knowledge Structure

Node

↓

Relationships

↓

Evidence

↓

Embeddings

↓

Reasoning

↓

AI Context

---

# Knowledge Sources

Timeline

Trips

Navigation

Finance

Safety

Communication

AI Memory

Insights

Predictions

Recommendations

---

# AI Integration

AI Uses

Graph Traversal

Semantic Search

Context Expansion

Relationship Reasoning

Fact Validation

Knowledge Synthesis

---

AI Can

Traverse relationships

Explain reasoning

Find hidden connections

Expand context

Support RAG

Identify missing knowledge

---

AI Never

Invent unsupported relationships

Ignore confidence levels

Treat inferred knowledge as verified facts

---

# Knowledge Graph

Graph Node

Yes

Node Type

KnowledgeNode

---

Embeddings

Generated

Supports hybrid graph + vector search.

---

# Search Support

Search By

Node Type

Relationship

Semantic Similarity

Embedding

Trip

Concept

---

# Realtime Support

Node Created

Relationship Added

Node Updated

Graph Reindexed

---

# Events

KnowledgeNodeCreated

RelationshipCreated

KnowledgeNodeMerged

KnowledgeGraphIndexed

KnowledgeUpdated

---

# Audit Strategy

Track

Creation

Relationship Changes

Confidence Updates

Reasoning

Graph Evolution

---

# Database Ownership

Schema

knowledge

---

Tables

knowledge_nodes

knowledge_relationships

---

Primary Key

UUID v7

---

Indexes

Node Type

Embedding

Source

Created At

---

# Database Columns

knowledge_node_id

node_type

title

summary

embedding

confidence

source

metadata

created_at

updated_at

---

Relationship Table

relationship_id

source_node

target_node

relationship_type

confidence

metadata

created_at

---

# API Endpoints

GET

/knowledge/nodes/{nodeId}

GET

/knowledge/search

POST

/knowledge/nodes

POST

/knowledge/relationships

GET

/knowledge/graph

---

# Performance Requirements

Graph Lookup

<50 ms

Relationship Traversal

<100 ms

Hybrid Search

<300 ms

---

# Testing Requirements

Relationship Integrity

Graph Traversal

Hybrid Search

Confidence

Performance

---

# Future Evolution

Distributed Knowledge Graph

Temporal Graphs

Multi-Agent Shared Knowledge

Ontology Management

Cross-Workspace Knowledge

Graph Neural Networks

---

# Entity Summary

ENT-705 (Knowledge Node) is the semantic foundation of Project Atlas.

By representing entities, concepts, and their relationships as interconnected knowledge, Atlas enables contextual reasoning, explainable AI, hybrid graph and vector search, and reusable intelligence across every platform domain.

---

# Next Entity

ENT-706

Decision Explanation

Represents a structured explanation describing how an AI-generated recommendation, prediction, insight, or operational decision was produced, including supporting evidence, reasoning steps, confidence, assumptions, and limitations.

# ==============================================================================
# VOLUME 04
# DOMAIN MODEL & DATABASE DESIGN
# PART 09
#
# INTELLIGENCE & AI DOMAIN
#
# ENTITY CARD
#
# ENT-706
#
# DECISION EXPLANATION
#
# ==============================================================================

# Entity Information

Entity ID

ENT-706

---

Entity Name

Decision Explanation

---

Owner Module

Explainability Engine

---

Bounded Context

Intelligence & AI Domain

---

Aggregate Root

No

Parent Aggregate

AI Assistant (ENT-700)

---

# Business Purpose

A Decision Explanation provides a structured explanation describing how an AI-generated recommendation, prediction, insight, or operational decision was produced.

Rather than exposing raw model internals, Atlas communicates evidence, reasoning, confidence, assumptions, trade-offs, and limitations in a user-friendly and auditable manner.

---

# Responsibilities

Explain Decisions

Expose Supporting Evidence

Describe Trade-offs

Communicate Confidence

Highlight Assumptions

Document Limitations

Audit

---

# Does NOT Own

Recommendations

Predictions

Insights

Knowledge Graph

AI Memory

Risk Assessments

---

# Lifecycle

Generated

↓

Reviewed

↓

Presented

↓

Referenced

↓

Archived

---

Alternative

Superseded

Expired

---

# Business Rules

Every explanation references its originating decision.

Evidence is traceable.

Confidence is disclosed.

Assumptions are separated from verified facts.

Historical explanations remain immutable.

---

# Relationships

Decision Explanation

↓

Recommendation

Decision Explanation

↓

Prediction

Decision Explanation

↓

Insight

Decision Explanation

↓

Knowledge Graph

Decision Explanation

↓

Timeline

Decision Explanation

↓

Evidence

---

# Explanation Types

Recommendation

Prediction

Risk Assessment

Navigation

Safety

Budget

Planning

Operational

Custom

---

# Required Fields

Explanation ID

Decision Type

Generated At

Created At

---

# Optional Fields

Summary

Supporting Evidence

Reasoning Steps

Assumptions

Trade-offs

Confidence

Limitations

Metadata

---

# Explanation Structure

Decision

↓

Evidence

↓

Reasoning

↓

Assumptions

↓

Trade-offs

↓

Alternatives

↓

Confidence

↓

Limitations

---

# Evidence Sources

Knowledge Graph

Timeline

AI Memory

Navigation

Weather

Traffic

Finance

Safety

Operational Events

---

# Confidence Levels

Very Low

Low

Moderate

High

Very High

---

# AI Integration

AI Uses

Knowledge Graph

Memory

Predictions

Recommendations

Operational History

Timeline

Risk Assessments

---

AI Can

Explain recommendations

Summarize reasoning

Compare alternatives

Highlight uncertainty

Expose assumptions

Describe evidence

---

AI Never

Fabricate evidence

Hide significant uncertainty

Present assumptions as facts

Reveal restricted information

---

# Knowledge Graph

Graph Node

Yes

Node Type

DecisionExplanation

---

Relationships

EXPLAINS

SUPPORTED_BY

REFERENCES

GENERATED_FROM

---

Embeddings

Generated

Supports semantic explanation retrieval.

---

# Search Support

Search By

Decision Type

Trip

Confidence

Evidence

Semantic Search

---

# Realtime Support

Explanation Generated

Evidence Updated

Explanation Referenced

---

# Events

DecisionExplained

ExplanationPublished

EvidenceLinked

ExplanationArchived

---

# Audit Strategy

Track

Generation

Evidence

Confidence

Presentation

Access

---

# Database Ownership

Schema

intelligence

---

Table

decision_explanations

---

Primary Key

UUID v7

---

Indexes

Decision Type

Generated At

Confidence

Trip ID

---

# Database Columns

explanation_id

trip_id

decision_type

summary

supporting_evidence

reasoning_steps

assumptions

tradeoffs

confidence

limitations

metadata

generated_at

created_at

updated_at

---

# API Endpoints

GET

/ai/explanations

GET

/explanations/{explanationId}

POST

/explanations/generate

GET

/explanations/history

---

# Performance Requirements

Explanation Generation

<500 ms

Evidence Retrieval

<300 ms

Semantic Search

<300 ms

---

# Testing Requirements

Evidence Traceability

Reasoning Accuracy

Confidence

Trade-off Presentation

Performance

---

# Future Evolution

Interactive Explanations

Visual Reasoning Graphs

Counterfactual Explanations

Multi-Agent Reasoning Trace

Personalized Explanation Styles

Regulatory AI Compliance

---

# Entity Summary

ENT-706 (Decision Explanation) provides transparent, evidence-based explanations for AI-generated decisions within Project Atlas.

By exposing supporting evidence, reasoning, assumptions, confidence, trade-offs, and limitations, Atlas builds user trust, enables informed decision-making, and ensures explainable AI across planning, navigation, finance, safety, and collaboration.

---

# End of Intelligence & AI Domain

AI Domain Entities

✓ ENT-700 AI Assistant

✓ ENT-701 AI Memory

✓ ENT-702 Recommendation

✓ ENT-703 Prediction

✓ ENT-704 Insight

✓ ENT-705 Knowledge Node

✓ ENT-706 Decision Explanation

---

# End of Volume 04

Volume 04 Complete

Covered Domains

✓ Planning

✓ Consensus

✓ Finance

✓ Communication

✓ Navigation

✓ Safety

✓ Intelligence & AI

Total Entity Cards

49 Core Entities

Comprehensive cross-domain relationships

Knowledge Graph integration

Event-driven architecture

AI-first design

Provider abstraction

Privacy-aware modeling

Explainability support
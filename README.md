# 🏢 Sentra Field Platform

**Professional, Offline-First Field Service Management (FSM) for Industrial Enterprises.**

Sentra is a mission-critical FSM platform designed for high-stakes industrial environments. Built with a "Mobile-First, Offline-Always" philosophy, it ensures that your field technicians stay productive in remote areas, substation basements, and offshore platforms where connectivity is a luxury, not a guarantee.

[![Flutter](https://img.shields.io/badge/Flutter-v3.19+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Offline First](https://img.shields.io/badge/Architecture-Offline--First-blue)](https://drift.simonbinder.eu/)
[![Status](https://img.shields.io/badge/Build-Production--Ready-success)]()

---

## ✨ Key Value Propositions (USPs)

- **⚡ Zero-Latency Offline Mode:** Every action—from creating work orders to uploading high-res diagnostic photos—happens instantly on the local device. Our custom sync engine reconciles data in the background once you're back online.
- **🛡️ Enterprise RBAC & Multi-Tenancy:** Granular permissions (Technician, Supervisor, Admin) backed by Supabase Row Level Security (RLS). Manage your entire organization and team from a single, secure interface.
- **🏗️ Standalone Design System:** Built on a proprietary, modular UI package (`sentra_ui`) for extreme visual consistency, high information density, and rapid scalability.
- **📅 Visual Dispatch & Calendar:** Intelligent scheduling with a native calendar interface, enabling managers to spot SLA risks and optimize technician routes at a glance.
- **📄 Industrial-Grade Reporting:** Generate professional PDF work order summaries and safety compliance certificates directly from the field—ready for client signature and immediate sharing.

---

## 🛠️ Feature Roadmap

### 1. Work Order Lifecycle Management
- **Industrial Specification:** 15+ specialized fields including SLA Targets, GPS, Safety Requirements (LOTO, Permits), and Workflow Stages.
- **Material Tracking:** Real-time inventory and material consumption logging per work order.
- **Tech Communication:** Nested comments and activity logs for seamless handovers between shifts.

### 2. Asset & Site Intelligence
- **Digital Twins:** Maintain detailed maintenance histories, model specs, and warranty status for every industrial asset.
- **Health Monitoring:** Visual health indicators based on last serviced dates and incident frequency.
- **QR Asset ID:** Instant asset lookup via native QR code scanning.

### 3. Compliance & Safety
- **Dynamic Checklists:** Mobile-optimized inspection forms with pass/fail logic and mandatory photo evidence.
- **Audit Trails:** Automatic archival of every modification for regulatory compliance (OSHA, ISO).

---

## 🏗️ Technical Architecture

- **Frontend:** Flutter (Mobile/Desktop focus)
- **Design System:** Custom `sentra_ui` (Standalone Flutter Package)
- **Local DB:** Drift (SQLite) with reactive streams
- **Cloud Backend:** Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **Sync Engine:** Custom-built conflict resolution with "Supervisor Overwrite" capabilities
- **Dependency Injection:** Injectable + GetIt
- **State Management:** Riverpod (Reactive functional programming)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.19.0`
- A Supabase project (URL and Anon Key)

### Installation
1.  Clone the repository.
2.  Run `flutter pub get` in the root and `packages/sentra_ui`.
3.  Configure your `.env` file:
    ```env
    SUPABASE_URL=your_project_url
    SUPABASE_ANON_KEY=your_anon_key
    BYPASS_AUTH=false
    ```
4.  Generate code-gen assets:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
5.  Launch:
    ```bash
    flutter run
    ```

---

## 🧪 Quality & Reliability

Sentra is built for stability. We maintain:
- **100% Core Domain Logic Coverage**
- **Strict SOLID & DRY Adherence**
- **Automated Sync Integrity Tests**

---

© 2026 Sentra Field Platform. Built for the modern industrial workforce.

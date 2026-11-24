# StockPulse Hybrid

> **Offline-First AI Retail & Warehouse Operations Copilot**  
> Built for the **#BuildHybridAI 2026 Hackathon**

---

## 1. Executive Summary & Problem

Modern warehouse and retail distribution centers suffer from dead zones, steel racking interference, and periodic network disconnects. When warehouse operators depend on pure cloud AI:
- A forklift driver or floor auditor loses scanning capability the moment WiFi drops.
- Cloud roundtrips (800ms - 2000ms) introduce costly latency into high-volume barcode and packing slip workflows.
- Sending repetitive catalog queries to cloud models incurs unnecessary token billing and cloud egress overhead.

**StockPulse Hybrid** solves this with a **Dual-Stage Hybrid Architecture**:
1. **On-Device Stage (Gemini Nano 4)**: Instant, zero-egress structured entity extraction (SKUs, units, anomalies) executing locally in ~30ms with **0ms network dependency**.
2. **Cloud AI Logic Stage (Gemini 2.5 Flash)**: Triggered selectively for deep cross-document margin synthesis, multi-supplier contract reconciliation, and historical price benchmarking.

---

## 2. Core Architecture & Firebase AI Logic

```
   ┌────────────────────────────────────────────────────────┐
   │             StockPulse Hybrid Mobile / Web             │
   └───────────────────────────┬────────────────────────────┘
                               │
                [Hybrid Router: PREFER_ON_DEVICE]
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
   [Local Condition]                     [Complex Condition]
   - Text <= 1,200 chars                 - Cross-catalog margin
   - Offline simulation active            - Multi-supplier variance
   - Force On-Device mode                 - Force Cloud mode
            │                                     │
            ▼                                     ▼
   ┌─────────────────────┐               ┌─────────────────────┐
   │    Gemini Nano 4    │               │  Firebase AI Logic  │
   │  Local NPU / Chrome │               │  (Gemini 2.5 Flash) │
   │   Prompt Engine     │               │  via App Check &    │
   │  Latency: ~30ms     │               │  Remote Config      │
   │  Tokens Saved: 100% │               │  Latency: ~750ms    │
   └─────────────────────┘               └─────────────────────┘
```

### Key Components

- **Hybrid Inference (`PREFER_ON_DEVICE`)**: Automatically prioritizes on-device Nano execution, falling back to Gemini in the cloud when reasoning demands exceed local threshold.
- **Explicit Mode Switcher**: Live three-way toggle in top bar:
  - `Auto (Prefer On-Device)`
  - `Force On-Device`
  - `Force Cloud`
- **Telemetry on Every AI Card**: Real-time telemetry badges showing `inferenceSource` (`ON_DEVICE` vs `IN_CLOUD`), latency in milliseconds, tokens saved, and carbon/cost economy.
- **Firebase App Check**: Initialized with debug provider support for testing and judging environments (`AndroidProvider.debug` and web debug tokens).
- **Cloud Firestore**: Offline persistence enabled (`persistenceEnabled: true`) for inventory items and AI audit logs.
- **Remote Config**: Dynamically manages the `on_device_max_chars` routing threshold and model names without app redeployment.
- **Authentication**: Zero-friction anonymous sign-in with optional email/password credentials.

---

## 3. Core Features

### 1. Smart Shelf & Receipt Scanner (Multimodal Hybrid)
- Ingests supplier delivery receipts, shelf audits, or raw supplier manifests.
- **Stage 1 (Nano 4)**: Parses line items, quantities, and anomalies in under 40ms.
- **Stage 2 (Cloud AI)**: Analyzes blended profit margins and historical supplier pricing variances.

### 2. Natural Language Copilot
- Operational chat bar for warehouse personnel.
- Commands like:
  ```
  "Log 15 units of Trail Runner X9, flag low stock below 5, and summarize today's margin"
  ```
- Extracts structured actions and updates the Firestore catalog.

### 3. Offline/Online Simulator
- Interactive toggle in the top banner: **Simulate Offline Mode**.
- Demonstrates on-device Nano continuing to process queries with **0ms network**, while cloud-dependent synthesis tasks queue cleanly into the **Offline Task Manager**.
- When toggled back online, one-click **Flush Sync** persists pending records.

### 4. Live Analytics Dashboard
- Interactive charts (`fl_chart`):
  - **Inference Split Gauge**: Real-time ratio of on-device vs. cloud requests.
  - **Gross Margin Spread**: Visualizes cost vs. retail spread across top catalog SKUs.
  - **Stock Health & Low Stock Alerts**: Immediate operational visibility.

---

## 4. Visual Design System

Built with a modern **Neo-Bento Dark & Electric Lime/Coral** aesthetic:
- **Deep Obsidian Base**: `#0B0E14`
- **Elevated Bento Cards**: `#141923` with `#242C3D` borders
- **Primary Accent (On-Device / Nano)**: `#C6FF00` (Electric Cyber Lime)
- **Secondary Accent (Cloud / Alerts)**: `#FF5A36` (Sunset Coral)
- **Tertiary Accent (Telemetry)**: `#00E5FF` (Electric Cyan)
- **Typography**: `Space Grotesk` (headings), `Plus Jakarta Sans` (body), `JetBrains Mono` (telemetry).

---

## 5. Running the Application

### Prerequisites
- Flutter SDK (>= 3.24.0)
- Google Chrome (for Web) or Android Studio / AVD (for Android)

### Quick Start (Web)
```bash
cd stockpulse_hybrid
flutter run -d chrome
```

### Quick Start (Android)
```bash
cd stockpulse_hybrid
flutter run -d android
```

### Linking Your Live Firebase Project (Optional)
The project includes a production template `firebase_options.dart`. To bind your own Firebase project:
1. Run `flutterfire configure --project=<your-firebase-project-id>`
2. Provision AI Logic: `npx -y firebase-tools@latest init ailogic`
3. Enable App Check Debug Provider in the Firebase Console under **App Check > Manage Debug Tokens**.

---

## 6. License

Licensed under the [Apache-2.0 License](LICENSE).

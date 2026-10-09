# MARKet

> A digital business presence and geofenced promotion platform empowering Micro, Small, and Medium Enterprises (MSMEs) in Antique to verify business locations, launch 100-meter proximity promotions, and monitor customer engagement.

---

## 🚧 Project Status: Work in Progress (WIP)
This project is currently in an early development phase. **UI designs are inconsistent and core workflows are subject to change.** The codebase serves as an initial functional prototype and architectural skeleton.

---

## 🛠️ Tech Stack
* **Framework:** Flutter
* **Language:** Dart
* **State Management:** Provider (ChangeNotifier / MVVM pattern)
* **Backend / Services:** In-Memory Mock Services (Backend integration pending)

---

## 📁 Project Architecture
An overview of how the repository is structured:

```text
├── lib/
│   ├── data/              # Repositories, data sources, and mock services
│   ├── domain/            # Core business models and entities
│   ├── ui/
│   │   ├── core/          # Shared design system, theme tokens, and reusable widgets
│   │   └── features/      # Feature screens and ViewModels (Onboarding, Home, Promo Studio, Pulse, Account)
│   ├── router.dart        # App navigation and route configuration (go_router)
│   └── main.dart          # Entry point and provider tree initialization
├── assets/                # App typography (Plus Jakarta Sans, Inter) and images
├── specs/                 # Product specifications, workflows, and feature documents
├── test/                  # Unit, widget, and integration tests
└── pubspec.yaml           # Flutter dependencies, assets, and project metadata
```

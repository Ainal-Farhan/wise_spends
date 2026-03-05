# WiseSpends - Personal Finance Manager

<div align="center">

![WiseSpends Banner](assets/images/logo.png)

**Take control of your finances with intelligent tracking and insights**

[![Flutter](https://img.shields.io/badge/Flutter-3.11.1-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.0-blue?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📱 Overview

**WiseSpends** is a comprehensive personal finance management application built with Flutter. It helps users track expenses, manage savings, set budgets, and maintain financial health through intuitive visualizations and smart insights.

### ✨ Key Features

- 💰 **Transaction Management** - Record income, expenses, and transfers with categorization
- 🏦 **Savings Tracking** - Monitor multiple savings accounts with real-time balance updates
- 📊 **Budget Planning** - Set spending limits per category with visual progress tracking
- 📈 **Reports & Analytics** - Visualize spending patterns with charts and insights
- 🎯 **Commitment Goals** - Track financial commitments and savings goals
- 🌓 **Theme Support** - Beautiful light and dark modes
- 📱 **Offline-First** - All data stored locally with Drift (SQLite)
- 🔒 **Privacy-First** - No cloud sync, your data stays on your device

---

## 🎨 Screenshots

<div align="center">

| Dashboard | Add Transaction | Budgets | Reports |
|:---------:|:---------------:|:-------:|:-------:|
| ![Dashboard](assets/screenshots/home.png) | ![Add Transaction](assets/screenshots/add_transaction.png) | ![Budgets](assets/screenshots/budgets.png) | ![Reports](assets/screenshots/reports.png) |

</div>

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** >= 3.11.1
- **Dart SDK** >= 3.9.0
- **Android Studio** / **VS Code** with Flutter extensions
- **Xcode** (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ainal-Farhan/wise_spends.git
   cd wise_spends
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (Drift, etc.)**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 🏗️ Architecture

WiseSpends follows **Clean Architecture** principles with a clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│              Presentation Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Screens  │  │ Widgets  │  │  BLoCs   │              │
│  └──────────┘  └──────────┘  └──────────┘              │
├─────────────────────────────────────────────────────────┤
│                Domain Layer                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Entities │  │Repositories│ │ UseCases │              │
│  └──────────┘  └──────────┘  └──────────┘              │
├─────────────────────────────────────────────────────────┤
│                 Data Layer                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  Models  │  │Repositories│ │ Database │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **Presentation** | UI rendering, user interactions, state management via BLoC |
| **Domain** | Business logic, entities, repository interfaces, use cases |
| **Data** | Data persistence, API calls, repository implementations |

### State Management

WiseSpends uses the **BLoC (Business Logic Component)** pattern for predictable state management:

```
User Action → Event → BLoC → State → UI Update
```

**Benefits:**
- ✅ Separation of business logic from UI
- ✅ Testable and maintainable code
- ✅ Predictable state transitions
- ✅ Reactive programming with streams

---

## 📦 Tech Stack

### Core Technologies

| Technology | Purpose | Version |
|------------|---------|---------|
| **Flutter** | UI Framework | >= 3.11.1 |
| **Dart** | Programming Language | >= 3.9.0 |
| **BLoC** | State Management | ^9.1.1 |
| **Drift** | Local Database (SQLite) | ^2.32.0 |
| **GetIt** | Dependency Injection | ^9.2.1 |

### Key Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1      # BLoC state management
  equatable: ^2.0.8         # Value equality
  drift: ^2.32.0            # Reactive SQLite
  get_it: ^9.2.1            # Service locator
  rxdart: ^0.28.0           # Reactive extensions
  intl: ^0.20.2             # Internationalization
  google_fonts: ^6.2.1      # Custom fonts
  shimmer: ^3.0.0           # Loading effects
  fl_chart: ^0.69.2         # Charts and graphs
  settings_ui: ^2.0.2       # Settings screen
  share_plus: ^12.0.1       # Sharing functionality
  file_picker: ^10.3.10     # File selection
  permission_handler: ^12.0.1 # Runtime permissions
```

---

## 📂 Project Structure

```
lib/
├── core/                      # Core utilities and configuration
│   ├── config/               # App configuration
│   ├── constants/            # Constants and route definitions
│   ├── di/                   # Dependency injection
│   └── utils/                # Utility functions
├── data/                      # Data layer
│   ├── db/                   # Database tables and queries
│   ├── repositories/         # Repository implementations
│   └── services/             # External services
├── domain/                    # Domain layer
│   ├── entities/             # Business entities
│   ├── repositories/         # Repository interfaces
│   └── usecases/             # Business use cases
├── presentation/              # Presentation layer
│   ├── blocs/                # BLoC classes (state management)
│   ├── screens/              # Screen widgets
│   └── widgets/              # Reusable widgets
├── router/                    # Navigation and routing
└── shared/                    # Shared resources
    ├── theme/                # App theme and styling
    └── resources/            # Assets and constants
```

---

## 🎯 Features Deep Dive

### 1. Transaction Management

**Add Transaction Screen:**
- Three-way toggle: Income | Expense | Transfer
- Large calculator-style amount input
- Category selection with icon grid
- Date picker with relative labels (Today, Yesterday)
- Optional notes field
- Real-time validation

**Transaction List:**
- Grouped by date with sticky headers
- Swipe-to-delete with undo
- Pull-to-refresh
- Search and filter capabilities
- Color-coded amounts (green for income, red for expense)

### 2. Dashboard

**Home Screen:**
- Time-based greeting (Good morning/afternoon/evening)
- Total balance card with gradient
- Income/Expense summary cards
- Recent transactions (last 10)
- Quick-action FAB with speed dial
- Pull-to-refresh

### 3. Budget Planning

**Budget Cards:**
- Visual progress bars
- Color-coded by usage:
  - 🟢 Green: < 60% used
  - 🟡 Amber: 60-85% used
  - 🔴 Red: > 85% used
- "X of Y spent" display
- Budget summary at top

### 4. Reports & Analytics

**Visualizations:**
- Bar chart: Income vs Expenses over time
- Donut chart: Expense breakdown by category
- Period selector: Week | Month | Year
- Comparison with previous period (%)

### 5. Settings

**Organized Sections:**
- 💰 Preferences (currency, language, start of week)
- 🔔 Notifications
- 📦 Data (Export CSV, Import, Backup)
- ℹ️ About (Version, Rate App, Privacy Policy)

---

## 🎨 Design System

### Color Palette

```dart
// Primary - Green (money/growth)
Primary:        #4CAF82
Primary Light:  #81C784
Primary Dark:   #388E3C

// Secondary - Red/Coral (expenses)
Secondary:      #FF6B6B
Secondary Light:#FF8A80
Secondary Dark: #D32F2F

// Tertiary - Blue (transfers)
Tertiary:       #42A5F5

// Status Colors
Success:        #4CAF50
Warning:        #FFA726
Error:          #B00020
```

### Typography

**Font Family:** Montserrat

| Style | Size | Weight |
|-------|------|--------|
| Display Large | 32sp | Bold |
| Headline | 20-22sp | SemiBold |
| Title | 14-16sp | SemiBold |
| Body | 14-16sp | Regular |
| Caption | 12sp | Regular |

### Spacing & Layout

```dart
// Border Radius
Cards:     12dp
Inputs:    8dp
FAB/Chips: 16-24dp

// Touch Targets
Minimum: 48×48dp

// Spacing Scale
8dp   - Small gap
16dp  - Standard gap
24dp  - Section gap
32dp  - Large gap
```

---

## 🧪 Testing

### Run Tests

```bash
# Unit tests
flutter test

# Coverage report
flutter test --coverage

# Integration tests
flutter test integration_test/
```

### Test Structure

```
test/
├── unit/                    # Unit tests
│   ├── blocs/              # BLoC tests
│   ├── repositories/       # Repository tests
│   └── usecases/           # Use case tests
└── integration/            # Integration tests
    └── app_test.dart       # Full app flow tests
```

---

## 🔧 Development

### Code Generation

WiseSpends uses code generation for:
- **Drift** database tables
- **BLoC** events and states (optional)
- **GetIt** dependency injection

```bash
# Generate all code
dart run build_runner build

# Watch for changes
dart run build_runner watch
```

### Linting

```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Fix common issues
dart fix --apply
```

### Debugging Tips

1. **Enable BLoC observer** in `main.dart`:
   ```dart
   Bloc.observer = SimpleBlocObserver();
   ```

2. **Use DevTools** for performance profiling:
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

3. **Check database** with Drift inspector:
   ```bash
   dart run drift_dev cli
   ```

---

## 📱 Platform Support

| Platform | Status | Minimum Version |
|----------|--------|-----------------|
| Android  | ✅ Stable | API 21+ (Android 5.0) |
| iOS      | ✅ Stable | iOS 12.0+ |
| Web      | ⚠️ Limited | N/A (requires web build) |
| Desktop  | ⚠️ Experimental | N/A |

---

## 🔐 Privacy & Security

### Data Storage
- All data stored **locally** on device
- **No cloud sync** by default
- **No analytics** or tracking
- **No internet permission** required (unless using backup features)

### Backup & Export
- CSV export for data portability
- Local backup files
- User-controlled data sharing

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Run tests and linting**
   ```bash
   flutter test
   flutter analyze
   ```
5. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
6. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request**

### Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Write tests for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

- **Lead Developer** - [Your Name](https://github.com/Ainal-Farhan)
- **UI/UX Designer** - [Designer Name]
- **Contributors** - [See Contributors Graph](https://github.com/Ainal-Farhan/wise_spends/graphs/contributors)

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/Ainal-Farhan/wise_spends/issues)
- **Discussions:** [GitHub Discussions](https://github.com/Ainal-Farhan/wise_spends/discussions)
- **Email:** support@wisespends.app

---

## 🗺️ Roadmap

### Q2 2026
- [ ] Multi-currency support
- [ ] Recurring transactions
- [ ] Bill reminders
- [ ] Export to Google Sheets

### Q3 2026
- [ ] Cloud backup (optional)
- [ ] Biometric authentication
- [ ] Widget for home screen
- [ ] Apple Watch / Wear OS companion app

### Q4 2026
- [ ] AI-powered spending insights
- [ ] Budget recommendations
- [ ] Receipt scanning (OCR)
- [ ] Multi-language support

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [BLoC Library](https://bloclibrary.dev) for state management
- [Drift](https://drift.simonbinder.eu) for local database
- [Material Design 3](https://m3.material.io) for design system
- All contributors and supporters

---

<div align="center">

**Made with ❤️ using Flutter**

[Website](https://wisespends.app) • [Discord](https://discord.gg/wisespends)

</div>

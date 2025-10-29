# Wise Spends

A comprehensive personal finance management application designed to help users track expenses, manage savings, and maintain financial health.

## Features

- **Transaction Management**: Record income, expenses, and transfers between different savings accounts
- **Savings Tracking**: Monitor and manage multiple savings accounts with real-time balance updates
- **Money Storage Management**: Organize funds across different storage methods (bank accounts, cash, etc.)
- **Theming**: Light and dark mode support for comfortable viewing in any lighting condition
- **Comprehensive Dashboard**: View daily usage and credit information in one centralized location
- **Commitment Tasks**: Track financial commitments and their progress
- **Profile Management**: Personalize your financial experience with user profiles

## Getting Started

This project is a Flutter application that uses the following technologies:
- **State Management**: BLoC pattern for predictable state management
- **Database**: Drift (SQLite) for local data persistence
- **Dependency Injection**: GetIt for service locator pattern
- **UI Components**: Material Design with custom theming

### Prerequisites

- Flutter SDK (>=3.35.0)
- Dart SDK (>=3.9.0)

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `dart run build_runner build` to generate code
4. Run the application with `flutter run`

## Architecture

The app follows a clean architecture pattern with:
- **Presentation Layer**: UI and User Interaction
- **Domain Layer**: Business Logic
- **Data Layer**: Data Sources and Repositories
- **Core**: Common utilities and dependency injection

## Contributing

We welcome contributions to the Wise Spends project. Please see our Contributing Guidelines for more information.

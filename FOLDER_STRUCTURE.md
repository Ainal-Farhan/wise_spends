# WiseSpends Folder Structure

## Corrected Folder Structure (Clean Architecture + BLoC)

```
lib/
├── core/
│   ├── config/
│   │   ├── app_config.dart          # App-wide configuration
│   │   └── environment_config.dart  # Environment-specific config
│   ├── constants/
│   │   ├── app_routes.dart          # Route path constants
│   │   ├── asset_constants.dart     # Asset path constants
│   │   └── api_constants.dart       # API endpoint constants
│   ├── di/
│   │   ├── i_manager_locator.dart
│   │   ├── i_repository_locator.dart
│   │   ├── i_service_locator.dart
│   │   └── impl/
│   │       ├── manager_locator.dart
│   │       ├── repository_locator.dart
│   │       └── service_locator.dart
│   └── utils/
│       ├── singleton_util.dart
│       ├── date_utils.dart
│       └── validation_utils.dart
│
├── data/
│   ├── db/
│   │   ├── app_database.dart        # Drift database definition
│   │   ├── dao/
│   │   │   ├── transaction_dao.dart
│   │   │   ├── category_dao.dart
│   │   │   └── budget_dao.dart
│   │   └── tables/
│   │       ├── transaction_table.dart
│   │       ├── category_table.dart
│   │       └── budget_table.dart
│   ├── remote/
│   │   ├── api_client.dart
│   │   └── api_service.dart
│   ├── repositories/
│   │   ├── transaction_repository.dart
│   │   ├── category_repository.dart
│   │   └── budget_repository.dart
│   └── services/
│       ├── analytics_service.dart
│       └── notification_service.dart
│
├── domain/
│   ├── entities/
│   │   ├── transaction/
│   │   │   └── transaction_entity.dart
│   │   ├── category/
│   │   │   └── category_entity.dart
│   │   ├── budget/
│   │   │   └── budget_entity.dart
│   │   └── account/
│   │       └── account_entity.dart
│   ├── models/
│   │   ├── user_profile.dart
│   │   └── report_model.dart
│   ├── repositories/
│   │   ├── transaction_repository_interface.dart
│   │   ├── category_repository_interface.dart
│   │   └── budget_repository_interface.dart
│   ├── services/
│   │   ├── analytics_service_interface.dart
│   │   └── notification_service_interface.dart
│   └── usecases/
│       ├── transaction/
│       │   ├── get_transactions.dart
│       │   ├── create_transaction.dart
│       │   ├── update_transaction.dart
│       │   └── delete_transaction.dart
│       ├── category/
│       │   ├── get_categories.dart
│       │   └── create_category.dart
│       └── budget/
│           ├── get_budgets.dart
│           ├── create_budget.dart
│           └── update_budget.dart
│
├── presentation/
│   ├── blocs/
│   │   ├── transaction/
│   │   │   ├── transaction_bloc.dart
│   │   │   ├── transaction_event.dart
│   │   │   └── transaction_state.dart
│   │   ├── category/
│   │   │   ├── category_bloc.dart
│   │   │   ├── category_event.dart
│   │   │   └── category_state.dart
│   │   ├── budget/
│   │   │   ├── budget_bloc.dart
│   │   │   ├── budget_event.dart
│   │   │   └── budget_state.dart
│   │   ├── reports/
│   │   │   ├── reports_bloc.dart
│   │   │   ├── reports_event.dart
│   │   │   └── reports_state.dart
│   │   └── settings/
│   │       ├── settings_bloc.dart
│   │       ├── settings_event.dart
│   │       └── settings_state.dart
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── transaction/
│   │   │   ├── add_transaction_screen.dart
│   │   │   ├── transaction_history_screen.dart
│   │   │   └── transaction_detail_screen.dart
│   │   ├── budget/
│   │   │   ├── budget_list_screen.dart
│   │   │   └── budget_detail_screen.dart
│   │   ├── reports/
│   │   │   └── reports_screen.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   └── login/
│   │       └── login_screen.dart
│   └── widgets/
│       ├── components/
│       │   ├── transaction_card.dart
│       │   ├── budget_card.dart
│       │   ├── amount_display.dart
│       │   ├── category_selector.dart
│       │   ├── empty_state_widget.dart
│       │   └── error_state_widget.dart
│       ├── loaders/
│       │   ├── shimmer_loader.dart
│       │   └── loading_overlay.dart
│       └── charts/
│           ├── donut_chart.dart
│           ├── bar_chart.dart
│           └── line_chart.dart
│
├── router/
│   ├── app_router.dart              # Route generation logic
│   └── route_arguments.dart         # Typed route arguments
│
├── shared/
│   ├── components/
│   │   └── custom_app_bar.dart
│   ├── constants/
│   │   └── ui_constants.dart        # Spacing, radius, etc.
│   ├── resources/
│   │   └── strings.dart             # Localized strings
│   ├── theme/
│   │   └── wise_spends_theme.dart   # Theme data & colors
│   └── utils/
│       ├── category_icon_mapper.dart
│       └── formatters.dart
│
└── main.dart                        # App entry point
```

## Key Changes Made

### 1. Removed Redundancies
- ❌ Removed `presentation/pages/` → Merged into `presentation/screens/`
- ❌ Removed `db/domain/` → Empty folder, domain logic belongs in `domain/`
- ❌ Removed `.bak` files → Should never be committed

### 2. Clear Layer Separation
```
✅ Presentation  →  Domain (uses interfaces)
✅ Data          →  Domain (implements interfaces)
❌ Presentation  →  Data (NEVER direct calls)
❌ Domain        →  Data (interfaces only)
```

### 3. BLoC Structure
Each feature has its own folder with:
- `*_event.dart` - User actions
- `*_state.dart` - UI states
- `*_bloc.dart` - Business logic

### 4. Entity vs Model Distinction
- **Entities**: Pure data classes (no business logic) - used across layers
- **Models**: Domain-specific data with business logic - domain layer only

### 5. Service Clarification
- **Domain services**: Interfaces/abstractions
- **Data services**: Concrete implementations

## Migration Notes

### Files to Move
1. Move `presentation/pages/*` → `presentation/screens/*`
2. Consolidate `domain/entities/` subfolders
3. Remove `db/domain/` (already empty)

### Import Path Updates
```dart
// OLD
import 'package:wise_spends/presentation/pages/home/home_page.dart';

// NEW
import 'package:wise_spends/presentation/screens/home/home_screen.dart';
```

## BLoC Pattern Enforcement

All screens must follow:
```dart
BlocProvider(
  create: (context) => FeatureBloc(repository) ..add(LoadEvent()),
  child: _ScreenContent(),
)
```

All state management:
```
Event → BLoC → State → UI
```

No business logic in widgets or screens!

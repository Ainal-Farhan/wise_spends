# Budget Plan Feature - Detailed Architecture Summary

## Overview

The **Budget Plan** feature (internally using "Savings Plan" terminology in the database) is a comprehensive financial goal tracking system that allows users to:
- Create savings goals with target amounts and deadlines
- Track progress through deposits and spending
- Manage budget line items (e.g., wedding items like Pelamin, Makeup, etc.)
- Link external savings accounts with allocated amounts
- Set milestones for sub-goals
- View analytics and charts

---

## Core Domain Entities

### 1. BudgetPlanEntity (Main Goal)

The primary entity representing a financial goal.

**Key Fields:**
- `id` - Unique identifier
- `name` - Plan name (e.g., "Wedding Fund")
- `category` - Type: wedding, house, travel, education, emergency, vehicle, medical, custom
- `targetAmount` - Goal amount
- `currentAmount` - **Calculated field** (see calculation section below)
- `totalSpent` - Total money spent from the plan
- `totalDeposited` - Total money deposited to the plan
- `startDate` / `targetDate` - Timeline
- `status` - active, completed, paused, cancelled

**Computed Properties:**
```dart
progressPercentage = currentAmount / targetAmount
remainingAmount = targetAmount - currentAmount
daysRemaining = targetDate - now
healthStatus = onTrack / slightlyBehind / atRisk / overBudget / completed
projectedCompletionMonths = based on deposit rate
```

---

### 2. BudgetPlanItemEntity (Budget Line Items)

Represents individual line items within a budget plan (especially useful for wedding budgets).

**Key Fields:**
- `id` - Unique identifier
- `planId` - Parent plan reference
- `bil` - Display number (e.g., "1", "2", "3") - user-editable
- `sortOrder` - Fractional ordering (starts at 1000.0, increments by 1000.0)
- `name` - Item name (e.g., "Pelamin", "Makeup")
- `totalCost` - Full agreed price of the item
- `depositPaid` - Amount paid as deposit (upfront commitment)
- `amountPaid` - Amount paid toward remaining balance (**excluding** deposit)
- `tags` - Optional categorization (Pelamin, Hantaran, Makeup, Photography, etc.)
- `isCompleted` - Whether item is fully paid/completed
- `dueDate` - Payment deadline

**Critical Calculation Semantics:**

```dart
// Total money handed over
totalPaid = depositPaid + amountPaid

// Remaining balance
outstanding = totalCost - depositPaid - amountPaid

// Payment progress
paymentProgress = totalPaid / totalCost

// Deposit-specific calculations
hasDeposit = depositPaid > 0
remainingAfterDeposit = totalCost - depositPaid
depositCoversFullCost = depositPaid >= totalCost
```

**Example:**
```
totalCost   = 1000
depositPaid = 500   ← deposit settled
amountPaid  = 250   ← partial payment on remaining 500
─────────────────────────────────────────────────────
totalPaid   = 750   (500 + 250)
outstanding = 250   (1000 - 500 - 250)
progress    = 75%   (750 / 1000)
```

**Status Labels:**
- `Fully Paid` - outstanding == 0
- `Partially Paid` - amountPaid > 0 AND outstanding > 0
- `Deposit Only` - hasDeposit AND amountPaid == 0
- `Not Paid` - no payments yet

---

### 3. BudgetPlanDepositEntity (Money In)

Represents money added to a budget plan.

**Key Fields:**
- `id` - Unique identifier
- `planId` - Parent plan reference
- `amount` - Deposit amount (always positive)
- `source` - manual, linked_account, salary, bonus, other
- `depositDate` - When deposit was made
- `linkedAccountId` - Optional reference to linked savings account
- `note` - Optional description

**Important:** Deposits can be:
1. **Manual deposits** - Direct cash additions
2. **Linked account deposits** - Transferred from linked savings accounts (creates actual transaction in main transaction table)

---

### 4. BudgetPlanTransactionEntity (Money Out / Spending)

Represents money spent from a budget plan.

**Key Fields:**
- `id` - Unique identifier
- `planId` - Parent plan reference
- `transactionId` - Optional link to main transaction table
- `amount` - Spending amount (always positive)
- `vendor` - Where money was spent
- `description` - Spending description
- `transactionDate` - When spending occurred
- `receiptImagePath` - Optional receipt image

**Important:** Spending can be:
1. **Manual spending** - Tracked within budget plan only
2. **Linked account spending** - Creates actual transaction in main transaction table (type: `TransactionType.budgetPlanExpense`)

---

### 5. LinkedAccountSummaryEntity (Linked Savings Accounts)

Represents a linked external savings account.

**Key Fields:**
- `id` - Unique identifier
- `planId` - Parent plan reference
- `accountId` - Reference to actual savings account
- `accountName` - Name of the savings account
- `accountBalance` - Current balance in the account
- `allocatedAmount` - **Amount allocated to this plan** (can be adjusted)
- `linkedAt` - When account was linked

**Important:** The allocated amount contributes to the plan's `currentAmount`.

---

### 6. BudgetPlanMilestoneEntity (Sub-goals)

Represents intermediate goals within a plan.

**Key Fields:**
- `id` - Unique identifier
- `planId` - Parent plan reference
- `title` - Milestone name
- `targetAmount` - Target for this milestone
- `dueDate` - Deadline
- `isCompleted` / `completedAt` - Completion status

---

### 7. BudgetPlanItemTagEntity (Item Categories)

Optional tags for categorizing budget items.

**Key Fields:**
- `itemId` - Reference to budget item
- `tagName` - Tag name (e.g., "Pelamin", "Hantaran", "Makeup", "Photography", "Catering", etc.)

**Pre-defined Tags:**
```dart
pelamin, hantaran, makeup, photography, catering, venue, attire,
jewelry, accommodation, transportation, entertainment, gifts, miscellaneous
```

---

## Database Tables (Drift)

| Table Name | Entity | Purpose |
|------------|--------|---------|
| `savings_plan_table` | BudgetPlanEntity | Main goal tracking |
| `savings_plan_item_table` | BudgetPlanItemEntity | Budget line items |
| `savings_plan_deposit_table` | BudgetPlanDepositEntity | Money added |
| `savings_plan_spending_table` | BudgetPlanTransactionEntity | Money spent |
| `savings_plan_linked_account_table` | LinkedAccountSummaryEntity | Linked accounts |
| `savings_plan_milestone_table` | BudgetPlanMilestoneEntity | Sub-goals |
| `savings_plan_item_tag_table` | BudgetPlanItemTagEntity | Item tags |

**Related External Tables:**
- `saving_table` - External savings accounts
- `transaction_table` - Main transaction ledger (for linked account operations)

---

## THE CRITICAL CALCULATION: How `currentAmount` is Computed

This is the **most important** and often misunderstood part of the budget plan system.

### Formula

```dart
currentAmount = 
    totalManualDeposits           // From savings_plan_deposit_table
  + totalItemPayments             // From items: (depositPaid + amountPaid)
  - totalManualSpending           // From savings_plan_spending_table
  + totalAllocatedFromLinked      // From savings_plan_linked_account_table
```

### Detailed Breakdown

**Step 1: Calculate Manual Deposits**
```dart
totalManualDeposits = SUM(deposit.amount) 
                      FROM savings_plan_deposit_table 
                      WHERE planId = currentPlan
```

**Step 2: Calculate Item Payments**
```dart
totalItemDeposits = SUM(item.depositPaid) 
                    FROM savings_plan_item_table 
                    WHERE planId = currentPlan

totalItemPayments = SUM(item.amountPaid) 
                    FROM savings_plan_item_table 
                    WHERE planId = currentPlan

// Note: Items contribute BOTH depositPaid AND amountPaid to currentAmount
// This is because both represent money that has been paid out
```

**Step 3: Calculate Manual Spending**
```dart
totalManualSpending = SUM(spending.amount) 
                      FROM savings_plan_spending_table 
                      WHERE planId = currentPlan
```

**Step 4: Calculate Allocated Amounts from Linked Accounts**
```dart
totalAllocated = SUM(linkedAccount.allocatedAmount) 
                 FROM savings_plan_linked_account_table 
                 WHERE planId = currentPlan
```

**Step 5: Final Calculation**
```dart
// In _updatePlanCurrentAmount() method
currentAmount = totalDeposits + totalItemPayments - totalSpending + totalAllocated

// Where:
// - totalDeposits = manual deposits
// - totalItemPayments = item deposits + item payments (depositPaid + amountPaid for all items)
// - totalSpending = manual spending
// - totalAllocated = allocated amounts from linked accounts
```

### Why This Formula Makes Sense

The `currentAmount` represents **how much money you currently have available/accumulated** toward your goal:

1. **Manual Deposits** ✓ - Money you've explicitly added
2. **Item Payments** ✓ - Money you've paid out for items (this is "committed" money working toward your goal)
3. **Minus Spending** ✗ - Money you've withdrawn/spent from the plan
4. **Plus Allocated** 💰 - Money reserved in linked accounts for this plan

### Alternative View: Item-Based Calculation

For budget plans using items (like wedding budgets):

```dart
// Total money committed to items
totalItemCommitment = SUM(item.totalCost)

// Total money already paid for items
totalItemPaid = SUM(item.depositPaid + item.amountPaid)

// Outstanding item payments
totalItemOutstanding = totalItemCommitment - totalItemPaid

// The currentAmount includes what you've already paid (not the full item cost)
// This makes sense because you're tracking actual cash flow, not commitments
```

---

## TotalSpent and TotalDeposited Calculation

These are **separate tracking fields** used for analytics and display.

### totalDeposited

```dart
totalDeposited = totalManualDeposits + totalItemDeposits

Where:
- totalManualDeposits = SUM(deposit.amount) from deposit table
- totalItemDeposits = SUM(item.depositPaid) from item table
```

### totalDeposited

```dart
totalDeposited = totalManualDeposits + totalItemDepositsPaid

Where:
- totalManualDeposits = SUM(deposit.amount) from deposit table
- totalItemDepositsPaid = SUM(item.depositPaid) from item table
```

**Represents:** All money contributed/saved toward the plan (both direct deposits and vendor deposits).

### totalSpent

```dart
totalSpent = totalManualSpending + totalItemAmountPaid

Where:
- totalManualSpending = SUM(spending.amount) from spending table
- totalItemAmountPaid = SUM(item.amountPaid) from item table
```

**Represents:** All money withdrawn/spent from the plan.

**Why this formula?**
- `amountPaid` represents payments made toward the remaining balance AFTER the initial deposit
- These payments are treated as "spending" from the plan's accumulated savings
- `depositPaid` is NOT counted as spending because it represents the initial commitment, not ongoing withdrawals
- This separates the deposit (commitment/saving) from ongoing payments (spending)

---

## Data Flow Architecture

### Repository Layer (`BudgetPlanRepository`)

**Key Methods:**

1. **CRUD Operations:**
   - `createPlan()`, `updatePlan()`, `deletePlan()`
   - `addDeposit()`, `deleteDeposit()`
   - `addPlanTransaction()`, `deletePlanTransaction()`
   - `linkAccount()`, `unlinkAccount()`
   - `addMilestone()`, `deleteMilestone()`

2. **Calculation Methods:**
   - `recalculatePlanAmount(planId)` - Updates `currentAmount`
   - `_enrichPlanWithCalculatedValues(plan)` - Adds `totalDeposited` and `totalSpent`
   - `_updatePlanCurrentAmount(planId)` - Internal DB update

3. **Query Methods:**
   - `watchAllPlans()` - Stream of all plans
   - `watchPlanById(id)` - Stream of single plan
   - `getDeposits(planId)` - List of deposits
   - `getPlanTransactions(planId)` - List of transactions
   - `getMilestones(planId)` - List of milestones
   - `watchLinkedAccounts(planId)` - Stream of linked accounts

4. **Analytics:**
   - `getPlanAnalytics(planId)` - Complete analytics data
   - `getProgressHistory(planId)` - Historical snapshots
   - `getMonthlyContributions(planId)` - Monthly breakdown
   - `getSpendingByCategory(planId)` - Category breakdown

---

### BLoC Layer (State Management)

**BudgetPlanDetailBloc:**
- Manages individual plan detail state
- Events: `LoadPlanDetail`, `AddDeposit`, `AddSpending`, `AddMilestone`, etc.
- States: `BudgetPlanDetailLoaded`, `BudgetPlanDetailError`, etc.
- Automatically recalculates amounts after mutations

**BudgetPlanListBloc:**
- Manages list of all plans
- Handles loading, filtering, sorting

**Create/Edit Budget Plan Form BLoCs:**
- Manage form state for creating/editing plans
- Handle validation, step progression

---

### Integration with Main Transaction System

When using **linked accounts**, the budget plan integrates with the main transaction ledger:

**For Deposits:**
```dart
// 1. Create deposit record in savings_plan_deposit_table
// 2. Create transaction in transaction_table with type: TransactionType.budgetPlanDeposit
// 3. Update linked savings account balance (+amount)
// 4. Update allocation in savings_plan_linked_account_table (+amount)
// 5. Recalculate plan currentAmount
```

**For Spending:**
```dart
// 1. Create spending record in savings_plan_spending_table
// 2. Create transaction in transaction_table with type: TransactionType.budgetPlanExpense
// 3. Update linked savings account balance (-amount)
// 4. Update allocation in savings_plan_linked_account_table (-amount)
// 5. Recalculate plan currentAmount
```

**Transaction Types:**
- `TransactionType.budgetPlanDeposit` - Money flowing into budget plan
- `TransactionType.budgetPlanExpense` - Money flowing out of budget plan

---

## UI Components

### Key Widgets

1. **BudgetPlanOverviewTab** - Main overview with progress, milestones, linked accounts
2. **BudgetPlanProgressBody** - Progress visualization
3. **BudgetPlanTotalPaidCard** - Shows deposit + payment breakdown for items
4. **BudgetPlanItemDetails** - Item editing form with BIL stepper
5. **BudgetPlanMilestoneCard** - Milestone display
6. **BudgetPlanLinkedAccountCard** - Linked account display
7. **BudgetPlanChartsTab** - Analytics charts

### Item Management

**Add/Edit Item Bottom Sheet:**
- BIL (number) stepper
- Name field
- Total cost input
- Deposit paid input
- Amount paid input (excluding deposit)
- Tags selection (multi-select chips)
- Notes field
- Due date picker

**Item List Screen:**
- Sortable by BIL or name
- Shows payment status badges
- Progress indicators per item
- Tag filtering

---

## Business Logic & Rules

### Item Payment Flow

1. **Create Item** with `totalCost`
2. **Record Deposit** (optional) → `depositPaid`
   - Status: "Deposit Only" or "Deposit Partial"
3. **Make Payments** → `amountPaid` (excludes deposit)
   - Status: "Partially Paid"
4. **Fully Paid** when `depositPaid + amountPaid >= totalCost`
   - Status: "Fully Paid"

### Linked Account Allocation

1. **Link Account** with initial `allocatedAmount`
2. **Deposit to Plan** from linked account:
   - Increases allocation (you're moving money INTO the plan)
   - Creates actual transaction in linked account
   - Decreases linked account balance
3. **Spend from Plan** via linked account:
   - Decreases allocation (you're using allocated funds)
   - Creates actual transaction in linked account
   - Decreases linked account balance
4. **Check Allocation** before spending:
   - `canSpend()` validates spending doesn't exceed allocation

### Plan Health Calculation

```dart
healthStatus = 
  if (progressPercentage >= 1.0) → completed
  else if (totalSpent > targetAmount) → overBudget
  else:
    expectedProgress = elapsedMonths / totalMonths
    actualProgress = progressPercentage
    
    if (actualProgress >= expectedProgress * 0.9) → onTrack
    else if (actualProgress >= expectedProgress * 0.7) → slightlyBehind
    else → atRisk
```

---

## Common Pitfalls & Hidden Behaviors

### 1. Double Counting in Items

**Problem:** Items have both `depositPaid` and `amountPaid`.

**Solution:** 
- `totalPaid = depositPaid + amountPaid` (correct)
- `outstanding = totalCost - depositPaid - amountPaid` (correct)
- Don't forget to include BOTH in `currentAmount` calculation

### 2. Allocation vs Balance

**Confusion:** `allocatedAmount` ≠ `accountBalance`

**Clarification:**
- `accountBalance` = Actual money in the external savings account
- `allocatedAmount` = Portion of that balance reserved for THIS plan
- You can have multiple plans linked to one account with different allocations

### 3. Spending Reduces CurrentAmount

**Behavior:** When you record spending, `currentAmount` decreases.

**Why:** Spending represents money withdrawn from the plan, reducing available funds.

### 4. Item Payments Increase CurrentAmount

**Counter-intuitive:** Paying for items INCREASES `currentAmount`.

**Why:** The system tracks money you've "invested" toward your goal. Paying for wedding items is progress toward the wedding goal, even though it's money spent.

### 5. Recalculation Triggers

**When does `currentAmount` update?**
- After adding/deleting a deposit
- After adding/deleting a spending transaction
- After linking/unlinking an account
- After updating item payments (via `recalculatePlanAmount()`)

**Important:** The repository calls `recalculatePlanAmount()` after most mutations.

---

## Analytics & Reporting

### Progress History

Tracks cumulative deposits over time for line charts.

### Monthly Contributions

Shows deposits vs spending per month for bar charts.

```dart
MonthlyContribution {
  year, month
  deposits   // Total deposits this month
  spending   // Total spending this month
  net        // deposits - spending
}
```

### Spending by Category

Groups spending by vendor for donut charts.

### Projected Completion

Based on average monthly deposit rate:
```dart
monthlyRate = totalDeposited / elapsedMonths
monthsNeeded = remainingAmount / monthlyRate
projectedDate = now + monthsNeeded
```

---

## Summary: The Complete Picture

### Money Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    BUDGET PLAN (Goal)                          │
│                                                                 │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐ │
│  │   MANUAL     │      │    ITEM      │      │   LINKED     │ │
│  │   DEPOSITS   │      │   PAYMENTS   │      │   ACCOUNTS   │ │
│  │      +       │      │      +       │      │      +       │ │
│  └──────────────┘      └──────────────┘      └──────────────┘ │
│           │                     │                      │       │
│           └─────────────────────┼──────────────────────┘       │
│                                 │                               │
│                          currentAmount                          │
│                                 │                               │
│                                 │                               │
│                    ┌────────────┴────────────┐                  │
│                    │    MANUAL SPENDING      │                  │
│                    │           −             │                  │
│                    └─────────────────────────┘                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Takeaways

1. **`currentAmount`** = Your current progress toward the goal (cash + commitments)
2. **Items** track individual budget line items with deposit/payment separation
3. **Deposits** increase your progress (money in)
4. **Spending** decreases your progress (money out)
5. **Linked Accounts** allow integration with external savings accounts
6. **Allocations** track how much of a linked account is reserved for this plan
7. **Item Payments** (deposit + amountPaid) represent money committed to goal-related expenses
8. **Recalculation** happens automatically after mutations

---

## API Reference (Quick Lookup)

### Entity Properties

| Entity | Key Calculation Properties |
|--------|---------------------------|
| BudgetPlanEntity | `progressPercentage`, `remainingAmount`, `healthStatus`, `daysRemaining` |
| BudgetPlanItemEntity | `totalPaid`, `outstanding`, `paymentProgress`, `isFullyPaid` |
| BudgetPlanDepositEntity | `sourceDisplayName` |
| BudgetPlanTransactionEntity | (no computed properties) |
| LinkedAccountSummaryEntity | (no computed properties) |

### Repository Methods

| Method | Purpose |
|--------|---------|
| `watchAllPlans()` | Stream all plans |
| `getPlanByUuid(id)` | Get single plan with calculated values |
| `addDeposit(planId, params)` | Add deposit, triggers recalculation |
| `addPlanTransaction(planId, params)` | Add spending, triggers recalculation |
| `linkAccount(planId, accountId, amount)` | Link account with allocation |
| `recalculatePlanAmount(planId)` | Manually trigger recalculation |
| `getPlanAnalytics(planId)` | Get complete analytics data |

---

## Testing Considerations

When testing budget plan features:

1. **Test item calculations** with various deposit/payment combinations
2. **Test linked account flows** end-to-end (including main transaction creation)
3. **Test recalculation** after each mutation type
4. **Test edge cases**: negative amounts, zero targets, overdue dates
5. **Test allocation validation** (can't spend more than allocated)
6. **Test health status** transitions based on progress vs timeline

---

This document provides a comprehensive understanding of how the budget plan feature works, including the hidden calculations and data flows that aren't immediately obvious from the surface-level API.

// ---------------------------------------------------------------------------
// Commitment Detail Type enum
// ---------------------------------------------------------------------------
// Using an intEnum column instead of free-text ensures consistency and
// prevents invalid values like "Monthly" vs "monthly" vs "MONTHLY".

enum CommitmentDetailType {
  /// Generates one task per month
  monthly,

  /// Generates one task per week
  weekly,

  /// Generates one task per quarter
  quarterly,

  /// Generates one task per year
  yearly,

  /// Generates a single task, no recurrence
  oneOff,
}

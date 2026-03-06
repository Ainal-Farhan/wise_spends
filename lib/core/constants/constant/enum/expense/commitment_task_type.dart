// ---------------------------------------------------------------------------
// Payment type enum
// ---------------------------------------------------------------------------
// Using an intEnum column instead of isThirdParty (bool) means adding new payment
// types (e.g. cash, crypto) never requires a schema change or migration — just
// add a new enum value.

enum CommitmentTaskType {
  /// Moves money between two of the user's own savings accounts.
  internalTransfer,

  /// Sends money to an external payee (bank transfer, FPX, etc.).
  thirdPartyPayment,

  /// Physical cash payment — no source saving deducted digitally.
  cash,
}

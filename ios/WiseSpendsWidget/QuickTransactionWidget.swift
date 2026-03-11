//
//  QuickTransactionWidget.swift
//  WiseSpends
//
//  iOS Home Screen Widget for Quick Transactions
//  Allows users to quickly add expense/income transactions from home screen
//

import WidgetKit
import SwiftUI

/// Widget Entry View
struct QuickTransactionWidgetEntry: TimelineEntry {
    let date: Date
    let lastTransactionTitle: String
    let lastTransactionAmount: String
    let lastTransactionType: String
}

/// Widget Provider
struct QuickTransactionWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickTransactionWidgetEntry {
        QuickTransactionWidgetEntry(
            date: Date(),
            lastTransactionTitle: "Lunch at Restaurant",
            lastTransactionAmount: "45.00",
            lastTransactionType: "expense"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickTransactionWidgetEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickTransactionWidgetEntry>) -> Void) {
        // Get data from UserDefaults (shared with Flutter app)
        let defaults = UserDefaults(suiteName: "group.wise_spends.widgets")
        
        let lastTransactionTitle = defaults?.string(forKey: "last_transaction_title") ?? "No transactions"
        let lastTransactionAmount = defaults?.string(forKey: "last_transaction_amount") ?? "0.00"
        let lastTransactionType = defaults?.string(forKey: "last_transaction_type") ?? "none"
        
        let entry = QuickTransactionWidgetEntry(
            date: Date(),
            lastTransactionTitle: lastTransactionTitle,
            lastTransactionAmount: lastTransactionAmount,
            lastTransactionType: lastTransactionType
        )

        // Update every 30 minutes
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

/// Widget View
struct QuickTransactionWidgetEntryView: View {
    var entry: QuickTransactionWidgetProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                Text("WiseSpends")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                // Expense Button
                Link(destination: URL(string: "wisespends://quick-transaction?type=expense")!) {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                        Text("Expense")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // Income Button
                Link(destination: URL(string: "wisespends://quick-transaction?type=income")!) {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title)
                        Text("Income")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            // Last Transaction
            HStack(spacing: 8) {
                Image(systemName: transactionIcon)
                    .foregroundColor(transactionColor)
                    .frame(width: 28, height: 28)
                    .background(transactionColor.opacity(0.1))
                    .cornerRadius(7)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Last Transaction")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(entry.lastTransactionTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text("- RM \(entry.lastTransactionAmount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(transactionColor)
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(12)
    }
    
    var transactionIcon: String {
        switch entry.lastTransactionType {
        case "income":
            return "arrow.down.circle.fill"
        case "expense":
            return "arrow.up.circle.fill"
        default:
            return "creditcard.fill"
        }
    }
    
    var transactionColor: Color {
        switch entry.lastTransactionType {
        case "income":
            return .green
        case "expense":
            return .red
        default:
            return .gray
        }
    }
}

/// Widget Configuration
@main
struct QuickTransactionWidget: Widget {
    let kind: String = "QuickTransactionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: QuickTransactionWidgetProvider()
        ) { entry in
            QuickTransactionWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quick Transaction")
        .description("Add transactions quickly from your home screen")
        .supportedFamilies([.systemSmall])
    }
}

/// Preview
struct QuickTransactionWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuickTransactionWidgetEntryView(entry: QuickTransactionWidgetEntry(
            date: Date(),
            lastTransactionTitle: "Lunch at Restaurant",
            lastTransactionAmount: "45.00",
            lastTransactionType: "expense"
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

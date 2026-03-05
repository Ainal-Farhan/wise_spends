import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Reports Export Service
/// Generates CSV exports of financial reports
class ReportsExportService {
  /// Export financial report to CSV
  Future<String> exportReportToCsv({
    required String period,
    required double totalIncome,
    required double totalExpenses,
    required double totalBalance,
    required Map<String, double> categoryBreakdown,
  }) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('WiseSpends - Financial Report');
    buffer.writeln(
      'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
    );
    buffer.writeln('Period: $period');
    buffer.writeln();

    // Summary
    buffer.writeln('SUMMARY');
    buffer.writeln('Total Income,RM ${totalIncome.toStringAsFixed(2)}');
    buffer.writeln('Total Expenses,RM ${totalExpenses.toStringAsFixed(2)}');
    buffer.writeln('Total Balance,RM ${totalBalance.toStringAsFixed(2)}');
    buffer.writeln();

    // Category Breakdown
    buffer.writeln('EXPENSE BREAKDOWN BY CATEGORY');
    buffer.writeln('Category,Amount,Percentage');

    final total = categoryBreakdown.values.fold<double>(
      0,
      (sum, val) => sum + val,
    );
    categoryBreakdown.forEach((category, amount) {
      final percentage = total > 0 ? (amount / total * 100) : 0;
      buffer.writeln(
        '$category,RM ${amount.toStringAsFixed(2)},${percentage.toStringAsFixed(1)}%',
      );
    });

    buffer.writeln();
    buffer.writeln('End of Report');

    // Write to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'financial_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  /// Share exported file
  Future<void> shareExport(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          subject: 'Financial Report Export',
        ),
      );
    }
  }
}

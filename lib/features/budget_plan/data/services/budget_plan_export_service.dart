import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';

/// Budget Plan Export Service
/// Generates PDF/CSV exports of budget plans
class BudgetPlanExportService {
  /// Escape a value for CSV format
  /// Handles commas, quotes, and newlines per RFC 4180
  String _escapeCsvValue(String? value) {
    if (value == null) return '';
    // If value contains comma, newline, or double quote, wrap in quotes
    if (value.contains(',') ||
        value.contains('\n') ||
        value.contains('\r') ||
        value.contains('"')) {
      // Escape double quotes by doubling them
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }

  /// Export budget plan to CSV
  Future<String> exportToCsv(BudgetPlanEntity plan) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('WiseSpends - Budget Plan Export');
    buffer.writeln(
      'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
    );
    buffer.writeln();

    // Plan Summary
    buffer.writeln('PLAN SUMMARY');
    buffer.writeln('Name,${_escapeCsvValue(plan.name)}');
    buffer.writeln('Description,${_escapeCsvValue(plan.description)}');
    buffer.writeln('Category,${_escapeCsvValue(plan.category.name)}');
    buffer.writeln(
      'Target Amount,RM ${plan.targetAmount.toStringAsFixed(2)}',
    );
    buffer.writeln(
      'Current Amount,RM ${plan.currentAmount.toStringAsFixed(2)}',
    );
    buffer.writeln(
      'Progress,${(plan.progressPercentage * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln(
      'Start Date,${DateFormat('yyyy-MM-dd').format(plan.startDate)}',
    );
    buffer.writeln(
      'Target Date,${DateFormat('yyyy-MM-dd').format(plan.targetDate)}',
    );
    buffer.writeln('Status,${_escapeCsvValue(plan.status.name)}');
    buffer.writeln();

    buffer.writeln('End of Export');

    // Write to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'budget_plan_${_escapeCsvValue(plan.name.replaceAll(' ', '_'))}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  /// Share exported file
  Future<void> shareExport(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], subject: 'Budget Plan Export'),
      );
    }
  }
}

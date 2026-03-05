import 'package:flutter/material.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'commitment_list_screen.dart';

/// Commitment Management Screen - Main entry point for commitments
class CommitmentManagementScreen extends StatelessWidget {
  const CommitmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commitments')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            AppCard.gradient(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.tertiary, AppColors.tertiaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: Colors.white70,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Commitment Overview',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Manage Recurring Expenses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track bills, subscriptions, and regular payments',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What are Commitments?', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Text(
                    'Commitments are recurring expenses that you pay regularly, such as:',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint('Rent or mortgage payments'),
                  _buildBulletPoint('Car insurance'),
                  _buildBulletPoint(
                    'Streaming subscriptions (Netflix, Spotify)',
                  ),
                  _buildBulletPoint('Utility bills'),
                  _buildBulletPoint('Loan payments'),
                  const SizedBox(height: 20),
                  Text(
                    'Tap the button below to view and manage your commitments.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // View Commitments Button
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                label: 'View All Commitments',
                icon: Icons.list,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommitmentListScreen(),
                    ),
                  );
                },
                size: AppButtonSize.large,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

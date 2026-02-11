import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DividendsScreen extends StatelessWidget {
  const DividendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dividends'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 36,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Dividend Reports',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Import your dividend report to see your dividend income, yield, and history.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accent.withAlpha(40)),
                ),
                child: Text(
                  'Coming soon',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.accent,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

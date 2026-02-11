import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../theme/app_theme.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    Uint8List? bytes = file.bytes;

    // On mobile, bytes may be null — read from path
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }

    if (bytes != null && context.mounted) {
      await context.read<ReportProvider>().loadReport(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // App icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.candlestick_chart,
                  size: 40,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'P&L Tracker',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Import your broker report to get started',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              // Import card
              Card(
                child: InkWell(
                  onTap: provider.loading ? null : () => _pickFile(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: provider.loading
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.accent,
                                  ),
                                )
                              : const Icon(
                                  Icons.upload_file_rounded,
                                  size: 28,
                                  color: AppTheme.accent,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.loading
                              ? 'Parsing report...'
                              : 'Import Stock P&L Report',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Supports Groww (.xlsx)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lossBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.loss, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.loss),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(flex: 3),
              // Supported brokers
              Text(
                'SUPPORTED BROKERS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BrokerChip(label: 'Groww', active: true),
                  const SizedBox(width: 8),
                  _BrokerChip(label: 'Zerodha', active: false),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrokerChip extends StatelessWidget {
  final String label;
  final bool active;

  const _BrokerChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppTheme.accent.withAlpha(20) : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppTheme.accent.withAlpha(50) : AppTheme.cardBorder,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: active ? AppTheme.accent : AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

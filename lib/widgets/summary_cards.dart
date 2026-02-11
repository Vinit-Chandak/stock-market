import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../theme/app_theme.dart';

class SummaryCards extends StatelessWidget {
  final StockReport report;

  const SummaryCards({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);

    return Column(
      children: [
        // Main P&L card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net P&L',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${report.netPnl >= 0 ? '+' : ''}${fmt.format(report.netPnl)}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            color: AppTheme.pnlColor(report.netPnl),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Icon(
                        report.netPnl >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: AppTheme.pnlColor(report.netPnl),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'After charges: ${report.netPnlAfterCharges >= 0 ? '+' : ''}${fmt.format(report.netPnlAfterCharges)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.pnlColor(report.netPnlAfterCharges),
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Realised / Unrealised row
        Row(
          children: [
            Expanded(
              child: _MiniCard(
                label: 'Realised',
                value: report.realisedPnl,
                fmt: fmt,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniCard(
                label: 'Unrealised',
                value: report.unrealisedPnl,
                fmt: fmt,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniCard(
                label: 'Charges',
                value: -report.charges.total,
                fmt: fmt,
                alwaysNegative: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final double value;
  final NumberFormat fmt;
  final bool alwaysNegative;

  const _MiniCard({
    required this.label,
    required this.value,
    required this.fmt,
    this.alwaysNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = alwaysNegative ? value.abs() : value;
    final color = alwaysNegative ? AppTheme.loss : AppTheme.pnlColor(value);
    final prefix = alwaysNegative ? '-' : (value >= 0 ? '+' : '');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$prefix${fmt.format(displayValue)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

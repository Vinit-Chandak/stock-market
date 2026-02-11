import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../theme/app_theme.dart';

class ChargesCard extends StatelessWidget {
  final ChargesBreakdown charges;

  const ChargesCard({super.key, required this.charges});

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 2);

    final items = [
      _ChargeItem('STT', charges.stt),
      _ChargeItem('Brokerage', charges.brokerage),
      _ChargeItem('GST', charges.gst),
      _ChargeItem('DP Charges', charges.dpCharges),
      _ChargeItem('Stamp Duty', charges.stampDuty),
      _ChargeItem('Exchange Txn', charges.exchangeCharges),
      _ChargeItem('SEBI Charges', charges.sebiCharges),
      _ChargeItem('IPFT Charges', charges.ipftCharges),
    ];

    // Sort by value descending
    items.sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Charges',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  fmt.format(charges.total),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.loss,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == items.length - 1;
                final pct =
                    charges.total > 0 ? (item.value / charges.total * 100) : 0;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Bar indicator
                          Container(
                            width: 3,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.loss.withAlpha(
                                  (40 + (pct * 2.1).toInt()).clamp(40, 255)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${pct.toStringAsFixed(1)}% of total',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            fmt.format(item.value),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                          indent: 31, endIndent: 16, height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChargeItem {
  final String label;
  final double value;
  _ChargeItem(this.label, this.value);
}

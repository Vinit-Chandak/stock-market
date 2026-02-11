import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../theme/app_theme.dart';

class ScripPnlList extends StatelessWidget {
  final List<ScripSummary> scrips;

  const ScripPnlList({super.key, required this.scrips});

  @override
  Widget build(BuildContext context) {
    if (scrips.isEmpty) {
      return const Center(child: Text('No realised scrip data found'));
    }

    final currFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);

    // Sort by absolute P&L descending
    final sorted = List<ScripSummary>.from(scrips)
      ..sort((a, b) => b.pnl.abs().compareTo(a.pnl.abs()));

    final totalPnl = scrips.fold(0.0, (s, sc) => s + sc.pnl);
    final profitCount = scrips.where((s) => s.pnl >= 0).length;
    final lossCount = scrips.where((s) => s.pnl < 0).length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Summary row
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company-wise P&L',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${totalPnl >= 0 ? '+' : ''}${currFmt.format(totalPnl)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.pnlColor(totalPnl),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  _CountChip(
                    label: '$profitCount',
                    icon: Icons.arrow_upward_rounded,
                    color: AppTheme.profit,
                    bgColor: AppTheme.profitBg,
                  ),
                  const SizedBox(width: 8),
                  _CountChip(
                    label: '$lossCount',
                    icon: Icons.arrow_downward_rounded,
                    color: AppTheme.loss,
                    bgColor: AppTheme.lossBg,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 12),
        ...sorted.map((s) => _ScripCard(scrip: s, currFmt: currFmt)),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _CountChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ScripCard extends StatelessWidget {
  final ScripSummary scrip;
  final NumberFormat currFmt;

  const _ScripCard({required this.scrip, required this.currFmt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scrip.stockName,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Qty: ${scrip.quantity.toInt()}  \u00B7  Buy: ${currFmt.format(scrip.buyValue)}  \u00B7  Sell: ${currFmt.format(scrip.sellValue)}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${scrip.pnl >= 0 ? '+' : ''}${currFmt.format(scrip.pnl)}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: AppTheme.pnlColor(scrip.pnl),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${scrip.pnlPercent >= 0 ? '+' : ''}${scrip.pnlPercent.toStringAsFixed(2)}%',
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.pnlColor(scrip.pnl),
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

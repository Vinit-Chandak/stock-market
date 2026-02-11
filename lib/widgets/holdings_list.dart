import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../theme/app_theme.dart';

class HoldingsList extends StatelessWidget {
  final List<ScripSummary> holdings;
  final double totalValue;

  const HoldingsList({
    super.key,
    required this.holdings,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) {
      return const Center(child: Text('No holdings found'));
    }

    final currFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);
    final totalPnl = holdings.fold(0.0, (s, h) => s + h.pnl);

    // Sort by absolute P&L descending
    final sorted = List<ScripSummary>.from(holdings)
      ..sort((a, b) => b.pnl.abs().compareTo(a.pnl.abs()));

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
                    'Current Value',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currFmt.format(totalValue + totalPnl),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Unrealised P&L',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${totalPnl >= 0 ? '+' : ''}${currFmt.format(totalPnl)}',
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.pnlColor(totalPnl),
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 12),
        ...sorted.map((h) => _HoldingCard(holding: h, currFmt: currFmt)),
      ],
    );
  }
}

class _HoldingCard extends StatelessWidget {
  final ScripSummary holding;
  final NumberFormat currFmt;

  const _HoldingCard({required this.holding, required this.currFmt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holding.stockName,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Qty: ${holding.quantity.toInt()}  \u00B7  Avg: ${holding.avgBuyPrice.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${holding.pnl >= 0 ? '+' : ''}${currFmt.format(holding.pnl)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: AppTheme.pnlColor(holding.pnl),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${holding.pnlPercent >= 0 ? '+' : ''}${holding.pnlPercent.toStringAsFixed(2)}%',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.pnlColor(holding.pnl),
                                ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Value bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: _safeProgress(holding),
                  minHeight: 4,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: AlwaysStoppedAnimation(
                    AppTheme.pnlColor(holding.pnl).withAlpha(180),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invested: ${currFmt.format(holding.buyValue)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Current: ${currFmt.format(holding.sellValue)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _safeProgress(ScripSummary h) {
    if (h.buyValue == 0) return 0;
    final ratio = h.sellValue / h.buyValue;
    return ratio.clamp(0.0, 1.0);
  }
}

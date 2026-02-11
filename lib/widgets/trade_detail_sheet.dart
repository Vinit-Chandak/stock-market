import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../theme/app_theme.dart';

class TradeDetailSheet extends StatelessWidget {
  final DailyPnl day;

  const TradeDetailSheet({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final currFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9', decimalDigits: 2);
    final dateFmt = DateFormat('dd MMM yyyy, EEEE');

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFmt.format(day.date),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.tradeCount} trades',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.pnlBgColor(day.totalPnl),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${day.totalPnl >= 0 ? '+' : ''}${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(day.totalPnl)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.pnlColor(day.totalPnl),
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Trade list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: day.trades.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final trade = day.trades[index];
                    return _TradeCard(trade: trade, currFmt: currFmt);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TradeCard extends StatelessWidget {
  final Trade trade;
  final NumberFormat currFmt;

  const _TradeCard({required this.trade, required this.currFmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trade.stockName,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${trade.pnl >= 0 ? '+' : ''}${currFmt.format(trade.pnl)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.pnlColor(trade.pnl),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (trade.remark.isNotEmpty) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withAlpha(15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trade.remark,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.accent,
                          fontSize: 10,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Qty: ${trade.quantity.toInt()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${trade.pnlPercent >= 0 ? '+' : ''}${trade.pnlPercent.toStringAsFixed(2)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.pnlColor(trade.pnl),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _PriceLabel(
                context: context,
                label: 'Buy',
                value: currFmt.format(trade.buyPrice),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 12, color: AppTheme.textTertiary),
              const SizedBox(width: 4),
              _PriceLabel(
                context: context,
                label: 'Sell',
                value: currFmt.format(trade.sellPrice),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  final BuildContext context;
  final String label;
  final String value;

  const _PriceLabel({
    required this.context,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

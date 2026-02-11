import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../theme/app_theme.dart';
import 'trade_detail_sheet.dart';

class DailyPnlList extends StatelessWidget {
  final List<DailyPnl> dailyPnl;

  const DailyPnlList({super.key, required this.dailyPnl});

  @override
  Widget build(BuildContext context) {
    if (dailyPnl.isEmpty) {
      return const Center(
        child: Text('No realised trades found'),
      );
    }

    final currFmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM');
    final dayFmt = DateFormat('EEE');
    final yearFmt = DateFormat('yyyy');

    // Group by month
    final grouped = <String, List<DailyPnl>>{};
    for (final day in dailyPnl) {
      final key = DateFormat('MMM yyyy').format(day.date);
      grouped.putIfAbsent(key, () => []).add(day);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: grouped.length,
      itemBuilder: (context, groupIndex) {
        final month = grouped.keys.elementAt(groupIndex);
        final days = grouped[month]!;
        final monthPnl = days.fold(0.0, (s, d) => s + d.totalPnl);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groupIndex > 0) const SizedBox(height: 16),
            // Month header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    month,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.textTertiary,
                          letterSpacing: 0.8,
                        ),
                  ),
                  Text(
                    '${monthPnl >= 0 ? '+' : ''}${currFmt.format(monthPnl)}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.pnlColor(monthPnl),
                        ),
                  ),
                ],
              ),
            ),
            // Daily cards
            ...days.map((day) => _DailyPnlCard(
                  day: day,
                  currFmt: currFmt,
                  dateFmt: dateFmt,
                  dayFmt: dayFmt,
                  yearFmt: yearFmt,
                )),
          ],
        );
      },
    );
  }
}

class _DailyPnlCard extends StatelessWidget {
  final DailyPnl day;
  final NumberFormat currFmt;
  final DateFormat dateFmt;
  final DateFormat dayFmt;
  final DateFormat yearFmt;

  const _DailyPnlCard({
    required this.day,
    required this.currFmt,
    required this.dateFmt,
    required this.dayFmt,
    required this.yearFmt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTrades(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Date badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.pnlBgColor(day.totalPnl),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateFmt.format(day.date).split(' ').first,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: AppTheme.pnlColor(day.totalPnl),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.1,
                            ),
                      ),
                      Text(
                        dateFmt.format(day.date).split(' ').last,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppTheme.pnlColor(day.totalPnl),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayFmt.format(day.date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${day.tradeCount} trade${day.tradeCount > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // P&L
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${day.totalPnl >= 0 ? '+' : ''}${currFmt.format(day.totalPnl)}',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.pnlColor(day.totalPnl),
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.pnlPercent >= 0 ? '+' : ''}${day.pnlPercent.toStringAsFixed(1)}%',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.pnlColor(day.totalPnl),
                              ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTrades(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TradeDetailSheet(day: day),
    );
  }
}

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
            // Month header with total
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.pnlBgColor(monthPnl),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${monthPnl >= 0 ? '+' : ''}${currFmt.format(monthPnl)}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.pnlColor(monthPnl),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // Grid of day tiles
            _DayGrid(days: days, currFmt: currFmt),
          ],
        );
      },
    );
  }
}

class _DayGrid extends StatelessWidget {
  final List<DailyPnl> days;
  final NumberFormat currFmt;

  const _DayGrid({required this.days, required this.currFmt});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) => _DayTile(day: day, currFmt: currFmt)).toList(),
    );
  }
}

class _DayTile extends StatelessWidget {
  final DailyPnl day;
  final NumberFormat currFmt;

  const _DayTile({required this.day, required this.currFmt});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 5 tiles per row: (screenWidth - 32 padding - 4*8 spacing) / 5
    final tileWidth = (screenWidth - 32 - 32) / 5;
    final dayNum = DateFormat('dd').format(day.date);
    final dayName = DateFormat('EEE').format(day.date);

    return GestureDetector(
      onTap: () => _showTrades(context),
      child: Container(
        width: tileWidth,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.pnlBgColor(day.totalPnl),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.pnlColor(day.totalPnl).withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayNum,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.pnlColor(day.totalPnl),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              dayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.pnlColor(day.totalPnl).withAlpha(180),
                    fontSize: 9,
                  ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  '${day.totalPnl >= 0 ? '+' : ''}${currFmt.format(day.totalPnl)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.pnlColor(day.totalPnl),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.tradeCount}t',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.pnlColor(day.totalPnl).withAlpha(120),
                    fontSize: 8,
                  ),
            ),
          ],
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

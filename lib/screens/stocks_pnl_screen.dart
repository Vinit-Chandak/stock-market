import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/summary_cards.dart';
import '../widgets/daily_pnl_list.dart';
import '../widgets/holdings_list.dart';
import '../widgets/charges_card.dart';

class StocksPnlScreen extends StatelessWidget {
  const StocksPnlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final report = provider.report!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock P&L'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, size: 22),
            onPressed: () => provider.clearReport(),
            tooltip: 'Import new report',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source and period
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            report.source.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            report.period.replaceAll(
                                'P&L Statement for stocks from ', ''),
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SummaryCards(report: report),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  indicatorColor: AppTheme.accent,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppTheme.textPrimary,
                  unselectedLabelColor: AppTheme.textTertiary,
                  labelStyle: Theme.of(context).textTheme.labelLarge,
                  unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
                  dividerHeight: 1,
                  dividerColor: AppTheme.divider,
                  tabs: [
                    Tab(text: 'Daily P&L (${report.dailyPnl.length})'),
                    Tab(text: 'Holdings (${report.unrealisedScrips.length})'),
                    const Tab(text: 'Charges'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              DailyPnlList(dailyPnl: report.dailyPnl),
              HoldingsList(
                holdings: report.unrealisedScrips,
                totalValue: report.unrealisedTrades.fold(
                    0.0, (s, t) => s + t.buyValue),
              ),
              ChargesCard(charges: report.charges),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

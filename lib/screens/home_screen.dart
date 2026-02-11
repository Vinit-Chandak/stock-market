import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../theme/app_theme.dart';
import 'stocks_pnl_screen.dart';
import 'dividends_screen.dart';
import 'fno_screen.dart';
import 'import_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    if (!provider.hasData) {
      return const ImportScreen();
    }

    final screens = [
      const StocksPnlScreen(),
      const DividendsScreen(),
      const FnoScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.divider, width: 1),
          ),
        ),
        child: NavigationBar(
          height: 64,
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.candlestick_chart_outlined),
              selectedIcon: Icon(Icons.candlestick_chart),
              label: 'Stocks',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments),
              label: 'Dividends',
            ),
            NavigationDestination(
              icon: Icon(Icons.swap_vert_circle_outlined),
              selectedIcon: Icon(Icons.swap_vert_circle),
              label: 'F&O',
            ),
          ],
        ),
      ),
    );
  }
}

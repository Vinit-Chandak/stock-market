class Trade {
  final String stockName;
  final String isin;
  final double quantity;
  final DateTime buyDate;
  final double buyPrice;
  final double buyValue;
  final DateTime sellDate; // or closing date for unrealised
  final double sellPrice; // or closing price for unrealised
  final double sellValue; // or closing value for unrealised
  final double pnl;
  final String remark;
  final bool isRealised;

  Trade({
    required this.stockName,
    required this.isin,
    required this.quantity,
    required this.buyDate,
    required this.buyPrice,
    required this.buyValue,
    required this.sellDate,
    required this.sellPrice,
    required this.sellValue,
    required this.pnl,
    required this.remark,
    required this.isRealised,
  });

  bool get isIntraday => remark.toLowerCase().contains('intraday');
  bool get isIPO => remark.toLowerCase().contains('ipo');

  double get pnlPercent {
    if (buyValue == 0) return 0;
    return (pnl / buyValue) * 100;
  }
}

class DailyPnl {
  final DateTime date;
  final List<Trade> trades;

  DailyPnl({required this.date, required this.trades});

  double get totalPnl => trades.fold(0.0, (sum, t) => sum + t.pnl);
  double get totalBuyValue => trades.fold(0.0, (sum, t) => sum + t.buyValue);
  double get totalSellValue => trades.fold(0.0, (sum, t) => sum + t.sellValue);
  int get tradeCount => trades.length;

  double get pnlPercent {
    if (totalBuyValue == 0) return 0;
    return (totalPnl / totalBuyValue) * 100;
  }
}

class ScripSummary {
  final String stockName;
  final String isin;
  final double quantity;
  final double avgBuyPrice;
  final double buyValue;
  final double avgSellPrice;
  final double sellValue;
  final double pnl;
  final double pnlPercent;
  final bool isRealised;

  ScripSummary({
    required this.stockName,
    required this.isin,
    required this.quantity,
    required this.avgBuyPrice,
    required this.buyValue,
    required this.avgSellPrice,
    required this.sellValue,
    required this.pnl,
    required this.pnlPercent,
    required this.isRealised,
  });
}

class ChargesBreakdown {
  final double exchangeCharges;
  final double sebiCharges;
  final double stt;
  final double stampDuty;
  final double ipftCharges;
  final double brokerage;
  final double dpCharges;
  final double gst;

  ChargesBreakdown({
    required this.exchangeCharges,
    required this.sebiCharges,
    required this.stt,
    required this.stampDuty,
    required this.ipftCharges,
    required this.brokerage,
    required this.dpCharges,
    required this.gst,
  });

  double get total =>
      exchangeCharges +
      sebiCharges +
      stt +
      stampDuty +
      ipftCharges +
      brokerage +
      dpCharges +
      gst;
}

class StockReport {
  final String userName;
  final String clientCode;
  final String period;
  final String source; // "groww", "zerodha", etc.
  final double realisedPnl;
  final double unrealisedPnl;
  final ChargesBreakdown charges;
  final List<Trade> realisedTrades;
  final List<Trade> unrealisedTrades;
  final List<ScripSummary> realisedScrips;
  final List<ScripSummary> unrealisedScrips;

  StockReport({
    required this.userName,
    required this.clientCode,
    required this.period,
    required this.source,
    required this.realisedPnl,
    required this.unrealisedPnl,
    required this.charges,
    required this.realisedTrades,
    required this.unrealisedTrades,
    required this.realisedScrips,
    required this.unrealisedScrips,
  });

  List<Trade> get allTrades => [...realisedTrades, ...unrealisedTrades];

  double get netPnl => realisedPnl + unrealisedPnl;
  double get netPnlAfterCharges => netPnl - charges.total;

  List<DailyPnl> get dailyPnl {
    final map = <DateTime, List<Trade>>{};
    for (final trade in realisedTrades) {
      final dateKey = DateTime(
        trade.sellDate.year,
        trade.sellDate.month,
        trade.sellDate.day,
      );
      map.putIfAbsent(dateKey, () => []).add(trade);
    }
    final days =
        map.entries.map((e) => DailyPnl(date: e.key, trades: e.value)).toList();
    days.sort((a, b) => b.date.compareTo(a.date));
    return days;
  }
}

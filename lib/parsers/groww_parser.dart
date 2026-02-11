import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import 'report_parser.dart';

class GrowwParser implements ReportParser {
  @override
  String get source => 'groww';

  @override
  String get displayName => 'Groww';

  @override
  bool canParse(Uint8List bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      return excel.tables.containsKey('Trade Level') &&
          excel.tables.containsKey('Scrip Level');
    } catch (_) {
      return false;
    }
  }

  @override
  StockReport parse(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final tradeSheet = excel['Trade Level'];
    final scripSheet = excel['Scrip Level'];

    // Parse header info
    final userName = _cellStr(tradeSheet, 0, 1);
    final clientCode = _cellStr(tradeSheet, 1, 1);
    final period = _cellStr(tradeSheet, 3, 0);

    // Parse summary charges
    final charges = ChargesBreakdown(
      exchangeCharges: _cellDouble(tradeSheet, 12, 1),
      sebiCharges: _cellDouble(tradeSheet, 13, 1),
      stt: _cellDouble(tradeSheet, 14, 1),
      stampDuty: _cellDouble(tradeSheet, 15, 1),
      ipftCharges: _cellDouble(tradeSheet, 16, 1),
      brokerage: _cellDouble(tradeSheet, 17, 1),
      dpCharges: _cellDouble(tradeSheet, 18, 1),
      gst: _cellDouble(tradeSheet, 19, 1),
    );

    final realisedPnl = _cellDouble(tradeSheet, 8, 1);
    final unrealisedPnl = _cellDouble(tradeSheet, 9, 1);

    // Parse realised trades (row 25 is header, data starts at 26)
    final realisedTrades = <Trade>[];
    final unrealisedTrades = <Trade>[];

    // Find the "Realised trades" and "Unrealised trades" sections
    int realisedDataStart = -1;
    int unrealisedDataStart = -1;

    for (int i = 0; i < tradeSheet.maxRows; i++) {
      final cellVal = _cellStr(tradeSheet, i, 0);
      if (cellVal == 'Stock name' && realisedDataStart == -1) {
        realisedDataStart = i + 1;
      } else if (cellVal == 'Unrealised trades') {
        // Find the header row after this
        for (int j = i + 1; j < tradeSheet.maxRows; j++) {
          if (_cellStr(tradeSheet, j, 0) == 'Stock name') {
            unrealisedDataStart = j + 1;
            break;
          }
        }
      }
    }

    // Parse realised trades
    if (realisedDataStart > 0) {
      for (int i = realisedDataStart; i < tradeSheet.maxRows; i++) {
        final stockName = _cellStr(tradeSheet, i, 0);
        if (stockName.isEmpty || stockName == 'Unrealised trades') break;

        final trade = Trade(
          stockName: stockName,
          isin: _cellStr(tradeSheet, i, 1),
          quantity: _cellDouble(tradeSheet, i, 2),
          buyDate: _parseDate(_cellStr(tradeSheet, i, 3)),
          buyPrice: _cellDouble(tradeSheet, i, 4),
          buyValue: _cellDouble(tradeSheet, i, 5),
          sellDate: _parseDate(_cellStr(tradeSheet, i, 6)),
          sellPrice: _cellDouble(tradeSheet, i, 7),
          sellValue: _cellDouble(tradeSheet, i, 8),
          pnl: _cellDouble(tradeSheet, i, 9),
          remark: _cellStr(tradeSheet, i, 10),
          isRealised: true,
        );
        realisedTrades.add(trade);
      }
    }

    // Parse unrealised trades
    if (unrealisedDataStart > 0) {
      for (int i = unrealisedDataStart; i < tradeSheet.maxRows; i++) {
        final stockName = _cellStr(tradeSheet, i, 0);
        if (stockName.isEmpty || stockName.startsWith('Disclaimer')) break;

        final trade = Trade(
          stockName: stockName,
          isin: _cellStr(tradeSheet, i, 1),
          quantity: _cellDouble(tradeSheet, i, 2),
          buyDate: _parseDate(_cellStr(tradeSheet, i, 3)),
          buyPrice: _cellDouble(tradeSheet, i, 4),
          buyValue: _cellDouble(tradeSheet, i, 5),
          sellDate: _parseDate(_cellStr(tradeSheet, i, 6)),
          sellPrice: _cellDouble(tradeSheet, i, 7),
          sellValue: _cellDouble(tradeSheet, i, 8),
          pnl: _cellDouble(tradeSheet, i, 9),
          remark: _cellStr(tradeSheet, i, 10),
          isRealised: false,
        );
        unrealisedTrades.add(trade);
      }
    }

    // Parse scrip level data
    final realisedScrips = <ScripSummary>[];
    final unrealisedScrips = <ScripSummary>[];

    // Realised scrips start at row 3 (0-indexed)
    int scripRealisedStart = -1;
    int scripUnrealisedStart = -1;

    for (int i = 0; i < scripSheet.maxRows; i++) {
      final cellVal = _cellStr(scripSheet, i, 0);
      if (cellVal == 'Stock name' && scripRealisedStart == -1) {
        scripRealisedStart = i + 1;
      } else if (cellVal == 'Stock name' && scripRealisedStart > 0) {
        scripUnrealisedStart = i + 1;
      }
    }

    if (scripRealisedStart > 0) {
      for (int i = scripRealisedStart; i < scripSheet.maxRows; i++) {
        final stockName = _cellStr(scripSheet, i, 0);
        if (stockName.isEmpty || stockName == 'Total') break;

        realisedScrips.add(ScripSummary(
          stockName: stockName,
          isin: _cellStr(scripSheet, i, 1),
          quantity: _cellDouble(scripSheet, i, 2),
          avgBuyPrice: _cellDouble(scripSheet, i, 3),
          buyValue: _cellDouble(scripSheet, i, 4),
          avgSellPrice: _cellDouble(scripSheet, i, 5),
          sellValue: _cellDouble(scripSheet, i, 6),
          pnl: _cellDouble(scripSheet, i, 7),
          pnlPercent: _cellDouble(scripSheet, i, 8) * 100,
          isRealised: true,
        ));
      }
    }

    if (scripUnrealisedStart > 0) {
      for (int i = scripUnrealisedStart; i < scripSheet.maxRows; i++) {
        final stockName = _cellStr(scripSheet, i, 0);
        if (stockName.isEmpty || stockName == 'Total') break;

        unrealisedScrips.add(ScripSummary(
          stockName: stockName,
          isin: _cellStr(scripSheet, i, 1),
          quantity: _cellDouble(scripSheet, i, 2),
          avgBuyPrice: _cellDouble(scripSheet, i, 3),
          buyValue: _cellDouble(scripSheet, i, 4),
          avgSellPrice: _cellDouble(scripSheet, i, 5),
          sellValue: _cellDouble(scripSheet, i, 6),
          pnl: _cellDouble(scripSheet, i, 7),
          pnlPercent: _cellDouble(scripSheet, i, 8) * 100,
          isRealised: false,
        ));
      }
    }

    return StockReport(
      userName: userName,
      clientCode: clientCode,
      period: period,
      source: source,
      realisedPnl: realisedPnl,
      unrealisedPnl: unrealisedPnl,
      charges: charges,
      realisedTrades: realisedTrades,
      unrealisedTrades: unrealisedTrades,
      realisedScrips: realisedScrips,
      unrealisedScrips: unrealisedScrips,
    );
  }

  String _cellStr(Sheet sheet, int row, int col) {
    if (row >= sheet.maxRows) return '';
    final rowData = sheet.row(row);
    if (col >= rowData.length) return '';
    final cell = rowData[col];
    if (cell == null || cell.value == null) return '';
    return cell.value.toString();
  }

  double _cellDouble(Sheet sheet, int row, int col) {
    final str = _cellStr(sheet, row, col);
    if (str.isEmpty) return 0;
    return double.tryParse(str) ?? 0;
  }

  DateTime _parseDate(String dateStr) {
    if (dateStr.isEmpty) return DateTime(2000);
    try {
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (_) {
      return DateTime(2000);
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/trade.dart';
import '../parsers/report_parser.dart';
import '../parsers/groww_parser.dart';
import '../parsers/dividend_parser.dart';

class ReportProvider extends ChangeNotifier {
  StockReport? _report;
  DividendReport? _dividendReport;
  String? _error;
  bool _loading = false;

  StockReport? get report => _report;
  DividendReport? get dividendReport => _dividendReport;
  String? get error => _error;
  bool get loading => _loading;
  bool get hasData => _report != null;
  bool get hasDividendData => _dividendReport != null;

  final GrowwDividendParser _dividendParser = GrowwDividendParser();

  ReportProvider() {
    ParserRegistry.register(GrowwParser());
  }

  Future<void> loadReport(Uint8List bytes) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final report = ParserRegistry.tryParse(bytes);
      if (report == null) {
        _error = 'Unsupported report format. Currently supported: ${ParserRegistry.availableSources.join(", ")}';
      } else {
        _report = report;
        _error = null;
      }
    } catch (e) {
      _error = 'Failed to parse report: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadDividendReport(Uint8List bytes) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (_dividendParser.canParse(bytes)) {
        _dividendReport = _dividendParser.parse(bytes);
        _error = null;
      } else {
        _error = 'Not a valid dividend report PDF';
      }
    } catch (e) {
      _error = 'Failed to parse dividend report: $e';
    }

    _loading = false;
    notifyListeners();
  }

  void clearReport() {
    _report = null;
    _error = null;
    notifyListeners();
  }

  void clearDividendReport() {
    _dividendReport = null;
    _error = null;
    notifyListeners();
  }
}

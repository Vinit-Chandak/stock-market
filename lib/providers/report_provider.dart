import 'package:flutter/foundation.dart';
import '../models/trade.dart';
import '../parsers/report_parser.dart';
import '../parsers/groww_parser.dart';

class ReportProvider extends ChangeNotifier {
  StockReport? _report;
  String? _error;
  bool _loading = false;

  StockReport? get report => _report;
  String? get error => _error;
  bool get loading => _loading;
  bool get hasData => _report != null;

  ReportProvider() {
    ParserRegistry.register(GrowwParser());
    // Future: ParserRegistry.register(ZerodhaParser());
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

  void clearReport() {
    _report = null;
    _error = null;
    notifyListeners();
  }
}

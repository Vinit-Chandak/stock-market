import 'dart:typed_data';
import '../models/trade.dart';

/// Abstract parser interface. Implement this for each broker.
abstract class ReportParser {
  /// Unique identifier for this parser (e.g., "groww", "zerodha")
  String get source;

  /// Human-readable name
  String get displayName;

  /// Check if the given file bytes match this parser's expected format.
  bool canParse(Uint8List bytes);

  /// Parse the file bytes into a StockReport.
  StockReport parse(Uint8List bytes);
}

/// Registry of all available parsers.
class ParserRegistry {
  static final List<ReportParser> _parsers = [];

  static void register(ReportParser parser) {
    _parsers.add(parser);
  }

  static StockReport? tryParse(Uint8List bytes) {
    for (final parser in _parsers) {
      if (parser.canParse(bytes)) {
        return parser.parse(bytes);
      }
    }
    return null;
  }

  static List<String> get availableSources =>
      _parsers.map((p) => p.displayName).toList();
}

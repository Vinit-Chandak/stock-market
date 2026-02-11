import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/trade.dart';

class GrowwDividendParser {
  DividendReport parse(Uint8List bytes) {
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final String text = PdfTextExtractor(document).extractText();
    document.dispose();

    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    String clientName = '';
    String clientCode = '';
    String period = '';
    final dividends = <Dividend>[];
    double totalDividend = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('Client name:')) {
        clientName = line.replaceFirst('Client name:', '').trim();
      } else if (line.startsWith('Client code:')) {
        clientCode = line.replaceFirst('Client code:', '').trim();
      } else if (line.contains('dividends from')) {
        final match = RegExp(r'from\s+(\S+)\s+to\s+(\S+)').firstMatch(line);
        if (match != null) {
          period = '${match.group(1)} to ${match.group(2)}';
        }
      } else if (line.contains('Total dividend amount')) {
        final match = RegExp(r'Rs\.\s*([\d,]+\.?\d*)').firstMatch(line);
        if (match != null) {
          totalDividend = double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0;
        }
      }
    }

    // Parse dividend rows - look for ISIN pattern
    final fullText = lines.join(' ');
    final isinPattern = RegExp(
      r'([A-Z][A-Z &().]+?)\s+(INE\w{9})\s+(\d{2}-\d{2}-\d{4})\s+(\d+)\s+Rs\.\s*([\d,]+\.?\d*)\s+Rs\.\s*([\d,]+\.?\d*)',
    );

    for (final match in isinPattern.allMatches(fullText)) {
      final companyName = match.group(1)!.trim();
      final isin = match.group(2)!;
      final exDateStr = match.group(3)!;
      final shares = int.tryParse(match.group(4)!) ?? 0;
      final dps = double.tryParse(match.group(5)!.replaceAll(',', '')) ?? 0;
      final amount = double.tryParse(match.group(6)!.replaceAll(',', '')) ?? 0;

      DateTime exDate;
      try {
        exDate = DateFormat('dd-MM-yyyy').parse(exDateStr);
      } catch (_) {
        exDate = DateTime(2000);
      }

      dividends.add(Dividend(
        companyName: companyName,
        isin: isin,
        exDate: exDate,
        numberOfShares: shares,
        dividendPerShare: dps,
        netDividendAmount: amount,
      ));
    }

    if (totalDividend == 0 && dividends.isNotEmpty) {
      totalDividend = dividends.fold(0.0, (s, d) => s + d.netDividendAmount);
    }

    return DividendReport(
      clientName: clientName,
      clientCode: clientCode,
      period: period,
      dividends: dividends,
      totalDividend: totalDividend,
    );
  }

  bool canParse(Uint8List bytes) {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text.contains('dividend') || text.contains('Dividend');
    } catch (_) {
      return false;
    }
  }
}

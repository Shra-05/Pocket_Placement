import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CoreNotesPdfService {
  static Future<void> exportNotes(List<Map<String, dynamic>> notes) async {
    final document = pw.Document();
    final sorted = [...notes]..sort((a, b) {
      final subject = (a['subject'] as String).compareTo(b['subject'] as String);
      return subject != 0
          ? subject
          : (a['level'] as int).compareTo(b['level'] as int);
    });

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (_) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
          ),
          child: pw.Text('POCKET PLACEMENT • MY NOTES',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ),
        build: (_) => [
          pw.SizedBox(height: 18),
          pw.Text('Saved Core CS Notes',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text('${sorted.length} notes • OOPS, OS, DBMS, CN, and ML'),
          pw.SizedBox(height: 20),
          ...sorted.map((note) {
            final subject = note['subject'] as String;
            final level = note['level'] as int;
            final content = note['content'] as String;
            return pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('$subject • Level $level',
                      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 7),
                  pw.Text(content, style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 3)),
                ],
              ),
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => document.save(),
      name: 'PocketPlacement_My_Notes.pdf',
    );
  }
}

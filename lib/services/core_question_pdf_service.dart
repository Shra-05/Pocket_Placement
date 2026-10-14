import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core_question_bank.dart';

class CoreQuestionPdfService {
  static Future<void> downloadSubjectQuestions(String subject) async {
    final questions = CoreQuestionBank.forSubject(subject);
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Text(
          'Pocket Placement • $subject Question Book',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber}'),
        ),
        build: (context) => [
          pw.SizedBox(height: 16),
          pw.Text('100 Core CS Learning Levels',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Includes questions, options, correct answers, and explanations.'),
          pw.SizedBox(height: 16),
          ...questions.asMap().entries.map((entry) {
            final number = entry.key + 1;
            final q = entry.value;
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 14),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Level $number • ${q.concept}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.SizedBox(height: 4),
                  pw.Text(q.question),
                  pw.SizedBox(height: 4),
                  ...q.options.asMap().entries.map(
                    (option) => pw.Text(
                      '${String.fromCharCode(65 + option.key)}. ${option.value}',
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Answer: ${q.options[q.correctOption]}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Explanation: ${q.explanation}'),
                ],
              ),
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => document.save(),
      name: 'PocketPlacement_${subject}_100_Levels.pdf',
    );
  }
}

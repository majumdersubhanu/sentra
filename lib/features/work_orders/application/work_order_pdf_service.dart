import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/work_order.dart';

class WorkOrderPdfService {
  static Future<void> generateAndPrint(WorkOrder wo) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SENTRA FIELD PLATFORM',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.Text(
                  'WORK ORDER: ${wo.id}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Section 1: Header
          _sectionTitle('1. WORK ORDER HEADER'),
          _infoRow([
            _infoCell('Title', wo.title),
            _infoCell('Status', wo.status.name.toUpperCase()),
          ]),
          _infoRow([
            _infoCell('Work Type', wo.workType?.name ?? 'N/A'),
            _infoCell('Priority', wo.priority.name.toUpperCase()),
          ]),
          _infoRow([
            _infoCell(
              'Scheduled Start',
              wo.scheduledStart?.toString() ?? 'N/A',
            ),
            _infoCell(
              'Scheduled Finish',
              wo.scheduledFinish?.toString() ?? 'N/A',
            ),
          ]),
          pw.SizedBox(height: 10),

          // Section 2: Location
          _sectionTitle('2. SITE INFORMATION'),
          _infoRow([
            _infoCell('Location', wo.siteLocation ?? 'N/A'),
            _infoCell('Region', wo.siteRegion ?? 'N/A'),
          ]),
          _infoRow([
            _infoCell('GPS Coordinates', wo.gpsCoordinates ?? 'N/A'),
            _infoCell('Business Unit', wo.businessUnit ?? 'N/A'),
          ]),
          pw.SizedBox(height: 10),

          // Section 3: Safety
          _sectionTitle('3. SAFETY REQUIREMENTS'),
          pw.Row(
            children: [
              _checkbox('Permit Required', wo.permitRequirement),
              pw.SizedBox(width: 20),
              _checkbox('Confined Space', wo.confinedSpaceEntry),
            ],
          ),
          pw.Row(
            children: [
              _checkbox('Hot Work', wo.hotWorkRequired),
              pw.SizedBox(width: 20),
              _checkbox('LOTO Required', wo.lockoutTagoutRequired),
            ],
          ),
          pw.SizedBox(height: 10),

          // Section 4: Problem Details
          _sectionTitle('4. PROBLEM DESCRIPTION'),
          pw.Text(wo.description, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),

          // Section 5: Personnel
          _sectionTitle('5. PERSONNEL ASSIGNMENT'),
          _infoRow([
            _infoCell('Primary Technician', wo.assignedTo ?? 'Unassigned'),
            _infoCell('Requested By', wo.requestedBy ?? 'N/A'),
          ]),
          pw.SizedBox(height: 20),

          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              children: [
                pw.Text(
                  'Authorized Signature',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                ),
                pw.SizedBox(height: 30),
                pw.Container(width: 150, height: 1, color: PdfColors.black),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Container(
        width: double.infinity,
        color: PdfColors.grey200,
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        ),
      ),
    );
  }

  static pw.Widget _infoRow(List<pw.Widget> children) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: children.map((c) => pw.Expanded(child: c)).toList(),
      ),
    );
  }

  static pw.Widget _infoCell(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.Text(value, style: pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static pw.Widget _checkbox(String label, bool checked) {
    return pw.Row(
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          child: checked
              ? pw.Center(
                  child: pw.Text('X', style: const pw.TextStyle(fontSize: 8)),
                )
              : null,
        ),
        pw.SizedBox(width: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}

import 'dart:typed_data';

import 'package:job_entry/src/taskManager/data/jobData.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generatePdf(JobData data) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Column(
              children: [ 
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}"),
                  ]
                )
              ]
            ),
            pw.SizedBox(height: 40),
            pw.Container(
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Container(child: 
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start, 
                      children: [
                        pw.Text("Job name: "),
                        pw.Text("Workers: "),
                      ]
                    ))),
                  pw.Container(height: 40),
                  pw.Expanded(child: pw.Container(child: 
                    pw.Column( 
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Start Date: __/__/____"),
                        pw.Text("Finish Date: __/__/____"),
                        pw.Text("Required By: __/__/____"),
                      ]
                    )
                  )),
                ]
              )
            ),
            pw.SizedBox(height: 40),
          ];
        },
      ),
    );

    return await pdf.save();
  }

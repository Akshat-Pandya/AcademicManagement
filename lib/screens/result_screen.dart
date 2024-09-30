import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart'; // Make sure to import cross_file

class ResultScreen extends StatelessWidget {
  final List<dynamic> students;

  const ResultScreen({Key? key, required this.students}) : super(key: key);

  _downloadAndShareExcel(BuildContext context) async {
    // Step 1: Create a new Excel document
    var excel = Excel.createExcel(); // Create a new Excel document
    Sheet sheet = excel['Sheet1']; // Access the first sheet

    // Step 2: Add headers
    sheet.appendRow([
      TextCellValue('Enrollment Number'),
      TextCellValue('Name'),
      TextCellValue('Year'),
      TextCellValue('Subject'),
      TextCellValue('CW Marks'),
      TextCellValue('SW Marks'),
    ]);

    // Step 3: Add student data
    for (var student in students) {
      sheet.appendRow([
        TextCellValue(student['enrollment_number'].toString()),
        TextCellValue(student['name'].toString()),
        IntCellValue(student['year']),
        TextCellValue(student['subject'].toString()),
        IntCellValue(student['cw_marks']),
        IntCellValue(student['sw_marks']),
      ]);
    }

    // Step 4: Save the Excel file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/students.xlsx';
    var file = File(path);
    await file.writeAsBytes(await excel.encode()!);

    // Step 5: Share the Excel file using shareXFiles
    final result = await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Here are the student results!',
    );

    // Show a message when the file is saved and shared
    if (result.status == ShareResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel file shared successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share the Excel file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Allow vertical scrolling
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Enrollment Number')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Year')),
              DataColumn(label: Text('Subject')),
              DataColumn(label: Text('CW Marks')),
              DataColumn(label: Text('SW Marks')),
            ],
            rows: students.map<DataRow>(
                  (student) => DataRow(
                cells: <DataCell>[
                  DataCell(Text(student['enrollment_number'].toString())),
                  DataCell(Text(student['name'].toString())),
                  DataCell(Text(student['year'].toString())),
                  DataCell(Text(student['subject'].toString())),
                  DataCell(Text(student['cw_marks'].toString())),
                  DataCell(Text(student['sw_marks'].toString())),
                ],
              ),
            ).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _downloadAndShareExcel(context),
        tooltip: 'Download and Share Excel',
        child: const Icon(Icons.download),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:skill_dev_project/screens/result_screen.dart';
import '../services/api_service.dart';
import 'package:excel/excel.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();

  // TextEditingController for adding records
  final TextEditingController enrollmentNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController subjectCodeController = TextEditingController();
  final TextEditingController cwMarksController = TextEditingController();
  final TextEditingController swMarksController = TextEditingController();

  // TextEditingController for filtering records
  final TextEditingController filterEnrollmentNumberController = TextEditingController();
  final TextEditingController filterNameController = TextEditingController();
  final TextEditingController filterYearController = TextEditingController();
  final TextEditingController filterSubjectController = TextEditingController();
  final TextEditingController filterSubjectCodeController = TextEditingController();

  File? _selectedFile;
  List<Map<String, dynamic>> _excelData = [];

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    enrollmentNumberController.dispose();
    nameController.dispose();
    yearController.dispose();
    subjectController.dispose();
    subjectCodeController.dispose();
    cwMarksController.dispose();
    swMarksController.dispose();
    filterEnrollmentNumberController.dispose();
    filterNameController.dispose();
    filterYearController.dispose();
    filterSubjectController.dispose();
    filterSubjectCodeController.dispose();
    super.dispose();
  }

  // Method to handle adding a record
  Future<void> _addRecord() async {
    final studentData = {
      'enrollment_number': enrollmentNumberController.text,
      'name': nameController.text,
      'year': int.tryParse(yearController.text) ?? 0,
      'subject': subjectController.text,
      'subject_code': subjectCodeController.text,
      'cw_marks': int.tryParse(cwMarksController.text) ?? 0,
      'sw_marks': int.tryParse(swMarksController.text) ?? 0,
    };

    try {
      await apiService.addStudent(studentData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add record')));
    }
  }

  // Method to fetch all records
  Future<void> _fetchAllRecords() async {
    try {
      final students = await apiService.getAllStudents();
      _navigateToResults(students);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch records')));
    }
  }

  // Method to fetch filtered records
  Future<void> _fetchFilteredRecords() async {
    try {
      final enrollmentNumber = filterEnrollmentNumberController.text.isNotEmpty ? filterEnrollmentNumberController.text : null;
      final name = filterNameController.text.isNotEmpty ? filterNameController.text : null;
      final year = int.tryParse(filterYearController.text);
      final subject = filterSubjectController.text.isNotEmpty ? filterSubjectController.text : null;
      final subjectCode = filterSubjectCodeController.text.isNotEmpty ? filterSubjectCodeController.text : null;

      final students = await apiService.filterStudents(
        enrollment_number: enrollmentNumber,
        name: name,
        year: year,
        subject: subject,
        subject_code: subjectCode,
      );
      _navigateToResults(students);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch filtered records')));
    }
  }

  // Method to pick an Excel file
  Future<void> _pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel file selected successfully')),
      );

      _readExcelData();
    }
  }

  // Method to read Excel file and parse data
  Future<void> _readExcelData() async {
    if (_selectedFile == null) return;

    var bytes = await _selectedFile!.readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    List<Map<String, dynamic>> excelData = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows.skip(1)) { // Skipping the header row
        var studentData = {
          'enrollment_number': row[0]?.value.toString(),
          'name': row[1]?.value.toString(),
          'year': int.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
          'subject': row[3]?.value.toString(),
          'subject_code': row[4]?.value.toString(),
          'cw_marks': int.tryParse(row[5]?.value.toString() ?? '0') ?? 0,
          'sw_marks': int.tryParse(row[6]?.value.toString() ?? '0') ?? 0,
        };

        excelData.add(studentData);
      }
    }

    setState(() {
      _excelData = excelData;
    });
  }

  // Method to add all records from Excel to the database
  Future<void> _addRecordsFromExcel() async {
    if (_excelData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data found in the Excel file')),
      );
      return;
    }

    try {
      for (var student in _excelData) {
        await apiService.addStudent(student);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All records added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add records from Excel')),
      );
    }
  }

  // Method to clear all previous data in the database
  Future<void> _clearPreviousData() async {
    try {
      await apiService.deleteAllRecords();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Previous data cleared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear previous data')),
      );
    }
  }

  // Navigate to Result Screen with student data
  void _navigateToResults(List<dynamic> students) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreen(students: students),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/images/logo.png'), height: 50.0, width: 48.0),
            SizedBox(width: 10.0),
            const Text('Academic Management', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: _pickExcelFile, child: const Text("Add File")),
                  ElevatedButton(onPressed: _clearPreviousData, child: const Text("Clear Old Data")),
                ],
              ),
              const SizedBox(height: 16.0),
              if (_selectedFile != null)
                Text('Selected file: ${_selectedFile!.path}'),
              const SizedBox(height: 32.0),

              _sectionTitle('Add Record'),
              _buildTextField(enrollmentNumberController, 'Enrollment Number'),
              _buildTextField(nameController, 'Name'),
              _buildTextField(yearController, 'Year'),
              _buildTextField(subjectController, 'Subject'),
              _buildTextField(subjectCodeController, 'Subject Code'),
              _buildTextField(cwMarksController, 'CW Marks'),
              _buildTextField(swMarksController, 'SW Marks'),
              _buildButton('Add Record', _addRecord),

              const SizedBox(height: 32),
              _sectionTitle('Fetch All Records'),
              _buildButton('Fetch All Records', _fetchAllRecords),

              const SizedBox(height: 32),
              _sectionTitle('Fetch Filtered Records'),
              _buildTextField(filterEnrollmentNumberController, 'Enrollment Number (filter)'),
              _buildTextField(filterNameController, 'Name (filter)'),
              _buildTextField(filterYearController, 'Year (filter)'),
              _buildTextField(filterSubjectController, 'Subject (filter)'),
              _buildTextField(filterSubjectCodeController, 'Subject Code (filter)'),
              _buildButton('Fetch Filtered Records',  _fetchFilteredRecords),

              const SizedBox(height: 32),
              _buildButton('Add All Records from Excel', _addRecordsFromExcel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

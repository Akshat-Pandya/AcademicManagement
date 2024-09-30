import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.249.156:3000'; // Update to your local API URL

  // Method to add student
  Future<void> addStudent(Map<String, dynamic> studentData) async {
    final url = Uri.parse('$baseUrl/addStudent');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(studentData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add student');
    }
  }

  // Method to get all students
  Future<List<dynamic>> getAllStudents() async {
    print("Entered get all students method");
    final url = Uri.parse('$baseUrl/getAllStudents');
    try {
      final response = await http.get(url);
    print("get request completed");
    print(response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching students: $e');
      rethrow;
    }
  }


  // Method to filter students
  Future<List<dynamic>> filterStudents({int? year, String? subject, String? enrollment_number, String? name, String? subject_code}) async {
    final queryParams = {
      if (year != null) 'year': year.toString(),
      if (subject != null) 'subject': subject,
      if (enrollment_number != null) 'enrollment_number': enrollment_number,
      if (name != null) 'name': name,
      if (subject_code != null) 'subject_code': subject_code,
    };

    final uri = Uri.parse('$baseUrl/filterStudents').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch filtered students');
    }
  }

  // Method to delete all records
  Future<void> deleteAllRecords() async {
    final url = Uri.parse('$baseUrl/deleteAllRecords'); // Ensure this matches your endpoint
    final response = await http.delete(url); // Use DELETE method

    if (response.statusCode != 200) {
      throw Exception('Failed to delete all records');
    }
  }

}

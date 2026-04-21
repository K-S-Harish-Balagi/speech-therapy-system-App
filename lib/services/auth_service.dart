import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {

  /// LOGIN — returns role string or null on failure
  static Future<String?> login(UserModel user) async {
    final prefix = (user.patientId ?? "").substring(0, 3).toUpperCase();

    String endpoint;
    if (prefix == "THE") {
      endpoint = "/therapist-login";
    } else if (prefix == "SUP") {
      endpoint = "/supervisor-login";
    } else {
      endpoint = "/login";
    }

    final url = Uri.parse("${ApiConfig.baseUrl}$endpoint");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toLoginJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token",     data["token"]);
        await prefs.setString("patientId", data["patientId"]);
        await prefs.setString("role",      data["role"]);
        return data["role"];
      }
    }

    return null;
  }

  /// REGISTER
  static Future<Map<String, dynamic>> register(
      UserModel user,
      PlatformFile? file,
      ) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/register");
    var request = http.MultipartRequest("POST", uri);

    request.fields["name"]     = user.name ?? "";
    request.fields["email"]    = user.email ?? "";
    request.fields["password"] = user.password;
    request.fields["gender"]   = user.gender ?? "";
    request.fields["problem"]  = user.problem ?? "";
    request.fields["dob"]      = user.dob ?? "";

    if (file != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "idDoc",
          file.bytes!,
          filename: file.name,
        ),
      );
    }

    var response = await request.send();
    var respStr  = await response.stream.bytesToString();
    return jsonDecode(respStr);
  }

  /// GET TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// GET ROLE
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  /// LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// GET PATIENT PROFILE
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final url   = Uri.parse("${ApiConfig.baseUrl}/profile");

    final response = await http.get(
      url,
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      return {"success": false, "expired": true};
    }

    return jsonDecode(response.body);
  }

  /// GET THERAPIST INFO (includes supervisorId)
  static Future<Map<String, dynamic>> getTherapistMe() async {
    final token = await getToken();
    final url   = Uri.parse("${ApiConfig.baseUrl}/therapist-me");

    final response = await http.get(
      url,
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      return {"success": false, "expired": true};
    }

    return jsonDecode(response.body);
  }

  /// GET SUPERVISOR NAME BY ID
  static Future<Map<String, dynamic>> getSupervisorName(String supervisorId) async {
    final token = await getToken();
    final url   = Uri.parse("${ApiConfig.baseUrl}/supervisor-name/$supervisorId");

    final response = await http.get(
      url,
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {"name": supervisorId}; // fallback to ID if fetch fails
  }

  /// GET REPORTS
  static Future<Map<String, dynamic>> getReports() async {
    final token = await getToken();
    final url   = Uri.parse("${ApiConfig.baseUrl}/get-reports");

    final response = await http.get(
      url,
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      return {"success": false, "expired": true};
    }

    return jsonDecode(response.body);
  }

  /// GET MY PATIENTS (therapist)
  static Future<Map<String, dynamic>> getMyPatients() async {
    final token = await getToken();
    final url   = Uri.parse("${ApiConfig.baseUrl}/my-patients");

    final response = await http.get(
      url,
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      return {"success": false, "expired": true};
    }

    return jsonDecode(response.body);
  }

  /// SEND REPORT
  static Future<Map<String, dynamic>> sendReport({
    required PlatformFile file,
    required String patientId,
  }) async {
    final token = await getToken();
    final uri   = Uri.parse("${ApiConfig.baseUrl}/send-report");

    var request = http.MultipartRequest("POST", uri);
    request.headers["Authorization"] = "Bearer $token";
    request.fields["patientId"] = patientId;

    request.files.add(
      http.MultipartFile.fromBytes(
        "report",
        file.bytes!,
        filename: file.name,
      ),
    );

    final response = await request.send();
    final respStr  = await response.stream.bytesToString();
    return jsonDecode(respStr);
  }
}


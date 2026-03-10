import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {

  /// LOGIN
  static Future<bool> login(UserModel user) async {

    final url = Uri.parse("${ApiConfig.baseUrl}/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toLoginJson()),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      if (data["success"] == true) {

        final prefs = await SharedPreferences.getInstance();

        /// Save token
        await prefs.setString("token", data["token"]);

        /// Save patientId
        await prefs.setString("patientId", data["patientId"]);

        return true;
      }
    }

    return false;
  }

  /// REGISTER
  static Future<Map<String, dynamic>> register(
      UserModel user,
      PlatformFile? file,
      ) async {

    final uri = Uri.parse("${ApiConfig.baseUrl}/register");

    var request = http.MultipartRequest("POST", uri);

    request.fields["name"] = user.name ?? "";
    request.fields["email"] = user.email ?? "";
    request.fields["password"] = user.password;
    request.fields["gender"] = user.gender ?? "";
    request.fields["problem"] = user.problem ?? "";
    request.fields["dob"] = user.dob ?? "";

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
    var respStr = await response.stream.bytesToString();

    return jsonDecode(respStr);
  }


  /// GET TOKEN (for protected APIs)
  static Future<String?> getToken() async {

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");

  }


  /// LOGOUT
  static Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

  }

}
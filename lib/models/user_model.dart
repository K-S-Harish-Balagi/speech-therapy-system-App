class UserModel {

  final String password;

  final String? patientId;
  final String? name;
  final String? email;
  final String? gender;
  final String? problem;
  final String? dob;

  UserModel({
    this.patientId,
    required this.password,
    this.name,
    this.email,
    this.gender,
    this.problem,
    this.dob,
  });

  /// LOGIN JSON
  Map<String, dynamic> toLoginJson() {
    return {
      "patientId": patientId,
      "password": password,
    };
  }

  /// REGISTER JSON
  Map<String, dynamic> toRegisterJson() {
    return {
      "email": email,
      "password": password,
      "name": name,
      "gender": gender,
      "problem": problem,
      "dob": dob,
    };
  }
}

extension UserValidation on UserModel {

  List<String> validate() {

    final errors = <String>[];

    if (name == null || name!.trim().isEmpty) {
      errors.add("Name is required");
    }

    if (email == null ||
        email!.trim().isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email!.trim())) {
      errors.add("Invalid email address");
    }

    if (password.trim().length < 6) {
      errors.add("Password must be at least 6 characters");
    }

    if (gender == null || gender!.isEmpty) {
      errors.add("Gender is required");
    }

    if (dob == null || dob!.isEmpty) {
      errors.add("Date of birth is required");
    }

    if (problem == null || problem!.isEmpty) {
      errors.add("Problem selection is required");
    }

    return errors;
  }
}
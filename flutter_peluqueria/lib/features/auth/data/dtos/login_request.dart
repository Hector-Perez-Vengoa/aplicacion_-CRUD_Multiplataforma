class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        email: json['email'] as String,
        password: json['contrasena'] as String? ?? json['password'] as String,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'contrasena': password,
      };
}

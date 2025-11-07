

import 'package:consumo_combustible/domain/models/user.dart';

class AuthResponse {
    bool? success;
    String message;
    Data? data;

    AuthResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    User? user; // ✅ Opcional para refresh token
    String accessToken;
    String refreshToken;
    int expiresIn;
    String tokenType;

    Data({
        this.user, // ✅ Opcional
        required this.accessToken,
        required this.refreshToken,
        required this.expiresIn,
        this.tokenType = 'Bearer',
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] != null ? User.fromJson(json["user"]) : null, // ✅ Manejo de null
        accessToken: json["accessToken"] ?? '',
        refreshToken: json["refreshToken"] ?? '',
        expiresIn: json["expiresIn"] ?? 900, // 15 minutos por defecto
        tokenType: json["tokenType"] ?? 'Bearer',
    );

    Map<String, dynamic> toJson() => {
        if (user != null) "user": user!.toJson(), // ✅ Solo incluir si existe
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "expiresIn": expiresIn,
        "tokenType": tokenType,
    };
}


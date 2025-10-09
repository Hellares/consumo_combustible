
import 'package:consumo_combustible/domain/models/user.dart';

class UserResponse {
    final bool success;
    final String message;
    final UserData data;

    UserResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        success: json["success"],
        message: json["message"],
        data: UserData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
    };
}

class UserData {
    final List<User> data;
    final Meta meta;

    UserData({
        required this.data,
        required this.meta,
    });

    factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        data: List<User>.from(json["data"].map((x) => User.fromJson(x))),
        meta: Meta.fromJson(json["meta"]),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta.toJson(),
    };
}

class Meta {
    final int total;
    final int page;
    final int pageSize;
    final int totalPages;
    final int offset;
    final int limit;
    final int? nextOffset;
    final dynamic prevOffset;
    final bool hasNext;
    final bool hasPrevious;

    Meta({
        required this.total,
        required this.page,
        required this.pageSize,
        required this.totalPages,
        required this.offset,
        required this.limit,
        this.nextOffset,
        this.prevOffset,
        required this.hasNext,
        required this.hasPrevious,
    });

    factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        total: json["total"],
        page: json["page"],
        pageSize: json["pageSize"],
        totalPages: json["totalPages"],
        offset: json["offset"],
        limit: json["limit"],
        nextOffset: json["nextOffset"],
        prevOffset: json["prevOffset"],
        hasNext: json["hasNext"],
        hasPrevious: json["hasPrevious"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "page": page,
        "pageSize": pageSize,
        "totalPages": totalPages,
        "offset": offset,
        "limit": limit,
        "nextOffset": nextOffset,
        "prevOffset": prevOffset,
        "hasNext": hasNext,
        "hasPrevious": hasPrevious,
    };
}

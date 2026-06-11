import 'package:equatable/equatable.dart';

class AppUserProfile extends Equatable {
  const AppUserProfile({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AppUserProfile.fromJson(Map<String, dynamic> json) {
    return AppUserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  AppUserProfile copyWith({String? username, DateTime? updatedAt}) {
    return AppUserProfile(
      id: id,
      username: username ?? this.username,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, username, createdAt, updatedAt];
}

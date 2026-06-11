import 'package:equatable/equatable.dart';

import 'prompt_category.dart';

class Prompt extends Equatable {
  const Prompt({
    required this.id,
    required this.userId,
    required this.title,
    required this.platform,
    required this.prompt,
    required this.imageUrl,
    this.category = PromptCategory.all,
    this.authorUsername,
    this.isSaved = false,
    this.savedCount = 0,
    this.imagePath,
    this.shareUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String platform;
  final String prompt;
  final String imageUrl;
  final PromptCategory category;
  final String? authorUsername;
  final bool isSaved;
  final int savedCount;
  final String? imagePath;
  final String? shareUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isOwnedBy(String? userId) => userId != null && this.userId == userId;

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      platform: json['platform'] as String,
      prompt: json['prompt'] as String,
      imageUrl: json['image_url'] as String,
      category: PromptCategory.fromValue(json['category'] as String?),
      authorUsername: _authorUsernameFromJson(json),
      isSaved: _isSavedFromJson(json),
      savedCount: _savedCountFromJson(json),
      imagePath: json['image_path'] as String?,
      shareUrl: json['share_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'title': title,
      'platform': platform,
      'prompt': prompt,
      'image_url': imageUrl,
      'category': category.value,
      'image_path': imagePath,
      'share_url': shareUrl,
    };
  }

  Prompt copyWith({
    String? id,
    String? userId,
    String? title,
    String? platform,
    String? prompt,
    String? imageUrl,
    PromptCategory? category,
    String? authorUsername,
    bool? isSaved,
    int? savedCount,
    String? imagePath,
    String? shareUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Prompt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      prompt: prompt ?? this.prompt,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      authorUsername: authorUsername ?? this.authorUsername,
      isSaved: isSaved ?? this.isSaved,
      savedCount: savedCount ?? this.savedCount,
      imagePath: imagePath ?? this.imagePath,
      shareUrl: shareUrl ?? this.shareUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    userId,
    title,
    platform,
    prompt,
    imageUrl,
    category,
    authorUsername,
    isSaved,
    savedCount,
    imagePath,
    shareUrl,
    createdAt,
    updatedAt,
  ];

  static String? _authorUsernameFromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'];
    if (profiles is Map<String, dynamic>) {
      return profiles['username'] as String?;
    }
    return null;
  }

  static bool _isSavedFromJson(Map<String, dynamic> json) {
    final promptSaves = json['prompt_saves'];
    if (promptSaves is List<dynamic>) {
      return promptSaves.isNotEmpty;
    }
    return false;
  }

  static int _savedCountFromJson(Map<String, dynamic> json) {
    final promptSavesCount = json['prompt_saves_count'];
    if (promptSavesCount is int) return promptSavesCount;

    final promptSaves = json['prompt_saves'];
    if (promptSaves is List<dynamic>) return promptSaves.length;

    return 0;
  }
}

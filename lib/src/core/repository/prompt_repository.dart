import 'dart:typed_data';

import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/core/repository/share_link_repository.dart';
import 'package:shareprompt/src/core/repository/storage_repository.dart';

class PromptDraft {
  const PromptDraft({
    required this.title,
    required this.platform,
    required this.prompt,
    required this.category,
    required this.imageBytes,
    required this.imageFileName,
  });

  final String title;
  final String platform;
  final String prompt;
  final PromptCategory category;
  final List<int> imageBytes;
  final String imageFileName;
}

class PromptRepository {
  PromptRepository(
    this._client,
    this._storageRepository,
    this._shareLinkRepository,
  );

  final SupabaseClient _client;
  final StorageRepository _storageRepository;
  final ShareLinkRepository _shareLinkRepository;
  final Uuid _uuid = const Uuid();

  Future<List<Prompt>> fetchPrompts({
    required int page,
    required int pageSize,
    String query = '',
    PromptCategory category = PromptCategory.all,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;
    final trimmedQuery = query.trim();
    final escaped = _escapeSearch(trimmedQuery);
    final data = switch ((trimmedQuery.isNotEmpty, category)) {
      (true, PromptCategory.all) =>
        await _client
            .from('prompts')
            .select('*, profiles!prompts_user_id_profiles_fkey(username)')
            .or(
              'title.ilike.%$escaped%,prompt.ilike.%$escaped%,platform.ilike.%$escaped%',
            )
            .order('created_at', ascending: false)
            .range(from, to),
      (true, _) =>
        await _client
            .from('prompts')
            .select('*, profiles!prompts_user_id_profiles_fkey(username)')
            .or(
              'title.ilike.%$escaped%,prompt.ilike.%$escaped%,platform.ilike.%$escaped%',
            )
            .eq('category', category.value)
            .order('created_at', ascending: false)
            .range(from, to),
      (false, PromptCategory.all) =>
        await _client
            .from('prompts')
            .select('*, profiles!prompts_user_id_profiles_fkey(username)')
            .order('created_at', ascending: false)
            .range(from, to),
      (false, _) =>
        await _client
            .from('prompts')
            .select('*, profiles!prompts_user_id_profiles_fkey(username)')
            .eq('category', category.value)
            .order('created_at', ascending: false)
            .range(from, to),
    };

    return _withSavedState(
      data
          .cast<Map<String, dynamic>>()
          .map(Prompt.fromJson)
          .toList(growable: false),
    );
  }

  Future<Prompt?> fetchPrompt(String id) async {
    final data = await _client
        .from('prompts')
        .select('*, profiles!prompts_user_id_profiles_fkey(username)')
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    final prompts = await _withSavedState(<Prompt>[Prompt.fromJson(data)]);
    return prompts.first;
  }

  Future<List<Prompt>> fetchUserPrompts(String userId) async {
    final data = await _client
        .from('prompts')
        .select('*, profiles!prompts_user_id_profiles_fkey(username)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return _withSavedState(
      data
          .cast<Map<String, dynamic>>()
          .map(Prompt.fromJson)
          .toList(growable: false),
    );
  }

  Future<List<Prompt>> fetchSavedPrompts(String userId) async {
    final savedRows = await _client
        .from('prompt_saves')
        .select('prompt_id')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final savedIds = savedRows
        .cast<Map<String, dynamic>>()
        .map((Map<String, dynamic> row) => row['prompt_id'] as String)
        .toList(growable: false);
    if (savedIds.isEmpty) return const <Prompt>[];

    final data = await _client
        .from('prompts')
        .select('*, profiles!prompts_user_id_profiles_fkey(username)')
        .inFilter('id', savedIds);
    final promptsById = <String, Prompt>{
      for (final row in data.cast<Map<String, dynamic>>())
        row['id'] as String: Prompt.fromJson(row).copyWith(isSaved: true),
    };

    return savedIds
        .map((String id) => promptsById[id])
        .whereType<Prompt>()
        .toList(growable: false);
  }

  Future<Prompt> createPrompt({
    required String userId,
    required PromptDraft draft,
  }) async {
    final promptId = _uuid.v4();
    final uploadedImage = await _storageRepository.uploadPromptImage(
      userId: userId,
      promptId: promptId,
      bytes: Uint8List.fromList(draft.imageBytes),
      fileName: draft.imageFileName,
    );
    final shareUrl = await _shareLinkRepository.createPromptShareUrl(promptId);

    final inserted = await _client
        .from('prompts')
        .insert(<String, dynamic>{
          'id': promptId,
          'user_id': userId,
          'title': draft.title.trim(),
          'platform': draft.platform,
          'prompt': draft.prompt.trim(),
          'category': draft.category.value,
          'image_url': uploadedImage.publicUrl,
          'image_path': uploadedImage.path,
          'share_url': shareUrl,
        })
        .select('*, profiles!prompts_user_id_profiles_fkey(username)')
        .single();

    return Prompt.fromJson(inserted);
  }

  Future<Prompt> updatePrompt({
    required Prompt prompt,
    required String title,
    required String platform,
    required String body,
    required PromptCategory category,
    List<int>? imageBytes,
    String? imageFileName,
  }) async {
    String imageUrl = prompt.imageUrl;
    String? imagePath = prompt.imagePath;

    if (imageBytes != null && imageFileName != null) {
      final uploadedImage = await _storageRepository.uploadPromptImage(
        userId: prompt.userId,
        promptId: prompt.id,
        bytes: Uint8List.fromList(imageBytes),
        fileName: imageFileName,
      );
      await _storageRepository.deletePromptImage(prompt.imagePath);
      imageUrl = uploadedImage.publicUrl;
      imagePath = uploadedImage.path;
    }

    final updated = await _client
        .from('prompts')
        .update(<String, dynamic>{
          'title': title.trim(),
          'platform': platform,
          'prompt': body.trim(),
          'category': category.value,
          'image_url': imageUrl,
          'image_path': imagePath,
        })
        .eq('id', prompt.id)
        .select('*, profiles!prompts_user_id_profiles_fkey(username)')
        .single();

    return Prompt.fromJson(updated);
  }

  Future<void> deletePrompt(Prompt prompt) async {
    await _client.from('prompts').delete().eq('id', prompt.id);
    await _storageRepository.deletePromptImage(prompt.imagePath);
  }

  Future<void> savePrompt({required String userId, required String promptId}) {
    return _client.from('prompt_saves').upsert(<String, dynamic>{
      'user_id': userId,
      'prompt_id': promptId,
    });
  }

  Future<void> unsavePrompt({
    required String userId,
    required String promptId,
  }) {
    return _client
        .from('prompt_saves')
        .delete()
        .eq('user_id', userId)
        .eq('prompt_id', promptId);
  }

  Future<List<Prompt>> _withSavedState(List<Prompt> prompts) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || prompts.isEmpty) return prompts;

    final ids = prompts.map((Prompt prompt) => prompt.id).toList();
    final savedRows = await _client
        .from('prompt_saves')
        .select('prompt_id')
        .eq('user_id', userId)
        .inFilter('prompt_id', ids);
    final savedIds = savedRows
        .cast<Map<String, dynamic>>()
        .map((Map<String, dynamic> row) => row['prompt_id'] as String)
        .toSet();

    return prompts
        .map(
          (Prompt prompt) =>
              prompt.copyWith(isSaved: savedIds.contains(prompt.id)),
        )
        .toList(growable: false);
  }

  String _escapeSearch(String value) {
    return value.replaceAll('%', r'\%').replaceAll(',', ' ');
  }
}

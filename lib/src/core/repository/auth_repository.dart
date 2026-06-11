import 'package:supabase/supabase.dart';

import 'package:shareprompt/src/core/model/app_user_profile.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<String> ensureAnonymousSession() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      await ensureProfile(currentUser.id);
      return currentUser.id;
    }

    final response = await _client.auth.signInAnonymously();
    final user = response.user;
    if (user == null) {
      throw StateError('Unable to start anonymous session');
    }
    await ensureProfile(user.id);
    return user.id;
  }

  Future<AppUserProfile> ensureCurrentUserProfile() async {
    final userId = await ensureAnonymousSession();
    return ensureProfile(userId);
  }

  Future<AppUserProfile> ensureProfile(String userId) async {
    final existing = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (existing != null) return AppUserProfile.fromJson(existing);

    final inserted = await _client
        .from('profiles')
        .insert(<String, dynamic>{
          'id': userId,
          'username': _randomUsername(userId),
        })
        .select()
        .single();
    return AppUserProfile.fromJson(inserted);
  }

  Future<AppUserProfile> updateUsername(String username) async {
    final userId = await ensureAnonymousSession();
    final updated = await _client
        .from('profiles')
        .update(<String, dynamic>{'username': username.trim()})
        .eq('id', userId)
        .select()
        .single();
    return AppUserProfile.fromJson(updated);
  }

  String _randomUsername(String userId) {
    final compactId = userId.replaceAll('-', '');
    final suffix = compactId.length >= 6
        ? compactId.substring(compactId.length - 6)
        : compactId;
    return 'user_$suffix';
  }
}

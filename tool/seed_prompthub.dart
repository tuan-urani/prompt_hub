import 'dart:io';

import 'package:supabase/supabase.dart';

import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/core/repository/share_link_repository.dart';
import 'package:shareprompt/src/core/repository/storage_repository.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_config.dart';

Future<void> main() async {
  final env = _readEnv('.env');
  final supabaseUrl = env['SUPABASE_URL'];
  final supabaseAnonKey = env['SUPABASE_ANON_KEY'];
  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw StateError('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
  }

  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  final storageRepository = StorageRepository(client);
  final promptRepository = PromptRepository(
    client,
    storageRepository,
    ShareLinkRepository(appsFlyerConfig: AppsFlyerConfig.fromEnv(env)),
  );

  final existingPrompts = await promptRepository.fetchPrompts(
    page: 0,
    pageSize: 1,
  );
  if (existingPrompts.isNotEmpty) {
    stdout.writeln('PromptHub seed skipped: prompt table already has data.');
    exit(0);
  }

  final authResponse = await client.auth.signInAnonymously();
  final userId = authResponse.user?.id;
  if (userId == null) {
    throw StateError('Unable to create anonymous seed user.');
  }

  final promptText = await File('seed/prompt.md').readAsString();
  final imageBytes = await File('seed/image.png').readAsBytes();
  final prompt = await promptRepository.createPrompt(
    userId: userId,
    draft: PromptDraft(
      title: 'Hands in Pockets',
      platform: 'OpenAI',
      prompt: promptText.trim(),
      category: PromptCategory.people,
      imageBytes: imageBytes,
      imageFileName: 'seed.png',
    ),
  );

  stdout.writeln('PromptHub seed created: ${prompt.id}');
  exit(0);
}

Map<String, String> _readEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) return <String, String>{};

  final env = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#') || !trimmed.contains('=')) {
      continue;
    }
    final index = trimmed.indexOf('=');
    env[trimmed.substring(0, index).trim()] = trimmed
        .substring(index + 1)
        .trim();
  }
  return env;
}

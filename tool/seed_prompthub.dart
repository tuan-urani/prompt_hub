import 'dart:io';

import 'package:supabase/supabase.dart';

import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/core/repository/share_link_repository.dart';
import 'package:shareprompt/src/core/repository/storage_repository.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_config.dart';

const List<_SeedCategory> _seedCategories = <_SeedCategory>[
  _SeedCategory(
    directory: 'anime',
    titlePrefix: 'Anime',
    category: PromptCategory.anime,
  ),
  _SeedCategory(
    directory: 'fashion',
    titlePrefix: 'Fashion',
    category: PromptCategory.fashion,
  ),
  _SeedCategory(
    directory: 'concept_art',
    titlePrefix: 'Concept Art',
    category: PromptCategory.conceptArt,
  ),
  _SeedCategory(
    directory: 'portrait',
    titlePrefix: 'Portrait',
    category: PromptCategory.portrait,
  ),
  _SeedCategory(
    directory: '3d',
    titlePrefix: '3D Render',
    category: PromptCategory.renders3d,
  ),
];

Future<void> main(List<String> args) async {
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
  final authRepository = AuthRepository(client);
  final userId = await authRepository.ensureAnonymousSession();

  if (!args.contains('--keep-existing')) {
    await _deleteExistingPrompts(promptRepository);
  }

  var createdCount = 0;
  for (final seedCategory in _seedCategories) {
    final prompts = await _readPrompts(seedCategory);
    for (final entry in prompts.entries) {
      final imageFile = File(
        'seed/${seedCategory.directory}/image/${entry.key}.png',
      );
      if (!imageFile.existsSync()) {
        throw StateError(
          'Missing image for ${seedCategory.directory}: ${imageFile.path}',
        );
      }

      final prompt = await promptRepository.createPrompt(
        userId: userId,
        draft: PromptDraft(
          title: '${seedCategory.titlePrefix} ${entry.key}',
          platform: 'Midjourney',
          prompt: entry.value,
          category: seedCategory.category,
          imageBytes: await imageFile.readAsBytes(),
          imageFileName: imageFile.path.split(Platform.pathSeparator).last,
        ),
      );
      createdCount++;
      stdout.writeln('Seeded ${seedCategory.category.value}: ${prompt.id}');
    }
  }

  stdout.writeln('PromptHub seed completed: $createdCount prompts created.');
  exit(0);
}

Future<void> _deleteExistingPrompts(PromptRepository promptRepository) async {
  var deletedCount = 0;
  while (true) {
    final prompts = await promptRepository.fetchPrompts(page: 0, pageSize: 50);
    if (prompts.isEmpty) break;
    for (final prompt in prompts) {
      await promptRepository.deletePrompt(prompt);
      deletedCount++;
      stdout.writeln('Deleted existing prompt: ${prompt.id}');
    }
  }
  stdout.writeln('PromptHub seed reset: $deletedCount prompts deleted.');
}

Future<Map<int, String>> _readPrompts(_SeedCategory seedCategory) async {
  final promptsFile = File('seed/${seedCategory.directory}/prompts.md');
  final promptFile = File('seed/${seedCategory.directory}/prompt.md');
  final file = promptsFile.existsSync() ? promptsFile : promptFile;
  if (!file.existsSync()) {
    throw StateError('Missing prompt file for ${seedCategory.directory}');
  }

  final prompts = <int, String>{};
  final pattern = RegExp(r'^\s*(\d+)\.\s*(.*)$');
  int? currentIndex;
  final buffer = StringBuffer();

  void flush() {
    final index = currentIndex;
    if (index == null) return;
    final prompt = buffer.toString().trim();
    if (prompt.isNotEmpty) {
      prompts[index] = prompt;
    }
    buffer.clear();
  }

  for (final line in file.readAsLinesSync()) {
    final match = pattern.firstMatch(line);
    if (match != null) {
      flush();
      currentIndex = int.parse(match.group(1)!);
      buffer.write(match.group(2)?.trim() ?? '');
      continue;
    }
    if (currentIndex == null) continue;
    if (buffer.isNotEmpty) buffer.writeln();
    buffer.write(line.trimRight());
  }
  flush();

  for (var index = 1; index <= 10; index++) {
    if (!prompts.containsKey(index)) {
      throw StateError('Missing prompt $index in ${file.path}');
    }
  }

  return Map<int, String>.fromEntries(
    prompts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
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

class _SeedCategory {
  const _SeedCategory({
    required this.directory,
    required this.titlePrefix,
    required this.category,
  });

  final String directory;
  final String titlePrefix;
  final PromptCategory category;
}

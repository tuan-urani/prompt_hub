import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';

class PromptHubSeedService {
  PromptHubSeedService(this._promptRepository);

  final PromptRepository _promptRepository;

  Future<void> seedIfNeeded(String userId) async {
    final isEnabled = dotenv.env['PROMPTHUB_SEED_ENABLED'] == 'true';
    if (!isEnabled) return;

    final existingPrompts = await _promptRepository.fetchPrompts(
      page: 0,
      pageSize: 1,
    );
    if (existingPrompts.isNotEmpty) return;

    final promptText = await rootBundle.loadString('seed/portrait/prompt.md');
    final imageData = await rootBundle.load('seed/portrait/image/1.png');
    await _promptRepository.createPrompt(
      userId: userId,
      draft: PromptDraft(
        title: 'Hands in Pockets',
        platform: 'OpenAI',
        prompt: promptText.trim(),
        category: PromptCategory.portrait,
        imageBytes: imageData.buffer.asUint8List(),
        imageFileName: '1.png',
      ),
    );

    if (kDebugMode) {
      debugPrint('PromptHub seed prompt created');
    }
  }
}

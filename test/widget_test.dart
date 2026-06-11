import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/locale/translation_manager.dart';
import 'package:shareprompt/src/ui/home/components/prompt_preview_modal.dart';
import 'package:shareprompt/src/ui/widgets/prompt_primary_button.dart';

void main() {
  testWidgets('primary prompt button renders label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: TranslationManager(),
        locale: TranslationManager.defaultLocale,
        home: Scaffold(
          body: PromptPrimaryButton(label: 'Publish', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Publish'), findsOneWidget);
  });

  testWidgets('prompt preview modal renders selected prompt actions', (
    WidgetTester tester,
  ) async {
    final prompt = Prompt(
      id: 'prompt-id',
      userId: 'user-id',
      title: 'LeoBlaze',
      platform: 'OpenAI',
      prompt: 'Clean portrait prompt body.',
      imageUrl: '',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        translations: TranslationManager(),
        locale: TranslationManager.defaultLocale,
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  showPromptPreviewModal(context: context, prompt: prompt);
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('LeoBlaze'), findsOneWidget);
    expect(find.text('OpenAI'), findsOneWidget);
    expect(find.text('Clean portrait prompt body.'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });
}

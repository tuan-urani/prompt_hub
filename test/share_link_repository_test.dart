import 'package:flutter_test/flutter_test.dart';

import 'package:shareprompt/src/core/repository/share_link_repository.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_config.dart';

void main() {
  group('ShareLinkRepository', () {
    const promptId = '32843379-29b5-4d3c-93e7-e511bf6c6f84';

    test('creates AppsFlyer OneLink URL when config is available', () async {
      const repository = ShareLinkRepository(
        appsFlyerConfig: AppsFlyerConfig(
          devKey: 'dev-key',
          iosAppId: '6778710143',
          oneLinkDomain: 'prompthub.onelink.me',
          oneLinkTemplateId: 'ptgB',
        ),
      );

      final url = await repository.createPromptShareUrl(promptId);
      final uri = Uri.parse(url);

      expect(uri.scheme, 'https');
      expect(uri.host, 'prompthub.onelink.me');
      expect(uri.path, '/ptgB');
      expect(uri.queryParameters['pid'], 'share');
      expect(uri.queryParameters['c'], 'prompt_share');
      expect(uri.queryParameters['deep_link_value'], 'prompt_detail');
      expect(uri.queryParameters['deep_link_sub1'], promptId);
    });

    test('falls back to app scheme when OneLink config is missing', () async {
      const repository = ShareLinkRepository();

      final url = await repository.createPromptShareUrl(promptId);

      expect(url, 'prompthub://prompt/$promptId');
    });

    test('parses prompt id from fallback and OneLink URLs', () {
      const repository = ShareLinkRepository();

      expect(
        repository.parsePromptId(Uri.parse('prompthub://prompt/$promptId')),
        promptId,
      );
      expect(
        repository.parsePromptId(
          Uri.parse(
            'https://prompthub.onelink.me/ptgB'
            '?deep_link_value=prompt_detail'
            '&deep_link_sub1=$promptId',
          ),
        ),
        promptId,
      );
    });
  });
}

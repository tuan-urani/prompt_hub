import 'package:shareprompt/src/core/service/appsflyer/appsflyer_config.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_service.dart';
import 'package:shareprompt/src/core/service/prompt_link_parser.dart';

class ShareLinkRepository {
  const ShareLinkRepository({
    this.appsFlyerConfig = const AppsFlyerConfig(),
    this.appsFlyerService,
  });

  final AppsFlyerConfig appsFlyerConfig;
  final AppsFlyerService? appsFlyerService;

  Future<String> createPromptShareUrl(String promptId) async {
    final sdkUrl = await appsFlyerService?.createPromptShareUrl(promptId);
    if (sdkUrl != null && sdkUrl.isNotEmpty) {
      return sdkUrl;
    }

    final oneLinkUrl = createPromptOneLinkUrl(promptId);
    if (oneLinkUrl != null) {
      return oneLinkUrl;
    }

    return PromptLinkParser.createFallbackUrl(promptId);
  }

  String? createPromptOneLinkUrl(String promptId) {
    if (!appsFlyerConfig.hasOneLinkConfig) return null;

    final domain = appsFlyerConfig.oneLinkDomain
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/+$'), '');
    final path = '/${appsFlyerConfig.oneLinkTemplateId}';

    return Uri.https(domain, path, <String, String>{
      'pid': PromptLinkParser.shareChannel,
      'c': PromptLinkParser.shareCampaign,
      PromptLinkParser.deepLinkValueKey: PromptLinkParser.promptDetailValue,
      PromptLinkParser.deepLinkPromptIdKey: promptId,
      PromptLinkParser.promptIdKey: promptId,
      'af_dp': PromptLinkParser.createFallbackUrl(promptId),
      if (appsFlyerConfig.fallbackUrl.isNotEmpty)
        'af_web_dp': appsFlyerConfig.fallbackUrl,
    }).toString();
  }

  String? parsePromptId(Uri uri) {
    return PromptLinkParser.parseUri(uri);
  }
}

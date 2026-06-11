import 'dart:async';
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import 'package:shareprompt/src/core/service/appsflyer/appsflyer_config.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_service.dart';
import 'package:shareprompt/src/core/service/prompt_link_parser.dart';

AppsFlyerService createPlatformAppsFlyerService(AppsFlyerConfig config) {
  return MobileAppsFlyerService(config);
}

class MobileAppsFlyerService implements AppsFlyerService {
  MobileAppsFlyerService(this.config);

  final AppsFlyerConfig config;
  final StreamController<String> _promptIdController =
      StreamController<String>.broadcast();

  AppsflyerSdk? _sdk;
  bool _isInitialized = false;
  String? _pendingPromptId;

  @override
  Stream<String> get promptIdStream => _promptIdController.stream;

  @override
  String? takePendingPromptId() {
    final promptId = _pendingPromptId;
    _pendingPromptId = null;
    return promptId;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized || !_isSupportedPlatform || !_hasSdkConfig) return;

    try {
      final sdk = AppsflyerSdk(
        AppsFlyerOptions(
          afDevKey: config.devKey,
          appId: config.iosAppId,
          appInviteOneLink: config.oneLinkTemplateId,
          showDebug: config.isDebug,
        ),
      );
      _sdk = sdk;
      sdk.onDeepLinking(_handleDeepLink);
      await sdk.setAppInviteOneLinkID(config.oneLinkTemplateId, (_) {});
      await sdk.initSdk(registerOnDeepLinkingCallback: true);
      if (Platform.isAndroid) {
        sdk.performOnDeepLinking();
      }
      _isInitialized = true;
    } on Object {
      _sdk = null;
      _isInitialized = false;
    }
  }

  @override
  Future<String?> createPromptShareUrl(String promptId) async {
    final sdk = _sdk;
    if (sdk == null ||
        !_isInitialized ||
        !_isSupportedPlatform ||
        !config.hasOneLinkConfig) {
      return null;
    }

    try {
      final completer = Completer<String?>();
      final fallbackDeepLink = PromptLinkParser.createFallbackUrl(promptId);
      final params = AppsFlyerInviteLinkParams(
        channel: PromptLinkParser.shareChannel,
        campaign: PromptLinkParser.shareCampaign,
        baseDeepLink: fallbackDeepLink,
        brandDomain: config.oneLinkDomain,
        customerID: promptId,
        customParams: <String, String>{
          PromptLinkParser.deepLinkValueKey: PromptLinkParser.promptDetailValue,
          PromptLinkParser.deepLinkPromptIdKey: promptId,
          PromptLinkParser.promptIdKey: promptId,
          'af_dp': fallbackDeepLink,
          if (config.fallbackUrl.isNotEmpty) 'af_web_dp': config.fallbackUrl,
        },
      );

      sdk.generateInviteLink(
        params,
        (dynamic result) {
          if (!completer.isCompleted) {
            completer.complete(_extractInviteUrl(result));
          }
        },
        (_) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      );

      return completer.future.timeout(
        const Duration(seconds: 6),
        onTimeout: () => null,
      );
    } on Object {
      return null;
    }
  }

  bool get _isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  bool get _hasSdkConfig {
    if (config.devKey.isEmpty || config.oneLinkTemplateId.isEmpty) {
      return false;
    }
    return !Platform.isIOS || config.iosAppId.isNotEmpty;
  }

  void _handleDeepLink(DeepLinkResult result) {
    if (result.status != Status.FOUND) return;
    final promptId = PromptLinkParser.parseParameters(
      result.deepLink?.clickEvent ?? const <String, dynamic>{},
    );
    if (promptId == null || promptId.isEmpty) return;
    if (_promptIdController.hasListener) {
      _promptIdController.add(promptId);
    } else {
      _pendingPromptId = promptId;
    }
  }

  String? _extractInviteUrl(dynamic result) {
    if (result is String && result.startsWith('http')) return result;
    if (result is! Map) return null;

    final payload = result['payload'];
    if (payload is Map) {
      final url = payload['userInviteURL'] ?? payload['link'];
      if (url is String && url.isNotEmpty) return url;
    }

    final url = result['userInviteURL'] ?? result['link'];
    if (url is String && url.isNotEmpty) return url;

    return null;
  }
}

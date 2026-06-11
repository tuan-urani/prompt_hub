import 'package:shareprompt/src/core/service/appsflyer/appsflyer_config.dart';

abstract class AppsFlyerService {
  Stream<String> get promptIdStream;

  String? takePendingPromptId();

  Future<void> initialize();

  Future<String?> createPromptShareUrl(String promptId);
}

class NoopAppsFlyerService implements AppsFlyerService {
  const NoopAppsFlyerService(this.config);

  final AppsFlyerConfig config;

  @override
  Stream<String> get promptIdStream => const Stream<String>.empty();

  @override
  String? takePendingPromptId() => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> createPromptShareUrl(String promptId) async => null;
}

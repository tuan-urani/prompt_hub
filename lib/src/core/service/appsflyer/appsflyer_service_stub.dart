import 'package:shareprompt/src/core/service/appsflyer/appsflyer_config.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_service.dart';

AppsFlyerService createPlatformAppsFlyerService(AppsFlyerConfig config) {
  return NoopAppsFlyerService(config);
}

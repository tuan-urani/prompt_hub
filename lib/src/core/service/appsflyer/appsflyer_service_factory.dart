import 'package:shareprompt/src/core/service/appsflyer/appsflyer_config.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_service.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_service_stub.dart'
    if (dart.library.io) 'package:shareprompt/src/core/service/appsflyer/appsflyer_service_mobile.dart';

AppsFlyerService createAppsFlyerService(AppsFlyerConfig config) {
  return createPlatformAppsFlyerService(config);
}

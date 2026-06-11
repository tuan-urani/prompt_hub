import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/core/repository/share_link_repository.dart';
import 'package:shareprompt/src/core/repository/storage_repository.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_config.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_service.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_service_factory.dart';
import 'package:shareprompt/src/core/service/prompthub_seed_service.dart';

Future<void> registerCoreModule() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw StateError('Missing Supabase configuration');
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  final appsFlyerConfig = AppsFlyerConfig.fromEnv(dotenv.env);
  final appsFlyerService = createAppsFlyerService(appsFlyerConfig);
  await appsFlyerService.initialize();

  final client = Supabase.instance.client;
  Get.put<SupabaseClient>(client, permanent: true);
  Get.put<AppsFlyerService>(appsFlyerService, permanent: true);
  Get.put<AuthRepository>(AuthRepository(client), permanent: true);
  Get.put<ShareLinkRepository>(
    ShareLinkRepository(
      appsFlyerConfig: appsFlyerConfig,
      appsFlyerService: appsFlyerService,
    ),
    permanent: true,
  );
  Get.put<StorageRepository>(StorageRepository(client), permanent: true);
  Get.put<PromptRepository>(
    PromptRepository(client, Get.find<StorageRepository>(), Get.find()),
    permanent: true,
  );
  Get.put<PromptHubSeedService>(
    PromptHubSeedService(Get.find<PromptRepository>()),
    permanent: true,
  );
}

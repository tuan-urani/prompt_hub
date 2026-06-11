import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/service/prompthub_seed_service.dart';
import 'package:shareprompt/src/utils/app_assets.dart';
import 'package:shareprompt/src/utils/app_pages.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authRepository = Get.find<AuthRepository>();
      final seedService = Get.find<PromptHubSeedService>();
      final userId = await authRepository.ensureAnonymousSession();
      await seedService.seedIfNeeded(userId);
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Get.offNamed(AppPages.main);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFF),
      body: SizedBox.expand(
        child: Image.asset(AppAssets.splashImagePng, fit: BoxFit.cover),
      ),
    );
  }
}

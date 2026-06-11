import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/repository/share_link_repository.dart';
import 'package:shareprompt/src/core/service/appsflyer/appsflyer_service.dart';
import 'package:shareprompt/src/ui/home/home_page.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_pages.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AppLinks _appLinks = AppLinks();
  late final ShareLinkRepository _shareLinkRepository;
  late final AppsFlyerService _appsFlyerService;
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<String>? _appsFlyerSubscription;
  String? _lastOpenedPromptId;
  DateTime? _lastOpenedAt;

  @override
  void initState() {
    super.initState();
    _shareLinkRepository = Get.find<ShareLinkRepository>();
    _appsFlyerService = Get.find<AppsFlyerService>();
    _listenForLinks();
  }

  Future<void> _listenForLinks() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _openLink(initialLink);
    }
    _linkSubscription = _appLinks.uriLinkStream.listen(_openLink);
    _appsFlyerSubscription = _appsFlyerService.promptIdStream.listen(
      _openPromptId,
    );
    final pendingPromptId = _appsFlyerService.takePendingPromptId();
    if (pendingPromptId != null && pendingPromptId.isNotEmpty) {
      _openPromptId(pendingPromptId);
    }
  }

  void _openLink(Uri uri) {
    final promptId = _shareLinkRepository.parsePromptId(uri);
    if (promptId == null || promptId.isEmpty) return;
    _openPromptId(promptId);
  }

  void _openPromptId(String promptId) {
    final now = DateTime.now();
    final lastOpenedAt = _lastOpenedAt;
    if (_lastOpenedPromptId == promptId &&
        lastOpenedAt != null &&
        now.difference(lastOpenedAt) < const Duration(seconds: 2)) {
      return;
    }
    _lastOpenedPromptId = promptId;
    _lastOpenedAt = now;
    Get.toNamed(
      AppPages.promptDetail,
      arguments: <String, dynamic>{'id': promptId},
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _appsFlyerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: AppColors.surface, body: HomePage());
  }
}

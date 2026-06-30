import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/model/app_user_profile.dart';
import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/extensions/int_extensions.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/settings/components/settings_header.dart';
import 'package:shareprompt/src/ui/settings/components/settings_menu_section.dart';
import 'package:shareprompt/src/ui/widgets/base/toast/app_toast.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AuthRepository _authRepository;
  AppUserProfile? _profile;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _authRepository = Get.find<AuthRepository>();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _authRepository.ensureCurrentUserProfile();
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  Future<void> _editUsername() async {
    final username = await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          _EditUsernameDialog(initialUsername: _profile?.username),
    );
    if (username == null || username.isEmpty) return;
    try {
      final profile = await _authRepository.updateUsername(username);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _changed = true;
      });
      showSuccessToast(LocaleKey.success.tr);
    } catch (error) {
      showErrorToast(error.toString());
    }
  }

  void _close() => Navigator.pop(context, _changed);

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
        backgroundColor: AppColors.profileBackgroundBottom,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.profileBackgroundGradient(),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: <Widget>[
                  SettingsHeader(onBack: _close),
                  26.height,
                  SettingsMenuSection(
                    children: <Widget>[
                      SettingsMenuItem(
                        icon: Icons.person_outline_rounded,
                        label:
                            _profile?.username ??
                            LocaleKey.profileUsernameHint.tr,
                        onTap: _editUsername,
                      ),
                      const SettingsMenuDivider(),
                      SettingsMenuItem(
                        icon: Icons.policy_outlined,
                        label: LocaleKey.settingsPrivacyPolicy.tr,
                      ),
                      const SettingsMenuDivider(),
                      SettingsMenuItem(
                        icon: Icons.description_outlined,
                        label: LocaleKey.settingsTermsOfUse.tr,
                      ),
                    ],
                  ),
                  18.height,
                  SettingsMenuSection(
                    children: <Widget>[
                      SettingsMenuItem(
                        icon: Icons.language_rounded,
                        label: LocaleKey.settingsLanguage.tr,
                        showChevron: false,
                        trailing: SettingsLanguagePill(
                          label: LocaleKey.settingsEnglish.tr,
                        ),
                      ),
                    ],
                  ),
                  18.height,
                  SettingsMenuSection(
                    isDanger: true,
                    children: <Widget>[
                      SettingsMenuItem(
                        icon: Icons.delete_outline_rounded,
                        label: LocaleKey.settingsDeleteData.tr,
                        isDanger: true,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Text(
                      '${LocaleKey.settingsAppVersion.tr} 1.0.0',
                      style: AppStyles.bodyMedium(
                        color: AppColors.createPromptMutedText,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditUsernameDialog extends StatefulWidget {
  const _EditUsernameDialog({this.initialUsername});

  final String? initialUsername;

  @override
  State<_EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<_EditUsernameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKey.profileEditUsername.tr),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: LocaleKey.profileUsernameHint.tr),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(LocaleKey.cancel.tr),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(LocaleKey.save.tr),
        ),
      ],
    );
  }
}

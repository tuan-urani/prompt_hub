import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/extensions/int_extensions.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/base/interactor/page_states.dart';
import 'package:shareprompt/src/ui/profile/bloc/profile_bloc.dart';
import 'package:shareprompt/src/ui/profile/components/profile_empty_state.dart';
import 'package:shareprompt/src/ui/profile/components/profile_header_card.dart';
import 'package:shareprompt/src/ui/profile/components/profile_stats_tabs.dart';
import 'package:shareprompt/src/ui/home/components/discovery_prompt_grid_card.dart';
import 'package:shareprompt/src/ui/home/components/prompt_preview_modal.dart';
import 'package:shareprompt/src/ui/widgets/base/toast/app_toast.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_pages.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileBloc _bloc;
  ProfileTab _selectedTab = ProfileTab.posts;

  @override
  void initState() {
    super.initState();
    _bloc = ProfileBloc(
      Get.find<PromptRepository>(),
      Get.find<AuthRepository>(),
    )..loadProfile();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.profileBackgroundBottom,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.profileBackgroundGradient(),
          ),
          child: SafeArea(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (BuildContext context, ProfileState state) {
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: Column(
                        children: <Widget>[
                          ProfileHeaderCard(
                            username: state.profile?.username ?? 'user',
                            postsCount: state.prompts.length,
                            savedCount: state.savedPrompts.length,
                            onEditUsername: () => _editUsername(context, state),
                            onBackTap: () => Navigator.pop(context),
                            onSettingsTap: () => Get.toNamed(AppPages.settings),
                          ),
                          0.height,
                          ProfileStatsTabs(
                            postsCount: state.prompts.length,
                            savedCount: state.savedPrompts.length,
                            selectedTab: _selectedTab,
                            onTabChanged: (ProfileTab tab) {
                              setState(() => _selectedTab = tab);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primaryLight,
                        backgroundColor: AppColors.profilePanel,
                        onRefresh: _bloc.loadProfile,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: <Widget>[_buildContentSliver(state)],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSliver(ProfileState state) {
    final prompts = _selectedTab == ProfileTab.saved
        ? state.savedPrompts
        : state.prompts;

    if (_selectedTab == ProfileTab.saved) {
      if (state.status == PageState.loading) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryLight),
          ),
        );
      }
      if (prompts.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 96),
              child: ProfileEmptyState(
                title: LocaleKey.profileNoSavedTitle.tr,
                message: LocaleKey.profileNoSavedMessage.tr,
              ),
            ),
          ),
        );
      }
    }

    return switch (state.status) {
      PageState.loading => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight),
        ),
      ),
      PageState.failure => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 96),
            child: Text(
              state.errorMessage ?? LocaleKey.loadError.tr,
              textAlign: TextAlign.center,
              style: AppStyles.bodyLarge(
                color: AppColors.profileMutedText,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
      PageState.success ||
      PageState.initial when prompts.isEmpty => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 96),
            child: ProfileEmptyState(
              title: LocaleKey.profileNoPostsTitle.tr,
              message: LocaleKey.profileNoPostsMessage.tr,
              actionLabel: LocaleKey.createPromptTitle.tr,
              onAction: () => Get.toNamed(AppPages.createPrompt),
            ),
          ),
        ),
      ),
      _ => SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
        sliver: SliverGrid.builder(
          itemCount: prompts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.87,
          ),
          itemBuilder: (BuildContext context, int index) {
            final prompt = prompts[index];
            return DiscoveryPromptGridCard(
              prompt: prompt,
              onTap: () => _openPromptPreview(context, prompt),
            );
          },
        ),
      ),
    };
  }

  Future<void> _editUsername(BuildContext context, ProfileState state) async {
    final controller = TextEditingController(text: state.profile?.username);
    final username = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(LocaleKey.profileEditUsername.tr),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: LocaleKey.profileUsernameHint.tr,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKey.cancel.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(LocaleKey.save.tr),
          ),
        ],
      ),
    );
    controller.dispose();
    if (username == null || username.isEmpty) return;
    try {
      await _bloc.updateUsername(username);
      showSuccessToast(LocaleKey.success.tr);
    } catch (error) {
      showErrorToast(error.toString());
    }
  }

  Future<void> _openPromptPreview(BuildContext context, Prompt prompt) async {
    final shouldRefresh = await showPromptPreviewModal(
      context: context,
      prompt: prompt,
    );
    if (shouldRefresh == true) {
      await _bloc.loadProfile();
    }
  }
}

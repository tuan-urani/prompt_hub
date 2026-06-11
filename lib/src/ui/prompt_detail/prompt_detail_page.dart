import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/base/interactor/page_states.dart';
import 'package:shareprompt/src/ui/prompt_detail/bloc/prompt_detail_bloc.dart';
import 'package:shareprompt/src/ui/widgets/base/toast/app_toast.dart';
import 'package:shareprompt/src/ui/widgets/prompt_image_view.dart';
import 'package:shareprompt/src/ui/widgets/prompt_platform_chip.dart';
import 'package:shareprompt/src/ui/widgets/prompt_primary_button.dart';
import 'package:shareprompt/src/ui/widgets/prompt_section_label.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_pages.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class PromptDetailPage extends StatefulWidget {
  const PromptDetailPage({super.key});

  @override
  State<PromptDetailPage> createState() => _PromptDetailPageState();
}

class _PromptDetailPageState extends State<PromptDetailPage> {
  late final PromptDetailBloc _bloc;
  late final String _promptId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _promptId = args?['id'] as String? ?? '';
    _bloc = PromptDetailBloc(
      Get.find<PromptRepository>(),
      Get.find<AuthRepository>(),
    )..loadPrompt(_promptId);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PromptDetailBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: BlocBuilder<PromptDetailBloc, PromptDetailState>(
          builder: (BuildContext context, PromptDetailState state) {
            if (state.status == PageState.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state.status == PageState.failure || state.prompt == null) {
              return _DetailError(
                message: state.errorMessage ?? LocaleKey.loadError.tr,
              );
            }
            return _DetailContent(
              prompt: state.prompt!,
              state: state,
              bloc: _bloc,
            );
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.prompt,
    required this.state,
    required this.bloc,
  });

  final Prompt prompt;
  final PromptDetailState state;
  final PromptDetailBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              flex: 48,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  PromptImageView(url: prompt.imageUrl, radius: 0),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _CircleIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context, true),
                        ),
                        Row(
                          children: <Widget>[
                            _CircleIconButton(
                              icon: prompt.isSaved
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              onTap: bloc.toggleSave,
                            ),
                            if (state.isOwner) ...<Widget>[
                              const SizedBox(width: 10),
                              _OwnerMenu(
                                onEdit: () async {
                                  final changed = await Get.toNamed(
                                    AppPages.editPrompt,
                                    arguments: <String, dynamic>{
                                      'id': prompt.id,
                                    },
                                  );
                                  if (changed == true) {
                                    bloc.loadPrompt(prompt.id);
                                  }
                                },
                                onDelete: () async {
                                  await bloc.deletePrompt();
                                  if (context.mounted) {
                                    Navigator.pop(context, true);
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(flex: 52, child: SizedBox()),
          ],
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.52,
          minChildSize: 0.52,
          maxChildSize: 0.86,
          builder: (BuildContext context, ScrollController scrollController) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  18,
                  24,
                  18,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      prompt.title,
                      style: AppStyles.h4(
                        color: AppColors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${LocaleKey.promptAuthor.tr}: ${prompt.authorUsername ?? 'user'}',
                      style: AppStyles.bodyMedium(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    PromptSectionLabel(LocaleKey.promptLabel.tr),
                    const SizedBox(height: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                prompt.prompt,
                                style: AppStyles.bodyMedium(
                                  color: AppColors.color333333,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                await bloc.copyPrompt();
                                showSuccessToast(LocaleKey.promptCopied.tr);
                              },
                              child: const Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    PromptSectionLabel(LocaleKey.platformLabel.tr),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        PromptPlatformChip(platform: prompt.platform),
                      ],
                    ),
                    const SizedBox(height: 36),
                    PromptPrimaryButton(
                      label: LocaleKey.copyPrompt.tr,
                      icon: Icons.link_rounded,
                      onPressed: () async {
                        await bloc.copyPrompt();
                        showSuccessToast(LocaleKey.promptCopied.tr);
                      },
                    ),
                    const SizedBox(height: 12),
                    PromptPrimaryButton(
                      label: LocaleKey.sharePrompt.tr,
                      icon: Icons.ios_share_rounded,
                      isOutlined: true,
                      onPressed: bloc.sharePrompt,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OwnerMenu extends StatelessWidget {
  const _OwnerMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.surface,
      icon: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.black.withAlpha(105),
          shape: BoxShape.circle,
        ),
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.more_horiz_rounded, color: AppColors.white),
        ),
      ),
      onSelected: (String value) => value == 'edit' ? onEdit() : onDelete(),
      itemBuilder: (_) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Text(LocaleKey.editPromptTitle.tr),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(LocaleKey.deletePrompt.tr),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.black.withAlpha(105),
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              LocaleKey.loadError.tr,
              style: AppStyles.h4(
                color: AppColors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKey.ok.tr),
            ),
          ],
        ),
      ),
    );
  }
}

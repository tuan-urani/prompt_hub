import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/home/bloc/home_bloc.dart';
import 'package:shareprompt/src/ui/widgets/base/toast/app_toast.dart';
import 'package:shareprompt/src/ui/widgets/prompt_image_view.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_pages.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

Future<bool?> showPromptPreviewModal({
  required BuildContext context,
  required Prompt prompt,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withAlpha(235),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, _, _) => PromptPreviewModal(prompt: prompt),
    transitionBuilder: (_, Animation<double> animation, _, Widget child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

class PromptPreviewModal extends StatelessWidget {
  const PromptPreviewModal({super.key, required this.prompt});

  final Prompt prompt;

  Future<void> _copyPrompt() async {
    await Clipboard.setData(ClipboardData(text: prompt.prompt));
    showSuccessToast(LocaleKey.promptCopied.tr);
  }

  Future<void> _sharePrompt() async {
    final shareText = prompt.shareUrl ?? 'prompthub://prompt/${prompt.id}';
    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final panelMaxWidth = constraints.maxWidth >= 560
                ? 430.0
                : double.infinity;
            final panelHeight = constraints.maxHeight > 36
                ? constraints.maxHeight - 36
                : constraints.maxHeight;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: panelMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                  child: SizedBox(
                    height: panelHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.promptInk,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.color484848),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              flex: 58,
                              child: _PreviewImage(prompt: prompt),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              flex: 32,
                              child: _PromptTextCard(prompt: prompt.prompt),
                            ),
                            const SizedBox(height: 14),
                            _PreviewActions(
                              onCopy: _copyPrompt,
                              onShare: _sharePrompt,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PreviewImage extends StatefulWidget {
  const _PreviewImage({required this.prompt});

  final Prompt prompt;

  @override
  State<_PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<_PreviewImage> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.prompt.isSaved;
  }

  Future<void> _toggleSave() async {
    final userId = await Get.find<AuthRepository>().ensureAnonymousSession();
    final promptRepository = Get.find<PromptRepository>();
    if (_isSaved) {
      await promptRepository.unsavePrompt(
        userId: userId,
        promptId: widget.prompt.id,
      );
    } else {
      await promptRepository.savePrompt(
        userId: userId,
        promptId: widget.prompt.id,
      );
    }
    if (!mounted) return;
    setState(() => _isSaved = !_isSaved);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Get.find<AuthRepository>().currentUserId;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PromptImageView(url: widget.prompt.imageUrl, radius: 0),
          Positioned(
            right: 0,
            top: 0,
            child: Row(
              children: <Widget>[
                if (widget.prompt.isOwnedBy(currentUserId)) ...<Widget>[
                  _PreviewOwnerMenu(prompt: widget.prompt),
                  // const SizedBox(width: 8),
                ],
                _CircleOverlayButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.pop(context, false),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: _SmallBadge(
              label: widget.prompt.authorUsername ?? 'user',
              icon: Icons.person_rounded,
              maxWidth: 150,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: _CircleOverlayButton(
              icon: _isSaved
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: _isSaved ? AppColors.error : AppColors.white,
              onTap: _toggleSave,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewOwnerMenu extends StatelessWidget {
  const _PreviewOwnerMenu({required this.prompt});

  final Prompt prompt;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.promptInk,
      elevation: 10,
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.color484848),
      ),
      icon: const _CircleOverlayButton(icon: Icons.more_horiz_rounded),
      onSelected: (String value) async {
        if (value == 'edit') {
          final changed = await Get.toNamed(
            AppPages.editPrompt,
            arguments: <String, dynamic>{'id': prompt.id},
          );
          if (changed == true) {
            Get.find<HomeBloc>().refresh();
            if (context.mounted) Navigator.pop(context, true);
          }
          return;
        }
        if (value == 'delete') {
          await Get.find<PromptRepository>().deletePrompt(prompt);
          if (context.mounted) Navigator.pop(context, true);
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: _PreviewMenuRow(
            icon: Icons.edit_outlined,
            iconColor: AppColors.discoveryPurple,
            label: LocaleKey.editPromptTitle.tr,
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: _PreviewMenuRow(
            icon: Icons.delete_outline_rounded,
            iconColor: AppColors.error,
            label: LocaleKey.deletePrompt.tr,
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'cancel',
          child: Center(
            child: Text(
              LocaleKey.cancel.tr,
              style: AppStyles.bodySmall(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewMenuRow extends StatelessWidget {
  const _PreviewMenuRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppStyles.bodySmall(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PromptTextCard extends StatefulWidget {
  const _PromptTextCard({required this.prompt});

  final String prompt;

  @override
  State<_PromptTextCard> createState() => _PromptTextCardState();
}

class _PromptTextCardState extends State<_PromptTextCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: AppColors.color484848),
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                widget.prompt,
                style: AppStyles.bodySmall(
                  color: AppColors.white,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewActions extends StatelessWidget {
  const _PreviewActions({required this.onCopy, required this.onShare});

  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _PreviewActionButton(
            label: LocaleKey.copy.tr,
            icon: Icons.copy_rounded,
            onTap: onCopy,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PreviewActionButton(
            label: LocaleKey.share.tr,
            icon: Icons.share_rounded,
            onTap: onShare,
          ),
        ),
      ],
    );
  }
}

class _PreviewActionButton extends StatelessWidget {
  const _PreviewActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isPrimary ? AppColors.black : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.white : AppColors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isPrimary ? AppColors.white : AppColors.color484848,
          ),
        ),
        child: SizedBox(
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: foregroundColor, size: 17),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.bodySmall(
                    color: foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleOverlayButton extends StatelessWidget {
  const _CircleOverlayButton({
    required this.icon,
    this.iconColor = AppColors.white,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.black.withAlpha(112),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withAlpha(40)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withAlpha(80),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label, this.icon, this.maxWidth});

  final String label;
  final IconData? icon;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.black.withAlpha(120),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.white.withAlpha(40)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, color: AppColors.white, size: 12),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.caption(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

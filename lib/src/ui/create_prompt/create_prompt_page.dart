import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/create_prompt/bloc/create_prompt_bloc.dart';
import 'package:shareprompt/src/ui/create_prompt/components/create_prompt_category_selector.dart';
import 'package:shareprompt/src/ui/create_prompt/components/create_prompt_header.dart';
import 'package:shareprompt/src/ui/create_prompt/components/create_prompt_image_picker.dart';
import 'package:shareprompt/src/ui/create_prompt/components/create_prompt_prompt_input.dart';
import 'package:shareprompt/src/ui/home/bloc/home_bloc.dart';
import 'package:shareprompt/src/ui/home/components/prompt_preview_modal.dart';
import 'package:shareprompt/src/ui/widgets/base/toast/app_toast.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class CreatePromptPage extends StatefulWidget {
  const CreatePromptPage({super.key});

  @override
  State<CreatePromptPage> createState() => _CreatePromptPageState();
}

class _CreatePromptPageState extends State<CreatePromptPage> {
  late final CreatePromptBloc _bloc;
  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = CreatePromptBloc(
      Get.find<PromptRepository>(),
      Get.find<AuthRepository>(),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreatePromptBloc>.value(
      value: _bloc,
      child: BlocConsumer<CreatePromptBloc, CreatePromptState>(
        buildWhen: (CreatePromptState previous, CreatePromptState current) {
          return previous.imageBytes != current.imageBytes ||
              previous.imageFileName != current.imageFileName ||
              previous.selectedCategories != current.selectedCategories;
        },
        listener: (BuildContext context, CreatePromptState state) {
          if (state.errorMessage != null) {
            showErrorToast(state.errorMessage);
          }
          final createdPrompt = state.createdPrompt;
          if (createdPrompt != null) {
            _bloc.resetAfterSuccess();
            _openCreatedPrompt(createdPrompt);
          }
        },
        builder: (BuildContext context, CreatePromptState state) {
          return Scaffold(
            backgroundColor: AppColors.discoveryBackgroundDeep,
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.createPromptBackgroundGradient(),
              ),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    BlocSelector<CreatePromptBloc, CreatePromptState, bool>(
                      selector: (CreatePromptState state) => state.isSubmitting,
                      builder: (BuildContext context, bool isSubmitting) {
                        return CreatePromptHeader(
                          isSubmitting: isSubmitting,
                          onClose: () => Navigator.pop(context),
                          onPublish: isSubmitting ? null : _bloc.submit,
                        );
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _CreatePromptSectionLabel(LocaleKey.imageLabel.tr),
                            const SizedBox(height: 14),
                            CreatePromptImagePicker(
                              bytes: state.imageBytes == null
                                  ? null
                                  : Uint8List.fromList(state.imageBytes!),
                              onAddImage: _bloc.pickImage,
                              onRemoveImage: _bloc.removeImage,
                            ),
                            const SizedBox(height: 20),
                            _CreatePromptSectionLabel(LocaleKey.promptLabel.tr),
                            const SizedBox(height: 14),
                            CreatePromptInput(
                              controller: _promptController,
                              onChanged: _bloc.promptChanged,
                            ),
                            const SizedBox(height: 26),
                            CreatePromptCategorySelector(
                              selectedCategories: state.selectedCategories,
                              onCategoryToggled: _bloc.categoryToggled,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openCreatedPrompt(Prompt createdPrompt) {
    if (Get.isRegistered<HomeBloc>()) {
      Get.find<HomeBloc>().refresh();
    }
    Get.back();
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 180)).then((_) {
        final context = Get.overlayContext ?? Get.context;
        if (context == null) return;
        // ignore: use_build_context_synchronously
        showPromptPreviewModal(context: context, prompt: createdPrompt);
      }),
    );
  }
}

class _CreatePromptSectionLabel extends StatelessWidget {
  const _CreatePromptSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppStyles.bodyLarge(
        color: AppColors.white,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
  }
}

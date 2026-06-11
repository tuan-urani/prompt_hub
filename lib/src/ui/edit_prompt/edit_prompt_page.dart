import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/base/interactor/page_states.dart';
import 'package:shareprompt/src/ui/create_prompt/components/create_prompt_category_selector.dart';
import 'package:shareprompt/src/ui/create_prompt/components/create_prompt_header.dart';
import 'package:shareprompt/src/ui/create_prompt/components/create_prompt_image_picker.dart';
import 'package:shareprompt/src/ui/create_prompt/components/create_prompt_prompt_input.dart';
import 'package:shareprompt/src/ui/edit_prompt/bloc/edit_prompt_bloc.dart';
import 'package:shareprompt/src/ui/widgets/base/toast/app_toast.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_styles.dart';

class EditPromptPage extends StatefulWidget {
  const EditPromptPage({super.key});

  @override
  State<EditPromptPage> createState() => _EditPromptPageState();
}

class _EditPromptPageState extends State<EditPromptPage> {
  late final EditPromptBloc _bloc;
  late final String _promptId;
  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _promptId = args?['id'] as String? ?? '';
    _bloc = EditPromptBloc(Get.find<PromptRepository>())..loadPrompt(_promptId);
  }

  @override
  void dispose() {
    _bloc.close();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditPromptBloc>.value(
      value: _bloc,
      child: BlocConsumer<EditPromptBloc, EditPromptState>(
        buildWhen: (EditPromptState previous, EditPromptState current) {
          return previous.status != current.status ||
              previous.originalPrompt != current.originalPrompt ||
              previous.imageBytes != current.imageBytes ||
              previous.imageFileName != current.imageFileName ||
              previous.selectedCategories != current.selectedCategories;
        },
        listener: (BuildContext context, EditPromptState state) {
          if (state.errorMessage != null) {
            showErrorToast(state.errorMessage);
          }
          if (state.savedPrompt != null || state.deleted) {
            Navigator.pop(context, true);
          }
        },
        builder: (BuildContext context, EditPromptState state) {
          if (state.status == PageState.loading) {
            return const Scaffold(
              backgroundColor: AppColors.discoveryBackgroundDeep,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryLight),
              ),
            );
          }
          final prompt = state.originalPrompt;
          if (state.status == PageState.failure || prompt == null) {
            return Scaffold(
              backgroundColor: AppColors.discoveryBackgroundDeep,
              body: Center(
                child: Text(
                  state.errorMessage ?? LocaleKey.loadError.tr,
                  style: AppStyles.bodyMedium(color: AppColors.white),
                ),
              ),
            );
          }
          _syncControllers(state);
          return Scaffold(
            backgroundColor: AppColors.discoveryBackgroundDeep,
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.createPromptBackgroundGradient(),
              ),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    BlocSelector<EditPromptBloc, EditPromptState, bool>(
                      selector: (EditPromptState state) => state.isSubmitting,
                      builder: (BuildContext context, bool isSubmitting) {
                        return CreatePromptHeader(
                          title: LocaleKey.editPromptTitle.tr,
                          actionLabel: LocaleKey.save.tr,
                          isSubmitting: isSubmitting,
                          onClose: () => Navigator.pop(context),
                          onPublish: isSubmitting ? null : _bloc.save,
                        );
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _EditPromptSectionLabel(LocaleKey.imageLabel.tr),
                            const SizedBox(height: 18),
                            CreatePromptImagePicker(
                              bytes: state.imageBytes == null
                                  ? null
                                  : Uint8List.fromList(state.imageBytes!),
                              imageUrl: state.imageBytes == null
                                  ? prompt.imageUrl
                                  : null,
                              onAddImage: _bloc.pickImage,
                              onRemoveImage: _bloc.removeImage,
                            ),
                            const SizedBox(height: 28),
                            _EditPromptSectionLabel(LocaleKey.promptLabel.tr),
                            const SizedBox(height: 18),
                            CreatePromptInput(
                              controller: _promptController,
                              onChanged: _bloc.promptChanged,
                            ),
                            const SizedBox(height: 32),
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

  void _syncControllers(EditPromptState state) {
    if (_promptController.text != state.prompt) {
      _promptController.text = state.prompt;
      _promptController.selection = TextSelection.collapsed(
        offset: _promptController.text.length,
      );
    }
  }
}

class _EditPromptSectionLabel extends StatelessWidget {
  const _EditPromptSectionLabel(this.label);

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

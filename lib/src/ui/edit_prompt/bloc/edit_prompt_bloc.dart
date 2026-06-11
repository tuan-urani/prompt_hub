import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/base/interactor/page_states.dart';

class EditPromptState extends Equatable {
  const EditPromptState({
    this.status = PageState.initial,
    this.originalPrompt,
    this.imageBytes,
    this.imageFileName,
    this.title = '',
    this.platform = '',
    this.prompt = '',
    this.selectedCategories = const <PromptCategory>[],
    this.isSubmitting = false,
    this.savedPrompt,
    this.deleted = false,
    this.errorMessage,
  });

  final PageState status;
  final Prompt? originalPrompt;
  final List<int>? imageBytes;
  final String? imageFileName;
  final String title;
  final String platform;
  final String prompt;
  final List<PromptCategory> selectedCategories;
  final bool isSubmitting;
  final Prompt? savedPrompt;
  final bool deleted;
  final String? errorMessage;

  bool get isValid =>
      title.trim().isNotEmpty &&
      platform.trim().isNotEmpty &&
      prompt.trim().isNotEmpty;

  EditPromptState copyWith({
    PageState? status,
    Prompt? originalPrompt,
    List<int>? imageBytes,
    String? imageFileName,
    String? title,
    String? platform,
    String? prompt,
    List<PromptCategory>? selectedCategories,
    bool? isSubmitting,
    Prompt? savedPrompt,
    bool? deleted,
    String? errorMessage,
    bool clearNewImage = false,
    bool clearSavedPrompt = false,
    bool clearError = false,
  }) {
    return EditPromptState(
      status: status ?? this.status,
      originalPrompt: originalPrompt ?? this.originalPrompt,
      imageBytes: clearNewImage ? null : imageBytes ?? this.imageBytes,
      imageFileName: clearNewImage ? null : imageFileName ?? this.imageFileName,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      prompt: prompt ?? this.prompt,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      savedPrompt: clearSavedPrompt ? null : savedPrompt ?? this.savedPrompt,
      deleted: deleted ?? this.deleted,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    originalPrompt,
    imageBytes,
    imageFileName,
    title,
    platform,
    prompt,
    selectedCategories,
    isSubmitting,
    savedPrompt,
    deleted,
    errorMessage,
  ];
}

class EditPromptBloc extends Cubit<EditPromptState> {
  EditPromptBloc(this._promptRepository) : super(const EditPromptState());

  final PromptRepository _promptRepository;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> loadPrompt(String promptId) async {
    emit(state.copyWith(status: PageState.loading, clearError: true));
    try {
      final prompt = await _promptRepository.fetchPrompt(promptId);
      if (prompt == null) {
        emit(
          state.copyWith(
            status: PageState.failure,
            errorMessage: LocaleKey.promptNotFound.tr,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: PageState.success,
          originalPrompt: prompt,
          title: prompt.title,
          platform: prompt.platform,
          prompt: prompt.prompt,
          selectedCategories: prompt.category == PromptCategory.all
              ? const <PromptCategory>[]
              : <PromptCategory>[prompt.category],
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PageState.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    emit(
      state.copyWith(
        imageBytes: bytes,
        imageFileName: image.name,
        clearError: true,
      ),
    );
  }

  void titleChanged(String value) =>
      emit(state.copyWith(title: value, clearError: true));

  void platformChanged(String value) =>
      emit(state.copyWith(platform: value, clearError: true));

  void promptChanged(String value) =>
      emit(state.copyWith(prompt: value, clearError: true));

  void removeImage() => emit(state.copyWith(clearNewImage: true));

  void categoryToggled(PromptCategory category) {
    if (category == PromptCategory.all) {
      emit(
        state.copyWith(
          selectedCategories: const <PromptCategory>[],
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedCategories: <PromptCategory>[category],
        clearError: true,
      ),
    );
  }

  Future<void> save() async {
    final originalPrompt = state.originalPrompt;
    if (originalPrompt == null || !state.isValid) {
      emit(state.copyWith(errorMessage: LocaleKey.formRequiredMessage.tr));
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSavedPrompt: true,
      ),
    );
    try {
      final savedPrompt = await _promptRepository.updatePrompt(
        prompt: originalPrompt,
        title: state.title,
        platform: state.platform,
        body: state.prompt,
        category: state.selectedCategories.firstOrNull ?? PromptCategory.all,
        imageBytes: state.imageBytes,
        imageFileName: state.imageFileName,
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          originalPrompt: savedPrompt,
          savedPrompt: savedPrompt,
          clearError: true,
          clearNewImage: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
    }
  }

  Future<void> deletePrompt() async {
    final originalPrompt = state.originalPrompt;
    if (originalPrompt == null) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _promptRepository.deletePrompt(originalPrompt);
      emit(state.copyWith(isSubmitting: false, deleted: true));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
    }
  }
}

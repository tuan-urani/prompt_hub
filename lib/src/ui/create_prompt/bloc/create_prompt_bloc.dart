import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/locale/locale_key.dart';

class CreatePromptState extends Equatable {
  const CreatePromptState({
    this.imageBytes,
    this.imageFileName,
    this.prompt = '',
    this.selectedCategories = const <PromptCategory>[],
    this.isSubmitting = false,
    this.createdPrompt,
    this.errorMessage,
  });

  final List<int>? imageBytes;
  final String? imageFileName;
  final String prompt;
  final List<PromptCategory> selectedCategories;
  final bool isSubmitting;
  final Prompt? createdPrompt;
  final String? errorMessage;

  bool get isValid => imageBytes != null && prompt.trim().isNotEmpty;

  CreatePromptState copyWith({
    List<int>? imageBytes,
    String? imageFileName,
    String? prompt,
    List<PromptCategory>? selectedCategories,
    bool? isSubmitting,
    Prompt? createdPrompt,
    String? errorMessage,
    bool clearImage = false,
    bool clearCreatedPrompt = false,
    bool clearError = false,
  }) {
    return CreatePromptState(
      imageBytes: clearImage ? null : imageBytes ?? this.imageBytes,
      imageFileName: clearImage ? null : imageFileName ?? this.imageFileName,
      prompt: prompt ?? this.prompt,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdPrompt: clearCreatedPrompt
          ? null
          : createdPrompt ?? this.createdPrompt,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    imageBytes,
    imageFileName,
    prompt,
    selectedCategories,
    isSubmitting,
    createdPrompt,
    errorMessage,
  ];
}

class CreatePromptBloc extends Cubit<CreatePromptState> {
  CreatePromptBloc(this._promptRepository, this._authRepository)
    : super(const CreatePromptState());

  final PromptRepository _promptRepository;
  final AuthRepository _authRepository;
  final ImagePicker _imagePicker = ImagePicker();

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

  void removeImage() => emit(state.copyWith(clearImage: true));

  void promptChanged(String value) =>
      emit(state.copyWith(prompt: value, clearError: true));

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

    final selectedCategories = List<PromptCategory>.of(
      state.selectedCategories,
    );
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    emit(
      state.copyWith(
        selectedCategories: List<PromptCategory>.unmodifiable(
          selectedCategories,
        ),
        clearError: true,
      ),
    );
  }

  Future<void> submit() async {
    if (!state.isValid || state.imageBytes == null) {
      emit(
        state.copyWith(errorMessage: LocaleKey.createPromptRequiredMessage.tr),
      );
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearCreatedPrompt: true,
      ),
    );
    try {
      final userId = await _authRepository.ensureAnonymousSession();
      final prompt = await _promptRepository.createPrompt(
        userId: userId,
        draft: PromptDraft(
          title: _deriveTitle(state.prompt),
          platform: _categoryLabel(state.selectedCategories),
          category: state.selectedCategories.firstOrNull ?? PromptCategory.all,
          prompt: state.prompt,
          imageBytes: state.imageBytes!,
          imageFileName: state.imageFileName ?? 'prompt.png',
        ),
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          createdPrompt: prompt,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
    }
  }

  void resetAfterSuccess() => emit(const CreatePromptState());

  String _categoryLabel(List<PromptCategory> categories) {
    if (categories.isEmpty) return PromptCategory.all.label;
    return categories
        .map((PromptCategory category) => category.label)
        .join(', ');
  }

  String _deriveTitle(String prompt) {
    final normalized = prompt.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= 64) return normalized;
    return normalized.substring(0, 64);
  }
}

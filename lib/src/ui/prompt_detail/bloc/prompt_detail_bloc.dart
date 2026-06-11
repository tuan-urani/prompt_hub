import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/base/interactor/page_states.dart';

class PromptDetailState extends Equatable {
  const PromptDetailState({
    this.status = PageState.initial,
    this.prompt,
    this.isOwner = false,
    this.errorMessage,
  });

  final PageState status;
  final Prompt? prompt;
  final bool isOwner;
  final String? errorMessage;

  PromptDetailState copyWith({
    PageState? status,
    Prompt? prompt,
    bool? isOwner,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PromptDetailState(
      status: status ?? this.status,
      prompt: prompt ?? this.prompt,
      isOwner: isOwner ?? this.isOwner,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, prompt, isOwner, errorMessage];
}

class PromptDetailBloc extends Cubit<PromptDetailState> {
  PromptDetailBloc(this._promptRepository, this._authRepository)
    : super(const PromptDetailState());

  final PromptRepository _promptRepository;
  final AuthRepository _authRepository;

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
          prompt: prompt,
          isOwner: prompt.isOwnedBy(_authRepository.currentUserId),
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

  Future<void> copyPrompt() async {
    final prompt = state.prompt;
    if (prompt == null) return;
    await Clipboard.setData(ClipboardData(text: prompt.prompt));
  }

  Future<void> sharePrompt() async {
    final prompt = state.prompt;
    if (prompt == null) return;
    final shareText = prompt.shareUrl ?? 'prompthub://prompt/${prompt.id}';
    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  Future<void> toggleSave() async {
    final prompt = state.prompt;
    if (prompt == null) return;
    final userId = await _authRepository.ensureAnonymousSession();
    if (prompt.isSaved) {
      await _promptRepository.unsavePrompt(userId: userId, promptId: prompt.id);
    } else {
      await _promptRepository.savePrompt(userId: userId, promptId: prompt.id);
    }
    emit(
      state.copyWith(
        prompt: prompt.copyWith(isSaved: !prompt.isSaved),
        clearError: true,
      ),
    );
  }

  Future<void> deletePrompt() async {
    final prompt = state.prompt;
    if (prompt == null) return;
    await _promptRepository.deletePrompt(prompt);
  }
}

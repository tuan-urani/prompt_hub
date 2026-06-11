import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shareprompt/src/core/model/app_user_profile.dart';
import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/repository/auth_repository.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/ui/base/interactor/page_states.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.status = PageState.initial,
    this.prompts = const <Prompt>[],
    this.savedPrompts = const <Prompt>[],
    this.profile,
    this.userId,
    this.errorMessage,
  });

  final PageState status;
  final List<Prompt> prompts;
  final List<Prompt> savedPrompts;
  final AppUserProfile? profile;
  final String? userId;
  final String? errorMessage;

  ProfileState copyWith({
    PageState? status,
    List<Prompt>? prompts,
    List<Prompt>? savedPrompts,
    AppUserProfile? profile,
    String? userId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      prompts: prompts ?? this.prompts,
      savedPrompts: savedPrompts ?? this.savedPrompts,
      profile: profile ?? this.profile,
      userId: userId ?? this.userId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    prompts,
    savedPrompts,
    profile,
    userId,
    errorMessage,
  ];
}

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc(this._promptRepository, this._authRepository)
    : super(const ProfileState());

  final PromptRepository _promptRepository;
  final AuthRepository _authRepository;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: PageState.loading, clearError: true));
    try {
      final profile = await _authRepository.ensureCurrentUserProfile();
      final userId = profile.id;
      final prompts = await _promptRepository.fetchUserPrompts(userId);
      final savedPrompts = await _promptRepository.fetchSavedPrompts(userId);
      emit(
        state.copyWith(
          status: PageState.success,
          userId: userId,
          prompts: prompts,
          savedPrompts: savedPrompts,
          profile: profile,
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

  Future<void> deletePrompt(Prompt prompt) async {
    await _promptRepository.deletePrompt(prompt);
    await loadProfile();
  }

  Future<void> updateUsername(String username) async {
    final profile = await _authRepository.updateUsername(username);
    emit(state.copyWith(profile: profile, userId: profile.id));
  }
}

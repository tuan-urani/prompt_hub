import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shareprompt/src/core/model/prompt.dart';
import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/ui/base/interactor/page_states.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = PageState.initial,
    this.prompts = const <Prompt>[],
    this.searchQuery = '',
    this.selectedCategory = PromptCategory.all,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final PageState status;
  final List<Prompt> prompts;
  final String searchQuery;
  final PromptCategory selectedCategory;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  HomeState copyWith({
    PageState? status,
    List<Prompt>? prompts,
    String? searchQuery,
    PromptCategory? selectedCategory,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      prompts: prompts ?? this.prompts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    prompts,
    searchQuery,
    selectedCategory,
    hasMore,
    isLoadingMore,
    errorMessage,
  ];
}

class HomeBloc extends Cubit<HomeState> {
  HomeBloc(this._promptRepository) : super(const HomeState());

  static const int _pageSize = 12;

  final PromptRepository _promptRepository;
  int _page = 0;

  Future<void> loadInitial() async {
    emit(state.copyWith(status: PageState.loading, clearError: true));
    _page = 0;
    try {
      final prompts = await _promptRepository.fetchPrompts(
        page: _page,
        pageSize: _pageSize,
        query: state.searchQuery,
        category: state.selectedCategory,
      );
      emit(
        state.copyWith(
          status: PageState.success,
          prompts: prompts,
          hasMore: prompts.length == _pageSize,
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

  Future<void> refresh() => loadInitial();

  Future<void> search(String query) async {
    emit(state.copyWith(searchQuery: query));
    await loadInitial();
  }

  Future<void> selectCategory(PromptCategory category) async {
    emit(state.copyWith(selectedCategory: category));
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status == PageState.loading) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final nextPage = _page + 1;
      final prompts = await _promptRepository.fetchPrompts(
        page: nextPage,
        pageSize: _pageSize,
        query: state.searchQuery,
        category: state.selectedCategory,
      );
      _page = nextPage;
      emit(
        state.copyWith(
          prompts: <Prompt>[...state.prompts, ...prompts],
          hasMore: prompts.length == _pageSize,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(isLoadingMore: false, errorMessage: error.toString()),
      );
    }
  }
}

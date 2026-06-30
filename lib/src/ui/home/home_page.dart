import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:shareprompt/src/core/model/prompt_category.dart';
import 'package:shareprompt/src/locale/locale_key.dart';
import 'package:shareprompt/src/ui/base/interactor/page_states.dart';
import 'package:shareprompt/src/ui/home/bloc/home_bloc.dart';
import 'package:shareprompt/src/ui/home/components/discover_header.dart';
import 'package:shareprompt/src/ui/home/components/discovery_background.dart';
import 'package:shareprompt/src/ui/home/components/discovery_floating_button.dart';
import 'package:shareprompt/src/ui/home/components/discovery_message_state.dart';
import 'package:shareprompt/src/ui/home/components/discovery_prompt_grid_card.dart';
import 'package:shareprompt/src/utils/app_colors.dart';
import 'package:shareprompt/src/utils/app_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = Get.find<HomeBloc>();
    if (_bloc.state.status == PageState.initial) {
      _bloc.loadInitial();
    }
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 420) {
      _bloc.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.discoveryBackground,
        floatingActionButton: const DiscoveryFloatingButton(),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: AppColors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppColors.discoveryBackground,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: DiscoveryBackground(
            child: SafeArea(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (BuildContext context, HomeState state) {
                  return Column(
                    children: <Widget>[
                      DiscoverHeader(
                        selectedCategory: state.selectedCategory,
                        onCategorySelected: (PromptCategory category) =>
                            _bloc.selectCategory(category),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.discoveryPurple,
                          backgroundColor: AppColors.discoveryChipFill,
                          onRefresh: _bloc.refresh,
                          child: CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: <Widget>[
                              if (state.status == PageState.loading)
                                const _DiscoveryPromptGridSkeleton()
                              else if (state.status == PageState.failure)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: DiscoveryMessageState(
                                    title: LocaleKey.loadError.tr,
                                    message: state.errorMessage ?? '',
                                    actionLabel: LocaleKey.retry.tr,
                                    onAction: _bloc.loadInitial,
                                  ),
                                )
                              else if (state.prompts.isEmpty)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: DiscoveryMessageState(
                                    title: LocaleKey.discoverEmptyTitle.tr,
                                    message: LocaleKey.discoverEmptyMessage.tr,
                                    actionLabel: LocaleKey.publish.tr,
                                    onAction: () =>
                                        Get.toNamed(AppPages.createPrompt),
                                  ),
                                )
                              else
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    14,
                                    24,
                                    116,
                                  ),
                                  sliver: SliverGrid.builder(
                                    itemCount: state.prompts.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 6,
                                          crossAxisSpacing: 6,
                                          childAspectRatio: 0.87,
                                        ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          return DiscoveryPromptGridCard(
                                            prompt: state.prompts[index],
                                          );
                                        },
                                  ),
                                ),
                              if (state.isLoadingMore)
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 24),
                                ),
                            ],
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
      ),
    );
  }
}

class _DiscoveryPromptGridSkeleton extends StatelessWidget {
  const _DiscoveryPromptGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 116),
      sliver: SliverGrid.builder(
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 0.87,
        ),
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.discoveryCardBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Skeletonizer(
                enabled: true,
                effect: ShimmerEffect(
                  baseColor: AppColors.discoveryChipFill,
                  highlightColor: AppColors.discoveryPurple.withValues(
                    alpha: 0.18,
                  ),
                ),
                child: Bone.square(
                  size: double.infinity,
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

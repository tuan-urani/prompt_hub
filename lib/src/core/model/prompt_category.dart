enum PromptCategory {
  all('all'),
  anime('anime'),
  fashion('fashion'),
  conceptArt('concept_art'),
  portrait('portrait'),
  renders3d('3d_renders');

  const PromptCategory(this.value);

  final String value;

  String get label {
    return switch (this) {
      PromptCategory.all => 'All',
      PromptCategory.anime => 'Anime',
      PromptCategory.fashion => 'Fashion',
      PromptCategory.conceptArt => 'Concept art',
      PromptCategory.portrait => 'Portrait',
      PromptCategory.renders3d => '3D/ Renders',
    };
  }

  static List<PromptCategory> get selectable => <PromptCategory>[
    all,
    anime,
    fashion,
    conceptArt,
    portrait,
    renders3d,
  ];

  static PromptCategory fromValue(String? value) {
    return PromptCategory.values.firstWhere(
      (PromptCategory category) => category.value == value,
      orElse: () => PromptCategory.all,
    );
  }
}

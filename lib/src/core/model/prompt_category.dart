enum PromptCategory {
  all('all'),
  people('people'),
  animals('animals'),
  fashion('fashion'),
  sports('sports');

  const PromptCategory(this.value);

  final String value;

  String get label {
    return switch (this) {
      PromptCategory.all => 'All',
      PromptCategory.people => 'People',
      PromptCategory.animals => 'Animals',
      PromptCategory.fashion => 'Fashion',
      PromptCategory.sports => 'Sports',
    };
  }

  static List<PromptCategory> get selectable => <PromptCategory>[
    all,
    people,
    animals,
    fashion,
    sports,
  ];

  static PromptCategory fromValue(String? value) {
    return PromptCategory.values.firstWhere(
      (PromptCategory category) => category.value == value,
      orElse: () => PromptCategory.all,
    );
  }
}

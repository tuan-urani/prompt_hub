enum PlatformType {
  openAI('OpenAI'),
  gemini('Gemini'),
  midjourney('Midjourney'),
  flux('Flux'),
  stableDiffusion('Stable Diffusion');

  const PlatformType(this.label);

  final String label;

  static List<String> get labels =>
      values.map((PlatformType type) => type.label).toList(growable: false);
}

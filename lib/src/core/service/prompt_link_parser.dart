class PromptLinkParser {
  const PromptLinkParser._();

  static const String promptDetailValue = 'prompt_detail';
  static const String deepLinkValueKey = 'deep_link_value';
  static const String deepLinkPromptIdKey = 'deep_link_sub1';
  static const String promptIdKey = 'prompt_id';
  static const String shareChannel = 'share';
  static const String shareCampaign = 'prompt_share';

  static String createFallbackUrl(String promptId) {
    return 'prompthub://prompt/$promptId';
  }

  static String? parseUri(Uri uri) {
    if (uri.scheme == 'prompthub' && uri.host == 'prompt') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.first;
      }
    }

    if (uri.scheme == 'prompthub' &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'prompt') {
      return uri.pathSegments[1];
    }

    return parseParameters(uri.queryParameters);
  }

  static String? parseParameters(Map<String, Object?> parameters) {
    final deepLinkValue = parameters[deepLinkValueKey]?.toString();
    final promptId =
        parameters[deepLinkPromptIdKey]?.toString() ??
        parameters[promptIdKey]?.toString() ??
        parameters['af_sub1']?.toString();

    if (promptId == null || promptId.isEmpty) return null;
    if (deepLinkValue == null || deepLinkValue == promptDetailValue) {
      return promptId;
    }

    return null;
  }
}

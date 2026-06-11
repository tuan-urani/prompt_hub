class AppsFlyerConfig {
  const AppsFlyerConfig({
    this.devKey = '',
    this.iosAppId = '',
    this.oneLinkDomain = '',
    this.oneLinkTemplateId = '',
    this.fallbackUrl = '',
    this.isDebug = false,
  });

  factory AppsFlyerConfig.fromEnv(Map<String, String?> env) {
    return AppsFlyerConfig(
      devKey: env['APPSFLYER_DEV_KEY']?.trim() ?? '',
      iosAppId:
          env['APPSFLYER_IOS_APP_ID']?.trim() ??
          env['APPSFLYER_APP_ID']?.trim() ??
          '',
      oneLinkDomain: env['APPSFLYER_ONELINK_DOMAIN']?.trim() ?? '',
      oneLinkTemplateId: env['APPSFLYER_ONELINK_TEMPLATE_ID']?.trim() ?? '',
      fallbackUrl: env['APPSFLYER_FALLBACK_URL']?.trim() ?? '',
      isDebug: env['APPSFLYER_DEBUG'] == 'true',
    );
  }

  final String devKey;
  final String iosAppId;
  final String oneLinkDomain;
  final String oneLinkTemplateId;
  final String fallbackUrl;
  final bool isDebug;

  bool get hasOneLinkConfig =>
      oneLinkDomain.isNotEmpty && oneLinkTemplateId.isNotEmpty;
}

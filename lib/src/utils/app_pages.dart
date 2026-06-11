import 'package:get/get.dart';

import 'package:shareprompt/src/ui/home/binding/home_binding.dart';
import 'package:shareprompt/src/ui/create_prompt/create_prompt_page.dart';
import 'package:shareprompt/src/ui/edit_prompt/edit_prompt_page.dart';
import 'package:shareprompt/src/ui/home/home_page.dart';
import 'package:shareprompt/src/ui/main/main_page.dart';
import 'package:shareprompt/src/ui/prompt_detail/prompt_detail_page.dart';
import 'package:shareprompt/src/ui/profile/profile_page.dart';
import 'package:shareprompt/src/ui/settings/settings_page.dart';
import 'package:shareprompt/src/ui/splash/splash_page.dart';

class AppPages {
  AppPages._();

  static const String splash = '/splash';
  static const String main = '/';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String createPrompt = '/create-prompt';
  static const String promptDetail = '/prompt-detail';
  static const String editPrompt = '/edit-prompt';

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: main, page: () => const MainPage(), binding: HomeBinding()),
    GetPage(name: home, page: () => const HomePage(), binding: HomeBinding()),
    GetPage(name: profile, page: () => const ProfilePage()),
    GetPage(name: settings, page: () => const SettingsPage()),
    GetPage(name: createPrompt, page: () => const CreatePromptPage()),
    GetPage(name: promptDetail, page: () => const PromptDetailPage()),
    GetPage(name: editPrompt, page: () => const EditPromptPage()),
  ];
}

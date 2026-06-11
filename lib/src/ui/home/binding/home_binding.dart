import 'package:get/get.dart';

import 'package:shareprompt/src/core/repository/prompt_repository.dart';
import 'package:shareprompt/src/ui/home/bloc/home_bloc.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeBloc>()) {
      Get.lazyPut<HomeBloc>(() => HomeBloc(Get.find<PromptRepository>()));
    }
  }
}

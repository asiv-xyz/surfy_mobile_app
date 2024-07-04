import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/user/onboarding.dart';
import 'package:surfy_mobile_app/ui/login/login_view.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class LoginViewModel {
  late LoginView _view;

  final Onboarding _onboardingUseCase = Get.find();

  void setView(LoginView view) {
    _view = view;
  }

  Future<void> processLogin(LoginParams params, Function onSuccess) async {
    try {
      _view.startLoading();
      final loginResponse = await Web3AuthFlutter.login(params);
      var sso = "";
      switch (params.loginProvider) {
        case Provider.google:
          sso = "google";
          break;
        case Provider.twitter:
          sso = "twitter";
          break;
        case Provider.farcaster:
          sso = "farcaster";
          break;
        case Provider.discord:
          sso = "discord";
          break;
        default:
          throw Exception("Unsupported login provider: ${params.loginProvider}");
      }

      await _onboardingUseCase.run(loginResponse.userInfo?.name ?? "", sso);
      onSuccess.call();
    } catch (e) {
      _view.onError("$e");
    } finally {
      _view.finishLoading();
    }
  }
}
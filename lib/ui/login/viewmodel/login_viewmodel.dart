import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:surfy_mobile_app/ui/login/login_view.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginViewModel {
  late LoginView _view;

  void setView(LoginView view) {
    _view = view;
  }

  Future<void> processLogin(LoginParams params, Function onSuccess) async {
    try {
      _view.startLoading();
      final loginResponse = await Web3AuthFlutter.login(params);
      final bytes = utf8.encode(loginResponse.userInfo?.idToken ?? "");
      print('oAuthIdToken: ${loginResponse.userInfo?.oAuthIdToken}');
      print('oAuthAccessToken: ${loginResponse.userInfo?.oAuthAccessToken}');
      final hash = sha1.convert(bytes);
      print('user id hash: ${hash.toString()}');
      onSuccess.call();
    } catch (e) {
      _view.onError("$e");
    } finally {
      _view.finishLoading();
    }
  }
}
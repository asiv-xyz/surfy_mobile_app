import 'package:get/get.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/user/user_service.dart';

class Onboarding {
  final KeyService _keyService = Get.find();
  final UserService _userService = Get.find();

  Future<void> run(String userName, String sso) async {
    final userHash = await _keyService.getKeyHash();
    try {
      final user = await _userService.getUserById(userHash);
    } on NoUserException catch (e) {
      await _userService.postUser(userHash, userName, sso);
    } catch (e) {
      print('login error: $e');
      rethrow;
    }
  }
}
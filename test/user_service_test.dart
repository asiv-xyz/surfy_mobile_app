import 'package:flutter_test/flutter_test.dart';
import 'package:surfy_mobile_app/service/user/user_service.dart';

void main() {
  test('test service', () async {
    final service = UserService();
    // final result = await service.getUserById('test_id2');
    await service.postUser('test_id_2', 'boo', 'farcaster');
  });
}
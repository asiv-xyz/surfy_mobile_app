import 'package:dio/dio.dart';
import 'package:surfy_mobile_app/entity/user/user.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';

class UserService {
  Future<User> getUserById(String id) async {
    print('getUserById: $id');
    final result = await dioObject.get('https://wgs0z4xv93.execute-api.ap-northeast-2.amazonaws.com/Prod/user/$id',
      options: Options(responseType: ResponseType.json),);

    print('getUserById: ${result.data}');
    if (result.data.length == 0) {
      print('UserService : result is null');
      throw NoUserException();
    }

    return result.data.map<User>((item) => User.fromJson(item)).toList().first;
  }

  Future<void> postUser(String id, String name, String sso) async {
    final result = await dioObject.post('https://wgs0z4xv93.execute-api.ap-northeast-2.amazonaws.com/Prod/user',
      data: {
        'id': id,
        'userName': name,
        'sso': sso,
        'createdAt': DateTime.now().toIso8601String(),
      },
      options: Options(responseType: ResponseType.json)
    );
  }
}

class NoUserException extends Error {

}
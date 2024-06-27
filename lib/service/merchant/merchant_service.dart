import 'package:dio/dio.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';

class MerchantService {
  Future<List<Merchant>> getPlaceList() async {
    final result = await dioObject.get('https://slq250cw87.execute-api.ap-northeast-2.amazonaws.com/Prod/merchants',
      options: Options(responseType: ResponseType.json),);
    final typedResult = result.data?.map<Merchant>((item) => Merchant.fromJson(item)).toList();
    return typedResult;
  }

  Future<Merchant?> getPlace(String id) async {
    final result = await dioObject.get('https://slq250cw87.execute-api.ap-northeast-2.amazonaws.com/Prod/merchant/id/$id',
      options: Options(responseType: ResponseType.json),);
    return Merchant.fromJson(result.data);
  }
}
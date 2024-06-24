import 'package:dio/dio.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';

class MerchantService {
  Future<List<Merchant>> getPlaceList() async {
    final result = await dioObject.get('https://slq250cw87.execute-api.ap-northeast-2.amazonaws.com/Prod/merchants',
      options: Options(responseType: ResponseType.json),);
    final typedResult = result.data?.map<Merchant>((item) => Merchant(
        id: item['id'] ?? "",
        storeName: item['storeName'] ?? "",
        owner: item['owner'] ?? "",
        latitude: item['latitude'] ?? "",
        longitude: item['longitude'] ?? "",
        thumbnail: item['thumbnail'] ?? "",
        address: item['address'] ?? "",
        phone: item['phone'] ?? "",
        email: item['email'] ?? "",
        category: item['category'] ?? "",
        nation: item['nation'] ?? "",
        sns: item['sns']?.map<MerchantSns>((s) => MerchantSns(type: s['type'] ?? "", url: s['url'] ?? "")).toList() ?? [])
    ).toList();
    return typedResult;
  }

  Future<Merchant?> getPlace(String id) async {
    final result = await dioObject.get('https://slq250cw87.execute-api.ap-northeast-2.amazonaws.com/Prod/merchant/id/$id',
      options: Options(responseType: ResponseType.json),);
    return Merchant.fromJson(result.data);
  }
}
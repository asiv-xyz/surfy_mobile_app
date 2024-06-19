import 'package:dio/dio.dart';
import 'package:surfy_mobile_app/entity/place/place.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';

class PlaceService {
  Future<List<Place>> getPlaceList() async {
    print('getPlaceList');
    final result = await dioObject.get('https://slq250cw87.execute-api.ap-northeast-2.amazonaws.com/Prod/merchants',
      options: Options(responseType: ResponseType.json),);
    print('result: ${result.data}');
    final typedResult = result.data?.map<Place>((item) => Place(
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

    print('typedResult: $typedResult');
    return typedResult;
  }
}
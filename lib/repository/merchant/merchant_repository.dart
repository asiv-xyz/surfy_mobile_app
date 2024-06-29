import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/merchant/merchant_service.dart';

// TODO : need to apply cache, but improve backend also.
class MerchantRepository {
  MerchantRepository({required this.service});

  final MerchantService service;
  List<Merchant> _placeList = [];

  Future<List<Merchant>> getPlaceList() async {
    if (_placeList.isEmpty) {
      logger.i('getPlaceList(): need to call server');
      _placeList = await service.getPlaceList();
    }

    return _placeList;
  }
}
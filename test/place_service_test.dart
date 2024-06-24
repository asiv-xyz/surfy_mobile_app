import 'package:flutter_test/flutter_test.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/service/merchant/merchant_service.dart';

void main() {
  // test('place service test', () async {
  //   final service = PlaceService();
  //   print(await service.getPlaceList());
  // });
  //
  // test('place repository test', () async {
  //   final repository = PlaceRepository(service: PlaceService());
  //   print(await repository.getPlaceList());
  // });

  test('domain test', () async {
    final domain = GetMerchants(placeService: MerchantService());
    print(await domain.getSingle('testStore'));
  });
}
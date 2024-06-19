import 'package:flutter_test/flutter_test.dart';
import 'package:surfy_mobile_app/repository/place/place_repository.dart';
import 'package:surfy_mobile_app/service/place/place_service.dart';

void main() {
  test('place service test', () async {
    final service = PlaceService();
    print(await service.getPlaceList());
  });

  test('place repository test', () async {
    final repository = PlaceRepository(service: PlaceService());
    print(await repository.getPlaceList());
  });
}
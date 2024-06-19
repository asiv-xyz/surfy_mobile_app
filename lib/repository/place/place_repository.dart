import 'package:surfy_mobile_app/entity/place/place.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/place/place_service.dart';

class PlaceRepository {
  PlaceRepository({required this.service});

  final PlaceService service;
  List<Place> _placeList = [];

  Future<List<Place>> getPlaceList() async {
    if (_placeList.isEmpty) {
      logger.i('getPlaceList(): need to call server');
      _placeList = await service.getPlaceList();
    }

    return _placeList;
  }
}
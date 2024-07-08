import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/ui/map/map_view.dart';

class MapViewModel {
  final MerchantRepository _merchantRepository = Get.find();

  final Rx<List<Merchant>> observableMerchantList = Rx([]);
  late MapView view;
  final RxBool observableIsAnnotationClicked = false.obs;
  final Rx<String?> observableSelectedAnnotationId = Rx(null);
  final Rx<Map<String, Merchant>> observableAnnotationMap = Rx({});

  final RxDouble observableCurrentMapLongitude = 0.0.obs;
  final RxDouble observableCurrentMapLatitude = 0.0.obs;
  final RxDouble observableCurrentZoom = 0.0.obs;


  Future<void> init() async {
    view.onLoading();

    final merchants = await _merchantRepository.getPlaceList();
    observableMerchantList.value = merchants;

    view.offLoading();
  }

  void setView(MapView view) {
    this.view = view;
  }

  Pair<double, double> getSelectedPlaceLngLat() {
    final merchant = observableAnnotationMap.value[observableSelectedAnnotationId.value];
    if (merchant == null) {
      throw Exception('No selected merchant');
    }

    return Pair(merchant.longitude, merchant.latitude);
  }

  dynamic toMapboxFeatureType() {
    return {
      "\"type\"": "\"geojson\"",
      "\"cluster\"": true,
      "\"clusterMaxZoom\"": 14,
      "\"clusterRadius\"": 50,
      "\"data\"": {
        "\"type\"": "\"FeatureCollection\"",
        "\"features\"": observableMerchantList.value.map((merchant) => {
          "\"type\"": "\"Feature\"",
          "\"properties\"": {
            "\"id\"": "\"${merchant.id}\"",
            "\"category\"": "\"${merchant.category}\"",
            "\"description\"": "\"test_description\""
          },
          "\"geometry\"": {
            "\"type\"": "\"Point\"",
            "\"coordinates\"": [merchant.longitude, merchant.latitude]
          }
        }).toList()
      }
    }.toString();
  }
}
import 'package:get/get.dart';
import 'package:surfy_mobile_app/entity/place/place.dart';

class ClickPlace {
  final isClicked = false.obs;
  String? selectedPlaceAnnotationId;
  final Map<String, Place> annotationMap = {};
}
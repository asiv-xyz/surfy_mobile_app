import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:surfy_mobile_app/domain/merchant/click_place.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/map/viewmodel/map_viewmodel.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MapPageState();
  }
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  AnnotationClickListener({
    required this.annotationMap,
    required this.clickPlaceUseCase,
    required this.moveCameraFunction,
    required this.viewModel,
  });

  final Map<String, Merchant> annotationMap;
  final ClickPlace clickPlaceUseCase;
  final Function moveCameraFunction;
  final MapViewModel viewModel;

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print('click annotation: ${annotation.id}');
    if (annotationMap[annotation.id] == null) {
      return;
    }
    // if (clickPlaceUseCase.isClicked.isTrue) {
    //   clickPlaceUseCase.isClicked.value = false;
    // } else {
    //   clickPlaceUseCase.isClicked.value = true;
    //   clickPlaceUseCase.selectedPlaceAnnotationId = annotation.id;
    //   moveCameraFunction.call();
    // }
    if (viewModel.observableIsAnnotationClicked.isTrue) {
      viewModel.observableIsAnnotationClicked.value = false;
    } else {
      viewModel.observableIsAnnotationClicked.value = true;
      viewModel.observableSelectedAnnotationId.value = annotation.id;
      moveCameraFunction.call();
    }
  }
}

abstract class MapView {
  void onLoading();
  void offLoading();
}

class _MapPageState extends State<MapPage> implements MapView {
  final ClickPlace _clickPlaceUseCase = Get.find();
  MapboxMap? mapboxMap;

  final _userLatitude = 0.0.obs;
  final _userLongitude = 0.0.obs;

  final RxBool _isLoading = false.obs;

  final MapViewModel _viewModel = MapViewModel();

  @override
  void onLoading() {
    _isLoading.value = true;
  }

  @override
  void offLoading() {
    _isLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    _viewModel.init();
  }

  Future<geolocator.Position> _determinePosition() async {
    bool serviceEnabled;
    geolocator.LocationPermission permission;

    serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == geolocator.LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await geolocator.Geolocator.getCurrentPosition();
  }

  Future<void> _setCurrentUserPosition(MapboxMap mapboxMap) async {
    final position = await geolocator.Geolocator.getCurrentPosition();
    mapboxMap.easeTo(mapbox.CameraOptions(
        center: Point(
            coordinates: Position(position.longitude, position.latitude)),
        zoom: 12.0), MapAnimationOptions(duration: 1000, startDelay: 0));
  }

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    _determinePosition().then((position) {
      _userLatitude.value = position.latitude;
      _userLongitude.value = position.longitude;
      mapboxMap.setCamera(mapbox.CameraOptions(
          center: Point(
              coordinates: Position(position.longitude, position.latitude)),
          zoom: 12.0));
    });
    mapboxMap.location.updateSettings(LocationComponentSettings(
        enabled: true,
        puckBearingEnabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
    ));
    mapboxMap.annotations.createPointAnnotationManager().then((manager) async {
      print('createPointAnnotationManager');
      for (final place in _viewModel.observableMerchantList.value) {
        var image = "";
        switch (place.category.toLowerCase()) {
          case "cafe":
            image = "assets/images/ic_cafe.png";
            break;
          case "restaurant":
            image = "assets/images/ic_restaurant.png";
            break;
          case "bar":
            image = "assets/images/ic_bar.png";
            break;
          default:
            break;
        }
        final ByteData bytes = await rootBundle.load(image);
        final Uint8List list = bytes.buffer.asUint8List();

        final options = <PointAnnotationOptions>[];
        final option = PointAnnotationOptions(
            geometry: Point(coordinates: Position(place.longitude, place.latitude)), image: list);
        options.add(option);
        final annotation = await manager.create(option);
        _viewModel.observableAnnotationMap.value[annotation.id] = place;
        manager.createMulti(options);
      }
      manager.addOnPointAnnotationClickListener(
          AnnotationClickListener(
            annotationMap: _viewModel.observableAnnotationMap.value,
            clickPlaceUseCase: _clickPlaceUseCase,
            viewModel: _viewModel,
            moveCameraFunction: () async {
              final cameraState = await mapboxMap.getCameraState();
              _viewModel.observableCurrentMapLongitude.value = cameraState.center.coordinates.lng.toDouble();
              _viewModel.observableCurrentMapLatitude.value = cameraState.center.coordinates.lat.toDouble();
              _viewModel.observableCurrentZoom.value = cameraState.zoom;

              final lnglat = _viewModel.getSelectedPlaceLngLat();
              mapboxMap.easeTo(mapbox.CameraOptions(
                center: Point(
                  coordinates: Position(lnglat.first, lnglat.second)
                ),
                zoom: 15.0), MapAnimationOptions(duration: 1000, startDelay: 0));
            }
          )
      );
    });
    mapboxMap.setOnMapTapListener((context) {
      if (_viewModel.observableIsAnnotationClicked.isTrue) {
        _viewModel.observableIsAnnotationClicked.value = false;
        mapboxMap.easeTo(mapbox.CameraOptions(
            center: Point(
                coordinates: Position(
                    _viewModel.observableCurrentMapLongitude.value,
                    _viewModel.observableCurrentMapLatitude.value
                )
            ),
            zoom: _viewModel.observableCurrentZoom.value), MapAnimationOptions(duration: 1000, startDelay: 0));
      }
    });
  }

  String _calculateDistance(double userLongitude, double userLatitude, double placeLongitude, double placeLatitude) {
    final distance = geolocator.Geolocator.distanceBetween(userLatitude, userLongitude, placeLatitude, placeLongitude);
    if (distance > 1000) {
      return "${(distance / 1000).toStringAsFixed(1)}km";
    } else {
      return "${distance}m";
    }
  }

  Widget _buildPlaceInfo() {
    final place = _viewModel.observableAnnotationMap.value[_viewModel.observableSelectedAnnotationId.value];
    return Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: SurfyColor.black,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 150,
                height: 150,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(place?.thumbnail ?? "", width: 150, height: 150, fit: BoxFit.fill,)
                )
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place?.storeName ?? "", style: GoogleFonts.sora(color: SurfyColor.blue, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 5,),
                    Text(place?.address ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 14)),
                    const SizedBox(height: 10,),
                    Text(place?.phone ?? "", style: GoogleFonts.sora(color: SurfyColor.blue, fontSize: 14)),
                    const SizedBox(height: 5,),
                    Row(
                      children: [
                        const Icon(Icons.location_on_sharp, color: SurfyColor.blue, size: 16,),
                        const SizedBox(width: 5),
                        Text(_calculateDistance(_userLongitude.value, _userLatitude.value, place?.longitude ?? 0.0, place?.latitude ?? 0.0), style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 14),)
                      ],
                    )
                  ],
                )
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: const Text('Find SURFY Store!')),
        body: Obx(() {
          if (_isLoading.isTrue) {
            return const LoadingWidget(opacity: 0.4);
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              mapbox.MapWidget(
                onMapCreated: _onMapCreated,
              ),
              Obx(() {
                return Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () async {
                              if (mapboxMap != null) {
                                await _setCurrentUserPosition(mapboxMap!);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(SurfyColor.black),
                            ),
                            icon: const Icon(Icons.my_location_rounded, color: SurfyColor.blue,)),
                        _viewModel.observableIsAnnotationClicked.isFalse ? const SizedBox(height: 20,) : Container(),
                        _viewModel.observableIsAnnotationClicked.isTrue ? _buildPlaceInfo() : Container()
                      ],
                    )
                );
              }),
            ],
          );
        })
    );
  }

  Widget buildAccessTokenWarning() {
    return const Center(
      child: Text('Access token is not valid.'),
    );
  }
}

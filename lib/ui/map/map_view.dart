import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MapPageState();
  }
}

class _MapPageState extends State<MapPage> {

  // static const String ACCESS_TOKEN = String.fromEnvironment("ACCESS_TOKEN");
  static const String ACCESS_TOKEN = "pk.eyJ1IjoiYm9vc2lrIiwiYSI6ImNsdm9xZmc4OTByOHoycm9jOWE5eHl6bnQifQ.Di5Upe8BfD8olr5r6wldNw";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget()
    );
  }

  Widget buildAccessTokenWarning() {
    return Center(
      child: Text('Access token is not valid.'),
    );
  }

}
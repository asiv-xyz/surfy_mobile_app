import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<StatefulWidget> createState() {
    return _QRPageState();
  }

}

class _QRPageState extends State<QRPage> {

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(_controller),
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      )
    );
  }

}
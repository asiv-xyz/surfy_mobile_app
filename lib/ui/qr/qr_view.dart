import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:surfy_mobile_app/domain/qr/get_qr_controller.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/router/router_service.dart';
import 'package:surfy_mobile_app/ui/navigation_controller.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:vibration/vibration.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<StatefulWidget> createState() {
    return _QRPageState();
  }
}

class _QRPageState extends State<QRPage> implements INavigationLifeCycle {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? _result;
  final GetQRController _getQRController = Get.find();

  final RxString _scannedUrl = "".obs;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState, $state}');
    switch (state) {
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _getQRController.qrViewController.value = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _result = scanData;
        if (_result?.code.isNotNullOrEmpty == true && _result?.code != _scannedUrl.value) {
          _scannedUrl.value = _result?.code ?? "";
          Vibration.vibrate(duration: 100);
          ScaffoldMessenger.of(context).showSnackBar(
            _buildSnackBar(_result?.code ?? ""),
          );
        }
      });
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _getQRController.qrViewController.value?.pauseCamera();
    } else if (Platform.isIOS) {
      _getQRController.qrViewController.value?.resumeCamera();
    }
  }

  @override
  void dispose() {
    _getQRController.qrViewController.value?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final NavigationController navController = Get.find();
    navController.addListener(1, this);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    logger.i('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  SnackBar _buildSnackBar(String qrUrl) {
    return SnackBar(
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      backgroundColor: SurfyColor.white,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      content: Material(
        color: SurfyColor.white,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            final RouterService routerService = Get.find();
            routerService.checkLoginAndGoByUrl(qrUrl);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tap to pay!", style: GoogleFonts.sora(fontWeight: FontWeight.bold, color: SurfyColor.black, fontSize: 16),),
              Text(qrUrl, style: GoogleFonts.sora(color: SurfyColor.black, fontSize: 12))
            ],
          )
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          )
      )
    );
  }

  @override
  void onPageEnd() {
    print('onQRPageEnd!');
    _getQRController.qrViewController.value?.pauseCamera();
    _result = null;
    _scannedUrl.value = "";
  }

  @override
  void onPageStart() {
    print('onQRPageStart!');
    _getQRController.qrViewController.value?.resumeCamera();
  }

}
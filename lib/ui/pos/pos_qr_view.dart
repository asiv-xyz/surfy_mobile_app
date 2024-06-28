import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/service/qr/qr_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class PosQrPageProps {
  const PosQrPageProps({
    required this.storeId,
    required this.receivedCurrencyType,
    required this.wantToReceiveAmount
  });

  final String storeId;
  final CurrencyType receivedCurrencyType;
  final double wantToReceiveAmount;
}

class PosQrPage extends StatefulWidget {
  const PosQrPage({
    super.key,
    required this.storeId,
    required this.receivedCurrencyType,
    required this.wantToReceiveAmount,
  });

  final String storeId;
  final CurrencyType receivedCurrencyType;
  final double wantToReceiveAmount;

  @override
  State<StatefulWidget> createState() {
    return _PosQrPageState();
  }
}

class _PosQrPageState extends State<PosQrPage> {
  final QRService _qrService = Get.find();
  final RxString _qrUrl = "".obs;

  @override
  void initState() {
    super.initState();
    _qrService.getQRcode("https://store.surfy.network/pos/payment/${widget.storeId}/${widget.wantToReceiveAmount}/${widget.receivedCurrencyType.name}").then((url) {
      _qrUrl.value = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('POS'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: SurfyColor.white,
                borderRadius: BorderRadius.circular(15)
              ),
              child: Center(
                child: Column(
                  children: [
                    Obx(() {
                      if (_qrUrl.isNotEmpty) {
                        return Image.network(_qrUrl.value, fit: BoxFit.fill, loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: SurfyColor.blue,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },);
                      } else {
                        return const CircularProgressIndicator(color: SurfyColor.blue,);
                      }
                    }),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: SurfyColor.darkGrey
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pay', style: GoogleFonts.sora(fontSize: 16, color: SurfyColor.white),),
                          Text('${widget.wantToReceiveAmount} ${widget.receivedCurrencyType.name.toUpperCase()}', style: GoogleFonts.sora(fontSize: 24, color: SurfyColor.blue))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}
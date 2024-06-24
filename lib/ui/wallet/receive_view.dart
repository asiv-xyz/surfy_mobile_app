import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/service/qr/qr_service.dart';
import 'package:surfy_mobile_app/ui/components/badge.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key, required this.token, required this.blockchain});

  final Token token;
  final Blockchain blockchain;

  @override
  State<StatefulWidget> createState() {
    return _ReceivePageState();
  }

}

class _ReceivePageState extends State<ReceivePage> {
  late Rx<Token> _selectedToken;
  late Rx<Blockchain> _selectedBlockchain;
  
  final QRService _qrService = Get.find();
  final _qrUrl = "".obs;
  final _amount = 0.obs;
  final _userAddress = "0x0".obs;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedToken = Rx(widget.token);
    _selectedBlockchain = Rx(widget.blockchain);
    
    _qrService.getQRcode("https://store.surfy.network/send/${_selectedBlockchain.value.name}/${_selectedToken.value.name}/${_userAddress.value}/${_amount.value}").then((r) {
      _qrUrl.value = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: SurfyColor.white),
        titleSpacing: 0,
        title: Text('Receive', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold)),
        backgroundColor: SurfyColor.black,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: SurfyColor.black,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: SurfyColor.white,
          ),
          child: Obx(() {
            if (_qrUrl.value.isNullOrEmpty) {
              return const Center(
                  child: CircularProgressIndicator(color: SurfyColor.blue)
              );
            } else {
              return Column(
                children: [
                  Image.network(_qrUrl.value, loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Center(
                      child: CircularProgressIndicator(
                        color: SurfyColor.blue,
                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                      ),
                    );
                  },),
                  const SizedBox(height: 10,),
                  TextField(
                    cursorColor: SurfyColor.black,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      label: Text('Amount to receive', style: GoogleFonts.sora(color: SurfyColor.black)),
                      focusColor: SurfyColor.blue,
                      hoverColor: SurfyColor.blue,
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SurfyColor.blue), borderRadius: BorderRadius.all(Radius.circular(10)))
                    ),
                    style: GoogleFonts.sora(color: SurfyColor.black,),
                    controller: _textController
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Token", style: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.bold),),
                      TokenBadge(token: _selectedToken.value),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Network", style: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.bold),),
                      NetworkBadge(blockchain: _selectedBlockchain.value)
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    width: double.infinity,
                    height: 60,
                    child: Material(
                      color: SurfyColor.blue,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: () {
                          _qrUrl.value = "";
                          _qrService.getQRcode("https://store.surfy.network/send/${_selectedBlockchain.value.name}/${_selectedToken.value.name}/${_userAddress.value}/${_amount.value}").then((r) {
                            _qrUrl.value = r;
                          });
                        },
                        child: Center(
                          child: Text("Create QR code", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                        )
                      )
                    )
                  )
                ],
              );
            }
          }),
        )
      )
    );
  }
}
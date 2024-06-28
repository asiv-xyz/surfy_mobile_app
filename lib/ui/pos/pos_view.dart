import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/ui/navigation_controller.dart';
import 'package:surfy_mobile_app/ui/pos/pos_qr_view.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:go_router/go_router.dart';

class PosPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PosPageState();
  }

}

class _PosPageState extends State<PosPage> implements INavigationLifeCycle {

  final RxString _inputAmount = "0".obs;
  final SettingsPreference _preference = Get.find();
  final IsMerchant _isMerchantUseCase = Get.find();
  final RxBool _isMerchant = false.obs;
  final RxBool _isLoading = true.obs;
  final Rx<Merchant?> _merchantData = Rx(null);

  @override
  void initState() {
    _isLoading.value = true;
    _isMerchantUseCase.isMerchant().then((r) async {
      _isMerchant.value = r;
      final merchant = await _isMerchantUseCase.getMyMerchantData();
      _merchantData.value = merchant;
      print('merchant: $merchant');
      _isLoading.value = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        if (_isLoading.isTrue) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: CircularProgressIndicator(color: SurfyColor.blue)
            )
          );
        }

        if (_isMerchant.isFalse) {
          return Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: SurfyColor.deepRed, size: 80,),
                      const SizedBox(height: 20,),
                      Text('You are not a merchant!', style: GoogleFonts.sora(color: SurfyColor.deepRed, fontWeight: FontWeight.bold, fontSize: 18),),
                      Text('If you are a merchant, please register.', style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 14),),
                    ],
                  )
              )
          );
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          child: KeyboardView(
            buttonText: 'Create QR code',
            inputAmount: _inputAmount,
            onClickSend: () {
              if (mounted) {
                context.push('/pos/qr', extra: PosQrPageProps(
                    storeId: _merchantData.value?.id ?? "",
                    receivedCurrencyType: _preference.userCurrencyType.value,
                    wantToReceiveAmount: _inputAmount.value.toDouble()));
              }
            },
            isFiatInputMode: false,
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello ${_merchantData.value?.storeName}!', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 5,),
                    Text('Enter you want to receive', style: Theme.of(context).textTheme.bodySmall),
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(_inputAmount.value, style: GoogleFonts.sora(color: SurfyColor.blue, fontSize: 36),),
                        const SizedBox(width: 10),
                        Text(_preference.userCurrencyType.value.name.toUpperCase(), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 36),)
                      ],
                    ),),
                  ],
                )
            ),
          ),
        );
      })
    );
  }

  @override
  void onPageEnd() {
    print('onPageEnd');
  }

  @override
  void onPageStart() {
    print('onPageStart');
  }
}
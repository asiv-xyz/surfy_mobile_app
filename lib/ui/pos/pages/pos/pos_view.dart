import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/pos/pages/pos/viewmodel/pos_viewmodel.dart';
import 'package:surfy_mobile_app/ui/pos/pages/qr/pos_qr_view.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:go_router/go_router.dart';

class PosPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PosPageState();
  }
}

abstract class PosView {
  void onLoading();
  void offLoading();
}

class _PosPageState extends State<PosPage> implements PosView {
  final PosViewModel _viewModel = PosViewModel();

  final RxString _inputAmount = "0".obs;
  final SettingsPreference _preference = Get.find();
  final IsMerchant _isMerchantUseCase = Get.find();
  final RxBool _isMerchant = false.obs;
  final RxBool _isLoading = true.obs;
  final Rx<Merchant?> _merchantData = Rx(null);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        if (_isLoading.isTrue) {
          return const LoadingWidget(opacity: 0.4);
        }

        if (_viewModel.observableIsMerchant.isFalse) {
          return Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: SurfyColor.deepRed, size: 80,),
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
            enable: true,
            buttonText: 'Create QR code',
            inputAmount: _inputAmount,
            onClickSend: () {
              if (mounted) {
                checkAuthAndPush(context, '/pos/qr', extra: PosQrPageProps(
                    storeId: _viewModel.observableMerchant.value?.id ?? "",
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
                    Text('Hello ${_viewModel.observableMerchant.value?.storeName}!', style: Theme.of(context).textTheme.bodyLarge),
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
}
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/pos/pages/pos/viewmodel/pos_viewmodel.dart';
import 'package:surfy_mobile_app/ui/pos/pages/qr/pos_qr_view.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

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
  final RxBool _isLoading = true.obs;

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
                    const SizedBox(height: 5,),
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
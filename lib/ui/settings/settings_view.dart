import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:surfy_mobile_app/cache/wallet/wallet_cache.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/error_codes.dart' as auth_error;


class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final SettingsPreference _preference = Get.find();
  final EventBus _bus = Get.find();
  final LocalAuthentication auth = LocalAuthentication();
  final _processLogout = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 60,
                      child: PopupMenuButton<CurrencyType>(
                          onSelected: (currencyType) async {
                            await _preference.changeCurrencyType(currencyType);
                            await _bus.emit(ChangeCurrecnyTypeEvent());
                          },
                          itemBuilder: (context) => CurrencyType.values.map((currencyType) => PopupMenuItem(
                              value: currencyType,
                              child: Text(currencyType.name))
                          ).toList(),
                          child: Obx(() => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              color: SurfyColor.black,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Change currency type: ${_preference.userCurrencyType.value.name}', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold)),
                                  Icon(Icons.navigate_next_outlined, color: SurfyColor.white,)
                                ],
                              )
                          ))
                      )
                    ),
                    // Container(
                    //     width: double.infinity,
                    //     height: 60,
                    //     child: PopupMenuButton<ThemeMode>(
                    //         onSelected: (theme) async {
                    //           await _preference.setTheme(theme);
                    //         },
                    //         itemBuilder: (context) => ThemeMode.values.map((themeType) => PopupMenuItem(
                    //             value: themeType,
                    //             child: Text(themeType.name))
                    //         ).toList(),
                    //         child: Obx(() => Container(
                    //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    //             color: SurfyColor.black,
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //               children: [
                    //                 Text('Theme: ${_preference.themeObs.value.name}', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold)),
                    //                 Icon(Icons.navigate_next_outlined, color: SurfyColor.white,)
                    //               ],
                    //             )
                    //         ))
                    //     )
                    // ),
                    Container(
                        width: double.infinity,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        color: SurfyColor.black,
                        child: InkWell(
                            onTap: () {
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Show testnet', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                                Obx(() => Checkbox(
                                    value: _preference.isShowTestnet.value,
                                    onChanged: (value) async {
                                      await _preference.setIsShowTestnet(value ?? false);
                                    }
                                ))
                              ],
                            )
                        )
                    ),
                    Container(
                        width: double.infinity,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        color: SurfyColor.black,
                        child: InkWell(
                            onTap: () async {
                              final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
                              final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
                              if (canAuthenticate) {
                                final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
                                if (availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.face) || availableBiometrics.contains(BiometricType.fingerprint)) {
                                  try {
                                    final bool didAuthenticate = await auth.authenticate(
                                        localizedReason: 'Please authenticate to show account balance',
                                        options: const AuthenticationOptions(useErrorDialogs: false));
                                    if (didAuthenticate) {
                                      // show key
                                      checkAuthAndPush(context, '/key');
                                    }

                                  } on PlatformException catch (e) {
                                    print("error: $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("$e", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                                        backgroundColor: Colors.black,
                                      ),
                                    );
                                    if (e.code == auth_error.notAvailable) {
                                      // Add handling of no hardware here.
                                    } else if (e.code == auth_error.notEnrolled) {
                                      // ...
                                    } else {
                                      // ...
                                    }
                                  }
                                }
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Export private key', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                                Icon(Icons.navigate_next_outlined, color: SurfyColor.white,)
                              ],
                            )
                        )
                    ),
                    Container(
                        width: double.infinity,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        color: SurfyColor.black,
                        child: InkWell(
                            onTap: () {
                              _processLogout.value = true;
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Logout', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                                const Icon(Icons.navigate_next_outlined, color: SurfyColor.white,)
                              ],
                            )
                        )
                    )
                  ],
                )
            ),
          ),
          Obx(() {
            if (_processLogout.isTrue) {
              return Center(
                child: Container(
                  width: double.infinity,
                  height: 135,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: SurfyColor.white,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Do you want to logout?', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: SurfyColor.black),),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: MaterialButton(
                                onPressed: () async {
                                  await Web3AuthFlutter.logout();
                                  logger.i("Logout success! Move to login page.");
                                  WalletCache cache = Get.find();
                                  await cache.clearCache();
                                  context.go('/login');
                                },
                                color: SurfyColor.blue,
                                child: Center(
                                    child: Text('OK', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold))
                                )
                            )
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: MaterialButton(
                                onPressed: () {
                                  _processLogout.value = false;
                                },
                                color: SurfyColor.lightGrey,
                                child: Center(
                                    child: Text('Cancel', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold))
                                )
                            )
                          )
                        ],
                      )
                    ],
                  ),
                )
              );
            } else {
              return Container();
            }
          })
        ],
      )
    );
  }
}
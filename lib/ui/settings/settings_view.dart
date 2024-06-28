import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final SettingsPreference _preference = Get.find();
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
            child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                        child: PopupMenuButton<CurrencyType>(
                            onSelected: (currencyType) async {
                              await _preference.changeCurrencyType(currencyType);
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
                    Container(
                        child: PopupMenuButton<ThemeMode>(
                            onSelected: (theme) async {
                              await _preference.setTheme(theme);
                            },
                            itemBuilder: (context) => ThemeMode.values.map((themeType) => PopupMenuItem(
                                value: themeType,
                                child: Text(themeType.name))
                            ).toList(),
                            child: Obx(() => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                color: SurfyColor.black,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Theme: ${_preference.themeObs.value.name}', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold)),
                                    Icon(Icons.navigate_next_outlined, color: SurfyColor.white,)
                                  ],
                                )
                            ))
                        )
                    ),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        color: SurfyColor.black,
                        child: InkWell(
                            onTap: () {
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
                      Text('Do you want to logout?', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold),),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: MaterialButton(
                                onPressed: () async {
                                  await Web3AuthFlutter.logout();
                                  logger.i("Logout success! Move to login page.");
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
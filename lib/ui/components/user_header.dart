import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class UserHeader extends StatelessWidget {
  UserHeader({super.key, required this.profileImageUrl, required this.profileName});

  final String profileImageUrl;
  final String profileName;
  final KeyService keyService = Get.find();

  @override
  Widget build(BuildContext context) {
    if (profileImageUrl == "" || profileName == "") {
      return Container();
    }

    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(profileImageUrl, width: 48, height: 48,)
                  )
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${profileName}', style: GoogleFonts.sora(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white)),
                    Text('Welcome to SURFY!', style: GoogleFonts.sora(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white))
                  ],
                )
              ],
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                child: IconButton(
                    onPressed: () {
                      context.push('/settings');
                    },
                    icon: Icon(Icons.settings_outlined, color: Colors.white, size: 24))
              ),
              SizedBox(width: 20),
              Container(
                width: 24,
                height: 24,
                child: IconButton(
                    onPressed: () async {
                      final GetWalletBalances getWalletBalancesUseCase = Get.find();
                      final key = await keyService.getKey();
                      getWalletBalancesUseCase.loadNewTokenDataList(
                          Token.values, key.first, key.second);
                    },
                    icon: Icon(Icons.refresh_outlined, color: Colors.white, size: 24)
                )
              )
            ],
          )
        ],
      )
    );
  }
  
}
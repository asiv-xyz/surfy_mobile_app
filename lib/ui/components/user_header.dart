import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class UserHeader extends StatelessWidget {
  UserHeader({super.key, required this.profileImageUrl, required this.profileName, required this.onRefresh});

  final String profileImageUrl;
  final String profileName;
  final Function onRefresh;
  final KeyService keyService = Get.find();

  @override
  Widget build(BuildContext context) {
    if (profileImageUrl == "" || profileName == "") {
      return Container();
    }

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(profileImageUrl, width: 48, height: 48,)
                )
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $profileName', style: Theme.of(context).textTheme.titleLarge),
                  Text('Welcome to SURFY!', style: Theme.of(context).textTheme.titleLarge)
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    checkAuthAndPush(context, '/settings');
                  },
                  icon: const Icon(Icons.settings_outlined, size: 25)
              ),
              // const SizedBox(width: 20),
              IconButton(
                  onPressed: () async {
                    onRefresh.call();
                  },
                  icon: const Icon(Icons.refresh_outlined, size: 25)
              )
            ],
          )
        ],
      )
    );
  }
  
}
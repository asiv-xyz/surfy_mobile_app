import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/enums.dart' as web3_auth_enum;
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                ),
                Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: 0,
                    child: const Image(
                        image: AssetImage('assets/images/splash_bg.png'),
                        width: double.infinity)),
                Positioned(
                    top: 0,
                    left: 28,
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Image(
                            image: AssetImage('assets/images/surfy_logo.png')),
                        SizedBox(height: 10),
                        Text('Nice to see you!',
                            style: GoogleFonts.sora(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold))
                      ],
                    )),
                Positioned(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Login',
                              style: GoogleFonts.sora(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20,),
                          MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                final Web3AuthResponse response =
                                await Web3AuthFlutter.login(
                                  LoginParams(
                                      loginProvider: Provider.twitter,
                                      curve: web3_auth_enum.Curve.ed25519),
                                );
                                if (response.error != null) {
                                  logger.e('error! ${response.error}');
                                } else {
                                  if (mounted) {
                                    context.go('/wallet');
                                  }
                                }
                              },
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Image(
                                              image: AssetImage(
                                                  'assets/images/ic_x.png'),
                                              width: 20,
                                              height: 20),
                                          const SizedBox(width: 10),
                                          Text('Sign In with X',
                                              style: GoogleFonts.sora(
                                                  textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold)))
                                        ],
                                      )))),
                          const SizedBox(height: 20,),
                          MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                final Web3AuthResponse response = await Web3AuthFlutter.login(LoginParams(
                                    loginProvider: Provider.farcaster
                                ));
                                if (response.error != null) {
                                  logger.e('error! ${response.error}');
                                } else {
                                  if (mounted) {
                                    context.go('/wallet');
                                  }
                                }
                              },
                              child: Container(
                                  width: double.infinity,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: const Color(0xFF855DCD),
                                  ),
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Image(
                                              image: AssetImage(
                                                  'assets/images/ic_farcaster.png'),
                                              width: 20,
                                              height: 20),
                                          const SizedBox(width: 10),
                                          Text('Sign In with Farcaster',
                                              style: GoogleFonts.sora(
                                                  textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold)))
                                        ],
                                      ))))
                        ],
                      )
                    ))
              ],
            )));
  }
}

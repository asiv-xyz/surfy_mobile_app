import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/login/viewmodel/login_viewmodel.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

abstract class LoginView {
  void startLoading();
  void finishLoading();
  void onError(String error);
}

class _LoginPageState extends State<LoginPage> implements LoginView {
  final LoginViewModel _viewModel = LoginViewModel();
  final _isLoading = false.obs;

  @override
  void startLoading() {
    _isLoading.value = true;
  }

  @override
  void finishLoading() {
    _isLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
  }

  @override
  void onError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
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
                        const SizedBox(height: 10),
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
                                _viewModel.processLogin(LoginParams(
                                  loginProvider: Provider.google,
                                ), () {
                                  if (mounted) {
                                    context.go('/wallet');
                                  }
                                });
                              },
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Image(
                                              image: AssetImage(
                                                  'assets/images/ic_google.png'),
                                              width: 20,
                                              height: 20),
                                          const SizedBox(width: 10),
                                          Text('Sign In with Google',
                                              style: GoogleFonts.sora(
                                                  textStyle: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold)))
                                        ],
                                      )))),
                          const SizedBox(height: 20,),
                          MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                await _viewModel.processLogin(LoginParams(loginProvider: Provider.twitter,
                                    extraLoginOptions: ExtraLoginOptions(
                                        domain: dotenv.env["AUTH0_DOMAIN"],
                                        client_id: dotenv.env["AUTH0_CLIENT_ID"],
                                        redirect_uri: "surfy://com.riverbank.surfy/auth"
                                    )), () {
                                  if (mounted) {
                                    context.go('/wallet');
                                  }
                                });
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
                                _viewModel.processLogin(LoginParams(
                                    loginProvider: Provider.farcaster
                                ), () {
                                  if (mounted) {
                                    context.go('/wallet');
                                  }
                                });
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
                    )),
                Obx(() {
                  if (_isLoading.isTrue) {
                    return const LoadingWidget(opacity: 0.4);
                  } else {
                    return Container();
                  }
                })
              ],
            )));
  }
}

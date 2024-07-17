import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/login/viewmodel/login_viewmodel.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
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
    _isLoading.value = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: Theme.of(context).textTheme.displaySmall),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: AppBar(
              backgroundColor: SurfyColor.black,
            )
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
                        const SizedBox(height: 10),
                        Text('Nice to see you!', style: Theme.of(context).textTheme.displaySmall?.apply(color: SurfyColor.white))
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
                          Text('Login', style: Theme.of(context).textTheme.displaySmall?.apply(color: SurfyColor.white)),
                          const SizedBox(height: 20,),
                          MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                try {
                                  _viewModel.processLogin(LoginParams(
                                    loginProvider: Provider.google,
                                  ), () {
                                    if (mounted) {
                                      checkAuthAndGo(context, "/wallet");
                                    }
                                  });
                                } catch (e) {
                                  onError('$e');
                                }

                                print('???');
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
                                          Text('Sign In with Google', style: Theme.of(context).textTheme.displaySmall?.apply(color: SurfyColor.black),)
                                        ],
                                      )))),
                          const SizedBox(height: 20,),
                          // MaterialButton(
                          //     padding: EdgeInsets.zero,
                          //     onPressed: () async {
                          //       await _viewModel.processLogin(LoginParams(loginProvider: Provider.twitter), () {
                          //         if (mounted) {
                          //           context.go('/wallet');
                          //         }
                          //       });
                          //     },
                          //     child: Container(
                          //         width: double.infinity,
                          //         padding: const EdgeInsets.symmetric(vertical: 15),
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(10.0),
                          //           color: Colors.black,
                          //         ),
                          //         child: Center(
                          //             child: Row(
                          //               mainAxisAlignment: MainAxisAlignment.center,
                          //               children: [
                          //                 const Icon(Icons.discord_outlined, size: 20, color: SurfyColor.white,),
                          //                 const SizedBox(width: 10),
                          //                 Text('Sign In with Discord',
                          //                     style: GoogleFonts.sora(
                          //                         textStyle: const TextStyle(
                          //                             color: Colors.white,
                          //                             fontSize: 20,
                          //                             fontWeight: FontWeight.bold)))
                          //               ],
                          //             )))),
                          // const SizedBox(height: 20,),
                          MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                try {
                                  _viewModel.processLogin(LoginParams(
                                      loginProvider: Provider.farcaster
                                  ), () {
                                    if (mounted) {
                                      context.go('/wallet');
                                    }
                                  });
                                } catch (e) {
                                  onError('$e');
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
                                          Text('Sign In with Farcaster', style: Theme.of(context).textTheme.displaySmall)
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

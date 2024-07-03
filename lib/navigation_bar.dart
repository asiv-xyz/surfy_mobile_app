import 'package:camera/camera.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/domain/qr/get_qr_controller.dart';
import 'package:surfy_mobile_app/ui/common/error/error_page.dart';
import 'package:surfy_mobile_app/ui/history/history_view.dart';
import 'package:surfy_mobile_app/ui/login/login_view.dart';
import 'package:surfy_mobile_app/ui/map/map_view.dart';
import 'package:surfy_mobile_app/ui/navigation_controller.dart';
import 'package:surfy_mobile_app/ui/payment/payment_view.dart';
import 'package:surfy_mobile_app/ui/pos/pages/check/payment_complete_view.dart';
import 'package:surfy_mobile_app/ui/pos/pages/confirm/payment_confirm_view.dart';
import 'package:surfy_mobile_app/ui/pos/pages/pos/pos_view.dart';
import 'package:surfy_mobile_app/ui/pos/pages/qr/pos_qr_view.dart';
import 'package:surfy_mobile_app/ui/pos/pages/select/select_payment_token_view.dart';
import 'package:surfy_mobile_app/ui/qr/qr_view.dart';
import 'package:surfy_mobile_app/ui/settings/settings_view.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/check/check_view.dart';
import 'package:surfy_mobile_app/ui/wallet/direct_send_view.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/receive/receive_view.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/confirm/sending_confirm_view.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/detail/wallet_detail_view.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/send/send_view.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/single_balance/send_receive_view.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/wallet/wallet_view.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

Future<GoRouter> generateRouter(IsMerchant isMerchantUseCase, NavigationController controller, String initialLocation) async {
  final GoRouter goRouter =
  GoRouter(initialLocation: initialLocation,
      routes: <RouteBase>[
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              onTap: (index) {
                if (index != 1) {
                  GetQRController qrController = Get.find();
                  qrController.qrViewController.value?.pauseCamera();
                } else {
                  GetQRController qrController = Get.find();
                  qrController.qrViewController.value?.resumeCamera();
                }
                final NavigationController navController = Get.find();
                if (navController.currentIndex != index) {
                  navController.onPageEnd(navController.currentIndex);
                }
                navController.currentIndex = index;
                navController.onPageStart(index);
                switch (index) {
                  case 0:
                    context.go('/wallet');
                    break;
                  case 1:
                    context.go('/qr');
                    break;
                  case 2:
                    context.go('/history');
                    break;
                  case 3:
                    context.go('/map');
                    break;
                  case 4:
                    context.go('/pos');
                    break;
                  default:
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/images/ic_home.png')),
                    label: 'Home'),
                BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/images/ic_camera.png')),
                    label: 'QR'),
                BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/images/ic_history.png')),
                    label: 'History'),
                BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/images/ic_map.png')),
                    label: 'Map'),
                BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/images/ic_pos.png')),
                    label: 'POS'),
              ],
              currentIndex: navigationShell.currentIndex,
            ),
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                  path: '/wallet',
                  builder: (context, state) => const WalletPage(),
                  routes: [
                    GoRoute(
                        path: ':token',
                        builder: (context, state) {
                          final token = state.pathParameters["token"];
                          if (token == null) {
                            return Container();
                          }
                          return WalletDetailPage(
                              token: findTokenByName(token)
                          );
                        })
                  ]),
            ],
          ),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/qr',
                builder: (context, state) =>
                    QRPage(camera: Get.find<List<CameraDescription>>().first)),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryPage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(path: '/map', builder: (context, state) => const MapPage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/pos',
                builder: (context, state) => PosPage(),
                routes: [
                  GoRoute(
                      path: 'qr',
                      builder: (context, state) {
                        final extra = state.extra as PosQrPageProps;
                        return PosQrPage(
                            storeId: extra.storeId,
                            receivedCurrencyType: extra.receivedCurrencyType,
                            wantToReceiveAmount: extra.wantToReceiveAmount
                        );
                      }
                  ),
                  GoRoute(
                      path: 'payment',
                      builder: (context, state) {
                        final extra = state.extra as PaymentConfirmPageProps;
                        return PaymentConfirmPage(
                            storeId: extra.storeId,
                            receiveCurrency: extra.receiveCurrency,
                            wantToReceiveAmount: extra.wantToReceiveAmount);
                      }
                  ),
                  GoRoute(
                      path: 'select',
                      builder: (context, state) {
                        final props = state.extra as SelectPaymentTokenPageProps;
                        return SelectPaymentTokenPage(
                          onSelect: props.onSelect,
                          receiveCurrency: props.receiveCurrency,
                          wantToReceiveAmount: props.wantToReceiveAmount,
                        );
                      }
                  ),
                  GoRoute(
                    path: 'check',
                    builder: (context, state) {
                      final extra = state.extra as PaymentCompletePageProps;
                      return PaymentCompletePage(
                          storeName: extra.storeName,
                          fiatAmount: extra.fiatAmount,
                          currencyType: extra.currencyType,
                          blockchain: extra.blockchain,
                          txHash: extra.txHash,
                      );
                    }
                  )
                ]
            ),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/settings', builder: (context, state) => SettingsPage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(path: '/payment', builder: (context, state) {
              return PaymentPage(storeId: 'none');
            }, routes: [
              GoRoute(
                  path: ':storeId',
                  builder: (context, state) {
                    final storeId = state.pathParameters['storeId'];
                    print('route to payment page with storeId: $storeId');
                    return PaymentPage(storeId: storeId ?? 'none');
                  }
              ),
            ]),
          ]),
          StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                    path: '/single-balance',
                    builder: (context, state) {
                      final Pair<Token, Blockchain> extra = state.extra as Pair<Token, Blockchain>;
                      final token = extra.first;
                      final blockchain = extra.second;
                      return SingleBalancePage(
                          token: token,
                          blockchain: blockchain
                      );
                    }
                ),
                GoRoute(
                    path: '/receive',
                    builder: (context, state) {
                      final Pair<Token, Blockchain> extra = state.extra as Pair<Token, Blockchain>;
                      final token = extra.first;
                      final blockchain = extra.second;
                      return ReceivePage(token: token, blockchain: blockchain);
                    }
                ),
                GoRoute(
                    path: '/send',
                    builder: (context, state) {
                      final Pair<Token, Blockchain> extra = state.extra as Pair<Token, Blockchain>;
                      final token = extra.first;
                      final blockchain = extra.second;
                      return SendPage(token: token, blockchain: blockchain);
                    },
                    routes: [
                      GoRoute(
                          path: ':blockchain/:token/:address/:amount',
                          builder: (context, state) {
                            final blockchain = state.pathParameters['blockchain'];
                            final token = state.pathParameters['token'];
                            final blockchainEnum = Blockchain.values.where((b) => b.name.toLowerCase() == blockchain).first;
                            final tokenEnum = Token.values.where((t) => t.name.toLowerCase() == token).first;
                            final address = state.pathParameters['address'] ?? "";
                            final amount = state.pathParameters['amount']?.toInt() ?? 0;
                            return DirectSendPage(
                                token: tokenEnum,
                                blockchain: blockchainEnum,
                                recipient: address,
                                amount: amount
                            );
                          }
                      )
                    ]
                ),
                GoRoute(
                    path: '/sendConfirm',
                    builder: (context, state) {
                      print('extra: ${state.extra}');
                      final SendingConfirmViewProps extra = state.extra as SendingConfirmViewProps;
                      return SendingConfirmPage(
                        token: extra.token,
                        blockchain: extra.blockchain,
                        sender: extra.sender,
                        receiver: extra.receiver,
                        amount: extra.amount,
                        fiat: extra.fiat,
                        currencyType: extra.currencyType,
                      );
                    }
                ),
                GoRoute(
                    path: '/check',
                    builder: (context, state) {
                      final CheckViewProps extra = state.extra as CheckViewProps;
                      print('extra: $extra');
                      return CheckView(
                          token: extra.token,
                          blockchain: extra.blockchain,
                          transactionHash: extra.transactionHash,
                          receiver: extra.receiver,
                          crypto: extra.crypto,
                          fiat: extra.fiat,
                          currency: extra.currency
                      );
                    }
                ),
                GoRoute(
                  path: '/error',
                  builder: (context, state) {
                    return ErrorPage();
                  }
                )
              ]),
        ])
  ]);

  return goRouter;
}
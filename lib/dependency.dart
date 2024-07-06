
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/cache/token/token_price_cache.dart';
import 'package:surfy_mobile_app/cache/wallet/wallet_cache.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/merchant/click_place.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/domain/qr/get_qr_controller.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/get_transaction_history.dart';
import 'package:surfy_mobile_app/domain/transaction/save_transaction.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/user/onboarding.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/service/blockchain/blockchain_service.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/merchant/merchant_service.dart';
import 'package:surfy_mobile_app/service/qr/qr_service.dart';
import 'package:surfy_mobile_app/service/token/token_price_service.dart';
import 'package:surfy_mobile_app/service/transaction/transaction_service.dart';
import 'package:surfy_mobile_app/service/user/user_service.dart';
import 'package:surfy_mobile_app/service/wallet/wallet_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';

void buildDependencies() {
  logger.i('Build Dependency');
  final EventBus eventBus = Get.put(EventBus());

  // Setting preferences
  final SettingsPreference settingPreference = Get.put(SettingsPreference());

  // Key Service
  final KeyService keyService = Get.put(KeyService());

  // Token Price Domain
  final TokenPriceService tokenPriceService = Get.put(TokenPriceService());
  final TokenPriceCache tokenPriceCache = Get.put(TokenPriceCache());
  final TokenPriceRepository tokenPriceRepository = Get.put(TokenPriceRepository(service: tokenPriceService, tokenPriceCache: tokenPriceCache));
  final GetTokenPrice getTokenPriceUseCase = Get.put(GetTokenPrice(repository: tokenPriceRepository));

  // Calculator
  final Calculator calculator = Get.put(Calculator(getTokenPrice: getTokenPriceUseCase));

  // Wallet Domain
  final WalletCache walletCache = Get.put(WalletCache());
  final WalletService walletService = Get.put(WalletService(walletCache: walletCache));
  final GetWalletAddress getWalletAddressUseCase = Get.put(GetWalletAddress(service: walletService, keyService: keyService));

  final WalletBalancesRepository walletBalancesRepository = Get.put(WalletBalancesRepository(walletService: walletService, walletCache: walletCache));
  eventBus.addEventListener(walletBalancesRepository);

  final GetWalletBalances getWalletBalancesUseCase = Get.put(GetWalletBalances(
    repository: walletBalancesRepository,
    getWalletAddressUseCase: getWalletAddressUseCase,
    getTokenPriceUseCase: getTokenPriceUseCase,
    keyService: keyService,
    calculator: calculator,
    settingsPreference: settingPreference,
  ));

  // Camera
  availableCameras().then((r) => Get.put(r));

  // Merchant
  final MerchantService merchantService = Get.put(MerchantService());
  final MerchantRepository merchantRepository = Get.put(MerchantRepository(service: merchantService));
  final ClickPlace clickPlaceUseCase = Get.put(ClickPlace());

  // Blockchain
  final BlockchainService blockchainService = Get.put(BlockchainService(keyService: keyService));
  final SendP2pToken sendP2pTokenUseCase = Get.put(SendP2pToken(blockchainService: blockchainService));

  // QR
  final QRService qrService = Get.put(QRService());
  final GetQRController getQRController = Get.put(GetQRController());
  final GetMerchants getMerchantsUseCase = Get.put(GetMerchants(service: merchantService));

  // Merchant
  final IsMerchant isMerchantUseCase = Get.put(IsMerchant(service: merchantService));

  // User
  final UserService userService = Get.put(UserService());

  // Transaction (History)
  final TransactionService transactionService = Get.put(TransactionService());
  final SaveTransaction saveTransaction = Get.put(SaveTransaction());
  final GetTransactionHistory getTransactionHistoryUseCase = Get.put(GetTransactionHistory());

  // Onboarding
  final Onboarding onboardingUseCase = Get.put(Onboarding());
}
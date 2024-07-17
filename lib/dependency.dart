
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/cache/contact/contact_cache.dart';
import 'package:surfy_mobile_app/cache/payment/payment_cache.dart';
import 'package:surfy_mobile_app/cache/qr/qr_cache.dart';
import 'package:surfy_mobile_app/cache/token/token_price_cache.dart';
import 'package:surfy_mobile_app/cache/wallet/wallet_cache.dart';
import 'package:surfy_mobile_app/common/blockchain_provider.dart';
import 'package:surfy_mobile_app/common/token_provider.dart';
import 'package:surfy_mobile_app/domain/contact/recent_sent_contacts.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/domain/payment/get_latest_payment_method.dart';
import 'package:surfy_mobile_app/domain/qr/get_cached_qr.dart';
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
import 'package:surfy_mobile_app/repository/contact/contact_repository.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/service/blockchain/blockchain_service.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/merchant/merchant_service.dart';
import 'package:surfy_mobile_app/service/payment/payment_service.dart';
import 'package:surfy_mobile_app/service/qr/qr_service.dart';
import 'package:surfy_mobile_app/service/token/token_price_service.dart';
import 'package:surfy_mobile_app/service/transaction/transaction_service.dart';
import 'package:surfy_mobile_app/service/user/user_service.dart';
import 'package:surfy_mobile_app/service/wallet/wallet_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';

void buildDependencies() {
  logger.i('Build Dependency');
  final EventBus eventBus = Get.put(EventBus());

  // Providers
  final TokenProvider tokenProvider = Get.put<TokenProvider>(TokenProviderImpl());
  final BlockchainProvider blockchainProvider = Get.put<BlockchainProvider>(BlockchainProviderImpl());

  // Setting preferences
  final SettingsPreference settingPreference = Get.put(SettingsPreference());

  // Key Service
  final KeyService keyService = Get.put(KeyService());

  // Token Price Domain
  final TokenPriceService tokenPriceService = Get.put(TokenPriceService());
  final TokenPriceCache tokenPriceCache = Get.put(TokenPriceCache());
  final TokenPriceRepository tokenPriceRepository = Get.put(TokenPriceRepository(service: tokenPriceService, tokenPriceCache: tokenPriceCache));
  final GetTokenPrice getTokenPriceUseCase = Get.put(GetTokenPrice(repository: tokenPriceRepository));

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
    settingsPreference: settingPreference,
  ));

  // Camera
  availableCameras().then((r) => Get.put(r));

  // Merchant
  final MerchantService merchantService = Get.put(MerchantService());
  final MerchantRepository merchantRepository = Get.put(MerchantRepository(service: merchantService));

  // Blockchain
  final BlockchainService blockchainService = Get.put(BlockchainService(keyService: keyService));
  final SendP2pToken sendP2pTokenUseCase = Get.put(SendP2pToken(blockchainService: blockchainService));

  // QR
  final QrCache qrCache = Get.put(QrCache());
  final QRService qrService = Get.put(QRService(cache: qrCache));
  final GetQRController getQRController = Get.put(GetQRController());
  final GetMerchants getMerchantsUseCase = Get.put(GetMerchants(service: merchantService));
  final GetCachedQr getCachedQr = Get.put(GetCachedQr(service: qrService));

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

  // Contact
  final ContactCache contactCache = Get.put(ContactCache());
  final ContactRepository contactRepository = Get.put(ContactRepository(cache: contactCache));
  final RecentSentContacts getRecentSentContacts = Get.put(RecentSentContacts(repository: contactRepository));

  // Recent Payment Method
  final PaymentCache paymentCache = Get.put(PaymentCache());
  final PaymentService paymentService = Get.put(PaymentService(cache: paymentCache));
  final GetLatestPaymentMethod getLatestPaymentMethod = Get.put(GetLatestPaymentMethod(service: paymentService));
}
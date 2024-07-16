import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/contact/recent_sent_contacts.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/contact/contact.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/memo/memo_view.dart';

class MemoViewModel {

  late MemoView _view;

  final RecentSentContacts _getRecentSentContacts = Get.find();

  final RxString observableAddress = "".obs;
  final RxString observableMemo = "".obs;
  final Rx<List<Contact>> observableRecentSentContacts = Rx([]);

  void setView(MemoView view) {
    _view = view;
  }

  void onSubmit() {

  }

  void init(Blockchain blockchain) async {
     observableRecentSentContacts.value = await _getRecentSentContacts.get(blockchain);
  }
}
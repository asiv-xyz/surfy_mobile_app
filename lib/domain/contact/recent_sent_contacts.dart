import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/contact/contact.dart';
import 'package:surfy_mobile_app/repository/contact/contact_repository.dart';

class RecentSentContacts {
  RecentSentContacts({required this.repository});

  final ContactRepository repository;

  Future<List<Contact>> get(Blockchain blockchain) async {
    return await repository.getRecentSentContacts(blockchain);
  }

  Future<void> put(Blockchain blockchain, String address, String? memo) async {
    await repository.cache.addRecentSentContact(blockchain, address, memo);
  }
}
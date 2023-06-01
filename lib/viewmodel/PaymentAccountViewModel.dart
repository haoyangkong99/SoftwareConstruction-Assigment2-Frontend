import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utmletgo/model/_model.dart';

import '../app/route.locator.dart';
import '../services/StripeAccountService.dart';
import '../services/_services.dart';

class PaymentAccountViewModel extends MultipleStreamViewModel {
  final _authService = locator<FirebaseAuthenticationService>();
  final _paymentService = locator<StripePaymentService>();
  final _accountService = locator<StripeAccountService>();
  final _userService = locator<UserService>();
  @override
  Map<String, StreamData> get streamsMap => {
        'user': StreamData<User>(
            _userService.getUserByDocumentIdAsStream(_authService.getUID())),
        'account':
            StreamData<StripeAccount>(_accountService.getAccountAsStream()),
        'link': StreamData<StripeAccountLinks>(
            _accountService.getAccountLinkAsStream())
      };
  Future<void> setUpAccount(String email) async {
    String documentID = _authService.getUID();
    await _paymentService.createStripeStandardAccount(email, documentID);
  }

  Future<void> generateOnboardingLink(String accountId) async {
    String documentID = _authService.getUID();
    await _paymentService.generateOnboardingLink(accountId, documentID);
  }

  Future<void> generateUpdateAccountLink(String accountId) async {
    String documentID = _authService.getUID();
    await _paymentService.generateUpdateAccountLink(accountId, documentID);
  }

  Future<void> retrieveAccount(String accountId) async {
    String documentID = _authService.getUID();
    StripeAccount account =
        await _paymentService.retrieveStripeAccount(accountId, documentID);
  }

  Future<void> updateAccountLinkStatus(StripeAccountLinks link) async {
    String documentID = _authService.getUID();

    await _accountService.updateAccountLinksByDocumentId(link, documentID);
  }

  Future<void> launchLink(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
}

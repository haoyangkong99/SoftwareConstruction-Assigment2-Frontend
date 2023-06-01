import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:utmletgo/app/_route.dart';
import 'package:utmletgo/model/StripeAccountLinks.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/StripeAccountService.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:utmletgo/view/Address/AddressScreen.dart';
import 'package:utmletgo/view/PaymentAccount/PaymentAccountScreen.dart';
import 'package:utmletgo/view/Review/ReviewScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileViewModel extends MultipleStreamViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<FirebaseAuthenticationService>();
  final _storageService = locator<FirebaseStorageService>();
  final _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();
  final _dataPassingService = locator<DataPassingService>();
  final _paymentService = locator<StripePaymentService>();
  final _accountService = locator<StripeAccountService>();

  @override
  Map<String, StreamData> get streamsMap => {
        'user': StreamData<User>(
            _userService.getUserByDocumentIdAsStream(_authService.getUID())),
        'account':
            StreamData<StripeAccount>(_accountService.getAccountAsStream()),
        'link': StreamData<StripeAccountLinks>(
            _accountService.getAccountLinkAsStream())
      };

  void navigateToHomeScreen() {
    _navigationService.pushNamedAndRemoveUntil(Routes.homeScreen);
  }

  void navigateToEditProfile() {
    _navigationService.navigateToEditProfileScreen();
  }

  void navigateToReviews() {
    String userGuid = _dataPassingService.get('current_user_guid') as String;
    _navigationService.navigateToView(ReviewScreen(sellerGuid: userGuid));
  }

  void navigateToPayment() {
    _navigationService.navigateToView(const PaymentAccountScreen());
  }

  void navigateToAddress() {
    _navigationService.navigateToView(const AddressScreen());
  }

  Future<void> signOut() async {
    _dataPassingService.removeAllData();
    await _authService.signOut();
    navigateToHomeScreen();
  }

  Future<void> updateUser(
      String contact, XFile? profilePicture, String status, User? data) async {
    if (profilePicture != null) {
      String url = await _storageService.uploadImageToStorage(
          _storageService.convertXFileToFile(profilePicture));
      if (data!.profilePicture.isNotEmpty) {
        String? oldProfilePicture = data.profilePicture;
        await _storageService.deleteFromStorage(oldProfilePicture);
      }
      data.profilePicture = url;
    }

    data!.contact = contact;
    data.status = status;
    await _userService.updateUserByDocumentId(data, _authService.getUID());
  }

  Future<void> updateAddresses(String type, String line1, String line2,
      String postcode, String city, String state, User? data, int index) async {
    Address newAddress =
        Address.complete(type, line1, line2, city, state, postcode);
    if (index == 0) {
      data!.addresses.add(newAddress);
    } else {
      data!.addresses[index - 1] = newAddress;
    }

    String? guid = data.guid;

    await _userService.updateUserByGuid(data, guid);
  }

  Future<void> deleteAddress(int index, User? data) async {
    DialogResponse? response = await _dialogService.showConfirmationDialog(
        title: "Delete Confirmation",
        description: "Are you sure to delete this address?");
    if (response!.confirmed) {
      data!.addresses.removeAt(index - 1);
      String? guid = data.guid;
      await _userService.updateUserByGuid(data, guid);
    }
  }
}

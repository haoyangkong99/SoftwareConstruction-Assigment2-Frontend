import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:utmletgo/app/_route.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:utmletgo/view/Marketplace/_marketplace.dart';

class UserProfileViewModel extends MultipleStreamViewModel {
  final _navigationService = locator<NavigationService>();
  final _itemService = locator<ItemService>();
  final _dataPassingService = locator<DataPassingService>();
  final _userService = locator<UserService>();
  String userGuid;
  UserProfileViewModel({required this.userGuid});
  @override
  Map<String, StreamData> get streamsMap => {
        'item': StreamData<List<Item>>(_itemService.getAllItemsAsStream()),
        'user': StreamData<User>(getUser()),
      };
  Stream<User> getUser() {
    return _userService.getUserByGuidAsStream(userGuid);
  }

  void navigateToItemDetailScreen(String guid) {
    _dataPassingService.addToDataPassingList('item_guid', guid);
    _navigationService.navigateToView(ItemDetailsScreen());
  }
}

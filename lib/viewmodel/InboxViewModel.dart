import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:utmletgo/app/_route.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:utmletgo/view/Contact/ChatScreen.dart';

class InboxViewModel extends MultipleStreamViewModel {
  final _navigationService = locator<NavigationService>();
  final _itemService = locator<ItemService>();
  final _dataPassingService = locator<DataPassingService>();
  final _userService = locator<UserService>();
  final _chatService = locator<ChatService>();

  @override
  Map<String, StreamData> get streamsMap => {
        'chatList': StreamData<List<Chat>>(getChatList()),
        'itemList': StreamData<List<Item>>(_itemService.getAllItemsAsStream()),
        'userList': StreamData<List<User>>(_userService.getAllUsersAsStream()),
        'currentUser': StreamData<User>(_userService.getCurrentUserAsStream())
      };

  Stream<List<Chat>> getChatList() {
    String guid = _dataPassingService.get("current_user_guid") as String;
    return _chatService
        .getChatsWithConditionAsStream((chat) => chat.userGuids.contains(guid));
  }

  Future<List<Item>> getItem() {
    return _itemService.getAllItems();
  }

  void navigateToChatScreen(
      String chatGuid, String receiverGuid, String itemGuid) {
    _dataPassingService.addToDataPassingList('item_guid', itemGuid);
    _dataPassingService.addToDataPassingList('chat_guid', chatGuid);
    _dataPassingService.addToDataPassingList('receiver_guid', receiverGuid);
    _navigationService.navigateToView(ChatScreen());
  }
}

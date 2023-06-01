import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:utmletgo/app/_route.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:utmletgo/view/Contact/_contact.dart';

class ViewOfferViewModel extends MultipleStreamViewModel {
  final _navigationService = locator<NavigationService>();
  final _dataPassingService = locator<DataPassingService>();
  final _userService = locator<UserService>();
  final _chatService = locator<ChatService>();

  @override
  Map<String, StreamData> get streamsMap => {
        'user': StreamData<List<User>>(_userService.getAllUsersAsStream()),
        'chat': StreamData<List<Chat>>(getChat()),
      };

  Stream<List<Chat>> getChat() {
    String itemGuid = _dataPassingService.get('item_guid') as String;
    return _chatService
        .getChatsWithConditionAsStream((chat) => chat.itemGuid == itemGuid);
  }

  void navigateToChatScreen(
      String chatGuid, String receiverGuid, String itemGuid) {
    _dataPassingService.addToDataPassingList('item_guid', itemGuid);
    _dataPassingService.addToDataPassingList('chat_guid', chatGuid);
    _dataPassingService.addToDataPassingList('receiver_guid', receiverGuid);
    _navigationService.navigateToView(ChatScreen());
  }
}

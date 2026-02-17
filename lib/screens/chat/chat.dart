import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/chat_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
// import 'package:intl/intl.dart' as intl;
import 'package:shimmer/shimmer.dart';

import '../../app_config.dart';

class Chat extends StatefulWidget {
  const Chat({
    Key? key,
    this.conversation_id,
    this.messenger_name,
    this.messenger_title,
    this.messenger_image,
  }) : super(key: key);

  final int? conversation_id;
  final String? messenger_name;
  final String? messenger_title;
  final String? messenger_image;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _chatTextController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  // final ScrollController _xcrollController = ScrollController();
  final lastKey = GlobalKey();

  var uid = user_id;

  List<dynamic> _list = [];
  bool _isInitial = true;
  int _page = 1;
  int _totalData = 0;
  bool _showLoadingContainer = false;
  int? _last_id = 0;
  Timer? timer;
  // String _message = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();
  }

  fetchData() async {
    final messageResponse = await ChatRepository().getMessageResponse(
        conversation_id: widget.conversation_id, page: _page);
    _list.addAll(messageResponse.data);
    _isInitial = false;
    _showLoadingContainer = false;
    _last_id = _list[0].id;
    setState(() {});

    fetch_new_message();
  }

  reset() {
    _list.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    _last_id = 0;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  onPressLoadMore() {
    setState(() {
      _page++;
    });
    _showLoadingContainer = true;
    fetchData();
  }

  onTapSendMessage() async {
    final chatText = _chatTextController.text.toString();
    _chatTextController.clear();
    //print(chatText);
    if (chatText != "") {
      // final DateTime now = DateTime.now();
      // final intl.DateFormat date_formatter = intl.DateFormat('yyyy-MM-dd');
      // final intl.DateFormat time_formatter = intl.DateFormat('hh:ss');
      // final String formatted_date = date_formatter.format(now);
      // final String formatted_time = time_formatter.format(now);

      final messageResponse = await ChatRepository().getInserMessageResponse(
          conversation_id: widget.conversation_id, message: chatText);
      _list = [
        messageResponse.data,
        _list,
      ].expand((x) => x).toList(); //prepend
      _last_id = _list[0].id;
      setState(() {});
    }
  }

  fetch_new_message() async {
    await Future.delayed(const Duration(seconds: 5), () {
      get_new_message();
    }).then((value) {
      fetch_new_message();
    });
  }

  get_new_message() async {
    final messageResponse = await ChatRepository().getNewMessageResponse(
        conversation_id: widget.conversation_id, last_message_id: _last_id);

    _list = [
      messageResponse.data,
      _list,
    ].expand((x) => x).toList(); //prepend
    _last_id = _list[0].id;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar2(context),
        body: Stack(
          children: [
            !_isInitial ? conversations() : chatShimmer(),
            typeSmsSection(),
          ],
        ),
      ),
    );
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _list.length
            ? 'no_more_items_ucf'.tr(context: context)
            : 'loading_more_items_ucf'.tr(context: context)),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      toolbarHeight: 75,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
              app_language_rtl.$!
                  ? CupertinoIcons.arrow_right
                  : CupertinoIcons.arrow_left,
              color: MyTheme.dark_grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Container(
        child: Container(
            width: 350,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusVeryLarge),
                      border: Border.all(
                          color: const Color.fromRGBO(112, 112, 112, .3),
                          width: 1),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusVeryLarge),
                        child: FadeInImage.assetNetwork(
                          placeholder: AppImages.placeholder,
                          image: widget.messenger_image!,
                          fit: BoxFit.contain,
                        )),
                  ),
                  Container(
                    width: 220,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.messenger_name!,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.messenger_title!,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: MyTheme.medium_grey,
                              fontSize: 12,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      _onRefresh();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.rotate_left,
                        color: MyTheme.font_grey,
                      ),
                    ),
                  )
                ])),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  AppBar buildAppBar2(BuildContext context) {
    return AppBar(
      leadingWidth: 40,
      centerTitle: false,
      scrolledUnderElevation: 0.0,
      elevation: 0,
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  margin: const EdgeInsets.only(right: 14),
                  child: Stack(
                    children: [
                      UsefulElements.roundImageWithPlaceholder(
                          elevation: 1,
                          borderWidth: 0,
                          url: widget.messenger_image,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusDefault)),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: DeviceInfo(context).width! / 3,
                        child: Text(
                          widget.messenger_name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: MyTheme.dark_font_grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: MyTheme.mainColor,
      leading: Container(
        margin: const EdgeInsets.only(left: AppDimensions.paddingSupSmall),
        child: UsefulElements.backButton(),
      ),
    );
  }

  Widget buildChatList() {
    if (_isInitial && _list.isEmpty) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 10, item_height: 100.0));
    } else if (_list.isNotEmpty) {
      return SingleChildScrollView(
        child: ListView.builder(
          key: lastKey,
          controller: _chatScrollController,
          itemCount: _list.length,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          reverse: true,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: buildChatItem(index),
            );
          },
        ),
      );
    } else if (_totalData == 0) {
      return Center(child: Text('no_data_is_available'.tr(context: context)));
    } else {
      return emptyWidget;
    }
  }

  dynamic buildChatItem(index) {
    return _list[index].user_id == uid
        ? getSenderView(ChatBubbleClipper5(type: BubbleType.sendBubble),
            context, _list[index].message, _list[index].date, _list[index].time)
        : getReceiverView(
            ChatBubbleClipper5(type: BubbleType.receiverBubble),
            context,
            _list[index].message,
            _list[index].date,
            _list[index].time);
  }

  Row buildMessageSendingRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 40,
          width: (MediaQuery.sizeOf(context).width - 32) * (4 / 5),
          child: TextField(
            autofocus: false,
            maxLines: null,
            controller: _chatTextController,
            decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromRGBO(251, 251, 251, 1),
                hintText: 'type_your_message_here'.tr(context: context),
                hintStyle: const TextStyle(
                    fontSize: 14.0, color: MyTheme.textfield_grey),
                enabledBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.textfield_grey, width: 0.5),
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.radiusVeryLarge),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.medium_grey, width: 0.5),
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.radiusVeryLarge),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: GestureDetector(
            onTap: () {
              onTapSendMessage();
            },
            child: Container(
              width: 40,
              height: 40,
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusVeryLarge),
                border: Border.all(
                    color: const Color.fromRGBO(112, 112, 112, .3), width: 1),
              ),
              child: const Center(
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ChatBubble getSenderView(CustomClipper clipper, BuildContext context,
      String text, String date, String time) {
    return ChatBubble(
      elevation: 0.0,
      clipper: clipper,
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: AppDimensions.paddingSupSmall),
      backGroundColor: MyTheme.soft_accent_color,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: const TextStyle(color: MyTheme.font_grey, fontSize: 14),
            ),
            Text('$date $time',
                style:
                    const TextStyle(color: MyTheme.medium_grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  ChatBubble getReceiverView(
          CustomClipper clipper, BuildContext context, text, date, time) =>
      ChatBubble(
        elevation: 0.0,
        clipper: clipper,
        backGroundColor: const Color.fromRGBO(239, 239, 239, 1),
        margin: const EdgeInsets.only(top: AppDimensions.paddingSupSmall),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.6,
            minWidth: MediaQuery.sizeOf(context).width * 0.6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: MyTheme.font_grey, fontSize: 13, wordSpacing: 1),
                ),
              ),
              Text(date + " " + time,
                  style: const TextStyle(
                      color: MyTheme.medium_grey, fontSize: 10)),
            ],
          ),
        ),
      );

  SingleChildScrollView conversations() {
    return SingleChildScrollView(
      reverse: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 60),
        child: ListView.builder(
          reverse: true,
          itemCount: _list.length,
          shrinkWrap: true,
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingSupSmall,
              bottom: AppDimensions.paddingSupSmall),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.only(
                  left: 14, right: 14, top: 10, bottom: 10),
              child: Column(
                children: [
                  (index == _list.length - 1) ||
                          _list[index].year != _list[index + 1].year ||
                          _list[index].month != _list[index + 1].month
                      ? UsefulElements().customContainer(
                          width: 100,
                          height: 20,
                          borderRadius: 5,
                          child: Text(
                            "" + _list[index].date.toString(),
                            style: const TextStyle(
                                fontSize: 8, color: Color(0xff999999)),
                          ),
                        )
                      : emptyWidget,
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: (_list[index].sendType == "customer"
                        ? Alignment.topRight
                        : Alignment.topLeft),
                    child: smsContainer(index),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Container smsContainer(int index) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 80,
        maxWidth: DeviceInfo(context).width! / 1.6,
      ),
      padding: const EdgeInsets.only(
          top: AppDimensions.paddingSmall, bottom: 3, right: 10, left: 10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: MyTheme.noColor,
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppDimensions.radiusDefault),
          topRight: const Radius.circular(AppDimensions.radiusDefault),
          bottomLeft: _list[index].sendType == "customer"
              ? const Radius.circular(AppDimensions.radiusDefault)
              : const Radius.circular(0),
          bottomRight: _list[index].sendType == "customer"
              ? const Radius.circular(0)
              : const Radius.circular(AppDimensions.radiusDefault),
        ),
        color: (_list[index].sendType == "customer"
            ? Theme.of(context).primaryColor
            : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 20,
            spreadRadius: 0.0,
            offset: const Offset(0.0, 10.0),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              bottom: 3,
              right: _list[index].sendType == "customer" ? 2 : 2,
              //left: _list[index].sendType == "customer" ? 2 : null,
              child: Text(
                _list[index].time.toString(),
                style: TextStyle(
                  fontSize: 8,
                  color: (_list[index].sendType == "customer"
                      ? MyTheme.light_grey
                      : const Color(0xff707070)),
                ),
              )),
          Padding(
            padding:
                const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
            child: Text(
              " " + _list[index].message.toString(),
              style: TextStyle(
                fontSize: 12,
                color: (_list[index].sendType == "customer"
                    ? MyTheme.white
                    : Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget typeSmsSection() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.only(
            left: AppDimensions.paddingLarge, bottom: 10, top: 10),
        height: 60,
        width: double.infinity,
        color: Colors.white.withValues(alpha: 0.95),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLarge),
                  color: const Color(0xffEFEFEF),
                ),
                child: TextField(
                  controller: _chatTextController,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText:
                        "  ${'type_your_message_here'.tr(context: context)}",
                    hintStyle:
                        const TextStyle(color: Color(0xff999999), fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
              child: Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xffD1D1D1),
                    width: 2.0,
                  ),
                ),
                child: FloatingActionButton(
                  onPressed: _chatTextController.text.trim().isNotEmpty
                      ? () {
                          onTapSendMessage();
                        }
                      : null,
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView chatShimmer() {
    return SingleChildScrollView(
      reverse: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 60),
        child: ListView.builder(
          reverse: true,
          itemCount: 10,
          shrinkWrap: true,
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingSupSmall,
              bottom: AppDimensions.paddingSupSmall),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            //print(_messages[index+1].year.toString());
            return Container(
              padding: const EdgeInsets.only(
                  left: 14, right: 14, top: 10, bottom: 10),
              child: Align(
                alignment:
                    (index.isOdd ? Alignment.topRight : Alignment.topLeft),
                child: smsShimmer(index),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget smsShimmer(int index) {
    return Shimmer.fromColors(
      baseColor: MyTheme.shimmer_base,
      highlightColor: MyTheme.shimmer_highlighted,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 150,
          maxWidth: DeviceInfo(context).width! / 1.6,
        ),
        padding: const EdgeInsets.only(
            top: AppDimensions.paddingSmall, bottom: 3, right: 10, left: 10),
        decoration: BoxDecoration(
          border: Border.all(
              width: 1,
              color: index.isOdd
                  ? Theme.of(context).primaryColor
                  : MyTheme.grey_153),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppDimensions.radiusDefault),
            topRight: const Radius.circular(AppDimensions.radiusDefault),
            bottomLeft: index.isOdd
                ? const Radius.circular(AppDimensions.radiusDefault)
                : const Radius.circular(0),
            bottomRight: index.isOdd
                ? const Radius.circular(0)
                : const Radius.circular(AppDimensions.radiusDefault),
          ),
          color: (index.isOdd
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor),
        ),
        child: Stack(
          children: [
            Positioned(
                bottom: 2,
                right: index.isOdd ? 2 : null,
                left: index.isOdd ? null : 2,
                child: Text(
                  "    ",
                  style: TextStyle(
                    fontSize: 8,
                    color:
                        (index.isOdd ? MyTheme.light_grey : MyTheme.grey_153),
                  ),
                )),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
              child: Text(
                "    ",
                style: TextStyle(
                  fontSize: 12,
                  color: (index.isOdd ? MyTheme.white : Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

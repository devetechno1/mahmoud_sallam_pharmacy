import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/notification_repository.dart';
import 'package:flutter/material.dart';

import '../../custom/loading.dart';
import '../../custom/toast_component.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';
import 'widgets/notification_card.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({Key? key}) : super(key: key);

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<dynamic> _notificationList = [];
  bool _isFetching = true;
  List<String> notificationIds = [];
  bool isAllSelected = false;

  fetch() async {
    final notificationResponse =
        await NotificationRepository().getAllNotification();
    _notificationList.addAll(notificationResponse.data as Iterable);
    _isFetching = false;
    setState(() {});
  }

  cleanAll() {
    _isFetching = true;
    notificationIds = [];
    _notificationList = [];
    isAllSelected = false;
    setState(() {});
  }

  resetAll() {
    cleanAll();
    fetch();
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.white,
        iconTheme: const IconThemeData(color: MyTheme.dark_grey),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'notification_ucf'.tr(context: context),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.dark_font_grey),
            ),
            if (notificationIds.isNotEmpty)
              PopupMenuButton<int>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text('delete_selection'.tr(context: context)),
                  ),
                ],
                onSelected: (value) async {
                  // print('delete on selection');
                  // if empty list then return
                  if (notificationIds.isEmpty) {
                    ToastComponent.showDialog(
                      'nothing_selected'.tr(context: context),
                    );
                    return;
                  }
                  // show loading and delete selected notification
                  Loading.show(context);
                  final notificationResponse = await NotificationRepository()
                      .notificationBulkDelete(notificationIds);
                  Loading.close();
                  if (notificationResponse.result) {
                    ToastComponent.showDialog(
                      notificationResponse.message,
                    );
                  }
                  // reset all list
                  if (notificationResponse.result) {
                    resetAll();
                  }
                },
              )
          ],
        ),
      ),
      body: SafeArea(
          child: _isFetching == false
              ? buildShowNotificationSection()
              : ShimmerHelper().buildListShimmer(
                  item_count: 10,
                  item_height: 60.0,
                )),
    );
  }

  Container buildShowNotificationSection() {
    return Container(
        padding: const EdgeInsets.only(bottom: AppDimensions.paddingSupSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _notificationList.isNotEmpty
                ? Container(
                    height: 50,
                    width: DeviceInfo(context).width,
                    child: CheckboxListTile(
                      title: Text('select_all'.tr(context: context)),
                      value: isAllSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          isAllSelected = value!;
                          _notificationList.forEach((notification) {
                            notification.isChecked = isAllSelected;

                            if (isAllSelected) {
                              notificationIds.add(notification.id);
                            } else {
                              notificationIds = [];
                            }
                          });
                        });
                      },
                    ),
                  )
                : const SizedBox.shrink(),
            _notificationList.isNotEmpty
                ? Flexible(
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _notificationList.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return NotificationListCard(
                          id: _notificationList[index].id!,
                          type: _notificationList[index].type!,
                          status: _notificationList[index].data!.status,
                          orderId: _notificationList[index].data!.orderId,
                          orderCode: _notificationList[index].data!.orderCode,
                          notificationText:
                              _notificationList[index].notificationText,
                          link: _notificationList[index].data!.link,
                          dateTime: _notificationList[index].date,
                          image: _notificationList[index].image,
                          // for all checked
                          isChecked: _notificationList[index].isChecked,
                          onSelect: (String id, bool isChecked) {
                            // print("id: $id, isChecked: $isChecked");
                            setState(() {
                              _notificationList[index].isChecked = isChecked;
                              // isAllSelected = _notificationList.every(
                              //     (notification) => notification.isChecked);
                            });
                            // Define the onSelect function here
                            if (isChecked) {
                              // If checkbox is checked, add the ID to your selected IDs list
                              notificationIds.add(id);
                            } else {
                              // If checkbox is unchecked, remove the ID from your selected IDs list
                              notificationIds.remove(id);
                            }
                            // Optionally, you can perform any other actions based on the selection
                            print(notificationIds);
                          },
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                    'no_notification_ucf'.tr(context: context),
                  )),
          ],
        ));
  }
}

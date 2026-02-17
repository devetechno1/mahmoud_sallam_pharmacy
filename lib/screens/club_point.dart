import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/clubpoint_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wallet.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../app_config.dart';

class Clubpoint extends StatefulWidget {
  @override
  _ClubpointState createState() => _ClubpointState();
}

class _ClubpointState extends State<Clubpoint> {
  final ScrollController _xcrollController = ScrollController();

  final List<dynamic> _list = [];
  final List<dynamic> _converted_ids = [];
  bool _isInitial = true;
  int _page = 1;
  int? _totalData = 0;
  bool _showLoadingContainer = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    _xcrollController.addListener(() {
      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
        });
        _showLoadingContainer = true;
        fetchData();
      }
    });
  }

  fetchData() async {
    final clubpointResponse =
        await ClubpointRepository().getClubPointListResponse(page: _page);
    setState(() {
      _list.addAll(clubpointResponse.clubpoints ?? []);
      _isInitial = false;
      _totalData = clubpointResponse.meta?.total ?? 0;
      _showLoadingContainer = false;
    });
  }

  reset() {
    setState(() {
      _list.clear();
      _converted_ids.clear();
      _isInitial = true;
      _totalData = 0;
      _page = 1;
      _showLoadingContainer = false;
    });
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  Future<void> onPressConvert(itemId, SnackBar _convertedSnackbar) async {
    if (itemId == null) return;

    final clubpointToWalletResponse =
        await ClubpointRepository().getClubpointToWalletResponse(itemId);
    if (clubpointToWalletResponse.result == false) {
      ToastComponent.showDialog(clubpointToWalletResponse.message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(_convertedSnackbar);
      setState(() {
        _converted_ids.add(itemId);
      });
    }
  }

  onPopped(value) async {
    reset();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final SnackBar _convertedSnackbar = SnackBar(
      content: Text(
        'points_converted_to_wallet'.tr(context: context),
        style: const TextStyle(color: MyTheme.font_grey),
      ),
      backgroundColor: MyTheme.soft_accent_color,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'show_wallet_all_capital'.tr(context: context),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Wallet();
          })).then((value) {
            onPopped(value);
          });
        },
        textColor: Theme.of(context).primaryColor,
        disabledTextColor: Colors.grey,
      ),
    );

    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        body: Stack(
          children: [
            RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              onRefresh: _onRefresh,
              displacement: 0,
              child: CustomScrollView(
                controller: _xcrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: buildList(_convertedSnackbar),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: buildLoadingContainer(),
            ),
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
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'earned_points_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildList(SnackBar _convertedSnackbar) {
    if (_isInitial && _list.isEmpty) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 10, item_height: 100.0));
    } else if (_list.isNotEmpty) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemCount: _list.length,
          scrollDirection: Axis.vertical,
          // padding: const EdgeInsets.all(0.0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildItemCard(index, _convertedSnackbar);
          },
        ),
      );
    } else if (_totalData == 0) {
      return Center(child: Text('no_data_is_available'.tr(context: context)));
    } else {
      return emptyWidget; // should never happen
    }
  }

  Widget buildItemCard(int index, SnackBar _convertedSnackbar) {
    final item = _list[index];
    return Container(
      height: 91,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingDefault),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: DeviceInfo(context).width! / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.orderCode ?? "",
                    style: const TextStyle(
                        color: MyTheme.dark_font_grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        "${'converted_ucf'.tr(context: context)} - ",
                        style: const TextStyle(
                            fontSize: 12, color: MyTheme.dark_font_grey),
                      ),
                      Text(
                        (item.convert_status == 1 ||
                                _converted_ids.contains(item.id))
                            ? 'yes_ucf'.tr(context: context)
                            : 'no_ucf'.tr(context: context),
                        style: TextStyle(
                          fontSize: 12,
                          color: item.convert_status == 1
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "${'date_ucf'.tr(context: context)} : ",
                        style: const TextStyle(
                            fontSize: 12, color: MyTheme.dark_font_grey),
                      ),
                      Text(
                        item.date ?? "",
                        style: const TextStyle(
                            fontSize: 12, color: MyTheme.dark_font_grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: DeviceInfo(context).width! / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.convertible_club_point?.toString() ?? "0",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  item.convert_status == 1 || _converted_ids.contains(item.id)
                      ? Text(
                          'done_all_capital'.tr(context: context),
                          style: const TextStyle(
                              color: MyTheme.grey_153,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        )
                      : (item.convertible_club_point ?? 0) <= 0
                          ? Text(
                              'refunded_ucf'.tr(context: context),
                              style: const TextStyle(
                                  color: MyTheme.grey_153,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            )
                          : SizedBox(
                              height: 24,
                              width: 80,
                              child: Btn.basic(
                                color: Theme.of(context).primaryColor,
                                child: Text(
                                  'convert_now_ucf'.tr(context: context),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                                onPressed: () {
                                  onPressConvert(item.id, _convertedSnackbar);
                                },
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

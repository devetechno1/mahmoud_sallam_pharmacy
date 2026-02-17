// ignore_for_file: unused_field

import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/text_styles.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/chat_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/screens/brand_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/chat/chat.dart';
import 'package:active_ecommerce_cms_demo_app/screens/checkout/cart.dart';
import 'package:active_ecommerce_cms_demo_app/screens/common_webview_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/seller_details.dart';
import 'package:active_ecommerce_cms_demo_app/screens/video_description_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_config.dart';
import '../../helpers/main_helpers.dart';
import '../../repositories/auction_products_repository.dart';

class AuctionProductsDetails extends StatefulWidget {
  final String slug;

  const AuctionProductsDetails({Key? key, required this.slug})
      : super(key: key);

  @override
  _AuctionProductsDetailsState createState() => _AuctionProductsDetailsState();
}

class _AuctionProductsDetailsState extends State<AuctionProductsDetails>
    with TickerProviderStateMixin {
  bool _showCopied = false;
  String _appbarPriceString = ". . .";
  int _currentImage = 0;
  final ScrollController _mainScrollController =
      ScrollController(initialScrollOffset: 0.0);
  final ScrollController _colorScrollController = ScrollController();
  final ScrollController _variantScrollController = ScrollController();
  final ScrollController _imageScrollController = ScrollController();
  TextEditingController sellerChatTitleController = TextEditingController();
  TextEditingController sellerChatMessageController = TextEditingController();
  final TextEditingController _bidPriceController = TextEditingController();

  CountdownTimerController? countDownTimercontroller;

  double _scrollPosition = 0.0;

  Animation? _colorTween;
  late AnimationController _ColorAnimationController;

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  late BuildContext loadingcontext;

  //init values
  final _formKey = GlobalKey<FormState>();

  var _productDetailsFetched = false;
  dynamic _auctionproductDetails = null;
  final _productImageList = [];
  final _selectedChoices = [];
  final _variant = "";
  final int _quantity = 1;

  double opacity = 0;

  @override
  void initState() {
    _ColorAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 0));

    _colorTween = ColorTween(begin: Colors.transparent, end: Colors.white)
        .animate(_ColorAnimationController);

    _mainScrollController.addListener(() {
      _scrollPosition = _mainScrollController.position.pixels;

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;
        }
      }

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;

          if (100 > _scrollPosition) {
            opacity = 1;
          }
        }
      }
      print("opachity{} $_scrollPosition");

      setState(() {});
    });
    fetchAll();
    super.initState();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _variantScrollController.dispose();
    _imageScrollController.dispose();
    _colorScrollController.dispose();
    // countDownTimercontroller.dispose();
    _bidPriceController.dispose();
    sellerChatTitleController.dispose();
    sellerChatMessageController.dispose();
    _ColorAnimationController.dispose();
    super.dispose();
  }

  Future<void> onPressBidPlace() async {
    final bidPlacedResponse = await AuctionProductsRepository()
        .placeBidResponse(
            _auctionproductDetails.id.toString(), _bidPriceController.text);

    if (bidPlacedResponse.result == true) {
      ToastComponent.showDialog(
        bidPlacedResponse.message!,
      );

      fetchAll();
    }
  }

  void fetchAll() {
    fetchAuctionProductDetails();
  }

  Future<void> fetchAuctionProductDetails() async {
    final auctionproductDetailsResponse = await AuctionProductsRepository()
        .getAuctionProductsDetails(widget.slug);

    if (auctionproductDetailsResponse.auctionProduct!.isNotEmpty) {
      _auctionproductDetails = auctionproductDetailsResponse.auctionProduct![0];
      sellerChatTitleController.text =
          auctionproductDetailsResponse.auctionProduct![0].name!;
    }

    setProductDetailValues();

    setState(() {});
  }

  void setProductDetailValues() {
    if (_auctionproductDetails != null) {
      _auctionproductDetails.photos.forEach((photo) {
        _productImageList.add(photo.path);
      });
      _productDetailsFetched = true;

      setState(() {});
    }
  }

  void reset() {
    restProductDetailValues();
    _currentImage = 0;
    _productImageList.clear();
    _productDetailsFetched = false;
    sellerChatTitleController.clear();
    setState(() {});
  }

  void restProductDetailValues() {
    _appbarPriceString = " . . .";
    _auctionproductDetails = null;
    _productImageList.clear();
    _currentImage = 0;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  void onPopped(value) {
    reset();
    fetchAll();
  }

  void onCopyTap(setState) {
    setState(() {
      _showCopied = true;
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showCopied = false;
      });
    });
  }

  Future<T?> onPressShare<T>(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              contentPadding: const EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 26,
                          color: const Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSmall),
                              side: const BorderSide(
                                  color: Colors.black, width: 1.0)),
                          child: Text(
                            'copy_product_link_ucf'.tr(context: context),
                            style: const TextStyle(
                              color: MyTheme.medium_grey,
                            ),
                          ),
                          onPressed: () {
                            onCopyTap(setState);
                            // todo:: copy to clip board implement this old code not working

                            Clipboard.setData(ClipboardData(
                                    text: _auctionproductDetails.link))
                                .then((_) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Copied to clipboard"),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(milliseconds: 300),
                              ));
                            });
                          },
                        ),
                      ),
                      _showCopied
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.paddingSmall),
                              child: Text(
                                'copied_ucf'.tr(context: context),
                                style: const TextStyle(
                                    color: MyTheme.medium_grey, fontSize: 12),
                              ),
                            )
                          : emptyWidget,
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 26,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSmall),
                              side: const BorderSide(
                                  color: Colors.black, width: 1.0)),
                          child: Text(
                            'share_options_ucf'.tr(context: context),
                            style: const TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            // print("share links ${_auctionproductDetails.link}");
                            Share.share(_auctionproductDetails.link);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: app_language_rtl.$!
                          ? const EdgeInsets.only(
                              left: AppDimensions.paddingSmall)
                          : const EdgeInsets.only(right: 8.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 30,
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSmall),
                            side: const BorderSide(
                                color: MyTheme.font_grey, width: 1.0)),
                        child: Text(
                          'close_all_capital'.tr(context: context),
                          style: const TextStyle(
                            color: MyTheme.font_grey,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  Future onTapSellerChat() {
    return showDialog(
        context: context,
        builder: (_) => Directionality(
              textDirection:
                  app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 10),
                contentPadding: const EdgeInsets.only(
                    top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
                content: Container(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingSmall),
                          child: Text('title_ucf'.tr(context: context),
                              style: const TextStyle(
                                  color: MyTheme.font_grey, fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingDefault),
                          child: Container(
                            height: 40,
                            child: TextField(
                              controller: sellerChatTitleController,
                              autofocus: false,
                              decoration: InputDecoration(
                                  hintText:
                                      'enter_title_ucf'.tr(context: context),
                                  hintStyle: const TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 0.5),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          AppDimensions.radiusSmall),
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          AppDimensions.radiusSmall),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingSmall),
                          child: Text("${'message_ucf'.tr(context: context)} *",
                              style: const TextStyle(
                                  color: MyTheme.font_grey, fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingDefault),
                          child: Container(
                            height: 55,
                            child: TextField(
                              controller: sellerChatMessageController,
                              autofocus: false,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  hintText:
                                      'enter_message_ucf'.tr(context: context),
                                  hintStyle: const TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 0.5),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          AppDimensions.radiusSmall),
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          AppDimensions.radiusSmall),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      right: 16.0,
                                      left: 8.0,
                                      top: 16.0,
                                      bottom: 16.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 30,
                          color: const Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSmall),
                              side: const BorderSide(
                                  color: MyTheme.light_grey, width: 1.0)),
                          child: Text(
                            'close_all_capital'.tr(context: context),
                            style: const TextStyle(
                              color: MyTheme.font_grey,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 30,
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSmall),
                              side: const BorderSide(
                                  color: MyTheme.light_grey, width: 1.0)),
                          child: Text(
                            'send_all_capital'.tr(context: context),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            onPressSendMessage();
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ));
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                width: 10,
              ),
              Text("${'please_wait_ucf'.tr(context: context)}"),
            ],
          ));
        });
  }

  Future<void> showLoginWarning() {
    return ToastComponent.showDialog(
      'you_need_to_log_in'.tr(context: context),
    );
  }

  Future<void> onPressSendMessage() async {
    if (!is_logged_in.$) {
      showLoginWarning();
      return;
    }
    loading();
    final title = sellerChatTitleController.text.toString();
    final message = sellerChatMessageController.text.toString();

    if (title == "" || message == "") {
      ToastComponent.showDialog(
        'title_or_message_empty_warning'.tr(context: context),
      );
      return;
    }

    final conversationCreateResponse = await ChatRepository()
        .getCreateConversationResponse(
            product_id: _auctionproductDetails.id,
            title: title,
            message: message);

    Navigator.of(loadingcontext).pop();

    if (!mounted) return;

    if (conversationCreateResponse.result == false) {
      ToastComponent.showDialog(
        'could_not_create_conversation'.tr(context: context),
      );
      return;
    }

    sellerChatTitleController.clear();
    sellerChatMessageController.clear();
    setState(() {});

    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Chat(
        conversation_id: conversationCreateResponse.conversation_id,
        messenger_name: conversationCreateResponse.shop_name,
        messenger_title: conversationCreateResponse.title,
        messenger_image: conversationCreateResponse.shop_logo,
      );
    })).then((value) {
      onPopped(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    SnackBar(
      content: Text(
        'added_to_cart'.tr(context: context),
        style: const TextStyle(color: MyTheme.font_grey),
      ),
      backgroundColor: MyTheme.soft_accent_color,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'show_cart_all_capital'.tr(context: context),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Cart(has_bottomnav: false);
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
          extendBody: true,
          // bottomNavigationBar: buildBottomAppBar(context, _addedToCartSnackbar),
          bottomNavigationBar: _auctionproductDetails != null
              ? Container(
                  padding: const EdgeInsets.only(
                      left: AppDimensions.paddingMedium,
                      right: AppDimensions.paddingMedium,
                      bottom: 10,
                      top: 10),
                  color: MyTheme.white.withValues(alpha: 0.9),
                  child: InkWell(
                    onTap: () {
                      is_logged_in.$
                          ? showAlertDialog(context)
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusHalfSmall),
                        color: Theme.of(context).primaryColor,
                        boxShadow: const [
                          BoxShadow(
                            color: MyTheme.accent_color_shadow,
                            blurRadius: 20,
                            spreadRadius: 0.0,
                            offset: Offset(
                                0.0, 10.0), // shadow direction: bottom right
                          )
                        ],
                      ),
                      height: 50,
                      child: Center(
                        child: Text(
                          (_auctionproductDetails.highestBid == '' ||
                                  _auctionproductDetails.highestBid == null)
                              ? 'place_bid_ucf'.tr(context: context)
                              : 'change_bid_ucf'.tr(context: context),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ))
              : ShimmerHelper().buildBasicShimmer(height: 30.0, width: 60),
          body: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            onRefresh: _onPageRefresh,
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: <Widget>[
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Colors.white.withValues(alpha: opacity),
                  pinned: true,
                  automaticallyImplyLeading: false,
                  //titleSpacing: 0,
                  title: Row(
                    children: [
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () {
                            return Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecorations
                                .buildCircularButtonDecoration_1(),
                            width: 36,
                            height: 36,
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.arrow_left,
                                color: MyTheme.dark_font_grey,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //Show product name in appbar
                      AnimatedOpacity(
                          opacity: _scrollPosition > 350 ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.paddingSmall),
                              width: DeviceInfo(context).width! / 2,
                              child: Text(
                                "${_auctionproductDetails != null ? _auctionproductDetails.name : ''}",
                                style: const TextStyle(
                                    color: MyTheme.dark_font_grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ))),
                      const Spacer(),
                    ],
                  ),
                  expandedHeight: 375.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: buildProductSliderImageSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecorations.buildBoxDecoration_1(),
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 14, right: 14),
                          child: _auctionproductDetails != null
                              ? Text(
                                  _auctionproductDetails.name,
                                  style: TextStyles.smallTitleTexStyle(),
                                  maxLines: 2,
                                )
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 14, right: 14),
                          child: _auctionproductDetails != null
                              ? buildMainPriceRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 14, right: 14),
                          child: _auctionproductDetails != null
                              ? buildBrandRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 50.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: AppDimensions.paddingNormal),
                          child: _auctionproductDetails != null
                              ? buildSellerRow(context)
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 50.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 12, right: 14),
                          child: _auctionproductDetails != null
                              ? buildAuctionWillEndRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        // starting bid
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 12, right: 14),
                          child: _auctionproductDetails != null
                              ? buildAuctionStartingBidRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 12, right: 14, bottom: 14),
                          child: _auctionproductDetails != null
                              ? buildAuctionHighestBidRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: MyTheme.white,
                          margin: const EdgeInsets.only(
                              top: AppDimensions.paddingSupSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  20.0,
                                  16.0,
                                  0.0,
                                ),
                                child: Text(
                                  'description_ucf'.tr(context: context),
                                  style: const TextStyle(
                                      color: MyTheme.dark_font_grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  8.0,
                                  0.0,
                                  8.0,
                                  8.0,
                                ),
                                child: _auctionproductDetails != null
                                    ? buildExpandableDescription()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child:
                                            ShimmerHelper().buildBasicShimmer(
                                          height: 60.0,
                                        )),
                              ),
                            ],
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            if (_auctionproductDetails.videoLink == "") {
                              ToastComponent.showDialog(
                                'video_not_available'.tr(context: context),
                              );
                              return;
                            }

                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return VideoDescription(
                                url: _auctionproductDetails.videoLink,
                              );
                            })).then((value) {
                              onPopped(value);
                            });
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'video_ucf'.tr(context: context),
                                    style: const TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    AppImages.arrow,
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/seller-policy",
                                page_name:
                                    'seller_policy_ucf'.tr(context: context),
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'seller_policy_ucf'.tr(context: context),
                                    style: const TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    AppImages.arrow,
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/return-policy",
                                page_name:
                                    'return_policy_ucf'.tr(context: context),
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'return_policy_ucf'.tr(context: context),
                                    style: const TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    AppImages.arrow,
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/support-policy",
                                page_name:
                                    'support_policy_ucf'.tr(context: context),
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'support_policy_ucf'.tr(context: context),
                                    style: const TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    AppImages.arrow,
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                      ]),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.0,
                        0.0,
                        16.0,
                        0.0,
                      ),
                    ),
                    Container(
                      height: 83,
                    )
                  ]),
                )
              ],
            ),
          )),
    );
  }

  Widget buildSellerRow(BuildContext context) {
    //print("sl:" +  _productDetails.shop_logo);
    return Container(
      color: MyTheme.light_grey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          _auctionproductDetails.addedBy == "admin"
              ? emptyWidget
              : InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SellerDetails(
                                  slug: _auctionproductDetails.shopSlug,
                                )));
                  },
                  child: Padding(
                    padding: app_language_rtl.$!
                        ? const EdgeInsets.only(
                            left: AppDimensions.paddingSmall)
                        : const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusHalfSmall),
                        border: Border.all(
                            color: const Color.fromRGBO(112, 112, 112, .3),
                            width: 1),
                        //shape: BoxShape.rectangle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusHalfSmall),
                        child: FadeInImage.assetNetwork(
                          placeholder: AppImages.placeholder,
                          image: _auctionproductDetails.shopLogo,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
          Container(
            width: MediaQuery.sizeOf(context).width * (.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('seller_ucf'.tr(context: context),
                    style: const TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1),
                    )),
                Text(
                  _auctionproductDetails.shopName,
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          const Spacer(),
          Visibility(
            visible: AppConfig.businessSettingsData.conversationSystem,
            child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingNormal),
                decoration: BoxDecorations.buildCircularButtonDecoration_1(),
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          if (is_logged_in == false) {
                            ToastComponent.showDialog(
                              'you_need_to_log_in'.tr(context: context),
                            );
                            return;
                          }

                          onTapSellerChat();
                        },
                        child: Image.asset(AppImages.chat,
                            height: 16, width: 16, color: MyTheme.dark_grey)),
                  ],
                )),
          )
        ],
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: Text(
        'submit_ucf'.tr(context: context),
        style: const TextStyle(color: MyTheme.white),
      ),
      onPressed: () {
        _bidPriceController.clear();
      },
    );

    // set up the AlertDialog
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'bid_for_product_ucf'.tr(context: context),
                        style: const TextStyle(
                            fontSize: 13, color: MyTheme.dark_font_grey),
                      ),
                      Text(
                        "(${'min_bid_amount_ucf'.tr(context: context)}: ${_auctionproductDetails.minBidPrice})",
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      // todo:: navigator does not pop
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Divider(
                thickness: 1,
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'place_bid_price_ucf'.tr(context: context),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Text(
                    "*",
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _bidPriceController,
                      decoration: InputDecoration(
                        hintText: 'enter_amount_ucf'.tr(context: context),
                        isDense: true,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'please_fill_out_this_form'
                              .tr(context: context);
                        }

                        if (_auctionproductDetails.highestBid != '') {
                          if (double.parse(value) <
                              _auctionproductDetails.minBidPrice.toDouble()) {
                            return 'value_must_be_greater'.tr(context: context);
                          }
                        }
                        if (_auctionproductDetails.highestBid == '') {
                          if (double.parse(value) <
                              _auctionproductDetails.minBidPrice.toDouble()) {
                            return 'value_must_be_greater_or_equal'
                                .tr(context: context);
                          }
                        }

                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text(
                            'submit_ucf'.tr(context: context),
                            style: const TextStyle(color: MyTheme.white),
                          ),
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                            } else {
                              onPressBidPlace();
                              Navigator.pop(context);

                              _bidPriceController.clear();
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          actions: const [
            // cancelButton,
            // submitBtn,
          ],
        );
      },
    );
  }

  Widget buildTotalPriceRow() {
    return Container(
      height: 40,
      color: MyTheme.amber,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            child: Padding(
              padding: app_language_rtl.$!
                  ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                  : const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 75,
                child: Text(
                  'total_price_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1), fontSize: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: AppDimensions.paddingSmallExtra),
            child: Text(
              _auctionproductDetails.currencySymbol.toString(),
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget buildAuctionStartingBidRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$!
              ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
              : const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 95,
            child: Text(
              'starting_bid_ucf'.tr(context: context),
              style: const TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(convertPrice(_auctionproductDetails.startingBid)),
              Text(" /${_auctionproductDetails.unit}"),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAuctionHighestBidRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$!
              ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
              : const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 95,
            child: Text(
              'highest_bid_ucf'.tr(context: context),
              style: const TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _auctionproductDetails.highestBid != ''
              ? Text(convertPrice(_auctionproductDetails.highestBid))
              : const Text(''),
        ),
      ],
    );
  }

  Row buildAuctionWillEndRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$!
              ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
              : const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 95,
            child: Text(
              'auction_will_end'.tr(context: context),
              style: const TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            height: 25,
            width: 200,
            child: CountdownTimer(
              controller: countDownTimercontroller,
              endTime: DateTime.now().day +
                  (1000 * _auctionproductDetails.auctionEndDate as int),
              widgetBuilder: (_, CurrentRemainingTime? time) {
                final List _auctionEndTimeList = [];
                _auctionEndTimeList
                    .addAll([time!.days, time.hours, time.min, time.sec]);

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _auctionEndTimeList.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(":"),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingHalfSmall),
                      child: Text(
                        '${_auctionEndTimeList[index] ?? 00}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSmallExtra)),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Padding buildVariantShimmers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        0.0,
        8.0,
        0.0,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row buildMainPriceRow() {
    return const Row(
      children: [],
    );
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
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
        height: kToolbarHeight +
            statusBarHeight -
            (MediaQuery.viewPaddingOf(context).top > 40 ? 32.0 : 16.0),
        //MediaQuery.viewPaddingOf(context).top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
        child: Container(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingLarge),
              child: Text(
                _appbarPriceString,
                style: const TextStyle(fontSize: 16, color: MyTheme.font_grey),
              ),
            )),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: MyTheme.dark_grey),
            onPressed: () {
              onPressShare(context);
            },
          ),
        ),
      ],
    );
  }

  Widget? buildBrandRow() {
    return (_auctionproductDetails.brand?.id != null &&
            _auctionproductDetails.brand!.id! > 0)
        ? InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BrandProducts(
                  slug: _auctionproductDetails.brand!.slug!,
                );
              }));
            },
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: 75,
                    child: Text(
                      'brand_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: Color.fromRGBO(153, 153, 153, 1),
                          fontSize: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    _auctionproductDetails.brand!.name ?? '',
                    style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ),
              ],
            ),
          )
        : emptyWidget;
  }

  ExpandableNotifier buildExpandableDescription() {
    return ExpandableNotifier(
        child: ScrollOnExpand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expandable(
            collapsed: Container(
                height: 50,
                child: Html(data: _auctionproductDetails.description)),
            expanded: Container(
                child: Html(data: _auctionproductDetails.description)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Builder(
                builder: (context) {
                  final controller = ExpandableController.of(context)!;
                  return Btn.basic(
                    child: Text(
                      !controller.expanded
                          ? 'view_more'.tr(context: context)
                          : 'show_less_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: MyTheme.font_grey, fontSize: 11),
                    ),
                    onPressed: () {
                      controller.toggle();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ));
  }

  void openPhotoDialog(BuildContext context, path) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                child: Stack(
              children: [
                PhotoView(
                  enableRotation: true,
                  heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
                  imageProvider: NetworkImage(path),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: const ShapeDecoration(
                      color: MyTheme.medium_grey_50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppDimensions.radius),
                          bottomRight: Radius.circular(AppDimensions.radius),
                          topRight: Radius.circular(AppDimensions.radius),
                          topLeft: Radius.circular(AppDimensions.radius),
                        ),
                      ),
                    ),
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: const Icon(Icons.clear, color: MyTheme.white),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                ),
              ],
            )),
          );
        },
      );

  Row buildProductImageSection() {
    if (_productImageList.isEmpty) {
      return Row(
        children: [
          Container(
            width: 40,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSupSmall),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSupSmall),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSupSmall),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSupSmall),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: ShimmerHelper().buildBasicShimmer(
                height: 190.0,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            width: 64,
            child: Scrollbar(
              controller: _imageScrollController,
              // isAlwaysShown: false,
              thickness: 4.0,
              child: Padding(
                padding: app_language_rtl.$!
                    ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                    : const EdgeInsets.only(right: 8.0),
                child: ListView.builder(
                    itemCount: _productImageList.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final int itemIndex = index;
                      return GestureDetector(
                        onTap: () {
                          _currentImage = itemIndex;
                          // print(_currentImage);
                          setState(() {});
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusNormal),
                            border: Border.all(
                                color: _currentImage == itemIndex
                                    ? Theme.of(context).primaryColor
                                    : const Color.fromRGBO(112, 112, 112, .3),
                                width: _currentImage == itemIndex ? 2 : 1),
                            //shape: BoxShape.rectangle,
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusNormal),
                              child:
                                  /*Image.asset(
                                        singleProduct.product_images[index])*/
                                  FadeInImage.assetNetwork(
                                placeholder: AppImages.placeholder,
                                image: _productImageList[index],
                                fit: BoxFit.contain,
                              )),
                        ),
                      );
                    }),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              openPhotoDialog(context, _productImageList[_currentImage]);
            },
            child: Container(
              height: 250,
              width: MediaQuery.sizeOf(context).width - 96,
              child: Container(
                  child: FadeInImage.assetNetwork(
                placeholder: AppImages.placeholderRectangle,
                image: _productImageList[_currentImage],
                fit: BoxFit.scaleDown,
              )),
            ),
          ),
        ],
      );
    }
  }

  Widget buildProductSliderImageSection() {
    if (_productImageList.isEmpty) {
      return ShimmerHelper().buildBasicShimmer(
        height: 190.0,
      );
    } else {
      return CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
            aspectRatio: 355 / 375,
            viewportFraction: 1,
            initialPage: 0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInExpo,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              print(index);
              setState(() {
                _currentImage = index;
              });
            }),
        items: _productImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        openPhotoDialog(
                            context, _productImageList[_currentImage]);
                      },
                      child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: FadeInImage.assetNetwork(
                            placeholder: AppImages.placeholderRectangle,
                            image: i,
                            fit: BoxFit.fitHeight,
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              _productImageList.length,
                              (index) => Container(
                                    width: 7.0,
                                    height: 7.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImage == index
                                          ? MyTheme.font_grey
                                          : Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ))),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    }
  }

  Widget divider() {
    return Container(
      color: MyTheme.light_grey,
      height: 5,
    );
  }
}

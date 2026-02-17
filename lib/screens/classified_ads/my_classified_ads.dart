import 'package:active_ecommerce_cms_demo_app/custom/common_functions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/classified_ads_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/user_info_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/classified_product_details.dart';
import 'package:active_ecommerce_cms_demo_app/screens/package/packages.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../../app_config.dart';
import '../../repositories/classified_product_repository.dart';
import 'classified_product_add.dart';
import 'classified_product_edit.dart';

class MyClassifiedAds extends StatefulWidget {
  final bool fromBottomBar;

  const MyClassifiedAds({Key? key, this.fromBottomBar = false})
      : super(key: key);

  @override
  _MyClassifiedAdsState createState() => _MyClassifiedAdsState();
}

class _MyClassifiedAdsState extends State<MyClassifiedAds> {
  bool _isProductInit = false;
  bool _showMoreProductLoadingContainer = false;

  List<ClassifiedAdsMiniData> _productList = [];
  UserInformation? _userInfo = null;

  // List<bool> _productStatus=[];
  // List<bool> _productFeatured=[];

  String _remainingProduct = "40";
  String? _currentPackageName = "...";
  late BuildContext? loadingContext;
  late BuildContext switchContext;
  BuildContext? featuredSwitchContext;

  //MenuOptions _menuOptionSelected = MenuOptions.Published;

  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0);

  // double variables
  double mHeight = 0.0, mWidht = 0.0;
  int _page = 1;

  getProductList() async {
    final productResponse = await ClassifiedProductRepository()
        .getOwnClassifiedProducts(page: _page);
    if (productResponse.data!.isEmpty) {
      ToastComponent.showDialog(
        'no_more_products_ucf'.tr(context: context),
      );
    }
    _productList.addAll(productResponse.data!);
    _showMoreProductLoadingContainer = false;
    _isProductInit = true;
    setState(() {});
  }

  getUserInfo() async {
    final userInfoRes = await ProfileRepository().getUserInfoResponse();
    if (userInfoRes.data?.isNotEmpty == true) {
      _userInfo = userInfoRes.data!.first;
      _remainingProduct = _userInfo!.remainingUploads.toString();
      _currentPackageName = _userInfo!.packageName;
    }

    setState(() {});
  }

  deleteProduct(int? id) async {
    loading();
    final response = await ClassifiedProductRepository()
        .getDeleteClassifiedProductResponse(id);
    Navigator.pop(loadingContext!);
    if (response.result) {
      resetAll();
    }
    ToastComponent.showDialog(
      response.message,
    );
  }

  productStatusChange(int? index, bool value, setState, id) async {
    loading();
    final response = await ClassifiedProductRepository()
        .getStatusChangeClassifiedProductResponse(id, value ? 1 : 0);
    Navigator.pop(loadingContext!);
    if (response.result) {
      _productList[index!].status = value;
      resetAll();
    }
    Navigator.pop(switchContext);
    ToastComponent.showDialog(
      response.message,
    );
  }

  scrollControllerPosition() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _showMoreProductLoadingContainer = true;
        setState(() {
          _page++;
        });
        getProductList();
      }
    });
  }

  cleanAll() {
    // print("clean all");
    _isProductInit = false;
    _showMoreProductLoadingContainer = false;
    _productList = [];
    _page = 1;
    _remainingProduct = "....";
    _currentPackageName = "...";
    setState(() {});
  }

  fetchAll() {
    getProductList();
    getUserInfo();
  }

  resetAll() {
    cleanAll();
    fetchAll();
  }

  _tabOption(int index, productId, listIndex) async {
    print(index);
    switch (index) {
      case 0:
        showChangeStatusDialog(listIndex, productId);
        break;
      case 1:
        showDeleteWarningDialog(productId);
        break;
      case 2:
        final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ClassifiedProductEdit(productId: productId)));

        if (result == true) {
          setState(() {
            resetAll();
          });
        }
        break;

      default:
        break;
    }
  }

  void dismissLoading() {
    // Only pop if loadingContext has been set
    if (loadingContext != null) {
      Navigator.of(loadingContext!).pop();
      loadingContext = null; // Reset to prevent reuse
    }
  }

  @override
  void initState() {
    scrollControllerPosition();
    fetchAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mHeight = MediaQuery.sizeOf(context).height;
    mWidht = MediaQuery.sizeOf(context).width;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          elevation: 0,
          title: Text(
            'my_products_ucf'.tr(context: context),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyTheme.dark_font_grey),
          ),
          backgroundColor: MyTheme.mainColor,
          leading: UsefulElements.backButton(),
        ),
        backgroundColor: MyTheme.mainColor,
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        resetAll();
        // Future.delayed(Duration(seconds: 1));
      },
      child: Container(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          child: Column(
            children: [
              buildTop2BoxContainer(context),
              const SizedBox(
                height: 16,
              ),
              Visibility(
                  visible: AppConfig.businessSettingsData.classifiedProduct,
                  child: buildPackageUpgradeContainer(context)),
              const SizedBox(
                height: 15,
              ),
              Container(
                child: _isProductInit
                    ? productsContainer()
                    : ShimmerHelper()
                        .buildListShimmer(item_count: 20, item_height: 80.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPackageUpgradeContainer(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              height: 40,
              width: DeviceInfo(context).width,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusHalfSmall),
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 1),
                color: const Color(0xffFBEAE6),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UpdatePackage()))
                      .then((value) {
                    resetAll();
                  });
                  //  MyTransaction(context: context).push(Packages());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppImages.package,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'current_package_ucf'.tr(context: context),
                          style: const TextStyle(
                              fontSize: 10, color: MyTheme.grey_153),
                        ),
                        const SizedBox(
                          width: 11,
                        ),
                        Text(
                          _currentPackageName!,
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'upgrade_package_ucf'.tr(context: context),
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Image.asset(AppImages.nextArrow,
                            color: Theme.of(context).primaryColor,
                            height: 9.08,
                            width: 7),
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  Container buildTop2BoxContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusHalfSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    spreadRadius: 0.5,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
                color: Theme.of(context).primaryColor,
              ),
              height: 75,
              width: mWidht / 2 - 23,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'remaining_uploads'.tr(context: context),
                      style: CommonFunctions.dashboardBoxText(context),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      _remainingProduct,
                      style: CommonFunctions.dashboardBoxNumber(context),
                    ),
                  ],
                ),
              )),
          // if(false)
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              if (int.parse(_remainingProduct) == 0) {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UpdatePackage()))
                    .then((value) {
                  resetAll();
                });

                ToastComponent.showDialog(
                  'classified_product_limit_expired'.tr(context: context),
                );
              } else {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClassifiedProductAdd()))
                    .then((value) => resetAll());
              }
            },
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusHalfSmall),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        spreadRadius: 0.5,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                    color: const Color(0xffFEF0D7),
                    border:
                        Border.all(color: const Color(0xffFFA800), width: 1)),
                height: 75,
                width: mWidht / 2 - 23,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'add_new_products_ucf'.tr(context: context),
                        style: CommonFunctions.dashboardBoxText(context)
                            .copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Image.asset(AppImages.add,
                          color: Theme.of(context).primaryColor,
                          height: 18,
                          width: 18),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget productsContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'all_products_ucf'.tr(context: context),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor),
          ),
          const SizedBox(
            height: 10,
          ),
          ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(
                    height: 20,
                  ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _productList.length + 1,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // print(index);
                if (index == _productList.length) {
                  return moreProductLoading();
                }
                return productItem(
                    index: index,
                    productId: _productList[index].id,
                    imageUrl: _productList[index].thumbnailImage,
                    slug: _productList[index].slug,
                    productTitle: _productList[index].name!,
                    productPrice: _productList[index].unitPrice,
                    condition: _productList[index].condition.toString());
              }),
        ],
      ),
    );
  }

  Widget productItem(
      {int? index,
      productId,
      String? slug,
      String? imageUrl,
      required String productTitle,
      String? productPrice,
      String? condition}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassifiedAdsDetails(slug: slug ?? ''),
          ),
        );
      },
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                //   spreadRadius: 0.5,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  UsefulElements.roundImageWithPlaceholder(
                    width: 88.0,
                    height: 80.0,
                    fit: BoxFit.cover,
                    url: imageUrl,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusSmallExtra),
                      bottomLeft:
                          Radius.circular(AppDimensions.radiusSmallExtra),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: mWidht - 129,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    textAlign: TextAlign.start,
                                    productTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xff3E4447),
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: showOptions(
                                    listIndex: index, productId: productId),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: true,
                child: Positioned.fill(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: condition == "new"
                            ? MyTheme.golden
                            : Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft:
                              Radius.circular(AppDimensions.radiusHalfSmall),
                          bottomRight:
                              Radius.circular(AppDimensions.radiusHalfSmall),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            offset: Offset(-1, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        condition ?? "",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xffffffff),
                          fontWeight: FontWeight.w700,
                          height: 1.8,
                        ),
                        textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false),
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  showDeleteWarningDialog(id) {
    showDialog(
      context: context,
      builder: (context) => Container(
        width: DeviceInfo(context).width! * 1.5,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
          title: Text(
            'do_you_want_to_delete_it'.tr(context: context),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
          ),
          content: const Text(
            'Are you sure you want to delete this product?',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          ),
          actions: [
            TextButton(
              child: Text('cancel_ucf'.tr(context: context)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteProduct(id);
                },
                child: Text('yes_ucf'.tr(context: context)))
          ],
        ),
      ),
    );
  }

  Widget showOptions({listIndex, productId}) {
    return Container(
      width: 35,
      child: PopupMenuButton<MenuOptions>(
        color: Colors.white,
        offset: const Offset(-12, 0),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Container(
            width: 35,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.topRight,
            child: Image.asset(AppImages.more,
                width: 3,
                height: 15,
                fit: BoxFit.contain,
                color: MyTheme.grey_153),
          ),
        ),
        onSelected: (MenuOptions result) {
          _tabOption(result.index, productId, listIndex);
          // setState(() {
          //   _menuOptionSelected = result;
          // });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Edit,
            child: Text('edit_ucf'.tr(context: context)),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Status,
            child: Text('status_ucf'.tr(context: context)),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Delete,
            child: Text('delete_ucf'.tr(context: context)),
          ),
        ],
      ),
    );
  }

  void showChangeStatusDialog(int? index, id) {
    showDialog(
      context: context,
      builder: (context) {
        switchContext = context;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall),
            ),
            content: Container(
              height: 40,
              width: DeviceInfo(context).width,
              child: Center(
                // Centering the content
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _productList[index!].status!
                          ? 'published_ucf'.tr(context: context)
                          : 'unpublished_ucf'.tr(context: context),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Transform.scale(
                      scale:
                          0.8, // Adjust this value to decrease the size (0.8 means 80% of the original size)
                      child: Switch(
                        value: _productList[index].status!,
                        activeColor: Colors.green,
                        activeTrackColor: const Color(0xffE9E9F0),
                        inactiveThumbColor: MyTheme.grey_153,
                        onChanged: (value) {
                          productStatusChange(index, value, setState, id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void showFeaturedUnFeaturedDialog(int index, id) {
    //print(_productFeatured[index]);
    print(index);
    showDialog(
        context: context,
        builder: (context) {
          featuredSwitchContext = context;
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              height: 75,
              width: DeviceInfo(context).width,
              child: AlertDialog(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _productList[index].published!
                          ? 'published_ucf'.tr(context: context)
                          : 'unpublished_ucf'.tr(context: context),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    Switch(
                      value: _productList[index].published!,
                      activeColor: Colors.green,
                      inactiveThumbColor: MyTheme.grey_153,
                      onChanged: (value) {
                        // productFeaturedChange(
                        //     index: index,
                        //     value: value,
                        //     setState: setState,
                        //     id: id);
                      },
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingContext = context;
          return AlertDialog(
              content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                width: 10,
              ),
              Text('loading_ucf'.tr(context: context)),
            ],
          ));
        });
  }

  Widget moreProductLoading() {
    return _showMoreProductLoadingContainer
        ? Container(
            alignment: Alignment.center,
            child: const SizedBox(
              height: 40,
              width: 40,
              child: Row(
                children: [
                  SizedBox(
                    width: 2,
                    height: 2,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          )
        : const SizedBox(
            height: 5,
            width: 5,
          );
  }
}

enum MenuOptions { Status, Delete, Edit }

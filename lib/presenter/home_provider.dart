import 'dart:async';
import 'dart:math';
import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/brand_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/product_mini_response.dart'
    as productMini;
import 'package:active_ecommerce_cms_demo_app/data_model/slider_response.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auction_products_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/brand_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/category_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/flash_deal_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/sliders_repository.dart';
import 'package:active_ecommerce_cms_demo_app/single_banner/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import '../custom/toast_component.dart';
import '../data_model/address_response.dart';
import '../data_model/category_response.dart';
import '../data_model/popup_banner_model.dart';
import '../data_model/today_deal_response.dart';
import '../helpers/shared_value_helper.dart';
import '../repositories/address_repository.dart';
import '../screens/address.dart';
import '../status/execute_and_handle_remote_errors.dart';
import '../status/status.dart';
import '../ui_elements/pop_up_banner.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import 'cart_provider.dart';
import 'prescription_controller.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(Address? address) {
    defaultAddress = address;
  }
  CurrentRemainingTime flashDealRemainingTime =
      const CurrentRemainingTime(days: 0, hours: 0, min: 0, sec: 0);
  FlashDealResponseDatum? flashDeal;

  final PrescriptionController presc = PrescriptionController();


  Timer? _flashDealTimer;
  DateTime? _flashDealEndTime;

  Address? defaultAddress;
  bool isLoadingAddress = false;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int current_slider = 0;
  // ScrollController? featuredCategoryScrollController;
  // ScrollController mainScrollController = ScrollController();

  // late AnimationController pirated_logo_controller;
  // late Animation pirated_logo_animation;

  List<AIZSlider> carouselImageList = [];
  List<AIZSlider> bannerOneImageList = [];
  List<AIZSlider> bannerTwoImageList = [];
  List<AIZSlider> bannerThreeImageList = [];
  List<AIZSlider> bannerFourImageList = [];
  List<AIZSlider> bannerFiveImageList = [];
  List<AIZSlider> flashDealBannerImageList = [];
  List<AIZSlider> todayDealBannerImageList = [];
  List<FlashDealResponseDatum> _banners = [];
  List<FlashDealResponseDatum> get banners => [..._banners];
  List<productMini.Product> bestSellingProductList = [];
  List<productMini.Product> discountedProductList = [];

  List<productMini.Product> auctionProductList = [];
  List<Brands> brandsList = [];
  List<productMini.Product> TodayDealList = [];

  final List<SingleBanner> _singleBanner = [];
  List<SingleBanner> get singleBanner => _singleBanner;

  List<Category> featuredCategoryList = [];

  bool isCategoryInitial = true;
  bool isCarouselInitial = true;
  bool isBannerOneInitial = true;
  bool isBannerTwoInitial = true;
  bool isBannerThreeInitial = true;
  bool isBannerFourInitial = true;
  bool isBannerFiveInitial = true;
  bool isFlashDealInitial = true;
  bool isBannerFlashDeal = true;
  bool isBrandsInitial = true;
  bool isTodayDwal = true;

  bool isBestSellingProductInitial = true;
  bool isDiscountedProductInitial = true;
  int totalBestSellingProductData = 0;
  int totalDiscountedProductData = 0;
  bool showBestSellingLoadingContainer = false;
  bool showDiscountedLoadingContainer=false;
  bool isTodayDealBannerInitial = true;
  bool isauctionProductInitial = true;
  int? totalauctionProductData;
  int bestauctionroductPage = 1;
  bool showauctionLoadingContainer = false;

  bool isTodayDealInitial = true;
  int? totalatodayDealData;
  int todayDealPage = 1;
  bool showTodayDealContainer = false;

  List<productMini.Product> featuredProductList = [];
  bool isFeaturedProductInitial = true;
  int totalFeaturedProductData = 0;
  int featuredProductPage = 1;
  bool showFeaturedLoadingContainer = false;
  int totalCategoryProductData = 0;
  int totalAllBrandsData = 0;

  bool isTodayDeal = false;
  bool isFlashDeal = false;

  bool isBrands = false;

  final List<productMini.Product> allProductList = [];
  bool isAllProductInitial = true;
  int totalAllProductData = 0;
  int allProductPage = 1;
  bool showAllLoadingContainer = false;
  int cartCount = 0;

  Future<void> fetchAll([bool isRefresh = false]) async {
    final BuildContext context = OneContext().context!;
    await Future.wait([
      fetchAddressLists(isRefresh),
      fetchCarouselImages(),
      fetchBannerOneImages(),
      fetchBannerTwoImages(),
      fetchBannerThreeImags(),
      fetchFeaturedCategories(),
      fetchFeaturedProducts(),
      fetchAllProducts(),
      fetchTodayDealData(),
      fetchFlashDealData(),
      fetchBannerFlashDeal(),
      fetchFlashDealBannerImages(),
      fetchBrands(),
      fetchBestSellingProducts(),
      fetchAuctionProducts(),
      fetchBrandsProducts(),
      fetchTodayDealProducts(),
      fetchTodayDealBannerImages(),
      fetchDiscountProducts(),
      fetchBannerFourImags(),
      fetchBannerFiveImags(),

      Provider.of<CartProvider>(context, listen: false).fetchData(context),
    ]);
  }

  Future<void> fetchBrands() async {
    final BrandResponse value = await BrandRepository().getBrands();
    isBrands = !value.noBrandsAvailable;
    notifyListeners();
  }

  Future<void> fetchBannerFlashDeal() async {
    final banners = await SlidersRepository().fetchBanners();
    _banners = banners;
    notifyListeners();
  }

  Future<void> fetchTodayDealData() async {
    productMini.ProductMiniResponse? deal;
    await executeAndHandleErrors(
        () async => deal = await ProductRepository().getTodaysDealProducts(paginate: ""));

    // print(deal.products!.length);
    // if (deal.success! && deal.products!.isNotEmpty) {
    //   isTodayDeal = true;
    //   notifyListeners();
    // }
    if (deal?.success == true &&
        deal?.products != null &&
        deal?.products?.isNotEmpty == true) {
      isTodayDeal = true;
      notifyListeners();
    } else {
      isTodayDeal = false;
    }
  }

  Future<void> fetchFlashDealData() async {
    FlashDealResponse? deal;
    await executeAndHandleErrors(
        () async => deal = await FlashDealRepository().getFlashDeals());

    if (deal?.success == true &&
        deal?.flashDeals != null &&
        deal?.flashDeals!.isNotEmpty == true) {
      isFlashDeal = true;
      _banners.clear();
      _banners.addAll(deal?.flashDeals ?? []);
      FlashDealResponseDatum? tempFlashDeal;
      for (FlashDealResponseDatum e in deal!.flashDeals!) {
        if (e.isFeatured) {
          tempFlashDeal = e;
          break;
        }
      }
      flashDeal = tempFlashDeal;

      if (flashDeal?.date != null) {
        final DateTime end =
            DateTime.fromMillisecondsSinceEpoch(flashDeal!.date! * 1000);
        final DateTime now = DateTime.now();
        final int diff = end.difference(now).inMilliseconds;
        final int endTime = diff + now.millisecondsSinceEpoch;
        startFlashDealCountdown(endTime);
      }

      notifyListeners();
    } else {
      isFlashDeal = false;
    }
  }

  void startFlashDealCountdown(
    int endTime,
  ) {
    _flashDealEndTime = DateTime.fromMillisecondsSinceEpoch(endTime);

    _flashDealTimer?.cancel();
    _flashDealTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final remaining = _flashDealEndTime!.difference(now);

      if (remaining.isNegative) {
        _flashDealTimer?.cancel();
        flashDealRemainingTime =
            const CurrentRemainingTime(days: 0, hours: 0, min: 0, sec: 0);
        isFlashDeal = false;
        notifyListeners();
        return;
      }

      flashDealRemainingTime = CurrentRemainingTime(
        days: remaining.inDays,
        hours: remaining.inHours % 24,
        min: remaining.inMinutes % 60,
        sec: remaining.inSeconds % 60,
      );

      notifyListeners();
    });
    //   // flashDealRemainingTime = CurrentRemainingTime(
    //   //   days: remaining.inDays,
    //   //   hours: remaining.inHours % 24,
    //   //   min: remaining.inMinutes % 60,
    //   //   sec: remaining.inSeconds % 60,
    //   // );
    // }
    notifyListeners();
  }

  bool get haveToGoAddress => shouldHaveAddress && defaultAddress == null;

  void logOutAddress([bool forceRemove = false]) {
    if (!(is_logged_in.$ || forceRemove)) return;
    defaultAddress = null;
    notifyListeners();
  }

  Future<void> fetchAddressLists(
    bool isRefresh, [
    bool navigateToAddress = true,
  ]) async {
    if (!shouldHaveAddress) return;

    if (!isRefresh) {
      isLoadingAddress = true;
      notifyListeners();
    }
    final AddressResponse? addressResponse =
        await handleErrorsWithMessage(AddressRepository().getAddressList);
    if (addressResponse != null) {
      if (addressResponse.addresses?.isNotEmpty != true) {
        defaultAddress = null;
        _handleAddressNavigationWithToast(navigateToAddress);
        return;
      }
      for (Address a in addressResponse.addresses!) {
        if (a.set_default == 1) {
          defaultAddress = a;
          break;
        }
      }
      if (defaultAddress == null) {
        final Address temp = addressResponse.addresses!.first;
        final addressMakeDefaultResponse =
            await AddressRepository().getAddressMakeDefaultResponse(temp.id);

        if (addressMakeDefaultResponse.result == false) {
          _handleAddressNavigationWithToast(navigateToAddress);
          return;
        }
        defaultAddress = temp;
      }
      isLoadingAddress = false;
      notifyListeners();
    }
  }

  bool needHandleAddressNavigation() {
    return _handleAddressNavigationWithToast(haveToGoAddress, true);
  }

  bool _handleAddressNavigationWithToast([
    bool navigateToAddress = true,
    bool goHome = false,
  ]) {
    if (!navigateToAddress) return false;
    ToastComponent.showDialog(
      'add_default_address'.tr(),
      isError: true,
    );
    handleAddressNavigation(goHome);
    return true;
  }

  Future<T?> handleAddressNavigation<T>(bool goHome) async {
    return Navigator.push<T?>(
      OneContext().context!,
      MaterialPageRoute(builder: (_) => AddressScreen(goHome: goHome)),
    ).then(
      (value) {
        reset();
        fetchAll(true);
        return value;
      },
    );
  }

  Future<void> fetchCarouselImages() async {
    SliderResponse? carouselResponse;
    await executeAndHandleErrors(
        () async => carouselResponse = await SlidersRepository().getSliders());

    carouselImageList.clear();
    carouselImageList.addAll(carouselResponse?.sliders ?? []);
    isCarouselInitial = false;

    notifyListeners();
  }

  Future<void> fetchBestSellingProducts() async {
    if (showBestSellingLoadingContainer) return;

    showBestSellingLoadingContainer = true;
    productMini.ProductMiniResponse? bestselling;
    await executeAndHandleErrors(() async =>
        bestselling = await ProductRepository().getBestSellingProducts(paginate: 10));
    bestSellingProductList.clear();
    bestSellingProductList.addAll(bestselling?.products ?? []);
    showBestSellingLoadingContainer = false;
    isBestSellingProductInitial = false;

    notifyListeners();
  }

   Future<void> fetchDiscountProducts() async {
    if (showDiscountedLoadingContainer) return;

    showDiscountedLoadingContainer = true;
    productMini.ProductMiniResponse? discountproducts;
    await executeAndHandleErrors(() async =>
        discountproducts = await ProductRepository().getDiscountProducts(paginate: 10));
    discountedProductList.clear();
    discountedProductList.addAll(discountproducts?.products ?? []);
    showDiscountedLoadingContainer = false;
    isDiscountedProductInitial = false;

    notifyListeners();
  }

  Future<void> fetchAuctionProducts() async {
    productMini.ProductMiniResponse? auction;
    await executeAndHandleErrors(() async => auction =
        await AuctionProductsRepository().getAuctionProducts(page: 1));

    auctionProductList.clear();
    auctionProductList.addAll(auction?.products ?? []);

    isauctionProductInitial = false;
    notifyListeners();
  }

  Future<void> fetchBrandsProducts() async {
    BrandResponse? brandsRes;
    await executeAndHandleErrors(
        () async => brandsRes = await BrandRepository().getBrands());

    brandsList.clear();
    if (brandsRes?.brands != null) {
      brandsList.addAll(brandsRes?.brands ?? []);
    }

    if (brandsRes?.brands != null) {
      totalAllBrandsData = brandsRes?.meta?.total ?? 0;
    }
    showAllLoadingContainer = false;

    isBrandsInitial = false;

    notifyListeners();
  }

  Future<void> fetchTodayDealProducts() async {
    productMini.ProductMiniResponse? deals;
    await executeAndHandleErrors(
        () async => deals = await ProductRepository().getTodaysDealProducts(paginate: 10));
    TodayDealList.clear();
    TodayDealList.addAll(deals?.products ?? []);
    isTodayDealInitial = false;
    notifyListeners();
  }

  Future<void> showPopupBanner([BuildContext? cntx]) async {
    final BuildContext? context = cntx ?? OneContext().context;
    if (context == null ||
        GoRouter.of(context).state.path != "/" ||
        _isOpenedBefore ||
        haveToGoAddress) return;
    _isOpenedBefore = true;

    final Status<List<PopupBannerModel>> bannersStatus =
        await executeAndHandleErrors(
            () => SlidersRepository().fetchBannerPopupData());

    if (bannersStatus is Success<List<PopupBannerModel>>) {
      final List<PopupBannerModel> banners =
          List.unmodifiable(bannersStatus.data);
      if (banners.isNotEmpty) {
        await lastIndexPopupBanner.load();
        int index = lastIndexPopupBanner.$ + 1;
        if (index >= banners.length) index = 0;

        lastIndexPopupBanner.$ = index;
        lastIndexPopupBanner.save();

        showDialog(
          context: context,
          builder: (context) =>
              PopupBannerDialog(popupBannerModel: banners[index]),
        );
      }
    }
  }

  Future<void> fetchBannerOneImages() async {
    SliderResponse? bannerOneResponse;
    await executeAndHandleErrors(() async =>
        bannerOneResponse = await SlidersRepository().getBannerOneImages());

    bannerOneImageList.clear();
    bannerOneImageList.addAll(bannerOneResponse?.sliders ?? []);

    isBannerOneInitial = false;
    notifyListeners();
  }

  Future<void> fetchFlashDealBannerImages() async {
    SliderResponse? flashDealBannerResponse;
    await executeAndHandleErrors(() async => flashDealBannerResponse =
        await SlidersRepository().getFlashDealBanner());

    flashDealBannerImageList.clear();
    flashDealBannerImageList.addAll(flashDealBannerResponse?.sliders ?? []);
    isFlashDealInitial = false;
    notifyListeners();
  }
    Future<void> fetchTodayDealBannerImages() async {
    TodaysDealBannerResponse? todayDealBannerResponse;
    await executeAndHandleErrors(() async => todayDealBannerResponse =
        await SlidersRepository().getTodaysDealBanner());
    todayDealBannerImageList.clear();
    if (todayDealBannerResponse != null &&
        todayDealBannerResponse!.todaysDealBannerSmall != null) {
      todayDealBannerImageList.add(AIZSlider(
        photo: todayDealBannerResponse!.todaysDealBannerSmall, 
      ));
    }
    isTodayDealBannerInitial = false;
    notifyListeners();
  }

  Future<void> fetchBannerTwoImages() async {
    SliderResponse? bannerTwoResponse;
    await executeAndHandleErrors(() async =>
        bannerTwoResponse = await SlidersRepository().getBannerTwoImages());

    bannerTwoImageList.clear();
    bannerTwoImageList.addAll(bannerTwoResponse?.sliders ?? []);
    isBannerTwoInitial = false;

    notifyListeners();
  }

  Future<void> fetchBannerThreeImags() async {
    SliderResponse? bannerThreeResponse;
    await executeAndHandleErrors(() async =>
        bannerThreeResponse = await SlidersRepository().getBannerThreeImages());
    bannerThreeImageList.clear();
    bannerThreeImageList.addAll(bannerThreeResponse?.sliders ?? []);
    isBannerThreeInitial = false;

    notifyListeners();
  }
 Future<void> fetchBannerFourImags() async {
    SliderResponse? bannerFourResponse;
    await executeAndHandleErrors(() async =>
        bannerFourResponse = await SlidersRepository().getBannerFourImages());
    bannerFourImageList.clear();
    bannerFourImageList.addAll(bannerFourResponse?.sliders ?? []);
    isBannerFourInitial = false;

    notifyListeners();
  }
   Future<void> fetchBannerFiveImags() async {
    SliderResponse? bannerFiveResponse;
    await executeAndHandleErrors(() async =>
        bannerFiveResponse = await SlidersRepository().getBannerFiveImages());
    bannerFiveImageList.clear();
    bannerFiveImageList.addAll(bannerFiveResponse?.sliders ?? []);
    isBannerFiveInitial = false;

    notifyListeners();
  }
  Future<void> fetchFeaturedCategories() async {
    CategoryResponse? categoryResponse;
    await executeAndHandleErrors(() async =>
        categoryResponse = await CategoryRepository().getFeturedCategories());
    featuredCategoryList.clear();
    featuredCategoryList.addAll(categoryResponse?.categories ?? []);
    isCategoryInitial = false;

    notifyListeners();
  }


  Future<void> fetchFeaturedProducts() async {
    if (showFeaturedLoadingContainer) return;

    showFeaturedLoadingContainer = true;
    productMini.ProductMiniResponse? productResponse;
    await executeAndHandleErrors(() async =>
        productResponse = await ProductRepository().getFeaturedProducts(
          // page: featuredProductPage,
          paginate: 10,
        ));

    featuredProductPage++;

    if (productResponse?.products != null) {
      featuredProductList.addAll(productResponse?.products ?? []);
    }

    isFeaturedProductInitial = false;

    if (productResponse?.meta != null) {
      totalFeaturedProductData =
          productResponse?.meta!.total ?? featuredProductList.length;
    }

    showFeaturedLoadingContainer = false;
    notifyListeners();
  }

  Future<void> fetchAllProducts() async {
    productMini.ProductMiniResponse? productResponse;
    await executeAndHandleErrors(() async => productResponse =
        await ProductRepository().getFilteredProducts(page: allProductPage));

    if (productResponse?.products != null) {
      allProductList.addAll(List.of(productResponse?.products ?? []));
    }
    isAllProductInitial = false;
    totalAllProductData = productResponse?.meta?.total ?? allProductList.length;

    showAllLoadingContainer = false;

    notifyListeners();

    if (productResponse?.meta?.total == null && AppConfig.isDebugMode) {
      print(
          "There is Error here total products from endpoint not work correctly");
      throw "There is Error here total products from endpoint not work correctly";
    }
  }

  resetBestSellingProducts() {
    bestSellingProductList.clear();
    isBestSellingProductInitial = true;
    totalBestSellingProductData = 0;
    showBestSellingLoadingContainer = false;
  }
  resetDiscountedProducts() {
    discountedProductList.clear();
    isDiscountedProductInitial = true;
    totalDiscountedProductData = 0;
    showDiscountedLoadingContainer = false;
  }

  resetAuctionProducts() {
    auctionProductList.clear();
    isauctionProductInitial = true;
    bestauctionroductPage = 1;
    totalauctionProductData = 0;
    showauctionLoadingContainer = false;
  }

  resetTodayDeals() {
    TodayDealList.clear();
    isTodayDealInitial = true;
    todayDealPage = 1;
    totalatodayDealData = 0;
    showTodayDealContainer = false;
  }

  void reset([bool isRefresh = false]) {
    if (!isRefresh) {
      carouselImageList.clear();
      bannerOneImageList.clear();
      bannerTwoImageList.clear();
      bannerThreeImageList.clear();
      bannerFourImageList.clear();
      bannerFiveImageList.clear();
      featuredCategoryList.clear();

      isCarouselInitial = true;
      isBannerOneInitial = true;
      isBannerTwoInitial = true;
      isBannerThreeInitial = true;
      isBannerFourInitial = true;
      isBannerFiveInitial = true;
      isCategoryInitial = true;
      isFeaturedProductInitial = true;
      isAllProductInitial = true;
    }

    cartCount = 0;

    resetFeaturedProductList();
    resetAllProductList();
    flashDealBannerImageList.clear();
    resetBestSellingProducts();
    resetDiscountedProducts();
    resetAuctionProducts();
    resetTodayDeals();
  }

  Future<void> onRefresh([bool isRefresh = true]) async {
    reset(isRefresh);
    await fetchAll(isRefresh);
  }

  void resetFeaturedProductList() {
    featuredProductList.clear();
    isFeaturedProductInitial = true;
    totalFeaturedProductData = 0;
    featuredProductPage = 1;
    showFeaturedLoadingContainer = false;
    notifyListeners();
  }

  void resetAllProductList() {
    allProductList.clear();
    isAllProductInitial = true;
    totalAllProductData = 0;
    allProductPage = 1;
    showAllLoadingContainer = false;
    notifyListeners();
  }

  void paginationListener(ScrollMetrics metrics) {
    final bool reached80 = metrics.pixels >= 0.8 * metrics.maxScrollExtent;

    if (reached80 &&
        !showAllLoadingContainer &&
        totalAllProductData > allProductList.length &&
        (metrics.pixels != metrics.maxScrollExtent ||
            metrics.pixels == metrics.minScrollExtent)) {
      allProductPage++;
      showAllLoadingContainer = true;
      fetchAllProducts();
    }
  }

  // void initPiratedAnimation(vnc) {
  //   pirated_logo_controller = AnimationController(
  //       vsync: vnc, duration: const Duration(milliseconds: 2000));
  //   pirated_logo_animation = Tween(begin: 40.0, end: 60.0).animate(
  //     CurvedAnimation(
  //       curve: Curves.bounceOut,
  //       parent: pirated_logo_controller,
  //     ),
  //   );

  //   pirated_logo_controller.addStatusListener((AnimationStatus status) {
  //     if (status == AnimationStatus.completed) {
  //       pirated_logo_controller.repeat();
  //     }
  //   });

  //   pirated_logo_controller.forward();
  // }

  void incrementCurrentSlider(index) {
    current_slider = index;
    notifyListeners();
  }

  @override
  void dispose() {
    // pirated_logo_controller.dispose();
    _flashDealTimer?.cancel();
    super.dispose();
  }
}

class CurrentRemainingTime extends Equatable {
  final int days;
  final int hours;
  final int min;
  final int sec;

  const CurrentRemainingTime({
    required this.days,
    required this.hours,
    required this.min,
    required this.sec,
  });

  @override
  List<Object?> get props => [days, hours, min, sec];
}

bool _isOpenedBefore = false;

Future<Address?> getDefaultAddress() async {
  if (!shouldHaveAddress) return null;

  Address? defaultAddress;

  final AddressResponse? addressResponse =
      await handleErrorsWithMessage(AddressRepository().getAddressList);
  if (addressResponse != null) {
    if (addressResponse.addresses?.isNotEmpty != true) return null;

    for (Address a in addressResponse.addresses!) {
      if (a.set_default == 1) {
        defaultAddress = a;
        break;
      }
    }
    if (defaultAddress == null) {
      final Address temp = addressResponse.addresses!.first;
      final addressMakeDefaultResponse =
          await AddressRepository().getAddressMakeDefaultResponse(temp.id);

      if (addressMakeDefaultResponse.result == false) return null;

      defaultAddress = temp;
    }
  }

  return defaultAddress;
}

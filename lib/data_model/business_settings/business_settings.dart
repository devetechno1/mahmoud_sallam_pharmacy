import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/helpers/color_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app_config.dart';
import '../../screens/home/home_page_type_enum.dart';
import '../otp_provider_model.dart';
import 'update_model.dart';
import 'verification_form.dart';

class BusinessSettingsData extends Equatable {
  final bool isPrescriptionActive;
  final bool hideEmailCheckout;
  final bool hidePostalCodeCheckout;
  final bool showWholesaleLabel;
  final bool showPackingQtyWholesaleProduct;
  final bool showPackingQtyPriceWholesaleProduct;
  final bool showPackingBeforePriceWholesaleProduct;
  final bool usePackingWholesaleProduct;
  final bool allowOTPLogin;
  final bool allowTwitterLogin;
  final bool allowGoogleLogin;
  final bool allowFacebookLogin;
  final bool allowAppleLogin;
  final bool homeDefaultCurrency;
  final bool systemDefaultCurrency;
  final bool currencyFormat;
  final bool symbolFormat;
  final bool noOfDecimals;
  final bool productActivation;
  final bool vendorSystemActivation;
  final bool showVendors;
  final bool cashPayment;
  final bool payumoneyPayment;
  final bool bestSelling;
  final bool paypalSandbox;
  final bool sslcommerzSandbox;
  final bool vendorCommission;
  final List<VerificationForm>? verificationForm;
  final bool googleAnalytics;
  final bool payumoneySandbox;
  final bool facebookChat;
  final bool mailVerificationStatus;
  final bool walletSystem;
  final bool couponSystem;
  final bool currentVersion;
  final bool instamojoSandbox;
  final bool pickupPoint;
  final bool maintenanceMode;
  final bool voguepaySandbox;
  final bool categoryWiseCommission;
  final bool conversationSystem;
  final bool guestCheckoutActive;
  final bool facebookPixel;
  final bool classifiedProduct;
  final bool posActivationForSeller;
  final String? shippingType;
  final bool flatRateShippingCost;
  final bool shippingCostAdmin;
  final bool payhereSandbox;
  final bool googleRecaptcha;
  final bool headerLogo;
  final bool showLanguageSwitcher;
  final bool showCurrencySwitcher;
  final bool headerStikcy;
  final bool footerLogo;
  final String? aboutUsDescription;
  final dynamic contactAddress;
  final bool contactPhone;
  final dynamic contactEmail;
  final dynamic widgetOneLabels;
  final dynamic widgetOneLinks;
  final dynamic widgetOne;
  final dynamic frontendCopyrightText;
  final dynamic showSocialLinks;
  final dynamic facebookLink;
  final dynamic twitterLink;
  final dynamic instagramLink;
  final dynamic youtubeLink;
  final dynamic linkedinLink;
  final dynamic paymentMethodImages;
  final bool homeSliderImages;
  final bool homeSliderLinks;
  final bool homeBanner1Images;
  final bool homeBanner1Links;
  final bool homeBanner2Images;
  final bool homeBanner2Links;
  final bool homeCategories;
  final bool top10Categories;
  final bool top10Brands;
  final bool websiteName;
  final dynamic siteMotto;
  final bool siteIcon;
  final Color? primaryColor;
  final Color? primaryHovColor;
  final dynamic metaTitle;
  final dynamic metaDescription;
  final dynamic metaKeywords;
  final dynamic metaImage;
  final String? siteName;
  final bool systemLogoWhite;
  final bool systemLogoBlack;
  final dynamic timezone;
  final dynamic adminLoginBackground;
  final String? iyzicoSandbox;
  final String? decimalSeparator;
  final String? bkashSandbox;
  final bool headerMenuLabels;
  final bool headerMenuLinks;
  final String? checkoutMessage;
  final String? proxypay;
  final String? proxypaySandbox;
  final String? googleMap;
  final String? googleFirebase;
  final String? authorizenetSandbox;
  final dynamic minOrderAmountCheckActivat;
  final double minimumOrderAmount;
  final double freeShippingMinimumOrderAmount;
  final bool freeShippingMinimumCheck;
  final String? itemName;
  final bool aamarpaySandbox;
  final Color? secondaryColor;
  final Color? secondaryHovColor;
  final String? headerNavMenuText;
  final HomePageType selectedHomePage;
  final dynamic todaysDealSectionBg;
  final Color? todaysDealSectionBgColor;
  final Color? flashDealBgColor;
  final dynamic flashDealBgFullWidth;
  final String? flashDealBannerMenuText;
  final bool isLightFlashDealTextColor;
  final Color? todaysDealBannerTextColor;
  final String? couponBackgroundImage;
  final bool adminLoginPageImage;
  final String? customerLoginPageImage;
  final dynamic customerRegisterPageImage;
  final dynamic sellerLoginPageImage;
  final dynamic sellerRegisterPageImage;
  final dynamic deliveryBoyLoginPageImage;
  final String? forgotPasswordPageImage;
  final dynamic passwordResetPageImage;
  final dynamic phoneNumberVerifyPageImage;
  final String? authenticationLayoutSelect;
  final String? flashDealCardBgImage;
  final String? flashDealCardBgTitle;
  final String? flashDealCardBgSubtitle;
  final String? flashDealCardText;
  final String? todaysDealCardBgImage;
  final String? todaysDealCardBgTitle;
  final String? todaysDealCardBgSubtitle;
  final String? todaysDealCardText;
  final String? newProductCardBgImage;
  final String? newProductCardBgTitle;
  final String? newProductCardBgSubtitle;
  final String? newProductCardText;
  final String? featuredCategoriesText;
  final bool guestCheckoutStatus;
  final String? sliderSectionFullWidth;
  final Color? sliderSectionBgColor;
  final List<String>? homeBanner4Images;
  final List<String>? homeBanner4Links;
  final List<String>? homeBanner5Images;
  final List<String>? homeBanner5Links;
  final List<String>? homeBanner6Images;
  final List<String>? homeBanner6Links;
  final bool lastViewedProductActivation;
  final String? customAlertLocation;
  final String? notificationShowType;
  final Color? cuponTextColor;
  final bool flashDealSectionOutline;
  final Color? flashDealSectionOutlineColor;
  final Color? featuredSectionBgColor;
  final bool featuredSectionOutline;
  final Color? featuredSectionOutlineColor;
  final Color? bestSellingSectionBgColor;
  final bool bestSellingSectionOutline;
  final Color? bestSellingSectionOutlineColor;
  final Color? newProductsSectionBgColor;
  final bool newProductsSectionOutline;
  final Color? newProductsSectionOutlineColor;
  final Color? homeCategoriesSectionBgColor;
  final Color? homeCategoriesContentBgColor;
  final bool homeCategoriesContentOutline;
  final Color? homeCategoriesContentOutlineColor;
  final Color? classifiedSectionBgColor;
  final bool classifiedSectionOutline;
  final Color? classifiedSectionOutlineColor;
  final Color? sellersSectionBgColor;
  final bool sellersSectionOutline;
  final Color? sellersSectionOutlineColor;
  final Color? brandsSectionBgColor;
  final bool brandsSectionOutline;
  final Color? brandsSectionOutlineColor;
  final String? uploadedImageFormat;
  final String? productExternalLinkForSeller;
  final String? useFloatingButtons;
  final String? sellerCommissionType;
  final String? purchaseCode;
  final Color? auctionSectionBgColor;
  final Color? auctionContentBgColor;
  final dynamic auctionSectionOutline;
  final Color? auctionSectionOutlineColor;
  final String? clubPointConvertRate;
  final String? toyyibpayPayment;
  final String? toyyibpaySandbox;
  final String? paytmPayment;
  final String? myfatoorah;
  final dynamic myfatoorahSandbox;
  final String? khaltiSandbox;
  final String? phonepePayment;
  final String? phonepeSandbox;
  final dynamic headerScript;
  final bool footerScript;
  final String? topbarBanner;
  final String? topbarBannerMedium;
  final String? topbarBannerSmall;
  final dynamic topbarBannerLink;
  final dynamic helplineNumber;
  final dynamic playStoreLink;
  final dynamic appStoreLink;
  final bool footerTitle;
  final bool footerDescription;
  final String? disableImageOptimization;
  final String? viewProductOutOfStock;
  final String? posAcceptsNegativeQuantity;
  final LatLng initPlace;
  final String? adminNotifications;
  final String? adminRealertNotification;
  final String? printWidth;
  final bool todaysDealBanner;
  final bool todaysDealBannerSmall;
  final Color? todaysDealBgColor;
  final bool posThermalInvoiceCompanyLogo;
  final bool posThermalInvoiceCompanyName;
  final bool posThermalInvoiceCompanyPhone;
  final bool posThermalInvoiceCompanyEmail;
  final dynamic flashDealBanner;
  final dynamic flashDealBannerSmall;
  final bool minimumOrderAmountCheck;

  final bool minimumOrderQuantityCheck;
  final int minimumOrderQuantity;
  final bool homeBanner3Images;
  final bool homeBanner3Links;
  final String? auctionBannerImage;
  final dynamic classifiedBannerImage;
  final dynamic classifiedBannerImageSmall;
  final bool topBrands;
  final String? posThermalInvoiceHeadDetailsFs;
  final String? posThermalInvoiceProductTableFs;
  final String? posThermalInvoiceFooterDetailsFs;
  final dynamic useImageWatermark;
  final String? imageWatermarkType;
  final dynamic watermarkImage;
  final String? watermarkText;
  final dynamic watermarkTextSize;
  final Color? watermarkTextColor;
  final String? watermarkPosition;
  final bool productManageByAdmin;
  final bool productApproveByAdmin;
  final bool productQueryActivation;
  final bool mustOtp;
  final Color? cuponBackgroundColor;
  final bool cuponTitle;
  final bool cuponSubtitle;
  final bool isBlogActive;
  final double? deliveryPickupLongitude;
  final double? deliveryPickupLatitude;
  final String? whatsappNumber;
  final String? clarityProjectId;
  final String? sentryDSN;
  final UpdateDataModel? updateData;
  final String? categoryAppStyle;
  final String? diplayDiscountType;
  final dynamic showBrandName;

  final List<OTPProviderModel> _otpProviders = List.empty(growable: true);
  List<OTPProviderModel> get otpProviders => _otpProviders;

  bool get carrierBaseShipping => shippingType == "carrier_wise_shipping";
  bool get sellerWiseShipping => shippingType == "seller_wise_shipping";

  bool get otherLogins =>
      allowFacebookLogin || allowGoogleLogin || otpProviders.isNotEmpty;

  bool get useSentry => sentryDSN?.isNotEmpty == true;
  bool get useClarity => clarityProjectId?.isNotEmpty == true;

  static const LatLng _initPlace =
      LatLng(30.723003387451172, 31.02609634399414);

  BusinessSettingsData({
    this.initPlace = _initPlace,
    this.isPrescriptionActive = false,
    this.hideEmailCheckout = false,
    this.hidePostalCodeCheckout = false,
    this.checkoutMessage,
    this.showWholesaleLabel = false,
    this.showPackingQtyWholesaleProduct = false,
    this.showPackingQtyPriceWholesaleProduct = false,
    this.showPackingBeforePriceWholesaleProduct = false,
    this.usePackingWholesaleProduct = false,
    this.whatsappNumber,
    this.updateData,
    this.isBlogActive = false,
    this.allowTwitterLogin = false,
    this.allowOTPLogin = false,
    this.allowGoogleLogin = false,
    this.allowFacebookLogin = false,
    this.allowAppleLogin = false,
    this.homeDefaultCurrency = false,
    this.systemDefaultCurrency = false,
    this.currencyFormat = false,
    this.symbolFormat = false,
    this.noOfDecimals = false,
    this.productActivation = false,
    this.vendorSystemActivation = false,
    this.showVendors = false,
    this.cashPayment = false,
    this.payumoneyPayment = false,
    this.bestSelling = false,
    this.paypalSandbox = false,
    this.sslcommerzSandbox = false,
    this.vendorCommission = false,
    this.verificationForm,
    this.googleAnalytics = false,
    this.payumoneySandbox = false,
    this.facebookChat = false,
    this.mailVerificationStatus = false,
    this.walletSystem = false,
    this.couponSystem = false,
    this.currentVersion = false,
    this.instamojoSandbox = false,
    this.pickupPoint = false,
    this.maintenanceMode = false,
    this.voguepaySandbox = false,
    this.categoryWiseCommission = false,
    this.conversationSystem = false,
    this.guestCheckoutActive = false,
    this.facebookPixel = false,
    this.classifiedProduct = false,
    this.posActivationForSeller = false,
    this.shippingType,
    this.flatRateShippingCost = false,
    this.shippingCostAdmin = false,
    this.payhereSandbox = false,
    this.googleRecaptcha = false,
    this.headerLogo = false,
    this.showLanguageSwitcher = false,
    this.showCurrencySwitcher = false,
    this.headerStikcy = false,
    this.footerLogo = false,
    this.aboutUsDescription,
    this.contactAddress,
    this.contactPhone = false,
    this.isLightFlashDealTextColor = false,
    this.contactEmail,
    this.widgetOneLabels,
    this.widgetOneLinks,
    this.widgetOne,
    this.frontendCopyrightText,
    this.showSocialLinks,
    this.facebookLink,
    this.twitterLink,
    this.instagramLink,
    this.youtubeLink,
    this.linkedinLink,
    this.paymentMethodImages,
    this.homeSliderImages = false,
    this.homeSliderLinks = false,
    this.homeBanner1Images = false,
    this.homeBanner1Links = false,
    this.homeBanner2Images = false,
    this.homeBanner2Links = false,
    this.homeCategories = false,
    this.top10Categories = false,
    this.top10Brands = false,
    this.websiteName = false,
    this.siteMotto,
    this.siteIcon = false,
    this.primaryColor,
    this.primaryHovColor,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.metaImage,
    this.siteName,
    this.systemLogoWhite = false,
    this.systemLogoBlack = false,
    this.timezone,
    this.adminLoginBackground,
    this.iyzicoSandbox,
    this.decimalSeparator,
    this.bkashSandbox,
    this.headerMenuLabels = false,
    this.headerMenuLinks = false,
    this.proxypay,
    this.proxypaySandbox,
    this.googleMap,
    this.googleFirebase,
    this.authorizenetSandbox,
    this.minOrderAmountCheckActivat,
    this.minimumOrderAmount = 0.0,
    this.freeShippingMinimumOrderAmount = 0.0,
    this.freeShippingMinimumCheck = false,
    this.itemName,
    this.aamarpaySandbox = false,
    this.secondaryColor,
    this.secondaryHovColor,
    this.headerNavMenuText,
    this.selectedHomePage = HomePageType.home,
    this.todaysDealSectionBg,
    this.todaysDealSectionBgColor,
    this.flashDealBgColor,
    this.flashDealBgFullWidth,
    this.flashDealBannerMenuText,
    this.todaysDealBannerTextColor,
    this.couponBackgroundImage,
    this.adminLoginPageImage = false,
    this.customerLoginPageImage,
    this.customerRegisterPageImage,
    this.sellerLoginPageImage,
    this.sellerRegisterPageImage,
    this.deliveryBoyLoginPageImage,
    this.forgotPasswordPageImage,
    this.passwordResetPageImage,
    this.phoneNumberVerifyPageImage,
    this.authenticationLayoutSelect,
    this.flashDealCardBgImage,
    this.flashDealCardBgTitle,
    this.flashDealCardBgSubtitle,
    this.flashDealCardText,
    this.todaysDealCardBgImage,
    this.todaysDealCardBgTitle,
    this.todaysDealCardBgSubtitle,
    this.todaysDealCardText,
    this.newProductCardBgImage,
    this.newProductCardBgTitle,
    this.newProductCardBgSubtitle,
    this.newProductCardText,
    this.featuredCategoriesText,
    this.guestCheckoutStatus = false,
    this.sliderSectionFullWidth,
    this.sliderSectionBgColor,
    this.homeBanner4Images,
    this.homeBanner4Links,
    this.homeBanner5Images,
    this.homeBanner5Links,
    this.homeBanner6Images,
    this.homeBanner6Links,
    this.lastViewedProductActivation = false,
    this.customAlertLocation,
    this.notificationShowType,
    this.cuponTextColor,
    this.flashDealSectionOutline = false,
    this.flashDealSectionOutlineColor,
    this.featuredSectionBgColor,
    this.featuredSectionOutline = false,
    this.featuredSectionOutlineColor,
    this.bestSellingSectionBgColor,
    this.bestSellingSectionOutline = false,
    this.bestSellingSectionOutlineColor,
    this.newProductsSectionBgColor,
    this.newProductsSectionOutline = false,
    this.newProductsSectionOutlineColor,
    this.homeCategoriesSectionBgColor,
    this.homeCategoriesContentBgColor,
    this.homeCategoriesContentOutline = false,
    this.homeCategoriesContentOutlineColor,
    this.classifiedSectionBgColor,
    this.classifiedSectionOutline = false,
    this.classifiedSectionOutlineColor,
    this.sellersSectionBgColor,
    this.sellersSectionOutline = false,
    this.sellersSectionOutlineColor,
    this.brandsSectionBgColor,
    this.brandsSectionOutline = false,
    this.brandsSectionOutlineColor,
    this.uploadedImageFormat,
    this.productExternalLinkForSeller,
    this.useFloatingButtons,
    this.sellerCommissionType,
    this.purchaseCode,
    this.auctionSectionBgColor,
    this.auctionContentBgColor,
    this.auctionSectionOutline,
    this.auctionSectionOutlineColor,
    this.clubPointConvertRate,
    this.toyyibpayPayment,
    this.toyyibpaySandbox,
    this.paytmPayment,
    this.myfatoorah,
    this.myfatoorahSandbox,
    this.khaltiSandbox,
    this.phonepePayment,
    this.phonepeSandbox,
    this.headerScript,
    this.footerScript = false,
    this.topbarBanner,
    this.topbarBannerMedium,
    this.topbarBannerSmall,
    this.topbarBannerLink,
    this.helplineNumber,
    this.playStoreLink,
    this.appStoreLink,
    this.footerTitle = false,
    this.footerDescription = false,
    this.disableImageOptimization,
    this.viewProductOutOfStock,
    this.posAcceptsNegativeQuantity,
    this.adminNotifications,
    this.adminRealertNotification,
    this.printWidth,
    this.todaysDealBanner = false,
    this.todaysDealBannerSmall = false,
    this.todaysDealBgColor,
    this.posThermalInvoiceCompanyLogo = false,
    this.posThermalInvoiceCompanyName = false,
    this.posThermalInvoiceCompanyPhone = false,
    this.posThermalInvoiceCompanyEmail = false,
    this.flashDealBanner,
    this.flashDealBannerSmall,
    this.minimumOrderAmountCheck = false,
    this.minimumOrderQuantityCheck = false,
    this.minimumOrderQuantity = 1,
    this.homeBanner3Images = false,
    this.homeBanner3Links = false,
    this.auctionBannerImage,
    this.classifiedBannerImage,
    this.classifiedBannerImageSmall,
    this.topBrands = false,
    this.posThermalInvoiceHeadDetailsFs,
    this.posThermalInvoiceProductTableFs,
    this.posThermalInvoiceFooterDetailsFs,
    this.useImageWatermark,
    this.imageWatermarkType,
    this.watermarkImage,
    this.watermarkText,
    this.watermarkTextSize,
    this.watermarkTextColor,
    this.watermarkPosition,
    this.productManageByAdmin = false,
    this.productApproveByAdmin = false,
    this.productQueryActivation = false,
    this.mustOtp = false,
    this.cuponBackgroundColor,
    this.cuponTitle = false,
    this.cuponSubtitle = false,
    this.deliveryPickupLongitude,
    this.deliveryPickupLatitude,
    this.clarityProjectId,
    this.sentryDSN,
     this.categoryAppStyle,
     this.diplayDiscountType,
     this.showBrandName,
  });

  factory BusinessSettingsData.fromMap(Map<String, dynamic> data) {
    UpdateDataModel? updateData;

    switch (AppConfig.storeType) {
      case StoreType.appGallery:
        updateData = UpdateDataModel(
          mustUpdate: '${data['must_appgallery_update']}' == '1',
          version: data['appgallery_version']?.toString(),
          storeLink: data['appgallery_link']?.toString(),
        );
      case StoreType.playStore:
        updateData = UpdateDataModel(
          mustUpdate: '${data['must_googleplay_update']}' == '1',
          version: data['googleplay_version']?.toString(),
          storeLink: data['googleplay_link']?.toString(),
        );
      case StoreType.appleStore:
        updateData = UpdateDataModel(
          mustUpdate: '${data['must_appstore_update']}' == '1',
          version: data['appstore_version']?.toString(),
          storeLink: data['appstore_link']?.toString(),
        );
      case StoreType.unknown:
        updateData = null;
    }
    return BusinessSettingsData(
        sentryDSN: (data['sentry_dsn'] as String?)?.trim(),
        clarityProjectId: (data['clarity_project_id'] as String?)?.trim(),
        updateData: updateData,
        isPrescriptionActive: "${data['is_prescription_active']}" == "1",
        hideEmailCheckout: "${data['hide_email_checkout']}" == "1",
        hidePostalCodeCheckout: "${data['hide_postal_code_checkout']}" == "1",
        checkoutMessage: data['checkout_message'] == null
            ? null
            : "${data['checkout_message']}".trim(),
        showWholesaleLabel: (data['wholesale_lable'] as String?) == "1",
        showPackingQtyWholesaleProduct:
            (data['packing_quty_wholesale_product'] as String?) == "1",
        showPackingQtyPriceWholesaleProduct:
            (data['packing_unit_price_wholesale_product'] as String?) == "1",
        showPackingBeforePriceWholesaleProduct:
            (data['packing_before_price_wholesale_product'] as String?) == "1",
        usePackingWholesaleProduct:
            (data['packing_wholesale_product'] as String?) == "1",
        whatsappNumber: data['whatsapp_number'] as String?,
        allowTwitterLogin: (data['twitter_login'] as String?) == "1",
        allowOTPLogin: (data['login_with_otp'] as String?) == "1",
        allowGoogleLogin: (data['google_login'] as String?) == "1",
        allowFacebookLogin: (data['facebook_login'] as String?) == "1",
        allowAppleLogin: (data['apple_login'] as String?) == "1",
        homeDefaultCurrency: (data['home_default_currency'] as String?) == "1",
        systemDefaultCurrency:
            (data['system_default_currency'] as String?) == "1",
        currencyFormat: (data['currency_format'] as String?) == "1",
        symbolFormat: (data['symbol_format'] as String?) == "1",
        noOfDecimals: (data['no_of_decimals'] as String?) == "1",
        productActivation: (data['product_activation'] as String?) == "1",
        vendorSystemActivation:
            (data['vendor_system_activation'] as String?) == "1",
        showVendors: (data['show_vendors'] as String?) == "1",
        cashPayment: (data['cash_payment'] as String?) == "1",
        payumoneyPayment: (data['payumoney_payment'] as String?) == "1",
        bestSelling: (data['best_selling'] as String?) == "1",
        paypalSandbox: (data['paypal_sandbox'] as String?) == "1",
        sslcommerzSandbox: (data['sslcommerz_sandbox'] as String?) == "1",
        vendorCommission: (data['vendor_commission'] as String?) == "1",
        verificationForm: (data['verification_form'] as List<dynamic>?)
            ?.map((e) => VerificationForm.fromMap(e as Map<String, dynamic>))
            .toList(),
        googleAnalytics: (data['google_analytics'] as String?) == "1",
        payumoneySandbox: (data['payumoney_sandbox'] as String?) == "1",
        facebookChat: (data['facebook_chat'] as String?) == "1",
        mailVerificationStatus: (data['email_verification'] as String?) == "1",
        walletSystem: (data['wallet_system'] as String?) == "1",
        couponSystem: (data['coupon_system'] as String?) == "1",
        currentVersion: (data['current_version'] as String?) == "1",
        instamojoSandbox: (data['instamojo_sandbox'] as String?) == "1",
        pickupPoint: (data['pickup_point'] as String?) == "1",
        maintenanceMode: (data['maintenance_mode'] as String?) == "1",
        voguepaySandbox: (data['voguepay_sandbox'] as String?) == "1",
        categoryWiseCommission:
            (data['category_wise_commission'] as String?) == 1,
        conversationSystem: (data['conversation_system'] as String?) == "1",
        guestCheckoutActive: false ,//(data['guest_checkout_active'] as String?) == "1",
        facebookPixel: (data['facebook_pixel'] as String?) == "1",
        classifiedProduct: (data['classified_product'] as String?) == "1",
        posActivationForSeller:
            (data['pos_activation_for_seller'] as String?) == "1",
        shippingType: data['shipping_type'] as String?,
        flatRateShippingCost:
            (data['flat_rate_shipping_cost'] as String?) == "1",
        shippingCostAdmin: (data['shipping_cost_admin'] as String?) == "1",
        payhereSandbox: (data['payhere_sandbox'] as String?) == "1",
        googleRecaptcha: (data['google_recaptcha'] as String?) == "1",
        headerLogo: (data['header_logo'] as String?) == "1",
        showLanguageSwitcher:
            (data['show_language_switcher'] as String?) == "1",
        showCurrencySwitcher:
            (data['show_currency_switcher'] as String?) == "1",
        headerStikcy: (data['header_stikcy'] as String?) == "1",
        footerLogo: (data['footer_logo'] as String?) == "1",
        aboutUsDescription: data['about_us_description'] as dynamic,
        contactAddress: data['contact_address'] as String?,
        contactPhone: (data['contact_phone'] as String?) == "1",
        contactEmail: data['contact_email'] as dynamic,
        widgetOneLabels: data['widget_one_labels'] as dynamic,
        widgetOneLinks: data['widget_one_links'] as dynamic,
        widgetOne: data['widget_one'] as dynamic,
        frontendCopyrightText: data['frontend_copyright_text'] as dynamic,
        showSocialLinks: data['show_social_links'] as dynamic,
        facebookLink: data['facebook_link'] as dynamic,
        twitterLink: data['twitter_link'] as dynamic,
        instagramLink: data['instagram_link'] as dynamic,
        youtubeLink: data['youtube_link'] as dynamic,
        linkedinLink: data['linkedin_link'] as dynamic,
        paymentMethodImages: data['payment_method_images'] as dynamic,
        homeSliderImages: (data['home_slider_images'] as String?) == "1",
        homeSliderLinks: (data['home_slider_links'] as String?) == "1",
        homeBanner1Images: (data['home_banner1_images'] as String?) == "1",
        homeBanner1Links: (data['home_banner1_links'] as String?) == "1",
        homeBanner2Images: (data['home_banner2_images'] as String?) == "1",
        homeBanner2Links: (data['home_banner2_links'] as String?) == "1",
        homeCategories: (data['home_categories'] as String?) == "1",
        top10Categories: (data['top10_categories'] as String?) == "1",
        top10Brands: (data['top10_brands'] as String?) == "1",
        websiteName: (data['website_name'] as String?) == "1",
        siteMotto: data['site_motto'] as dynamic,
        siteIcon: (data['site_icon'] as String?) == "1",
        primaryColor: ColorHelper.stringToColor(data['base_color'] as String?),
        primaryHovColor:
            ColorHelper.stringToColor(data['base_hov_color'] as String?),
        metaTitle: data['meta_title'] as dynamic,
        metaDescription: data['meta_description'] as dynamic,
        metaKeywords: data['meta_keywords'] as dynamic,
        metaImage: data['meta_image'] as dynamic,
        siteName: data['site_name'] as String?,
        systemLogoWhite: (data['system_logo_white'] as String?) == "1",
        systemLogoBlack: (data['system_logo_black'] as String?) == "1",
        timezone: data['timezone'] as dynamic,
        adminLoginBackground: data['admin_login_background'] as dynamic,
        iyzicoSandbox: data['iyzico_sandbox'] as String?,
        decimalSeparator: data['decimal_separator'] as String?,
        bkashSandbox: data['bkash_sandbox'] as String?,
        headerMenuLabels: (data['header_menu_labels'] as String?) == "1",
        headerMenuLinks: (data['header_menu_links'] as String?) == "1",
        proxypay: data['proxypay'] as String?,
        proxypaySandbox: data['proxypay_sandbox'] as String?,
        googleMap: data['google_map'] as String?,
        googleFirebase: data['google_firebase'] as String?,
        authorizenetSandbox: data['authorizenet_sandbox'] as String?,
        minOrderAmountCheckActivat:
            data['min_order_amount_check_activat'] as dynamic,
        minimumOrderAmount: double.tryParse(data['minimum_order_amount'] as String? ?? '0.0') ?? 0.0,
        freeShippingMinimumOrderAmount: double.tryParse(data['free_shipping_minimum_order_amount'] as String? ?? '0.0') ?? 0.0,
        itemName: data['item_name'] as String?,
        aamarpaySandbox: (data['aamarpay_sandbox'] as String?) == "1",
        secondaryColor: ColorHelper.stringToColor(data['secondary_base_color'] as String?),
        secondaryHovColor: ColorHelper.stringToColor(data['secondary_base_hov_color'] as String?),
        headerNavMenuText: data['header_nav_menu_text'] as String?,
        selectedHomePage: HomePageType.fromString(data['homepage_select'] as String?),
        todaysDealSectionBg: (data['todays_deal_section_bg'] as dynamic),
        todaysDealSectionBgColor: ColorHelper.stringToColor(data['todays_deal_section_bg_color'] as String?),
        flashDealBgColor: ColorHelper.stringToColor(data['flash_deal_bg_color'] as String?),
        flashDealBgFullWidth: data['flash_deal_bg_full_width'] as dynamic,
        flashDealBannerMenuText: data['flash_deal_banner_menu_text'] as String?,
        isLightFlashDealTextColor: (data['flash_deal_banner_menu_text'] as String?) == "light",
        todaysDealBannerTextColor: ColorHelper.stringToColor(data['todays_deal_banner_text_color'] as String?),
        couponBackgroundImage: data['coupon_background_image'] as String?,
        adminLoginPageImage: (data['admin_login_page_image'] as String?) == "1",
        customerLoginPageImage: data['customer_login_page_image'] as String?,
        customerRegisterPageImage: data['customer_register_page_image'] as dynamic,
        sellerLoginPageImage: data['seller_login_page_image'] as dynamic,
        sellerRegisterPageImage: data['seller_register_page_image'] as dynamic,
        deliveryBoyLoginPageImage: data['delivery_boy_login_page_image'] as dynamic,
        forgotPasswordPageImage: data['forgot_password_page_image'] as String?,
        passwordResetPageImage: data['password_reset_page_image'] as dynamic,
        phoneNumberVerifyPageImage: data['phone_number_verify_page_image'] as dynamic,
        authenticationLayoutSelect: data['authentication_layout_select'] as String?,
        flashDealCardBgImage: data['flash_deal_card_bg_image'] as String?,
        flashDealCardBgTitle: data['flash_deal_card_bg_title'] as String?,
        flashDealCardBgSubtitle: data['flash_deal_card_bg_subtitle'] as String?,
        flashDealCardText: data['flash_deal_card_text'] as String?,
        todaysDealCardBgImage: data['todays_deal_card_bg_image'] as String?,
        todaysDealCardBgTitle: data['todays_deal_card_bg_title'] as String?,
        todaysDealCardBgSubtitle: data['todays_deal_card_bg_subtitle'] as String?,
        todaysDealCardText: data['todays_deal_card_text'] as String?,
        newProductCardBgImage: data['new_product_card_bg_image'] as String?,
        newProductCardBgTitle: data['new_product_card_bg_title'] as String?,
        newProductCardBgSubtitle: data['new_product_card_bg_subtitle'] as String?,
        newProductCardText: data['new_product_card_text'] as String?,
        featuredCategoriesText: data['featured_categories_text'] as String?,
        guestCheckoutStatus: false,//(data['guest_checkout_activation'] as String?) == "1",
        sliderSectionFullWidth: data['slider_section_full_width'] as String?,
        sliderSectionBgColor: ColorHelper.stringToColor(data['slider_section_bg_color'] as String?),
        homeBanner4Images: _decodeJsonList(data['home_banner4_images'] as String?),
        homeBanner4Links: _decodeJsonList(data['home_banner4_links'] as String?),
        homeBanner5Images: _decodeJsonList(data['home_banner5_images'] as String?),
        homeBanner5Links: _decodeJsonList(data['home_banner5_links'] as String?),
        homeBanner6Images: _decodeJsonList(data['home_banner6_images'] as String?),
        homeBanner6Links: _decodeJsonList(data['home_banner6_links'] as String?),
        lastViewedProductActivation: "${data['last_viewed_product_activation'] as String?}" == "1",
        customAlertLocation: data['custom_alert_location'] as String?,
        notificationShowType: data['notification_show_type'] as String?,
        cuponTextColor: ColorHelper.stringToColor(data['cupon_text_color'] as String?),
        flashDealSectionOutline: (data['flash_deal_section_outline'] as String?) == "1",
        flashDealSectionOutlineColor: ColorHelper.stringToColor(data['flash_deal_section_outline_color'] as String?),
        featuredSectionBgColor: ColorHelper.stringToColor(data['featured_section_bg_color'] as String?),
        featuredSectionOutline: (data['featured_section_outline'] as String?) == "1",
        featuredSectionOutlineColor: ColorHelper.stringToColor(data['featured_section_outline_color'] as String?),
        bestSellingSectionBgColor: ColorHelper.stringToColor(data['best_selling_section_bg_color'] as String?),
        bestSellingSectionOutline: (data['best_selling_section_outline'] as String?) == "1",
        bestSellingSectionOutlineColor: ColorHelper.stringToColor(data['best_selling_section_outline_color'] as String?),
        newProductsSectionBgColor: ColorHelper.stringToColor(data['new_products_section_bg_color'] as String?),
        newProductsSectionOutline: (data['new_products_section_outline'] as String?) == "1",
        newProductsSectionOutlineColor: ColorHelper.stringToColor(data['new_products_section_outline_color'] as String?),
        homeCategoriesSectionBgColor: ColorHelper.stringToColor(data['home_categories_section_bg_color'] as String?),
        homeCategoriesContentBgColor: ColorHelper.stringToColor(data['home_categories_content_bg_color'] as String?),
        homeCategoriesContentOutline: data['home_categories_content_outline'] == '1',
        homeCategoriesContentOutlineColor: ColorHelper.stringToColor(data['home_categories_content_outline_color'] as String?),
        classifiedSectionBgColor: ColorHelper.stringToColor(data['classified_section_bg_color'] as String?),
        classifiedSectionOutline: (data['dclassified_section_outline'] as String?) == "1",
        classifiedSectionOutlineColor: ColorHelper.stringToColor(data['classified_section_outline_color'] as String?),
        sellersSectionBgColor: ColorHelper.stringToColor(data['sellers_section_bg_color'] as String?),
        sellersSectionOutline: data['sellers_section_outline'] == '1',
        sellersSectionOutlineColor: ColorHelper.stringToColor(data['sellers_section_outline_color'] as String?),
        brandsSectionBgColor: ColorHelper.stringToColor(data['brands_section_bg_color'] as String?),
        brandsSectionOutline: (data['brands_section_outline'] as String?) == "1",
        brandsSectionOutlineColor: ColorHelper.stringToColor(data['brands_section_outline_color'] as String?),
        uploadedImageFormat: data['uploaded_image_format'] as String?,
        productExternalLinkForSeller: data['product_external_link_for_seller'] as String?,
        useFloatingButtons: data['use_floating_buttons'] as String?,
        sellerCommissionType: data['seller_commission_type'] as String?,
        purchaseCode: data['purchase_code'] as String?,
        auctionSectionBgColor: ColorHelper.stringToColor(data['auction_section_bg_color'] as String?),
        auctionContentBgColor: ColorHelper.stringToColor(data['auction_content_bg_color'] as String?),
        auctionSectionOutline: data['auction_section_outline'] as dynamic,
        auctionSectionOutlineColor: ColorHelper.stringToColor(data['auction_section_outline_color'] as String?),
        clubPointConvertRate: data['club_point_convert_rate'] as String?,
        toyyibpayPayment: data['toyyibpay_payment'] as String?,
        toyyibpaySandbox: data['toyyibpay_sandbox'] as String?,
        paytmPayment: data['paytm_payment'] as String?,
        myfatoorah: data['myfatoorah'] as String?,
        myfatoorahSandbox: data['myfatoorah_sandbox'] as dynamic,
        khaltiSandbox: data['khalti_sandbox'] as String?,
        phonepePayment: data['phonepe_payment'] as String?,
        phonepeSandbox: data['phonepe_sandbox'] as String?,
        headerScript: data['header_script'] as dynamic,
        footerScript: (data['footer_script'] as String?) == "1",
        topbarBanner: data['topbar_banner'] as String?,
        topbarBannerMedium: data['topbar_banner_medium'] as String?,
        topbarBannerSmall: data['topbar_banner_small'] as String?,
        topbarBannerLink: data['topbar_banner_link'] as dynamic,
        helplineNumber: data['helpline_number'] as dynamic,
        playStoreLink: data['play_store_link'] as dynamic,
        appStoreLink: data['app_store_link'] as dynamic,
        footerTitle: (data['footer_title'] as String?) == "1",
        footerDescription: (data['footer_description'] as String?) == "1",
        disableImageOptimization: data['disable_image_optimization'] as String?,
        viewProductOutOfStock: data['view_product_out_of_stock'] as String?,
        posAcceptsNegativeQuantity: data['pos_accepts_negative_quantity'] as String?,
        initPlace: () {
          final double? lat = double.tryParse("${data['google_map_latitude']}");
          final double? long =
              double.tryParse("${data['google_map_longtitude']}");
          if (lat != null && long != null) return LatLng(lat, long);

          return _initPlace;
        }(),
        adminNotifications: data['admin_notifications'] as String?,
        adminRealertNotification: data['admin_realert_notification'] as String?,
        printWidth: data['print_width'] as String?,
        todaysDealBanner: (data['todays_deal_banner'] as String?) == "1",
        todaysDealBannerSmall: (data['todays_deal_banner_small'] as String?) == "1",
        todaysDealBgColor: ColorHelper.stringToColor(data['todays_deal_bg_color'] as String?),
        posThermalInvoiceCompanyLogo: (data['pos_thermal_invoice_company_logo'] as String?) == "1",
        posThermalInvoiceCompanyName: (data['pos_thermal_invoice_company_name'] as String?) == "1",
        posThermalInvoiceCompanyPhone: (data['pos_thermal_invoice_company_phone'] as String?) == "1",
        posThermalInvoiceCompanyEmail: (data['pos_thermal_invoice_company_email'] as String?) == "1",
        flashDealBanner: data['flash_deal_banner'] as dynamic,
        flashDealBannerSmall: data['flash_deal_banner_small'] as dynamic,
        minimumOrderAmountCheck: "${data['minimum_order_amount_check']}" == "1",
        freeShippingMinimumCheck: "${data['free_shipping_minimum_check']}" == "1",
        minimumOrderQuantityCheck: "${data['minimum_order_quantity_check']}" == "1",
        minimumOrderQuantity: int.parse((data['minimum_order_quantity'] as String?) ?? "1"),
        homeBanner3Images: (data['home_banner3_images'] as String?) == "1",
        homeBanner3Links: (data['home_banner3_links'] as String?) == "1",
        auctionBannerImage: data['auction_banner_image'] as String?,
        classifiedBannerImage: data['classified_banner_image'] as dynamic,
        classifiedBannerImageSmall: data['classified_banner_image_small'] as dynamic,
        topBrands: (data['top_brands'] as String?) == "1",
        posThermalInvoiceHeadDetailsFs: data['pos_thermal_invoice_head_details_fs'] as String?,
        posThermalInvoiceProductTableFs: data['pos_thermal_invoice_product_table_fs'] as String?,
        posThermalInvoiceFooterDetailsFs: data['pos_thermal_invoice_footer_details_fs'] as String?,
        useImageWatermark: data['use_image_watermark'] as dynamic,
        imageWatermarkType: data['image_watermark_type'] as String?,
        watermarkImage: data['watermark_image'] as dynamic,
        watermarkText: data['watermark_text'] as dynamic,
        watermarkTextSize: data['watermark_text_size'] as dynamic,
        watermarkTextColor: data['watermark_text_color'] as dynamic,
        watermarkPosition: data['watermark_position'] as String?,
        productManageByAdmin: (data['product_manage_by_admin'] as String?) == "1",
        productApproveByAdmin: (data['product_approve_by_admin'] as String?) == "1",
        productQueryActivation: (data['product_query_activation'] as String?) == "1",
        mustOtp: (data['must_otp'] as String?) == "1",
        cuponBackgroundColor: ColorHelper.stringToColor(data['cupon_background_color'] as String?),
        cuponTitle: (data['cupon_title'] as String?) == "1",
        cuponSubtitle: (data['cupon_subtitle'] as String?) == "1",
        deliveryPickupLongitude: double.tryParse(data['delivery_pickup_longitude']?.toString() ?? ''),
        deliveryPickupLatitude: double.tryParse(data['delivery_pickup_latitude']?.toString() ?? ''),
          categoryAppStyle: data['category_app_style']?.toString(),
          diplayDiscountType: data['display_discount_type'] as String?,
          showBrandName:(data['show_brand_name']?.toString() == "1"),
        );
        

  }

  void setOTPProviders(List<OTPProviderModel> newList) {
    _otpProviders.clear();
    _otpProviders.addAll(newList);
  }

  static List<String>? _decodeJsonList(String? data) {
    if (data == null) return null;
    return (json.decode(data) as List).cast<String>();
  }
  // Map<String, dynamic> toMap() => {
  //       'home_default_currency': homeDefaultCurrency,
  //       'system_default_currency': systemDefaultCurrency,
  //       'currency_format': currencyFormat,
  //       'symbol_format': symbolFormat,
  //       'no_of_decimals': noOfDecimals,
  //       'product_activation': productActivation,
  //       'vendor_system_activation': vendorSystemActivation,
  //       'show_vendors': showVendors,
  //       'cash_payment': cashPayment,
  //       'payumoney_payment': payumoneyPayment,
  //       'best_selling': bestSelling,
  //       'paypal_sandbox': paypalSandbox,
  //       'sslcommerz_sandbox': sslcommerzSandbox,
  //       'vendor_commission': vendorCommission,
  //       'verification_form': verificationForm?.map((e) => e.toMap()).toList(),
  //       'google_analytics': googleAnalytics,
  //       'facebook_login': facebookLogin,
  //       'google_login': googleLogin,
  //       'twitter_login': twitterLogin,
  //       'payumoney_sandbox': payumoneySandbox,
  //       'facebook_chat': facebookChat,
  //       'email_verification': emailVerification,
  //       'wallet_system': walletSystem,
  //       'coupon_system': couponSystem,
  //       'current_version': currentVersion,
  //       'instamojo_sandbox': instamojoSandbox,
  //       'pickup_point': pickupPoint,
  //       'maintenance_mode': maintenanceMode,
  //       'voguepay_sandbox': voguepaySandbox,
  //       'category_wise_commission': categoryWiseCommission,
  //       'conversation_system': conversationSystem,
  //       'guest_checkout_active': guestCheckoutActive,
  //       'facebook_pixel': facebookPixel,
  //       'classified_product': classifiedProduct,
  //       'pos_activation_for_seller': posActivationForSeller,
  //       'shipping_type': shippingType,
  //       'flat_rate_shipping_cost': flatRateShippingCost,
  //       'shipping_cost_admin': shippingCostAdmin,
  //       'payhere_sandbox': payhereSandbox,
  //       'google_recaptcha': googleRecaptcha,
  //       'header_logo': headerLogo,
  //       'show_language_switcher': showLanguageSwitcher,
  //       'show_currency_switcher': showCurrencySwitcher,
  //       'header_stikcy': headerStikcy,
  //       'footer_logo': footerLogo,
  //       'about_us_description': aboutUsDescription,
  //       'contact_address': contactAddress,
  //       'contact_phone': contactPhone,
  //       'contact_email': contactEmail,
  //       'widget_one_labels': widgetOneLabels,
  //       'widget_one_links': widgetOneLinks,
  //       'widget_one': widgetOne,
  //       'frontend_copyright_text': frontendCopyrightText,
  //       'show_social_links': showSocialLinks,
  //       'facebook_link': facebookLink,
  //       'twitter_link': twitterLink,
  //       'instagram_link': instagramLink,
  //       'youtube_link': youtubeLink,
  //       'linkedin_link': linkedinLink,
  //       'payment_method_images': paymentMethodImages,
  //       'home_slider_images': homeSliderImages,
  //       'home_slider_links': homeSliderLinks,
  //       'home_banner1_images': homeBanner1Images,
  //       'home_banner1_links': homeBanner1Links,
  //       'home_banner2_images': homeBanner2Images,
  //       'home_banner2_links': homeBanner2Links,
  //       'home_categories': homeCategories,
  //       'top10_categories': top10Categories,
  //       'top10_brands': top10Brands,
  //       'website_name': websiteName,
  //       'site_motto': siteMotto,
  //       'site_icon': siteIcon,
  //       'base_color': baseColor,
  //       'base_hov_color': baseHovColor,
  //       'meta_title': metaTitle,
  //       'meta_description': metaDescription,
  //       'meta_keywords': metaKeywords,
  //       'meta_image': metaImage,
  //       'site_name': siteName,
  //       'system_logo_white': systemLogoWhite,
  //       'system_logo_black': systemLogoBlack,
  //       'timezone': timezone,
  //       'admin_login_background': adminLoginBackground,
  //       'iyzico_sandbox': iyzicoSandbox,
  //       'decimal_separator': decimalSeparator,
  //       'bkash_sandbox': bkashSandbox,
  //       'header_menu_labels': headerMenuLabels,
  //       'header_menu_links': headerMenuLinks,
  //       'proxypay': proxypay,
  //       'proxypay_sandbox': proxypaySandbox,
  //       'google_map': googleMap,
  //       'google_firebase': googleFirebase,
  //       'authorizenet_sandbox': authorizenetSandbox,
  //       'min_order_amount_check_activat': minOrderAmountCheckActivat,
  //       'minimum_order_amount': minimumOrderAmount,
  //       'item_name': itemName,
  //       'aamarpay_sandbox': aamarpaySandbox,
  //       'secondary_base_color': secondaryBaseColor,
  //       'secondary_base_hov_color': secondaryBaseHovColor,
  //       'header_nav_menu_text': headerNavMenuText,
  //       'homepage_select': homepageSelect,
  //       'todays_deal_section_bg': todaysDealSectionBg,
  //       'todays_deal_section_bg_color': todaysDealSectionBgColor,
  //       'flash_deal_bg_color': flashDealBgColor,
  //       'flash_deal_bg_full_width': flashDealBgFullWidth,
  //       'flash_deal_banner_menu_text': flashDealBannerMenuText,
  //       'todays_deal_banner_text_color': todaysDealBannerTextColor,
  //       'coupon_background_image': couponBackgroundImage,
  //       'admin_login_page_image': adminLoginPageImage,
  //       'customer_login_page_image': customerLoginPageImage,
  //       'customer_register_page_image': customerRegisterPageImage,
  //       'seller_login_page_image': sellerLoginPageImage,
  //       'seller_register_page_image': sellerRegisterPageImage,
  //       'delivery_boy_login_page_image': deliveryBoyLoginPageImage,
  //       'forgot_password_page_image': forgotPasswordPageImage,
  //       'password_reset_page_image': passwordResetPageImage,
  //       'phone_number_verify_page_image': phoneNumberVerifyPageImage,
  //       'authentication_layout_select': authenticationLayoutSelect,
  //       'flash_deal_card_bg_image': flashDealCardBgImage,
  //       'flash_deal_card_bg_title': flashDealCardBgTitle,
  //       'flash_deal_card_bg_subtitle': flashDealCardBgSubtitle,
  //       'flash_deal_card_text': flashDealCardText,
  //       'todays_deal_card_bg_image': todaysDealCardBgImage,
  //       'todays_deal_card_bg_title': todaysDealCardBgTitle,
  //       'todays_deal_card_bg_subtitle': todaysDealCardBgSubtitle,
  //       'todays_deal_card_text': todaysDealCardText,
  //       'new_product_card_bg_image': newProductCardBgImage,
  //       'new_product_card_bg_title': newProductCardBgTitle,
  //       'new_product_card_bg_subtitle': newProductCardBgSubtitle,
  //       'new_product_card_text': newProductCardText,
  //       'featured_categories_text': featuredCategoriesText,
  //       'guest_checkout_activation': guestCheckoutActivation,
  //       'slider_section_full_width': sliderSectionFullWidth,
  //       'slider_section_bg_color': sliderSectionBgColor,
  //       'home_banner4_images': homeBanner4Images,
  //       'home_banner4_links': homeBanner4Links,
  //       'home_banner5_images': homeBanner5Images,
  //       'home_banner5_links': homeBanner5Links,
  //       'home_banner6_images': homeBanner6Images,
  //       'home_banner6_links': homeBanner6Links,
  //       'last_viewed_product_activation': lastViewedProductActivation,
  //       'custom_alert_location': customAlertLocation,
  //       'notification_show_type': notificationShowType,
  //       'cupon_text_color': cuponTextColor,
  //       'flash_deal_section_outline': flashDealSectionOutline,
  //       'flash_deal_section_outline_color': flashDealSectionOutlineColor,
  //       'featured_section_bg_color': featuredSectionBgColor,
  //       'featured_section_outline': featuredSectionOutline,
  //       'featured_section_outline_color': featuredSectionOutlineColor,
  //       'best_selling_section_bg_color': bestSellingSectionBgColor,
  //       'best_selling_section_outline': bestSellingSectionOutline,
  //       'best_selling_section_outline_color': bestSellingSectionOutlineColor,
  //       'new_products_section_bg_color': newProductsSectionBgColor,
  //       'new_products_section_outline': newProductsSectionOutline,
  //       'new_products_section_outline_color': newProductsSectionOutlineColor,
  //       'home_categories_section_bg_color': homeCategoriesSectionBgColor,
  //       'home_categories_content_bg_color': homeCategoriesContentBgColor,
  //       'home_categories_content_outline': homeCategoriesContentOutline,
  //       'home_categories_content_outline_color':
  //           homeCategoriesContentOutlineColor,
  //       'classified_section_bg_color': classifiedSectionBgColor,
  //       'classified_section_outline': classifiedSectionOutline,
  //       'classified_section_outline_color': classifiedSectionOutlineColor,
  //       'sellers_section_bg_color': sellersSectionBgColor,
  //       'sellers_section_outline': sellersSectionOutline,
  //       'sellers_section_outline_color': sellersSectionOutlineColor,
  //       'brands_section_bg_color': brandsSectionBgColor,
  //       'brands_section_outline': brandsSectionOutline,
  //       'brands_section_outline_color': brandsSectionOutlineColor,
  //       'uploaded_image_format': uploadedImageFormat,
  //       'product_external_link_for_seller': productExternalLinkForSeller,
  //       'use_floating_buttons': useFloatingButtons,
  //       'seller_commission_type': sellerCommissionType,
  //       'purchase_code': purchaseCode,
  //       'auction_section_bg_color': auctionSectionBgColor,
  //       'auction_content_bg_color': auctionContentBgColor,
  //       'auction_section_outline': auctionSectionOutline,
  //       'auction_section_outline_color': auctionSectionOutlineColor,
  //       'club_point_convert_rate': clubPointConvertRate,
  //       'toyyibpay_payment': toyyibpayPayment,
  //       'toyyibpay_sandbox': toyyibpaySandbox,
  //       'paytm_payment': paytmPayment,
  //       'myfatoorah': myfatoorah,
  //       'myfatoorah_sandbox': myfatoorahSandbox,
  //       'khalti_sandbox': khaltiSandbox,
  //       'phonepe_payment': phonepePayment,
  //       'phonepe_sandbox': phonepeSandbox,
  //       'header_script': headerScript,
  //       'footer_script': footerScript,
  //       'topbar_banner': topbarBanner,
  //       'topbar_banner_medium': topbarBannerMedium,
  //       'topbar_banner_small': topbarBannerSmall,
  //       'topbar_banner_link': topbarBannerLink,
  //       'helpline_number': helplineNumber,
  //       'play_store_link': playStoreLink,
  //       'app_store_link': appStoreLink,
  //       'footer_title': footerTitle,
  //       'footer_description': footerDescription,
  //       'disable_image_optimization': disableImageOptimization,
  //       'view_product_out_of_stock': viewProductOutOfStock,
  //       'pos_accepts_negative_quantity': posAcceptsNegativeQuantity,
  //       'google_map_longtitude': googleMapLongtitude,
  //       'google_map_latitude': googleMapLatitude,
  //       'admin_notifications': adminNotifications,
  //       'admin_realert_notification': adminRealertNotification,
  //       'print_width': printWidth,
  //       'todays_deal_banner': todaysDealBanner,
  //       'todays_deal_banner_small': todaysDealBannerSmall,
  //       'todays_deal_bg_color': todaysDealBgColor,
  //       'pos_thermal_invoice_company_logo': posThermalInvoiceCompanyLogo,
  //       'pos_thermal_invoice_company_name': posThermalInvoiceCompanyName,
  //       'pos_thermal_invoice_company_phone': posThermalInvoiceCompanyPhone,
  //       'pos_thermal_invoice_company_email': posThermalInvoiceCompanyEmail,
  //       'flash_deal_banner': flashDealBanner,
  //       'flash_deal_banner_small': flashDealBannerSmall,
  //       'minimum_order_amount_check': minimumOrderAmountCheck,
  //       'minimum_order_quantity_check': minimumOrderQuantityCheck,
  //       'minimum_order_quantity': minimumOrderQuantity,
  //       'home_banner3_images': homeBanner3Images,
  //       'home_banner3_links': homeBanner3Links,
  //       'auction_banner_image': auctionBannerImage,
  //       'classified_banner_image': classifiedBannerImage,
  //       'classified_banner_image_small': classifiedBannerImageSmall,
  //       'top_brands': topBrands,
  //       'pos_thermal_invoice_head_details_fs': posThermalInvoiceHeadDetailsFs,
  //       'pos_thermal_invoice_product_table_fs': posThermalInvoiceProductTableFs,
  //       'pos_thermal_invoice_footer_details_fs':
  //           posThermalInvoiceFooterDetailsFs,
  //       'use_image_watermark': useImageWatermark,
  //       'image_watermark_type': imageWatermarkType,
  //       'watermark_image': watermarkImage,
  //       'watermark_text': watermarkText,
  //       'watermark_text_size': watermarkTextSize,
  //       'watermark_text_color': watermarkTextColor,
  //       'watermark_position': watermarkPosition,
  //       'product_manage_by_admin': productManageByAdmin,
  //       'product_approve_by_admin': productApproveByAdmin,
  //       'product_query_activation': productQueryActivation,
  //       'must_otp': mustOtp,
  //       'cupon_background_color': cuponBackgroundColor,
  //       'cupon_title': cuponTitle,
  //       'cupon_subtitle': cuponSubtitle,
  //       'delivery_pickup_longitude': deliveryPickupLongitude,
  //       'delivery_pickup_latitude': deliveryPickupLatitude,
  //     };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [BusinessSettingsData].
  factory BusinessSettingsData.fromJson(String data) {
    return BusinessSettingsData.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [BusinessSettingsData] to a JSON string.
  // String toJson() => json.encode(toMap());

  // BusinessSettings copyWith({
  //   String? homeDefaultCurrency,
  //   String? systemDefaultCurrency,
  //   String? currencyFormat,
  //   String? symbolFormat,
  //   String? noOfDecimals,
  //   String? productActivation,
  //   String? vendorSystemActivation,
  //   String? showVendors,
  //   String? cashPayment,
  //   String? payumoneyPayment,
  //   String? bestSelling,
  //   String? paypalSandbox,
  //   String? sslcommerzSandbox,
  //   String? vendorCommission,
  //   List<VerificationForm>? verificationForm,
  //   String? googleAnalytics,
  //   String? facebookLogin,
  //   String? googleLogin,
  //   String? twitterLogin,
  //   String? payumoneySandbox,
  //   String? facebookChat,
  //   String? emailVerification,
  //   String? walletSystem,
  //   String? couponSystem,
  //   String? currentVersion,
  //   String? instamojoSandbox,
  //   String? pickupPoint,
  //   String? maintenanceMode,
  //   String? voguepaySandbox,
  //   String? categoryWiseCommission,
  //   String? conversationSystem,
  //   String? guestCheckoutActive,
  //   String? facebookPixel,
  //   String? classifiedProduct,
  //   String? posActivationForSeller,
  //   String? shippingType,
  //   String? flatRateShippingCost,
  //   String? shippingCostAdmin,
  //   String? payhereSandbox,
  //   String? googleRecaptcha,
  //   String? headerLogo,
  //   String? showLanguageSwitcher,
  //   String? showCurrencySwitcher,
  //   String? headerStikcy,
  //   String? footerLogo,
  //   dynamic aboutUsDescription,
  //   String? contactAddress,
  //   String? contactPhone,
  //   dynamic contactEmail,
  //   dynamic widgetOneLabels,
  //   dynamic widgetOneLinks,
  //   dynamic widgetOne,
  //   dynamic frontendCopyrightText,
  //   dynamic showSocialLinks,
  //   dynamic facebookLink,
  //   dynamic twitterLink,
  //   dynamic instagramLink,
  //   dynamic youtubeLink,
  //   dynamic linkedinLink,
  //   dynamic paymentMethodImages,
  //   String? homeSliderImages,
  //   String? homeSliderLinks,
  //   String? homeBanner1Images,
  //   String? homeBanner1Links,
  //   String? homeBanner2Images,
  //   String? homeBanner2Links,
  //   String? homeCategories,
  //   String? top10Categories,
  //   String? top10Brands,
  //   String? websiteName,
  //   dynamic siteMotto,
  //   String? siteIcon,
  //   String? baseColor,
  //   String? baseHovColor,
  //   dynamic metaTitle,
  //   dynamic metaDescription,
  //   dynamic metaKeywords,
  //   dynamic metaImage,
  //   String? siteName,
  //   String? systemLogoWhite,
  //   String? systemLogoBlack,
  //   dynamic timezone,
  //   dynamic adminLoginBackground,
  //   String? iyzicoSandbox,
  //   String? decimalSeparator,
  //   String? bkashSandbox,
  //   String? headerMenuLabels,
  //   String? headerMenuLinks,
  //   String? proxypay,
  //   String? proxypaySandbox,
  //   String? googleMap,
  //   String? googleFirebase,
  //   String? authorizenetSandbox,
  //   dynamic minOrderAmountCheckActivat,
  //   String? minimumOrderAmount,
  //   String? itemName,
  //   String? aamarpaySandbox,
  //   String? secondaryBaseColor,
  //   String? secondaryBaseHovColor,
  //   String? headerNavMenuText,
  //   String? homepageSelect,
  //   dynamic todaysDealSectionBg,
  //   String? todaysDealSectionBgColor,
  //   String? flashDealBgColor,
  //   dynamic flashDealBgFullWidth,
  //   String? flashDealBannerMenuText,
  //   String? todaysDealBannerTextColor,
  //   String? couponBackgroundImage,
  //   String? adminLoginPageImage,
  //   String? customerLoginPageImage,
  //   dynamic customerRegisterPageImage,
  //   dynamic sellerLoginPageImage,
  //   dynamic sellerRegisterPageImage,
  //   dynamic deliveryBoyLoginPageImage,
  //   String? forgotPasswordPageImage,
  //   dynamic passwordResetPageImage,
  //   dynamic phoneNumberVerifyPageImage,
  //   String? authenticationLayoutSelect,
  //   String? flashDealCardBgImage,
  //   String? flashDealCardBgTitle,
  //   String? flashDealCardBgSubtitle,
  //   String? flashDealCardText,
  //   String? todaysDealCardBgImage,
  //   String? todaysDealCardBgTitle,
  //   String? todaysDealCardBgSubtitle,
  //   String? todaysDealCardText,
  //   String? newProductCardBgImage,
  //   String? newProductCardBgTitle,
  //   String? newProductCardBgSubtitle,
  //   String? newProductCardText,
  //   String? featuredCategoriesText,
  //   String? guestCheckoutActivation,
  //   String? sliderSectionFullWidth,
  //   String? sliderSectionBgColor,
  //   String? homeBanner4Images,
  //   String? homeBanner4Links,
  //   String? homeBanner5Images,
  //   String? homeBanner5Links,
  //   String? homeBanner6Images,
  //   String? homeBanner6Links,
  //   String? lastViewedProductActivation,
  //   String? customAlertLocation,
  //   String? notificationShowType,
  //   String? cuponTextColor,
  //   String? flashDealSectionOutline,
  //   String? flashDealSectionOutlineColor,
  //   String? featuredSectionBgColor,
  //   String? featuredSectionOutline,
  //   String? featuredSectionOutlineColor,
  //   String? bestSellingSectionBgColor,
  //   String? bestSellingSectionOutline,
  //   String? bestSellingSectionOutlineColor,
  //   String? newProductsSectionBgColor,
  //   String? newProductsSectionOutline,
  //   String? newProductsSectionOutlineColor,
  //   String? homeCategoriesSectionBgColor,
  //   String? homeCategoriesContentBgColor,
  //   dynamic homeCategoriesContentOutline,
  //   String? homeCategoriesContentOutlineColor,
  //   String? classifiedSectionBgColor,
  //   String? classifiedSectionOutline,
  //   String? classifiedSectionOutlineColor,
  //   String? sellersSectionBgColor,
  //   dynamic sellersSectionOutline,
  //   String? sellersSectionOutlineColor,
  //   String? brandsSectionBgColor,
  //   String? brandsSectionOutline,
  //   String? brandsSectionOutlineColor,
  //   String? uploadedImageFormat,
  //   String? productExternalLinkForSeller,
  //   String? useFloatingButtons,
  //   String? sellerCommissionType,
  //   String? purchaseCode,
  //   String? auctionSectionBgColor,
  //   String? auctionContentBgColor,
  //   dynamic auctionSectionOutline,
  //   String? auctionSectionOutlineColor,
  //   String? clubPointConvertRate,
  //   String? toyyibpayPayment,
  //   String? toyyibpaySandbox,
  //   String? paytmPayment,
  //   String? myfatoorah,
  //   dynamic myfatoorahSandbox,
  //   String? khaltiSandbox,
  //   String? phonepePayment,
  //   String? phonepeSandbox,
  //   dynamic headerScript,
  //   String? footerScript,
  //   String? topbarBanner,
  //   String? topbarBannerMedium,
  //   String? topbarBannerSmall,
  //   dynamic topbarBannerLink,
  //   dynamic helplineNumber,
  //   dynamic playStoreLink,
  //   dynamic appStoreLink,
  //   String? footerTitle,
  //   String? footerDescription,
  //   String? disableImageOptimization,
  //   String? viewProductOutOfStock,
  //   String? posAcceptsNegativeQuantity,
  //   String? googleMapLongtitude,
  //   String? googleMapLatitude,
  //   String? adminNotifications,
  //   String? adminRealertNotification,
  //   String? printWidth,
  //   String? todaysDealBanner,
  //   String? todaysDealBannerSmall,
  //   String? todaysDealBgColor,
  //   String? posThermalInvoiceCompanyLogo,
  //   String? posThermalInvoiceCompanyName,
  //   String? posThermalInvoiceCompanyPhone,
  //   String? posThermalInvoiceCompanyEmail,
  //   dynamic flashDealBanner,
  //   dynamic flashDealBannerSmall,
  //   dynamic minimumOrderAmountCheck,
  //   dynamic minimumOrderQuantityCheck,
  //   String? minimumOrderQuantity,
  //   String? homeBanner3Images,
  //   String? homeBanner3Links,
  //   String? auctionBannerImage,
  //   dynamic classifiedBannerImage,
  //   dynamic classifiedBannerImageSmall,
  //   String? topBrands,
  //   String? posThermalInvoiceHeadDetailsFs,
  //   String? posThermalInvoiceProductTableFs,
  //   String? posThermalInvoiceFooterDetailsFs,
  //   dynamic useImageWatermark,
  //   String? imageWatermarkType,
  //   dynamic watermarkImage,
  //   dynamic watermarkText,
  //   dynamic watermarkTextSize,
  //   dynamic watermarkTextColor,
  //   String? watermarkPosition,
  //   String? productManageByAdmin,
  //   String? productApproveByAdmin,
  //   String? productQueryActivation,
  //   String? mustOtp,
  //   String? cuponBackgroundColor,
  //   String? cuponTitle,
  //   String? cuponSubtitle,
  //   String? deliveryPickupLongitude,
  //   String? deliveryPickupLatitude,
  // }) {
  //   return BusinessSettings(
  //     homeDefaultCurrency: homeDefaultCurrency ?? this.homeDefaultCurrency,
  //     systemDefaultCurrency:
  //         systemDefaultCurrency ?? this.systemDefaultCurrency,
  //     currencyFormat: currencyFormat ?? this.currencyFormat,
  //     symbolFormat: symbolFormat ?? this.symbolFormat,
  //     noOfDecimals: noOfDecimals ?? this.noOfDecimals,
  //     productActivation: productActivation ?? this.productActivation,
  //     vendorSystemActivation:
  //         vendorSystemActivation ?? this.vendorSystemActivation,
  //     showVendors: showVendors ?? this.showVendors,
  //     cashPayment: cashPayment ?? this.cashPayment,
  //     payumoneyPayment: payumoneyPayment ?? this.payumoneyPayment,
  //     bestSelling: bestSelling ?? this.bestSelling,
  //     paypalSandbox: paypalSandbox ?? this.paypalSandbox,
  //     sslcommerzSandbox: sslcommerzSandbox ?? this.sslcommerzSandbox,
  //     vendorCommission: vendorCommission ?? this.vendorCommission,
  //     verificationForm: verificationForm ?? this.verificationForm,
  //     googleAnalytics: googleAnalytics ?? this.googleAnalytics,
  //     facebookLogin: facebookLogin ?? this.facebookLogin,
  //     googleLogin: googleLogin ?? this.googleLogin,
  //     twitterLogin: twitterLogin ?? this.twitterLogin,
  //     payumoneySandbox: payumoneySandbox ?? this.payumoneySandbox,
  //     facebookChat: facebookChat ?? this.facebookChat,
  //     emailVerification: emailVerification ?? this.emailVerification,
  //     walletSystem: walletSystem ?? this.walletSystem,
  //     couponSystem: couponSystem ?? this.couponSystem,
  //     currentVersion: currentVersion ?? this.currentVersion,
  //     instamojoSandbox: instamojoSandbox ?? this.instamojoSandbox,
  //     pickupPoint: pickupPoint ?? this.pickupPoint,
  //     maintenanceMode: maintenanceMode ?? this.maintenanceMode,
  //     voguepaySandbox: voguepaySandbox ?? this.voguepaySandbox,
  //     categoryWiseCommission:
  //         categoryWiseCommission ?? this.categoryWiseCommission,
  //     conversationSystem: conversationSystem ?? this.conversationSystem,
  //     guestCheckoutActive: guestCheckoutActive ?? this.guestCheckoutActive,
  //     facebookPixel: facebookPixel ?? this.facebookPixel,
  //     classifiedProduct: classifiedProduct ?? this.classifiedProduct,
  //     posActivationForSeller:
  //         posActivationForSeller ?? this.posActivationForSeller,
  //     shippingType: shippingType ?? this.shippingType,
  //     flatRateShippingCost: flatRateShippingCost ?? this.flatRateShippingCost,
  //     shippingCostAdmin: shippingCostAdmin ?? this.shippingCostAdmin,
  //     payhereSandbox: payhereSandbox ?? this.payhereSandbox,
  //     googleRecaptcha: googleRecaptcha ?? this.googleRecaptcha,
  //     headerLogo: headerLogo ?? this.headerLogo,
  //     showLanguageSwitcher: showLanguageSwitcher ?? this.showLanguageSwitcher,
  //     showCurrencySwitcher: showCurrencySwitcher ?? this.showCurrencySwitcher,
  //     headerStikcy: headerStikcy ?? this.headerStikcy,
  //     footerLogo: footerLogo ?? this.footerLogo,
  //     aboutUsDescription: aboutUsDescription ?? this.aboutUsDescription,
  //     contactAddress: contactAddress ?? this.contactAddress,
  //     contactPhone: contactPhone ?? this.contactPhone,
  //     contactEmail: contactEmail ?? this.contactEmail,
  //     widgetOneLabels: widgetOneLabels ?? this.widgetOneLabels,
  //     widgetOneLinks: widgetOneLinks ?? this.widgetOneLinks,
  //     widgetOne: widgetOne ?? this.widgetOne,
  //     frontendCopyrightText:
  //         frontendCopyrightText ?? this.frontendCopyrightText,
  //     showSocialLinks: showSocialLinks ?? this.showSocialLinks,
  //     facebookLink: facebookLink ?? this.facebookLink,
  //     twitterLink: twitterLink ?? this.twitterLink,
  //     instagramLink: instagramLink ?? this.instagramLink,
  //     youtubeLink: youtubeLink ?? this.youtubeLink,
  //     linkedinLink: linkedinLink ?? this.linkedinLink,
  //     paymentMethodImages: paymentMethodImages ?? this.paymentMethodImages,
  //     homeSliderImages: homeSliderImages ?? this.homeSliderImages,
  //     homeSliderLinks: homeSliderLinks ?? this.homeSliderLinks,
  //     homeBanner1Images: homeBanner1Images ?? this.homeBanner1Images,
  //     homeBanner1Links: homeBanner1Links ?? this.homeBanner1Links,
  //     homeBanner2Images: homeBanner2Images ?? this.homeBanner2Images,
  //     homeBanner2Links: homeBanner2Links ?? this.homeBanner2Links,
  //     homeCategories: homeCategories ?? this.homeCategories,
  //     top10Categories: top10Categories ?? this.top10Categories,
  //     top10Brands: top10Brands ?? this.top10Brands,
  //     websiteName: websiteName ?? this.websiteName,
  //     siteMotto: siteMotto ?? this.siteMotto,
  //     siteIcon: siteIcon ?? this.siteIcon,
  //     baseColor: baseColor ?? this.baseColor,
  //     baseHovColor: baseHovColor ?? this.baseHovColor,
  //     metaTitle: metaTitle ?? this.metaTitle,
  //     metaDescription: metaDescription ?? this.metaDescription,
  //     metaKeywords: metaKeywords ?? this.metaKeywords,
  //     metaImage: metaImage ?? this.metaImage,
  //     siteName: siteName ?? this.siteName,
  //     systemLogoWhite: systemLogoWhite ?? this.systemLogoWhite,
  //     systemLogoBlack: systemLogoBlack ?? this.systemLogoBlack,
  //     timezone: timezone ?? this.timezone,
  //     adminLoginBackground: adminLoginBackground ?? this.adminLoginBackground,
  //     iyzicoSandbox: iyzicoSandbox ?? this.iyzicoSandbox,
  //     decimalSeparator: decimalSeparator ?? this.decimalSeparator,
  //     bkashSandbox: bkashSandbox ?? this.bkashSandbox,
  //     headerMenuLabels: headerMenuLabels ?? this.headerMenuLabels,
  //     headerMenuLinks: headerMenuLinks ?? this.headerMenuLinks,
  //     proxypay: proxypay ?? this.proxypay,
  //     proxypaySandbox: proxypaySandbox ?? this.proxypaySandbox,
  //     googleMap: googleMap ?? this.googleMap,
  //     googleFirebase: googleFirebase ?? this.googleFirebase,
  //     authorizenetSandbox: authorizenetSandbox ?? this.authorizenetSandbox,
  //     minOrderAmountCheckActivat:
  //         minOrderAmountCheckActivat ?? this.minOrderAmountCheckActivat,
  //     minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
  //     itemName: itemName ?? this.itemName,
  //     aamarpaySandbox: aamarpaySandbox ?? this.aamarpaySandbox,
  //     secondaryBaseColor: secondaryBaseColor ?? this.secondaryBaseColor,
  //     secondaryBaseHovColor:
  //         secondaryBaseHovColor ?? this.secondaryBaseHovColor,
  //     headerNavMenuText: headerNavMenuText ?? this.headerNavMenuText,
  //     homepageSelect: homepageSelect ?? this.homepageSelect,
  //     todaysDealSectionBg: todaysDealSectionBg ?? this.todaysDealSectionBg,
  //     todaysDealSectionBgColor:
  //         todaysDealSectionBgColor ?? this.todaysDealSectionBgColor,
  //     flashDealBgColor: flashDealBgColor ?? this.flashDealBgColor,
  //     flashDealBgFullWidth: flashDealBgFullWidth ?? this.flashDealBgFullWidth,
  //     flashDealBannerMenuText:
  //         flashDealBannerMenuText ?? this.flashDealBannerMenuText,
  //     todaysDealBannerTextColor:
  //         todaysDealBannerTextColor ?? this.todaysDealBannerTextColor,
  //     couponBackgroundImage:
  //         couponBackgroundImage ?? this.couponBackgroundImage,
  //     adminLoginPageImage: adminLoginPageImage ?? this.adminLoginPageImage,
  //     customerLoginPageImage:
  //         customerLoginPageImage ?? this.customerLoginPageImage,
  //     customerRegisterPageImage:
  //         customerRegisterPageImage ?? this.customerRegisterPageImage,
  //     sellerLoginPageImage: sellerLoginPageImage ?? this.sellerLoginPageImage,
  //     sellerRegisterPageImage:
  //         sellerRegisterPageImage ?? this.sellerRegisterPageImage,
  //     deliveryBoyLoginPageImage:
  //         deliveryBoyLoginPageImage ?? this.deliveryBoyLoginPageImage,
  //     forgotPasswordPageImage:
  //         forgotPasswordPageImage ?? this.forgotPasswordPageImage,
  //     passwordResetPageImage:
  //         passwordResetPageImage ?? this.passwordResetPageImage,
  //     phoneNumberVerifyPageImage:
  //         phoneNumberVerifyPageImage ?? this.phoneNumberVerifyPageImage,
  //     authenticationLayoutSelect:
  //         authenticationLayoutSelect ?? this.authenticationLayoutSelect,
  //     flashDealCardBgImage: flashDealCardBgImage ?? this.flashDealCardBgImage,
  //     flashDealCardBgTitle: flashDealCardBgTitle ?? this.flashDealCardBgTitle,
  //     flashDealCardBgSubtitle:
  //         flashDealCardBgSubtitle ?? this.flashDealCardBgSubtitle,
  //     flashDealCardText: flashDealCardText ?? this.flashDealCardText,
  //     todaysDealCardBgImage:
  //         todaysDealCardBgImage ?? this.todaysDealCardBgImage,
  //     todaysDealCardBgTitle:
  //         todaysDealCardBgTitle ?? this.todaysDealCardBgTitle,
  //     todaysDealCardBgSubtitle:
  //         todaysDealCardBgSubtitle ?? this.todaysDealCardBgSubtitle,
  //     todaysDealCardText: todaysDealCardText ?? this.todaysDealCardText,
  //     newProductCardBgImage:
  //         newProductCardBgImage ?? this.newProductCardBgImage,
  //     newProductCardBgTitle:
  //         newProductCardBgTitle ?? this.newProductCardBgTitle,
  //     newProductCardBgSubtitle:
  //         newProductCardBgSubtitle ?? this.newProductCardBgSubtitle,
  //     newProductCardText: newProductCardText ?? this.newProductCardText,
  //     featuredCategoriesText:
  //         featuredCategoriesText ?? this.featuredCategoriesText,
  //     guestCheckoutActivation:
  //         guestCheckoutActivation ?? this.guestCheckoutActivation,
  //     sliderSectionFullWidth:
  //         sliderSectionFullWidth ?? this.sliderSectionFullWidth,
  //     sliderSectionBgColor: sliderSectionBgColor ?? this.sliderSectionBgColor,
  //     homeBanner4Images: homeBanner4Images ?? this.homeBanner4Images,
  //     homeBanner4Links: homeBanner4Links ?? this.homeBanner4Links,
  //     homeBanner5Images: homeBanner5Images ?? this.homeBanner5Images,
  //     homeBanner5Links: homeBanner5Links ?? this.homeBanner5Links,
  //     homeBanner6Images: homeBanner6Images ?? this.homeBanner6Images,
  //     homeBanner6Links: homeBanner6Links ?? this.homeBanner6Links,
  //     lastViewedProductActivation:
  //         lastViewedProductActivation ?? this.lastViewedProductActivation,
  //     customAlertLocation: customAlertLocation ?? this.customAlertLocation,
  //     notificationShowType: notificationShowType ?? this.notificationShowType,
  //     cuponTextColor: cuponTextColor ?? this.cuponTextColor,
  //     flashDealSectionOutline:
  //         flashDealSectionOutline ?? this.flashDealSectionOutline,
  //     flashDealSectionOutlineColor:
  //         flashDealSectionOutlineColor ?? this.flashDealSectionOutlineColor,
  //     featuredSectionBgColor:
  //         featuredSectionBgColor ?? this.featuredSectionBgColor,
  //     featuredSectionOutline:
  //         featuredSectionOutline ?? this.featuredSectionOutline,
  //     featuredSectionOutlineColor:
  //         featuredSectionOutlineColor ?? this.featuredSectionOutlineColor,
  //     bestSellingSectionBgColor:
  //         bestSellingSectionBgColor ?? this.bestSellingSectionBgColor,
  //     bestSellingSectionOutline:
  //         bestSellingSectionOutline ?? this.bestSellingSectionOutline,
  //     bestSellingSectionOutlineColor:
  //         bestSellingSectionOutlineColor ?? this.bestSellingSectionOutlineColor,
  //     newProductsSectionBgColor:
  //         newProductsSectionBgColor ?? this.newProductsSectionBgColor,
  //     newProductsSectionOutline:
  //         newProductsSectionOutline ?? this.newProductsSectionOutline,
  //     newProductsSectionOutlineColor:
  //         newProductsSectionOutlineColor ?? this.newProductsSectionOutlineColor,
  //     homeCategoriesSectionBgColor:
  //         homeCategoriesSectionBgColor ?? this.homeCategoriesSectionBgColor,
  //     homeCategoriesContentBgColor:
  //         homeCategoriesContentBgColor ?? this.homeCategoriesContentBgColor,
  //     homeCategoriesContentOutline:
  //         homeCategoriesContentOutline ?? this.homeCategoriesContentOutline,
  //     homeCategoriesContentOutlineColor: homeCategoriesContentOutlineColor ??
  //         this.homeCategoriesContentOutlineColor,
  //     classifiedSectionBgColor:
  //         classifiedSectionBgColor ?? this.classifiedSectionBgColor,
  //     classifiedSectionOutline:
  //         classifiedSectionOutline ?? this.classifiedSectionOutline,
  //     classifiedSectionOutlineColor:
  //         classifiedSectionOutlineColor ?? this.classifiedSectionOutlineColor,
  //     sellersSectionBgColor:
  //         sellersSectionBgColor ?? this.sellersSectionBgColor,
  //     sellersSectionOutline:
  //         sellersSectionOutline ?? this.sellersSectionOutline,
  //     sellersSectionOutlineColor:
  //         sellersSectionOutlineColor ?? this.sellersSectionOutlineColor,
  //     brandsSectionBgColor: brandsSectionBgColor ?? this.brandsSectionBgColor,
  //     brandsSectionOutline: brandsSectionOutline ?? this.brandsSectionOutline,
  //     brandsSectionOutlineColor:
  //         brandsSectionOutlineColor ?? this.brandsSectionOutlineColor,
  //     uploadedImageFormat: uploadedImageFormat ?? this.uploadedImageFormat,
  //     productExternalLinkForSeller:
  //         productExternalLinkForSeller ?? this.productExternalLinkForSeller,
  //     useFloatingButtons: useFloatingButtons ?? this.useFloatingButtons,
  //     sellerCommissionType: sellerCommissionType ?? this.sellerCommissionType,
  //     purchaseCode: purchaseCode ?? this.purchaseCode,
  //     auctionSectionBgColor:
  //         auctionSectionBgColor ?? this.auctionSectionBgColor,
  //     auctionContentBgColor:
  //         auctionContentBgColor ?? this.auctionContentBgColor,
  //     auctionSectionOutline:
  //         auctionSectionOutline ?? this.auctionSectionOutline,
  //     auctionSectionOutlineColor:
  //         auctionSectionOutlineColor ?? this.auctionSectionOutlineColor,
  //     clubPointConvertRate: clubPointConvertRate ?? this.clubPointConvertRate,
  //     toyyibpayPayment: toyyibpayPayment ?? this.toyyibpayPayment,
  //     toyyibpaySandbox: toyyibpaySandbox ?? this.toyyibpaySandbox,
  //     paytmPayment: paytmPayment ?? this.paytmPayment,
  //     myfatoorah: myfatoorah ?? this.myfatoorah,
  //     myfatoorahSandbox: myfatoorahSandbox ?? this.myfatoorahSandbox,
  //     khaltiSandbox: khaltiSandbox ?? this.khaltiSandbox,
  //     phonepePayment: phonepePayment ?? this.phonepePayment,
  //     phonepeSandbox: phonepeSandbox ?? this.phonepeSandbox,
  //     headerScript: headerScript ?? this.headerScript,
  //     footerScript: footerScript ?? this.footerScript,
  //     topbarBanner: topbarBanner ?? this.topbarBanner,
  //     topbarBannerMedium: topbarBannerMedium ?? this.topbarBannerMedium,
  //     topbarBannerSmall: topbarBannerSmall ?? this.topbarBannerSmall,
  //     topbarBannerLink: topbarBannerLink ?? this.topbarBannerLink,
  //     helplineNumber: helplineNumber ?? this.helplineNumber,
  //     playStoreLink: playStoreLink ?? this.playStoreLink,
  //     appStoreLink: appStoreLink ?? this.appStoreLink,
  //     footerTitle: footerTitle ?? this.footerTitle,
  //     footerDescription: footerDescription ?? this.footerDescription,
  //     disableImageOptimization:
  //         disableImageOptimization ?? this.disableImageOptimization,
  //     viewProductOutOfStock:
  //         viewProductOutOfStock ?? this.viewProductOutOfStock,
  //     posAcceptsNegativeQuantity:
  //         posAcceptsNegativeQuantity ?? this.posAcceptsNegativeQuantity,
  //     googleMapLongtitude: googleMapLongtitude ?? this.googleMapLongtitude,
  //     googleMapLatitude: googleMapLatitude ?? this.googleMapLatitude,
  //     adminNotifications: adminNotifications ?? this.adminNotifications,
  //     adminRealertNotification:
  //         adminRealertNotification ?? this.adminRealertNotification,
  //     printWidth: printWidth ?? this.printWidth,
  //     todaysDealBanner: todaysDealBanner ?? this.todaysDealBanner,
  //     todaysDealBannerSmall:
  //         todaysDealBannerSmall ?? this.todaysDealBannerSmall,
  //     todaysDealBgColor: todaysDealBgColor ?? this.todaysDealBgColor,
  //     posThermalInvoiceCompanyLogo:
  //         posThermalInvoiceCompanyLogo ?? this.posThermalInvoiceCompanyLogo,
  //     posThermalInvoiceCompanyName:
  //         posThermalInvoiceCompanyName ?? this.posThermalInvoiceCompanyName,
  //     posThermalInvoiceCompanyPhone:
  //         posThermalInvoiceCompanyPhone ?? this.posThermalInvoiceCompanyPhone,
  //     posThermalInvoiceCompanyEmail:
  //         posThermalInvoiceCompanyEmail ?? this.posThermalInvoiceCompanyEmail,
  //     flashDealBanner: flashDealBanner ?? this.flashDealBanner,
  //     flashDealBannerSmall: flashDealBannerSmall ?? this.flashDealBannerSmall,
  //     minimumOrderAmountCheck:
  //         minimumOrderAmountCheck ?? this.minimumOrderAmountCheck,
  //     minimumOrderQuantityCheck:
  //         minimumOrderQuantityCheck ?? this.minimumOrderQuantityCheck,
  //     minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
  //     homeBanner3Images: homeBanner3Images ?? this.homeBanner3Images,
  //     homeBanner3Links: homeBanner3Links ?? this.homeBanner3Links,
  //     auctionBannerImage: auctionBannerImage ?? this.auctionBannerImage,
  //     classifiedBannerImage:
  //         classifiedBannerImage ?? this.classifiedBannerImage,
  //     classifiedBannerImageSmall:
  //         classifiedBannerImageSmall ?? this.classifiedBannerImageSmall,
  //     topBrands: topBrands ?? this.topBrands,
  //     posThermalInvoiceHeadDetailsFs:
  //         posThermalInvoiceHeadDetailsFs ?? this.posThermalInvoiceHeadDetailsFs,
  //     posThermalInvoiceProductTableFs: posThermalInvoiceProductTableFs ??
  //         this.posThermalInvoiceProductTableFs,
  //     posThermalInvoiceFooterDetailsFs: posThermalInvoiceFooterDetailsFs ??
  //         this.posThermalInvoiceFooterDetailsFs,
  //     useImageWatermark: useImageWatermark ?? this.useImageWatermark,
  //     imageWatermarkType: imageWatermarkType ?? this.imageWatermarkType,
  //     watermarkImage: watermarkImage ?? this.watermarkImage,
  //     watermarkText: watermarkText ?? this.watermarkText,
  //     watermarkTextSize: watermarkTextSize ?? this.watermarkTextSize,
  //     watermarkTextColor: watermarkTextColor ?? this.watermarkTextColor,
  //     watermarkPosition: watermarkPosition ?? this.watermarkPosition,
  //     productManageByAdmin: productManageByAdmin ?? this.productManageByAdmin,
  //     productApproveByAdmin:
  //         productApproveByAdmin ?? this.productApproveByAdmin,
  //     productQueryActivation:
  //         productQueryActivation ?? this.productQueryActivation,
  //     mustOtp: mustOtp ?? this.mustOtp,
  //     cuponBackgroundColor: cuponBackgroundColor ?? this.cuponBackgroundColor,
  //     cuponTitle: cuponTitle ?? this.cuponTitle,
  //     cuponSubtitle: cuponSubtitle ?? this.cuponSubtitle,
  //     deliveryPickupLongitude:
  //         deliveryPickupLongitude ?? this.deliveryPickupLongitude,
  //     deliveryPickupLatitude:
  //         deliveryPickupLatitude ?? this.deliveryPickupLatitude,
  //   );
  // }

  @override
  List<Object?> get props {
    return [
      usePackingWholesaleProduct,
      whatsappNumber,
      homeDefaultCurrency,
      systemDefaultCurrency,
      currencyFormat,
      symbolFormat,
      noOfDecimals,
      productActivation,
      vendorSystemActivation,
      showVendors,
      cashPayment,
      payumoneyPayment,
      bestSelling,
      paypalSandbox,
      sslcommerzSandbox,
      vendorCommission,
      verificationForm,
      googleAnalytics,
      payumoneySandbox,
      facebookChat,
      mailVerificationStatus,
      walletSystem,
      couponSystem,
      currentVersion,
      instamojoSandbox,
      pickupPoint,
      maintenanceMode,
      voguepaySandbox,
      categoryWiseCommission,
      conversationSystem,
      guestCheckoutActive,
      facebookPixel,
      classifiedProduct,
      posActivationForSeller,
      shippingType,
      flatRateShippingCost,
      shippingCostAdmin,
      payhereSandbox,
      googleRecaptcha,
      headerLogo,
      showLanguageSwitcher,
      showCurrencySwitcher,
      headerStikcy,
      footerLogo,
      aboutUsDescription,
      contactAddress,
      contactPhone,
      contactEmail,
      widgetOneLabels,
      widgetOneLinks,
      widgetOne,
      frontendCopyrightText,
      showSocialLinks,
      facebookLink,
      twitterLink,
      instagramLink,
      youtubeLink,
      linkedinLink,
      paymentMethodImages,
      homeSliderImages,
      homeSliderLinks,
      homeBanner1Images,
      homeBanner1Links,
      homeBanner2Images,
      homeBanner2Links,
      homeCategories,
      top10Categories,
      top10Brands,
      websiteName,
      siteMotto,
      siteIcon,
      primaryColor,
      primaryHovColor,
      metaTitle,
      metaDescription,
      metaKeywords,
      metaImage,
      siteName,
      systemLogoWhite,
      systemLogoBlack,
      timezone,
      adminLoginBackground,
      iyzicoSandbox,
      decimalSeparator,
      bkashSandbox,
      headerMenuLabels,
      headerMenuLinks,
      proxypay,
      proxypaySandbox,
      googleMap,
      googleFirebase,
      authorizenetSandbox,
      minOrderAmountCheckActivat,
      minimumOrderAmount,
      freeShippingMinimumOrderAmount,
      freeShippingMinimumCheck,
      itemName,
      aamarpaySandbox,
      secondaryColor,
      secondaryHovColor,
      headerNavMenuText,
      selectedHomePage,
      todaysDealSectionBg,
      todaysDealSectionBgColor,
      flashDealBgColor,
      flashDealBgFullWidth,
      flashDealBannerMenuText,
      todaysDealBannerTextColor,
      couponBackgroundImage,
      adminLoginPageImage,
      customerLoginPageImage,
      customerRegisterPageImage,
      sellerLoginPageImage,
      sellerRegisterPageImage,
      deliveryBoyLoginPageImage,
      forgotPasswordPageImage,
      passwordResetPageImage,
      phoneNumberVerifyPageImage,
      authenticationLayoutSelect,
      flashDealCardBgImage,
      flashDealCardBgTitle,
      flashDealCardBgSubtitle,
      flashDealCardText,
      todaysDealCardBgImage,
      todaysDealCardBgTitle,
      todaysDealCardBgSubtitle,
      todaysDealCardText,
      newProductCardBgImage,
      newProductCardBgTitle,
      newProductCardBgSubtitle,
      newProductCardText,
      featuredCategoriesText,
      guestCheckoutStatus,
      sliderSectionFullWidth,
      sliderSectionBgColor,
      homeBanner4Images,
      homeBanner4Links,
      homeBanner5Images,
      homeBanner5Links,
      homeBanner6Images,
      homeBanner6Links,
      lastViewedProductActivation,
      customAlertLocation,
      notificationShowType,
      cuponTextColor,
      flashDealSectionOutline,
      flashDealSectionOutlineColor,
      featuredSectionBgColor,
      featuredSectionOutline,
      featuredSectionOutlineColor,
      bestSellingSectionBgColor,
      bestSellingSectionOutline,
      bestSellingSectionOutlineColor,
      newProductsSectionBgColor,
      newProductsSectionOutline,
      newProductsSectionOutlineColor,
      homeCategoriesSectionBgColor,
      homeCategoriesContentBgColor,
      homeCategoriesContentOutline,
      homeCategoriesContentOutlineColor,
      classifiedSectionBgColor,
      classifiedSectionOutline,
      classifiedSectionOutlineColor,
      sellersSectionBgColor,
      sellersSectionOutline,
      sellersSectionOutlineColor,
      brandsSectionBgColor,
      brandsSectionOutline,
      brandsSectionOutlineColor,
      uploadedImageFormat,
      productExternalLinkForSeller,
      useFloatingButtons,
      sellerCommissionType,
      purchaseCode,
      auctionSectionBgColor,
      auctionContentBgColor,
      auctionSectionOutline,
      auctionSectionOutlineColor,
      clubPointConvertRate,
      toyyibpayPayment,
      toyyibpaySandbox,
      paytmPayment,
      myfatoorah,
      myfatoorahSandbox,
      khaltiSandbox,
      phonepePayment,
      phonepeSandbox,
      headerScript,
      footerScript,
      topbarBanner,
      topbarBannerMedium,
      topbarBannerSmall,
      topbarBannerLink,
      helplineNumber,
      playStoreLink,
      appStoreLink,
      footerTitle,
      footerDescription,
      disableImageOptimization,
      viewProductOutOfStock,
      posAcceptsNegativeQuantity,
      adminNotifications,
      adminRealertNotification,
      printWidth,
      todaysDealBanner,
      todaysDealBannerSmall,
      todaysDealBgColor,
      posThermalInvoiceCompanyLogo,
      posThermalInvoiceCompanyName,
      posThermalInvoiceCompanyPhone,
      posThermalInvoiceCompanyEmail,
      flashDealBanner,
      flashDealBannerSmall,
      minimumOrderAmountCheck,
      minimumOrderQuantityCheck,
      minimumOrderQuantity,
      homeBanner3Images,
      homeBanner3Links,
      auctionBannerImage,
      classifiedBannerImage,
      classifiedBannerImageSmall,
      topBrands,
      posThermalInvoiceHeadDetailsFs,
      posThermalInvoiceProductTableFs,
      posThermalInvoiceFooterDetailsFs,
      useImageWatermark,
      imageWatermarkType,
      watermarkImage,
      watermarkText,
      watermarkTextSize,
      watermarkTextColor,
      watermarkPosition,
      productManageByAdmin,
      productApproveByAdmin,
      productQueryActivation,
      mustOtp,
      cuponBackgroundColor,
      cuponTitle,
      cuponSubtitle,
      deliveryPickupLongitude,
      deliveryPickupLatitude,
      categoryAppStyle,
      diplayDiscountType,
      showBrandName,
    ];
  }
}

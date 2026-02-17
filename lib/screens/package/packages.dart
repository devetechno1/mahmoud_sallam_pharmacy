import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/enum_classes.dart';

import 'package:active_ecommerce_cms_demo_app/custom/style.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/customer_package_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/customer_package_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/checkout/checkout.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../../helpers/shared_value_helper.dart';
import '../auth/login.dart';

class UpdatePackage extends StatefulWidget {
  final bool goHome;

  const UpdatePackage({Key? key, this.goHome = false}) : super(key: key);

  @override
  State<UpdatePackage> createState() => _UpdatePackageState();
}

class _UpdatePackageState extends State<UpdatePackage> {
  List<Package> _packages = [];
  bool _isFetchAllData = false;

  Future<bool> getPackageList() async {
    final response = await CustomerPackageRepository().getList();
    _packages.addAll(response.data!);
    setState(() {});
    return true;
  }

  Future<bool> sendFreePackageReq(id) async {
    final response = await CustomerPackageRepository().freePackagePayment(id);
    ToastComponent.showDialog(
      response.message,
    );

    if (response.result) {
      Navigator.pop(context);
    }

    setState(() {});
    return true;
  }

  Future<bool> fetchData() async {
    await getPackageList();
    _isFetchAllData = true;
    setState(() {});
    return true;
  }

  clearData() {
    _isFetchAllData = false;
    _packages = [];
    setState(() {});
  }

  Future<bool> resetData() {
    clearData();
    return fetchData();
  }

  Future<void> refresh() async {
    await resetData();
    return Future.delayed(const Duration(seconds: 0));
  }

  @override
  void initState() {
    fetchData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.goHome) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Main();
          }));
        }

        return Future.delayed(Duration.zero);
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          elevation: 0,
          backgroundColor: MyTheme.white,
          title: Text(
            'packages_ucf'.tr(context: context),
            style: MyStyle.appBarStyle,
          ),
          //leadingWidth: 20,
          leading: widget.goHome
              ? UsefulElements.backToMain(go_back: false)
              : IconButton(
                  icon: Icon(
                      app_language_rtl.$!
                          ? CupertinoIcons.arrow_right
                          : CupertinoIcons.arrow_left,
                      color: MyTheme.dark_font_grey),
                  onPressed: () => Navigator.pop(context),
                ),
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: buildList(),
            ),
          ),
        ),
      ),
    );
  }

  ListView buildList() {
    return _isFetchAllData
        ? ListView.separated(
            padding: const EdgeInsets.only(top: AppDimensions.paddingSupSmall),
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 10,
              );
            },
            itemCount: _packages.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return packageItem(
                index,
                context,
                _packages[index].logo,
                _packages[index].name!,
                _packages[index].amount!,
                _packages[index].productUploadLimit.toString(),
                _packages[index].price,
                _packages[index].id,
              );
            })
        : loadingShimmer() as ListView;
  }

  Widget loadingShimmer() {
    return ShimmerHelper().buildListShimmer(item_count: 10, item_height: 170.0);
  }

  Widget packageItem(
      int index,
      BuildContext context,
      String? url,
      String packageName,
      String packagePrice,
      String packageProduct,
      price,
      packageId) {
    print(url);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecorations.buildBoxDecoration_1(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UsefulElements.roundImageWithPlaceholder(
                width: 30.0,
                height: 30.0,
                url: url,
                backgroundColor: MyTheme.noColor),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                packageName,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.normal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
              child: Container(
                width: DeviceInfo(context).width! / 2,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusHalfSmall)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                    onTap: () {
                      if (is_logged_in.$) {
                        if (double.parse(price.toString()) <= 0) {
                          sendFreePackageReq(packageId);
                          return;
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Checkout(
                                        title: 'purchase_package'
                                            .tr(context: context),
                                        rechargeAmount:
                                            double.parse(price.toString()),
                                        paymentFor: PaymentFor.PackagePay,
                                        packageId: packageId,
                                      )));
                        }
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()));
                      }
                    },
                    radius: 3.0,
                    child: Text(
                      packagePrice,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: MyTheme.white),
                      textAlign: TextAlign.center,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
              child: Container(
                width: DeviceInfo(context).width! / 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 11,
                    ),
                    Text(
                      packageProduct +
                          " " +
                          'upload_limit_ucf'.tr(context: context),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

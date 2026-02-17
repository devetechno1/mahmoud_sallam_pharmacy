import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/select_address_provider.dart';
import 'package:active_ecommerce_cms_demo_app/screens/address.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_config.dart';
import '../map_location.dart';

class SelectAddress extends StatefulWidget {
  final int? owner_id;
  const SelectAddress({Key? key, this.owner_id}) : super(key: key);

  @override
  State<SelectAddress> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  double mWidth = 0;
  double mHeight = 0;

  @override
  Widget build(BuildContext context) {
    mHeight = MediaQuery.sizeOf(context).height;
    mWidth = MediaQuery.sizeOf(context).width;
    return ChangeNotifierProvider(
      create: (_) => SelectAddressProvider()..init(context),
      child: Consumer<SelectAddressProvider>(
          builder: (context, selectAddressProvider, _) {
        return Directionality(
          textDirection:
              app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: UsefulElements.backButton(),
              backgroundColor: MyTheme.white,
              title: buildAppbarTitle(context),
            ),
            backgroundColor: Colors.white,
            bottomNavigationBar:
                buildBottomAppBar(context, selectAddressProvider),
            body: RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () => selectAddressProvider.onRefresh(context),
              displacement: 0,
              child: Container(
                child: CustomScrollView(
                  controller: selectAddressProvider.mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                        delegate: SliverChildListDelegate([
                      Padding(
                          padding: const EdgeInsets.all(
                              AppDimensions.paddingDefault),
                          child: buildShippingInfoList(
                              selectAddressProvider, context)),
                      buildAddOrEditAddress(context, selectAddressProvider),
                      const SizedBox(
                        height: 100,
                      )
                    ]))
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildAddOrEditAddress(
      BuildContext context, SelectAddressProvider provider) {
    return Container(
      height: 40,
      child: Center(
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const AddressScreen(
                from_shipping_info: true,
                goHome: false,
              );
            })).then((value) {
              provider.onPopped(value, context);
            });
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),       
           child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMaxLarge,
                  vertical: AppDimensions.paddingSmall),
              child: Text(
                'to_add_or_edit_addresses_go_to_address_page'
                    .tr(context: context),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? buildShippingInfoList(
      SelectAddressProvider selectAddressProvider, BuildContext context) {
    if (is_logged_in.$ == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            'you_need_to_log_in'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    } else if (!selectAddressProvider.faceData &&
        selectAddressProvider.shippingAddressList.isEmpty) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (selectAddressProvider.shippingAddressList.isNotEmpty) {
      return SingleChildScrollView(
        child: ListView.builder(
          itemCount: selectAddressProvider.shippingAddressList.length,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.paddingSmallExtra,
              ),
              child: buildShippingInfoItemCard(
                index,
                selectAddressProvider,
                context,
              ),
            );
          },
        ),
      );
    } else if (selectAddressProvider.faceData &&
        selectAddressProvider.shippingAddressList.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            'no_address_is_added'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    }
    return null;
  }

  GestureDetector buildShippingInfoItemCard(int index,
      SelectAddressProvider selectAddressProvider, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (selectAddressProvider
                .shippingAddressList[index].location_available ==
            true) {
          selectAddressProvider.shippingInfoCardFnc(index, context);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MapLocation(
                address: selectAddressProvider.shippingAddressList[index]);
          })).then((value) async {
            if (value != null) {
              await selectAddressProvider.onRefresh(context);
              selectAddressProvider.shippingInfoCardFnc(index, context);
            }
          });
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: selectAddressProvider.selectedShippingAddress ==
                  selectAddressProvider.shippingAddressList[index].id
              ? BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
              : const BorderSide(color: MyTheme.light_grey, width: 1.0),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        elevation: 0.0,
        child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LineData(
                        name: 'address_ucf'.tr(context: context),
                        body:
                            "${selectAddressProvider.shippingAddressList[index].address}",
                      ),
                    ),
                    buildShippingOptionsCheckContainer(
                        selectAddressProvider.selectedShippingAddress ==
                            selectAddressProvider.shippingAddressList[index].id)
                  ],
                ),
                LineData(
                  name: 'city_ucf'.tr(context: context),
                  body:
                      "${selectAddressProvider.shippingAddressList[index].city_name}",
                ),
                LineData(
                  name: 'state_ucf'.tr(context: context),
                  body:
                      "${selectAddressProvider.shippingAddressList[index].state_name}",
                ),
                LineData(
                  name: 'country_ucf'.tr(context: context),
                  body:
                      "${selectAddressProvider.shippingAddressList[index].country_name}",
                ),
                LineData(
                  name: 'postal_code'.tr(context: context),
                  body:
                      "${selectAddressProvider.shippingAddressList[index].postal_code}",
                ),
                LineData(
                  name: 'phone_ucf'.tr(context: context),
                  body:
                      "${selectAddressProvider.shippingAddressList[index].phone}",
                ),
                selectAddressProvider
                            .shippingAddressList[index].location_available !=
                        true
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 9),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSmallExtra)),
                          child: Text(
                            'you_have_to_add_location_here'
                                .tr(context: context),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          LineData(
                            name: 'latitude'.tr(context: context),
                            body:
                                "${selectAddressProvider.shippingAddressList[index].lat}",
                          ),
                          LineData(
                            name: 'longitude'.tr(context: context),
                            body:
                                "${selectAddressProvider.shippingAddressList[index].lang}",
                          ),
                        ],
                      ),
              ],
            )

            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     buildShippingInfoItemAddress(index, selectAddressProvider),
            //     buildShippingInfoItemCity(index, selectAddressProvider),
            //     buildShippingInfoItemState(index, selectAddressProvider),
            //     buildShippingInfoItemCountry(index, selectAddressProvider),
            //     buildShippingInfoItemPostalCode(index, selectAddressProvider),
            //     buildShippingInfoItemPhone(index, selectAddressProvider),
            //   ],
            // ),
            ),
      ),
    );
  }

  // Padding buildShippingInfoItemPhone(index, selectAddressProvider) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: AppDimensions.paddingsmall),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: 75,
  //           child: Text(
  //             'phone_ucf'.tr(context: context),
  //             style: TextStyle(
  //               color: MyTheme.grey_153,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           width: 200,
  //           child: Text(
  //             selectAddressProvider.shippingAddressList[index].phone,
  //             maxLines: 2,
  //             style: TextStyle(
  //                 color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Padding buildShippingInfoItemPostalCode(index, selectAddressProvider) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: AppDimensions.paddingsmall),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: 75,
  //           child: Text(
  //             'postal_code'.tr(context: context),
  //             style: TextStyle(
  //               color: MyTheme.grey_153,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           width: 200,
  //           child: Text(
  //             selectAddressProvider.shippingAddressList[index].postal_code,
  //             maxLines: 2,
  //             style: TextStyle(
  //                 color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Padding buildShippingInfoItemCountry(index, selectAddressProvider) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: AppDimensions.paddingsmall),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: 75,
  //           child: Text(
  //             'country_ucf'.tr(context: context),
  //             style: TextStyle(
  //               color: MyTheme.grey_153,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           width: 200,
  //           child: Text(
  //             selectAddressProvider.shippingAddressList[index].country_name,
  //             maxLines: 2,
  //             style: TextStyle(
  //                 color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Padding buildShippingInfoItemState(index, selectAddressProvider) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: AppDimensions.paddingsmall),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: 75,
  //           child: Text(
  //             'state_ucf'.tr(context: context),
  //             style: TextStyle(
  //               color: MyTheme.grey_153,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           width: 200,
  //           child: Text(
  //             selectAddressProvider.shippingAddressList[index].state_name,
  //             maxLines: 2,
  //             style: TextStyle(
  //                 color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Padding buildShippingInfoItemCity(index, selectAddressProvider) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: AppDimensions.paddingsmall),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: 75,
  //           child: Text(
  //             'city_ucf'.tr(context: context),
  //             style: TextStyle(
  //               color: MyTheme.grey_153,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           width: 200,
  //           child: Text(
  //             selectAddressProvider.shippingAddressList[index].city_name,
  //             maxLines: 2,
  //             style: TextStyle(
  //                 color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Padding buildShippingInfoItemAddress(index, selectAddressProvider) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: AppDimensions.paddingsmall),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: 75,
  //           child: Text(
  //             'address_ucf'.tr(context: context),
  //             style: TextStyle(
  //               color: MyTheme.grey_153,
  //             ),
  //           ),
  //         ),
  //         Container(
  //           width: 175,
  //           child: Text(
  //             selectAddressProvider.shippingAddressList[index].address,
  //             maxLines: 2,
  //             style: TextStyle(
  //                 color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //         Spacer(),
  //         buildShippingOptionsCheckContainer(
  //             selectAddressProvider.selectedShippingAddress ==
  //                 selectAddressProvider.shippingAddressList[index].id)
  //       ],
  //     ),
  //   );
  // }

  Widget buildShippingOptionsCheckContainer(bool check) {
    return check
        ? Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusDefault),
                color: Colors.green),
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.check, color: Colors.white, size: 10),
            ),
          )
        : emptyWidget;
  }

  BottomAppBar buildBottomAppBar(
      BuildContext context, SelectAddressProvider provider) {
    return BottomAppBar(
      color: Colors.transparent,
      child: Container(
        height: 50,
        child: Btn.minWidthFixHeight(
          minWidth: MediaQuery.sizeOf(context).width,
          height: 50,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Text(
            'continue_to_delivery_info_ucf'.tr(context: context),
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            provider.onPressProceed(context);
          },
        ),
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: MyTheme.white,
              child: Row(
                children: [
                  buildAppbarBackArrow(),
                ],
              ),
            ),
            // container for gaping into title text and title-bottom buttons
            Container(
              padding: const EdgeInsets.only(top: 2),
              width: mWidth,
              color: MyTheme.light_grey,
              height: 1,
            ),
            //buildChooseShippingOption(context)
          ],
        ),
      ),
    );
  }

  Container buildAppbarTitle(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width - 40,
      child: Text(
        "${'shipping_info'.tr(context: context)}",
        style: const TextStyle(
          fontSize: 16,
          color: MyTheme.dark_font_grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Container buildAppbarBackArrow() {
    return Container(
      width: 40,
      child: UsefulElements.backButton(),
    );
  }
}

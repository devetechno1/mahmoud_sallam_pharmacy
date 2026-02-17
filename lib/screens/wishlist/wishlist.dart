import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/wishlist_repository.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import 'widgets/wishlist_grid_view.dart';

class Wishlist extends StatefulWidget {
  @override
  _WishlistState createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  final ScrollController _mainScrollController = ScrollController();
  bool _wishlistInit = true;
  final List<dynamic> _wishlistItems = [];

  //init
  @override
  void initState() {
    if (is_logged_in.$ == true) {
      fetchWishlistItems();
    }
    super.initState();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  fetchWishlistItems() async {
    final wishlistResponse = await WishListRepository().getUserWishlist();
    _wishlistItems.addAll(wishlistResponse.wishlist_items);
    _wishlistInit = false;
    setState(() {});
  }

  reset() {
    _wishlistInit = true;
    _wishlistItems.clear();
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchWishlistItems();
  }

  // Future<void> _onPressRemove(index) async {
  //   var wishlist_id = _wishlistItems[index].id;
  //   _wishlistItems.removeAt(index);
  //   setState(() {});
  //
  //   var wishlistDeleteResponse =
  //       await WishListRepository().delete(wishlist_id: wishlist_id);
  //
  //   if (wishlistDeleteResponse.result == true) {
  //     ToastComponent.showDialog(wishlistDeleteResponse.message,
  //         gravity: Toast.top, duration: Toast.lengthShort);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: MyTheme.mainColor,
          appBar: buildAppBar(context),
          body: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            onRefresh: _onPageRefresh,
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate([
                  buildWishlist(),
                ])),
              ],
            ),
          )),
    );
  }

  Widget buildWishlist() {
    if (is_logged_in.$ == false) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            'you_need_to_log_in'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    } else if (_wishlistInit == true && _wishlistItems.isEmpty) {
      return SingleChildScrollView(
        child: ShimmerHelper().buildListShimmer(item_count: 10),
      );
    } else if (_wishlistItems.isNotEmpty) {
      return WishListGridView(
          onPopFromProduct: _onPageRefresh, wishlistItems: _wishlistItems);
    } else {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            'no_item_is_available'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    }
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
        'my_wishlist_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

// buildWishListItem(index) {
  //   return InkWell(
  //     onTap: () {
  //       Navigator.push(context, MaterialPageRoute(builder: (context) {
  //         return ProductDetails(
  //           slug: _wishlistItems[index].product.slug,
  //         );
  //       }));
  //     },
  //     child: Stack(
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.only(left: 12.0, right: 12.0),
  //           child: Card(
  //             shape: RoundedRectangleBorder(
  //               side: new BorderSide(color: MyTheme.light_grey, width: 1.0),
  //               borderRadius: BorderRadius.circular(AppDimensions.radiusDefualt),
  //             ),
  //             elevation: 0.0,
  //             child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: <Widget>[
  //                   Container(
  //                       width: 100,
  //                       height: 100,
  //                       child: ClipRRect(
  //                           borderRadius: BorderRadius.horizontal(
  //                               left: Radius.circular(AppDimensions.radiusDefualt), right: Radius.zero),
  //                           child: FadeInImage.assetNetwork(
  //                             placeholder: 'AppImages.placeholder',
  //                             image:
  //                                 _wishlistItems[index].product.thumbnail_image,
  //                             fit: BoxFit.cover,
  //                           ))),
  //                   Container(
  //                     width: 240,
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Padding(
  //                           padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
  //                           child: Text(
  //                             _wishlistItems[index].product.name,
  //                             overflow: TextOverflow.ellipsis,
  //                             maxLines: 2,
  //                             style: TextStyle(
  //                                 color: MyTheme.font_grey,
  //                                 fontSize: 14,
  //                                 height: 1.6,
  //                                 fontWeight: FontWeight.w400),
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
  //                           child: Text(
  //                             _wishlistItems[index].product.base_price,
  //                             textAlign: TextAlign.left,
  //                             overflow: TextOverflow.ellipsis,
  //                             maxLines: 1,
  //                             style: TextStyle(
  //                                 color: MyTheme.accent_color,
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.w600),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ]),
  //           ),
  //         ),
  //         app_language_rtl.$!
  //             ? Positioned(
  //                 bottom: 8,
  //                 left: 12,
  //                 child: IconButton(
  //                   icon: Icon(Icons.delete_forever_outlined,
  //                       color: MyTheme.medium_grey),
  //                   onPressed: () {
  //                     _onPressRemove(index);
  //                   },
  //                 ),
  //               )
  //             : Positioned(
  //                 bottom: 8,
  //                 right: 12,
  //                 child: IconButton(
  //                   icon: Icon(Icons.delete_forever_outlined,
  //                       color: MyTheme.medium_grey),
  //                   onPressed: () {
  //                     _onPressRemove(index);
  //                   },
  //                 ),
  //               ),
  //       ],
  //     ),
  //   );
  // }
}

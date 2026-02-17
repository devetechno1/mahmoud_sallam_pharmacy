import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/banned_user.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wishlist/models/wishlist_check_response.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wishlist/models/wishlist_delete_response.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wishlist/models/wishlist_response.dart';

import '../helpers/main_helpers.dart';

class WishListRepository {
  Future<dynamic> getUserWishlist() async {
    const String url = ("${AppConfig.BASE_URL}/wishlists");
    final Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());

    return wishlistResponseFromJson(response.body);
  }

  Future<dynamic> delete({
    int? wishlist_id = 0,
  }) async {
    final String url = ("${AppConfig.BASE_URL}/wishlists/$wishlist_id");
    final response = await ApiRequest.delete(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return wishlistDeleteResponseFromJson(response.body);
  }

  Future<dynamic> isProductInUserWishList({product_slug = ''}) async {
    final String url =
        ("${AppConfig.BASE_URL}/wishlists-check-product/$product_slug");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return wishListChekResponseFromJson(response.body);
  }

  Future<dynamic> add({product_slug = ''}) async {
    final String url =
        ("${AppConfig.BASE_URL}/wishlists-add-product/$product_slug");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return wishListChekResponseFromJson(response.body);
  }

  Future<dynamic> remove({product_slug = ''}) async {
    final String url =
        ("${AppConfig.BASE_URL}/wishlists-remove-product/$product_slug");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());

    return wishListChekResponseFromJson(response.body);
  }
}

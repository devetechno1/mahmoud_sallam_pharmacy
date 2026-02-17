import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';

import '../data_model/login_response.dart';
import '../presenter/cart_provider.dart';
import 'shared_value_helper.dart';

class AuthHelper {
  Future<void> setUserData(LoginResponse loginResponse) async {
    if (loginResponse.result == true) {
      SystemConfig.systemUser = loginResponse.user;
      is_logged_in.$ = true;
      access_token.$ = loginResponse.access_token;
      user_id.$ = loginResponse.user?.id;
      user_name.$ = loginResponse.user?.name;
      user_email.$ = loginResponse.user?.email ?? "";
      user_phone.$ = loginResponse.user?.phone ?? "";
      avatar_original.$ = loginResponse.user?.avatar_original;
      temp_user_id.$ = '';

      await Future.wait([
        is_logged_in.save(),
        access_token.save(),
        user_id.save(),
        user_name.save(),
        user_email.save(),
        user_phone.save(),
        avatar_original.save(),
        temp_user_id.save(),
      ]);
    }
  }

  Future<void> clearUserData() async {
    SystemConfig.systemUser = null;
    is_logged_in.$ = false;
    access_token.$ = "";
    user_id.$ = 0;
    temp_user_id.$ = '';
    user_name.$ = "";
    user_email.$ = "";
    user_phone.$ = "";
    avatar_original.$ = "";

    OneContext().context?.read<HomeProvider>().logOutAddress(true);

    await Future.wait([
      is_logged_in.save(),
      access_token.save(),
      user_id.save(),
      user_name.save(),
      user_email.save(),
      user_phone.save(),
      avatar_original.save(),
      temp_user_id.save(),
    ]);
    final BuildContext context = OneContext().context!;
    Provider.of<CartProvider>(context, listen: false).onRefresh(context);

    // temp_user_id.$ = "";
    // temp_user_id.save();
  }

  fetch_and_set() async {
    final userByTokenResponse = await AuthRepository().getUserByTokenResponse();
    if (userByTokenResponse.result == true) {
      setUserData(userByTokenResponse);
    } else {
      clearUserData();
    }
  }
}

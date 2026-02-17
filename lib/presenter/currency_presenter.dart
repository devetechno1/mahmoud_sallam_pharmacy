import 'package:active_ecommerce_cms_demo_app/data_model/currency_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/currency_repository.dart';
import 'package:flutter/material.dart';

class CurrencyPresenter extends ChangeNotifier {
  List<CurrencyInfo> currencyList = [];

  Future<void> fetchListData() async {
    try {
      currencyList.clear();
      final res = await CurrencyRepository().getListResponse();
      print("res.data ${system_currency.$}");
      // print(res.data.toString());
      currencyList.addAll(res.data!);

      currencyList.forEach((element) {
        if (element.isDefault!) {
          SystemConfig.defaultCurrency = element;
          SystemConfig.systemCurrency = element;
          system_currency.$ = element.id;
          system_currency.save();
        }
        if (system_currency.$ == 0 && element.isDefault!) {
          SystemConfig.systemCurrency = element;
          system_currency.$ = element.id;
          system_currency.save();
        }
        if (system_currency.$ != null && element.id == system_currency.$) {
          SystemConfig.systemCurrency = element;
          system_currency.$ = element.id;
          system_currency.save();
        }
      });
      notifyListeners();
    } catch (e, stackTrace) {
      print("Error in fetchListData: $e");
      print("StackTrace: $stackTrace");
    }
  }
}

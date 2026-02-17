import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/currency_response.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

class CurrencyRepository {
  Future<CurrencyResponse> getListResponse() async {
    const String url = ('${AppConfig.BASE_URL}/currencies');

    final response = await ApiRequest.get(url: url);
    return currencyResponseFromJson(response.body);
  }
}

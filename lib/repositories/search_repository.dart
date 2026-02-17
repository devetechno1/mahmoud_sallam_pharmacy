import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/search_suggestion_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

import '../helpers/shared_value_helper.dart';

class SearchRepository {
  Future<List<SearchSuggestionResponse>> getSearchSuggestionListResponse(
      {query_key = "", type = "product"}) async {
    final String url =
        ("${AppConfig.BASE_URL}/get-search-suggestions?query_key=$query_key&type=$type");
    final header = {
      if ("$query_key".trim().isNotEmpty)
        "App-Language": "$query_key".langCode
      else
        "App-Language": app_language.$!,
    };

    final response = await ApiRequest.get(
      url: url,
      headers: header,
    );
    return searchSuggestionResponseFromJson(response.body);
  }
}


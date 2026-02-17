// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:active_ecommerce_cms_demo_app/data_model/product_details_response.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/product_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test distributeWholesale calculator', () {
    final int number = distributeWholesale(index: 0, total: 35, list: list);

    expect(number, 2);
  });
}

final List<Wholesale> list = [
  Wholesale(minQty: 1, maxQty: 15),
];

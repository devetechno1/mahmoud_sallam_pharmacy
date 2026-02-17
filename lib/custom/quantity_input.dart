import 'package:active_ecommerce_cms_demo_app/custom/only_number_formatter.dart';
import 'package:flutter/material.dart';

class QuantityInputField {
  static TextField show(
    TextEditingController controller, {
    required VoidCallback onSubmitted,
    void Function(String)? onChanged,
    bool isDisable = false,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      readOnly: isDisable,
      keyboardType: TextInputType.number,
      inputFormatters: [OnlyNumberFormatter()],
      onSubmitted: (str) => onSubmitted(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: "0",
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          borderSide: BorderSide(),
        ),
      ),
    );
  }
}

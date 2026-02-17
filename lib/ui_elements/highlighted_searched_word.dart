import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

class HighlightedSearchedWord extends StatelessWidget {
  const HighlightedSearchedWord(
    this.text, {
    super.key,
    this.searchedText,
    this.maxLines,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.overflow = TextOverflow.clip,
  });
  final String text;
  final String? searchedText;
  final int? maxLines;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final List<String>? allWords = searchedText?.split(" ");
    final highlightedWord = HighlightedWord(
      decoration: const BoxDecoration(color: Colors.yellow),
    );
    return TextHighlight(
      text: text,
      words: searchedText?.isNotEmpty == true
          ? {
              searchedText!: highlightedWord,
              for (String t in allWords ?? []) t: highlightedWord
            }
          : const {},
      maxLines: maxLines,
      textStyle: style,
      textAlign: textAlign,
      textDirection: textDirection ?? text.direction,
      overflow: overflow,
    );
  }
}


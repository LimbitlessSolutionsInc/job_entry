import 'package:flutter/material.dart';
import 'SpellCheckerData.dart';

class SpellCheckController extends TextEditingController {

  SpellData sc = SpellData();

  SpellCheckController({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style, 
    required bool withComposing
  }) {
    // TODO: implement buildTextSpan
    assert(!value.composing.isValid || !withComposing || value.isComposingRangeValid);

    final TextStyle composingStyle = style!.merge(
      const TextStyle(decoration: TextDecoration.underline),
    );
    final TextStyle errorStyle = style.merge(
      const TextStyle(decoration: TextDecoration.underline, color: Colors.red),
    );
    
    if (!value.isComposingRangeValid || !withComposing) {
      return sc.checkString(text, style);//TextSpan(style: style, text: text);
    }

   return TextSpan(
      style: style,
      children: <TextSpan>[
        TextSpan(text: value.composing.textBefore(value.text)),
        TextSpan(
          style: composingStyle,
          text: value.composing.textInside(value.text),
        ),
        TextSpan(text: value.composing.textAfter(value.text)),
      ],
    );
  }
}
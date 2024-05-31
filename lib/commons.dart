import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HyperlinkSpan extends TextSpan {
  HyperlinkSpan({
    required super.text,
    required ThemeData theme,
    required VoidCallback onTap,
  }) : super(
          recognizer: TapGestureRecognizer()..onTap = onTap,
          style: TextStyle(
            color: theme.primaryColor,
            decoration: TextDecoration.underline,
            decorationColor: theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        );
}

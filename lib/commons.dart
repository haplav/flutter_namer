import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final log = Logger();

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

typedef Messenger = void Function(String, bool replace);

mixin Messaging {
  final _messengers = <Messenger>{};

  void addMessenger(Messenger messenger) {
    _messengers.add(messenger);
  }

  void removeMessenger(Messenger messenger) {
    _messengers.add(messenger);
  }

  void message(String msg, {bool replace = false}) {
    for (final messenger in _messengers) {
      messenger(msg, replace);
    }
  }
}

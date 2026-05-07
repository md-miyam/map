import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

void showAppSnackBar({
  required BuildContext context,
  required String message,
  Color backgroundColor = const Color(0xFF323232),
  Color textColor = Colors.white,
  double borderRadius = 8,
  int durationSeconds = 2,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: durationSeconds),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  );
}




// ______________________________________ showAppSnackBarV2



DateTime? _lastSnackBarShownAt;
String? _lastSnackBarMessage;

void showAppSnackBarV2({
  BuildContext? context,
  required String message,
  Color backgroundColor = const Color(0xFF323232),
  Color textColor = Colors.white,
  double borderRadius = 8,
  int durationSeconds = 2,
  double blurSigma = 12,
  int duplicateCooldownMilliseconds = 800,
}) {
  final messengerContext = context ?? Get.context ?? Get.overlayContext;
  if (messengerContext == null) return;

  final now = DateTime.now();
  final isDuplicateMessage = _lastSnackBarMessage == message;
  final isWithinCooldown =
      _lastSnackBarShownAt != null &&
          now.difference(_lastSnackBarShownAt!).inMilliseconds <
              duplicateCooldownMilliseconds;
  if (isDuplicateMessage && isWithinCooldown) return;

  _lastSnackBarShownAt = now;
  _lastSnackBarMessage = message;

  final messenger = ScaffoldMessenger.of(messengerContext);
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: durationSeconds),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  message,
                  // style: AppTextStylesPoppins.regular(14, textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
}
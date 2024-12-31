import 'package:flutter/material.dart';

import '../core/theme/theme_helper.dart';

import 'base_btton.dart';

class CustomElevatedButton extends BaseButton {
  const CustomElevatedButton({
    super.key,
    this.decoration,
    this.leftIcon,
    this.rightIcon,
    this.widgetText,
    super.margin,
    super.onPressed,
    super.buttonStyle,
    super.alignment,
    super.buttonTextStyle,
    super.isDisabled,
    super.height,
    super.width,
    required super.text,
  });

  final BoxDecoration? decoration;
  final Widget? widgetText;
  final Widget? leftIcon;
  final Widget? rightIcon;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: buildElevatedButtonWidget,
          )
        : buildElevatedButtonWidget;
  }

  Widget get buildElevatedButtonWidget => Container(
        height: height ?? 52,
        width: width ?? double.maxFinite,
        margin: margin,
        decoration: decoration ??
            BoxDecoration(
              color: theme.colorScheme.primary, // Gradient colors

              borderRadius: BorderRadius.circular(30.0), // Rounded corners
            ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            // Make button background transparent
            shadowColor: Colors.transparent,
            // Remove the shadow for better look
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  30), // Match the decoration borderRadius
            ),
          ),
          onPressed: isDisabled ?? false ? null : onPressed ?? () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leftIcon ?? const SizedBox.shrink(),
              widgetText ??
                  Text(
                    text,
                    style: buttonTextStyle ??
                        theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                  ),
              rightIcon ?? const SizedBox.shrink(),
            ],
          ),
        ),
      );
}

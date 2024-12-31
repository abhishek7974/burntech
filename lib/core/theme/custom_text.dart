

import 'package:flutter/material.dart';

import 'theme_helper.dart';

class CustomTextStyles {

  static get bodyMedium => theme.textTheme.bodyMedium!.copyWith(
    fontWeight: FontWeight.w600,
        fontSize: 18
  );

  static get titleSmallPrimarySemiBold => theme.textTheme.titleSmall!.copyWith(
    color: theme.colorScheme.primary,
    fontWeight: FontWeight.w600,
  );

  static get titleSmallYellow100SemiBold =>
      theme.textTheme.titleSmall!.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      );


  static get bodyMediumGrey => theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Colors.grey
  );

  static get bodySubheading => theme.textTheme.headlineMedium!.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: appTheme.blackColor,
  );

  static get bodySmall => theme.textTheme.bodySmall!.copyWith(
       color: appTheme.blackColor
  );

}
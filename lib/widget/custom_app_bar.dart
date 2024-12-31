import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theme/theme_helper.dart';
import '../main.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar(
      {super.key,
        this.height,
        this.leadingWidth,
        this.leading,
        this.title,
        this.centerTitle,
        this.actions,
        this.backgroundColor,
        this.elevation,
      });

  final double? height;

  final double? leadingWidth;

  final Widget? leading;

  final Widget? title;

  final bool? centerTitle;

  final double? elevation;

  final List<Widget>? actions;
  final Colors? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      toolbarHeight: height ?? 56,
      automaticallyImplyLeading: false,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      backgroundColor:  Colors.white,
      leadingWidth: leadingWidth ?? 0,
      leading: leading,
      title: title,
      titleTextStyle: theme.textTheme.bodyMedium!.copyWith(
        fontSize: 15,
      ),
      titleSpacing: 0,
      centerTitle: centerTitle ?? false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size(
    mq.width,
    height ?? 56,
  );
}
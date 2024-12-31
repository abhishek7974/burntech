import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/custom_text.dart';


class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.alignment,
    this.width,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = true,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.inputFormatters,
    this.onChange,
    this.autovalidateMode,
    this.showElevation,
    this.onClick,
    this.readOnly,
    this.onChanged,
    this.onTapOutside,

  });

  final Alignment? alignment;

  final double? width;
  final AutovalidateMode? autovalidateMode;
  // final TextEditingController? scrollPadding;

  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  final bool? autofocus;

  final TextStyle? textStyle;

  final bool? obscureText;

  final TextInputAction? textInputAction;

  final TextInputType? textInputType;

  final int? maxLines;

  final String? hintText;

  final TextStyle? hintStyle;

  final Widget? prefix;

  final BoxConstraints? prefixConstraints;

  final Widget? suffix;

  final BoxConstraints? suffixConstraints;

  final EdgeInsets? contentPadding;

  final InputBorder? borderDecoration;

  final Color? fillColor;

  final bool? filled;

  final FormFieldValidator<String>? validator;

  final bool? showElevation;

  final Function(String)? onChange;

  final Function()? onClick;

  final bool? readOnly ;
  final void Function(String)? onChanged;



  final void Function(PointerDownEvent)? onTapOutside;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: textFormFieldWidget(context))
        : textFormFieldWidget(context);
  }

  Widget textFormFieldWidget(BuildContext context) => SizedBox(
        width: width ?? double.maxFinite,
        child: Container(
          decoration: showElevation == true ? BoxDecoration(
            color: Colors.white, // Background color of the TextFormField
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ) : null,
          child: TextFormField(

            readOnly: readOnly ?? false,
            autovalidateMode: autovalidateMode,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            onTap: onClick,
            scrollPadding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            controller: controller,
            focusNode: focusNode,
            onTapOutside: (event) {
              if (focusNode != null) {
                focusNode?.unfocus();
              } else {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            onChanged: onChange,
            autofocus: autofocus ?? false,
            style: textStyle,
            obscureText: obscureText ?? false,
            textInputAction: textInputAction,
            keyboardType: textInputType,
            maxLines: maxLines ?? 1,
            decoration: decoration,
            validator: validator,
          ),
        ),
      );
  InputDecoration get decoration => InputDecoration(
        hintText: hintText ?? "",
        hintStyle:  hintStyle ?? CustomTextStyles.bodyMediumGrey,
        prefixIcon: prefix,
        prefixIconConstraints: prefixConstraints,
        suffixIcon: suffix,
        suffixIconConstraints: suffixConstraints,
        isDense: true,
        contentPadding: contentPadding ?? EdgeInsets.all(12),
        fillColor: fillColor,
        filled: filled,
        border: borderDecoration ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
        enabledBorder: borderDecoration ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
            ),
        focusedBorder: borderDecoration ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
            ),
      );
}

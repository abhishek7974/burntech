import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/theme_helper.dart';
import '../../../../main.dart';
import '../../../../widget/custom_image.dart';

class OnBoardingWidgetImageView extends StatelessWidget {
  final String imageUrl;

  final String heading;

  final String headingDec;
  const OnBoardingWidgetImageView(
      {super.key,
        required this.heading,
        required this.headingDec,
        required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomImageView(
          margin: EdgeInsets.symmetric(horizontal: 10),
          imagePath: imageUrl,
          height: mq.height * .6,

          radius: BorderRadius.circular(
            24,
          ),

        ),

        SizedBox(height: 18),
        Flexible(
          child: Text(
            heading,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.baskervville().copyWith(
              color: theme.colorScheme.errorContainer,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:burntech/view/auth/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/custom_text.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../widget/custom_elevated_button.dart';
import '../bottom_nav_bar/bottom_nav_bar.dart';
import 'widgets/onboarding_widget_image.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  List<Widget> onboardingImageView = [
    OnBoardingWidgetImageView(
      heading: "Comprehensive event listings with times, descriptions, and hosts",
      headingDec: '',
      imageUrl: "assets/images/burning_man.webp",
    ),

    OnBoardingWidgetImageView(
      heading: ' Interactive map showing camps, art installations, and services',
      headingDec: '',
      imageUrl: "assets/images/burning_man_2.webp",
    ),
    OnBoardingWidgetImageView(
      heading: "Events and camps are displayed on an interactive map of Black Rock City",
      headingDec: '',
      imageUrl: "assets/images/burning_man3.webp",
    )
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.colorScheme.onErrorContainer.withOpacity(1),
      body: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(vertical: 38, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Flexible(
              child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: onboardingImageView.length,
                  itemBuilder: (context, index) {
                    return onboardingImageView[index];
                  }),
            ),

            SmoothPageIndicator(
              controller: _pageController,
              count: onboardingImageView.length,
              effect: ExpandingDotsEffect(
                spacing: 8,
                activeDotColor: theme.colorScheme.primary,
                dotColor: Colors.indigo.shade50,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            SizedBox(height: 16),
            Builder(
              builder: (context) {
                bool isLastPage = _pageController.hasClients &&
                    _pageController.page?.toInt() ==
                        onboardingImageView.length - 1;
                return CustomElevatedButton(
                  onPressed: () {
                    if (_pageController.hasClients && !isLastPage) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut);
                    } else {
                      // Handle "Get Started" action, e.g., navigate to another screen
                      Navigator.of(context,).push(MaterialPageRoute(builder: (context){
                        return LoginPage();
                      }));
                    }
                  },
                  text: isLastPage ? "Get Started" : "Next",
                  buttonTextStyle: CustomTextStyles.titleSmallYellow100SemiBold,
                );
              },
            ),
            SizedBox(height: 29),
            Builder(builder: (context) {
              bool isLastPage = _pageController.hasClients &&
                  _pageController.page?.toInt() ==
                      onboardingImageView.length - 1;
              if (!isLastPage) {
                return InkWell(
                  onTap: () {
                    // Skip to the last page or handle the skip action
                    _pageController.jumpToPage(onboardingImageView.length - 1);
                  },
                  child: Text(
                    "Skip",
                    style: CustomTextStyles.titleSmallPrimarySemiBold,
                  ),
                );
              }

              return const SizedBox.shrink();
            })
          ],
        ),
      ),
    );
  }
}

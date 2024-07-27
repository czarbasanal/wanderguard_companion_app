import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:wanderguard_companion_app/screens/auth/signin_screen.dart';
import 'package:wanderguard_companion_app/screens/auth/signup_screen.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/utils/size_config.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  static const String route = "/";
  static const String name = "Onboarding";

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final CarouselController _controller = CarouselController();
  int _currentIndex = 0;

  final List<String> imgList = [
    'lib/assets/images/Asset1.png',
    'lib/assets/images/Asset2.png',
    'lib/assets/images/Asset3.png',
  ];

  final List<String> textList = [
    'Peace of mind for caregivers, freedom\nwith safety for those you love.',
    'Never lose sight of your loved one,\n wherever life\'s journey takes them.',
    'Connecting companions and dementia\n patients, for a safer and joyful tomorrow.',
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _controller,
                itemCount: imgList.length,
                itemBuilder: (context, index, realIndex) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: SizeConfig.screenWidth * 0.6,
                        height: SizeConfig.screenHeight * 0.3,
                        child: Image.asset(
                          imgList[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        textList[index],
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 2 * SizeConfig.textMultiplier,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
                options: CarouselOptions(
                  autoPlay: true,
                  height: SizeConfig.screenHeight * 0.5,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: imgList.length,
              effect: WormEffect(
                dotHeight: 8.0,
                dotWidth: 8.0,
                dotColor: Colors.grey,
                activeDotColor: CustomColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight * 0.4,
              decoration: BoxDecoration(
                color: CustomColors.primaryColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20.0),
                  Text(
                    'Welcome',
                    style: GoogleFonts.poppins(
                      color: CustomColors.secondaryColor,
                      fontSize: 3 * SizeConfig.textMultiplier,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get started with your account!',
                    style: TextStyle(
                      color: CustomColors.secondaryColor,
                      fontSize: 2.1 * SizeConfig.textMultiplier,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40.0),
                  MaterialButton(
                    elevation: 0,
                    color: CustomColors.tertiaryColor,
                    minWidth: 65 * SizeConfig.blockSizeHorizontal,
                    height: 5.5 * SizeConfig.blockSizeVertical,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      GlobalRouter.I.router.go(SigninScreen.route);
                    },
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                          color: CustomColors.primaryColor,
                          fontSize: 1.8 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?',
                          style: TextStyle(
                              color: CustomColors.secondaryColor,
                              fontSize: 1.6 * SizeConfig.textMultiplier)),
                      TextButton(
                        onPressed: () {
                          GlobalRouter.I.router.go(SignupScreen.route);
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                              color: CustomColors.secondaryColor,
                              fontSize: 1.6 * SizeConfig.textMultiplier,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

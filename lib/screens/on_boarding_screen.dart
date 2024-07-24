import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final CarouselController _controller = CarouselController();
  int _currentIndex = 0;

  final List<String> imgList = [
    'assets/images/Asset1.png',
    'assets/images/Asset2.png',
    'assets/images/Asset3.png',
  ];

  final List<String> textList = [
    'Peace of mind for caregivers, freedom\nwith safety for those you love.',
    'Never lose sight of your loved one,\n wherever life\'s journey takes them.',
    'Connecting companions and dementia\n patients, for a safer and joyful tomorrow.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              carouselController: _controller,
              itemCount: imgList.length,
              itemBuilder: (context, index, realIndex) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Image.asset(
                        imgList[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      textList[index], 
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
              options: CarouselOptions(
                autoPlay: true,
                height: MediaQuery.of(context).size.height * 0.5,
                enlargeCenterPage: false, // Set to false
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 8), // Reduced height
          AnimatedSmoothIndicator(
            activeIndex: _currentIndex,
            count: imgList.length,
            effect: WormEffect(
              dotHeight: 8.0,
              dotWidth: 8.0,
              dotColor: Colors.grey,
              activeDotColor: Color(0xFF934CCB),
            ),
          ),
          SizedBox(height: 16), // Reduced height
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: Color(0xFF934CCB),
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.0), // Reduced height
                Text(
                  'Welcome',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Get started with your account!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0), // Reduced height
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(260, 45),
                  ),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      color: Color(0XFFAF48FF),
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 8.0), // Reduced height
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Don\'t have an account? Sign Up',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAF48FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png'),
            const SizedBox(height: 25),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Wander',
                    style: GoogleFonts.outfit(fontSize: 38),
                  ),
                  TextSpan(
                    text: 'Guard',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 38),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

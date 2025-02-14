import 'package:flutter/material.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  final List<String> images = [
    'assets/images/sust_audi.jpg',
    'assets/images/central_field2.jpg',
    'assets/images/basketball_ground.jpg'
  ];
  int _imageIndex = 0;
  String fullQuote = "SUST Spot Booking, Smart & Easy!";
  String displayedQuote = "";
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _imageIndex = (_imageIndex + 1) % images.length;
      });
    });
    _animateQuote();
  }

  void _animateQuote() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_quoteIndex < fullQuote.length) {
        setState(() {
          displayedQuote = fullQuote.substring(0, _quoteIndex + 1);
          _quoteIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "SpotEase SUST", showBackButton: false),
      backgroundColor: const Color.fromARGB(197, 21, 18, 24),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                child: Image.asset(
                  images[_imageIndex],
                  key: ValueKey<String>(images[_imageIndex]),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                displayedQuote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist'),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Get Started",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
              Image.asset('assets/images/sust_logo.png', height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

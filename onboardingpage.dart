import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          OnboardingPage(
            image: Icons.directions_car,
            title: 'Welcome to Autonomous Valet Parking!',
            description: 'Your trusted partner for seamless, self-driving car parking and retrieval.',
          ),
          OnboardingPage(
            image: Icons.help_outline,
            title: 'How It Works',
            description: 'Manage your vehicle effortlessly with real-time automation and safety features.',
          ),
          OnboardingPage(
            image: Icons.build,
            title: 'Parking Assistance',
            description: 'Easily manage parking needs with quick access to real-time parking services and support.',
          ),
        ],
      ),
      bottomSheet: _currentIndex == 2
          ? ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/auth');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFBA321), // Button color set to #fba321 (yellow)
        ),
        child: Text(
          'Get Started',
          style: TextStyle(color: Color(0xFF033F58)), // Text color set to #033f58 (dark blue)
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            child: Text(
              'Skip',
              style: TextStyle(color: Color(0xFFFBA321)), // Text color set to #fba321 (yellow)
            ),
          ),
          Row(
            children: List.generate(3, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                width: 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Color(0xFF033F58) // Active indicator color set to #033f58 (dark blue)
                      : Color(0xFFFBA321), // Inactive indicator color set to #fba321 (yellow)
                ),
              );
            }),
          ),
          TextButton(
            onPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            child: Text(
              'Next',
              style: TextStyle(color: Color(0xFFFBA321)), // Text color set to #fba321 (yellow)
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final IconData image;
  final String title;
  final String description;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            image,
            size: 100.0,
            color: Color(0xFFFBA321), // Icon color set to #fba321 (yellow)
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF033F58), // Title text color set to #033f58 (dark blue)
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF033F58), // Description text color set to #033f58 (dark blue)
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

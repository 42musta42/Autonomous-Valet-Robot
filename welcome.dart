import 'package:flutter/material.dart';

import 'login.dart';
import 'signup.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white, // Background color set to #fba321 (yellow)
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add an image above the text
            Image.asset(
              'assets/images/16.jpeg', // Replace with your image path
              height: 250, // Set height as needed
              width: 250, // Set width as needed
            ),
            SizedBox(height: 30),
            Text(
              'Welcome',
              style: TextStyle(
                color: Color(0xFF033F58), // Text color set to #033f58 (dark blue)
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildButton(
              context,
              label: 'Sign Up',
              color: Color(0xFF033F58), // Button background color set to #033f58 (dark blue)
              textColor: Color(0xFFFBA321), // Text color set to #fba321 (yellow)
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Signup()),
                );
              },
            ),
            SizedBox(height: 10),
            _buildButton(
              context,
              label: 'Sign In',
              color: Color(0xFF033F58), // Button background color set to #033f58 (dark blue)
              textColor: Color(0xFFFBA321), // Text color set to #fba321 (yellow)
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {
    required String label,
    required Color color,
    required Color textColor,
    required void Function() onPressed,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor, // Text color
          backgroundColor: color, // Button background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

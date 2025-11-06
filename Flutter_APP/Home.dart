//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';

import 'package:valet_robot/welcome.dart';
import 'SplashScreen.dart';
import 'authProvider.dart';
import 'package:flutter/material.dart';
//import 'package:share/share.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isChecked = false;
  bool _showValidationMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: NavigationDrawer(
        onItemTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Checkbox section
                Image.asset(
                  'assets/images/11.png',
                  height: 250,
                ),
                SizedBox(height: 20),
                Text(
                  'Let’s park your car!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Ensure your car is ready and in the delivery spot. Select the service to proceed.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),

                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                          _showValidationMessage = false;
                        });
                      },
                      activeColor: Color(0xFF033f58), // Ko7ly
                    ),
                    Expanded(
                      child: Text(
                        "Make sure your car is in the delivery spot",
                        style: TextStyle(
                          color: Color(0xFF033f58), // Ko7ly
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                // Validation message
                if (_showValidationMessage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Please check this first to park your car.",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 40),
                // Park the car button
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (!_isChecked) {
                          setState(() {
                            _showValidationMessage = true; // Show validation
                          });
                          return;
                        }

                        // Send 's' to Flask backend
                        try {
                          final response = await http.post(
                            Uri.parse('http://192.168.1.13:5000/send-letter'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({'letter': 's'}),
                          );

                          if (response.statusCode == 200) {
                            print('Letter sent successfully');
                          } else {
                            print('Failed to send letter');
                          }
                        } catch (e) {
                          print('Error sending letter: $e');
                        }

                        // Show progress dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Color(0xFFfba321), // Yellow
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Wait until our robot reaches the delivery spot to park your car',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        // Wait for 3 seconds
                        await Future.delayed(Duration(seconds: 3));
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SplashScreen()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF033f58), // Ko7ly
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/14.jpg',
                              height: 100,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Park The Car',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Do not forget any important things in the car.',
                      style: TextStyle(
                        color: Color(0xFF033f58), // Ko7ly
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, String label, String assetPath, Widget destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset(
                  assetPath,
                  height: 100,
                ),
                SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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


class NavigationDrawer extends StatelessWidget {
  final Function(int) onItemTap;
  final int selectedIndex;

  NavigationDrawer({required this.onItemTap, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFFfba321),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    'Welcome ' ,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Color(0xFFfaa325)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Valet Robot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 50),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _buildListTile(
                      context,
                      icon: Icons.home,
                      title: 'Home Page',
                      onTap: () => onItemTap(0),
                      isSelected: selectedIndex == 0,
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.info,
                      title: 'About Us',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutUsPage()),
                      ),
                      isSelected: false,
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.description,
                      title: 'Terms of use',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsofusePage()),
                      ),
                      isSelected: false,
                    ),
                    _buildListTile(
                      context,
                      icon: Icons.help,
                      title: 'Call Center',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsofusePage()),
                      ),
                      isSelected: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Container(
      color: isSelected ? Color(0xFF033f58) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}



class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Learn more about us and our mission.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsofusePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of use'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Terms of use Page.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

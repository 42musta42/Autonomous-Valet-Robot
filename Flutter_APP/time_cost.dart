import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Make sure you have http package

class MyCarPage extends StatefulWidget {
  @override
  _MyCarPageState createState() => _MyCarPageState();
}

class _MyCarPageState extends State<MyCarPage> {
  int _elapsedSeconds = 0;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}h:${minutes.toString().padLeft(2, '0')}m:${remainingSeconds.toString().padLeft(2, '0')}s';
  }

  int _calculateCost() {
    return (_elapsedSeconds ~/ 30) * 2;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomClockShape(elapsedSeconds: _elapsedSeconds),
              SizedBox(height: 20),
              Text(
                'Your car calculation cost and time.',
                style: TextStyle(
                  color: Color(0xFFfba321), // Yellow
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Track the time and calculate the cost as your car arrives.',
                style: TextStyle(
                  color: Color(0xFF033f58), // Dark blue
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Text(
                'Elapsed Time: ${_formatTime(_elapsedSeconds)}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  int cost = _calculateCost();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Parking Fees'),
                      content: Text('Total Cost: \$${cost}'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ServicePage()),
                            );
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFfba321), // Yellow
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Get my car',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

      SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomClockShape extends StatelessWidget {
  final int elapsedSeconds;

  CustomClockShape({required this.elapsedSeconds});

  @override
  Widget build(BuildContext context) {
    int hours = elapsedSeconds ~/ 3600;
    int minutes = (elapsedSeconds % 3600) ~/ 60;
    int seconds = elapsedSeconds % 60;

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFF033f58), width: 5), // Dark blue border
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: Text(
                '$hours : $minutes : $seconds',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              top: 2,
            ),
            Positioned(
              child: Container(
                width: 2,
                height: 100,
                color: Color(0xFFfba321), // Yellow
              ),
              left: 124,
              top: 15,
            ),
            Positioned(
              child: Container(
                width: 2,
                height: 70,
                color: Color(0xFFfba321), // Yellow
              ),
              left: 124,
              top: 70,
            ),
            Positioned(
              child: Container(
                width: 2,
                height: 40,
                color: Color(0xFFfba321), // Yellow
              ),
              left: 124,
              top: 115,
            ),
          ],
        ),
      ),
    );
  }
}

class ServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Page'),
        backgroundColor: Color(0xFFfba321), // Yellow
      ),
      body: Center(
        child: Text(
          'Wait until we get your car to the delivery spot..Thnak you',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

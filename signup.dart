import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'welcome.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  //This function will be called when the user hits the sign up button
  Future<void> _signup() async {
    setState(() {
      _isLoading = true;  // Show loading indicator
    });
    //print('mustafa');

    // Prepare user data to be sent
    final userData = {
      'username': _userNameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneNumberController.text,
      'password': _passwordController.text,
      'address': _addressController.text,
      'documentId': _documentIdController.text,
      'documentSource': _documentSourceController.text,
      'carType': _carTypeController.text,
      'carModel': _carModelController.text,
      'carLetters': _carLettersController.text,
      'carNumbers': _carNumbersController.text,
      'carChassis': _carChassisController.text,
    };
    print('mustafa');

    // Send data to the Flask backend using POST request
    final response = await http.post(
      Uri.parse('http://192.168.1.13:5000/signup'), // Replace with your Flask server URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );
    print(response.statusCode);
    print(response.body);
    print(userData);
    print('mustafa');

    if (response.statusCode == 201) {
      // Success
      setState(() {
        _isLoading = false;  // Hide loading indicator
      });
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);  // Navigate to the next page
    } else {
      // Error
      setState(() {
        _isLoading = false;
      });
      final errorData = json.decode(response.body);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text(errorData['error']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }


  @override
  void initState() {
    super.initState();
  }

  File? _image;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _documentIdController = TextEditingController();
  final TextEditingController _documentSourceController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carLettersController = TextEditingController();
  final TextEditingController _carNumbersController = TextEditingController();
  final TextEditingController _carChassisController = TextEditingController();

  final PageController _pageController = PageController();
  final _profileFormKey = GlobalKey<FormState>();
  final _detailsFormKey = GlobalKey<FormState>();
  final _carFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscureText = true;
  final TextEditingController _passwordTextController = TextEditingController();





  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildProfilePage(),
          _buildDetailsPage(),
          _buildCarPage(),
          _buildSuccessPage(),
        ],
        onPageChanged: (index) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      child: Form(
        key: _profileFormKey,
        child: Column(
          children: [
            SizedBox(height: 50.0),
            _buildTitle('Profile'),
            _buildImagePicker(),
            _buildTextField(_userNameController, 'User Name', Icons.perm_contact_calendar_outlined, true),
            _buildNumberField(_phoneNumberController, 'Phone Number', Icons.phone_callback_rounded, true, validator: _validatePhoneNumber),
            _buildPasswordField(_passwordController, 'Password', Icons.password_rounded, true, isPassword: true, validator: _validatePassword),
            _buildNavigationButtons(0),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPage() {
    return SingleChildScrollView(
      child: Form(
        key: _detailsFormKey,
        child: Column(
          children: [
            SizedBox(height: 50.0),
            _buildTitle('Info'),
            _buildTextField(_emailController, 'Email Address', Icons.email_outlined, true, validator: _validateEmail),
            _buildTextField(_addressController, 'Address', Icons.location_on_outlined, true),
            _buildTextField(_documentIdController, 'Document ID', Icons.document_scanner_sharp, true),
            _buildTextField(_documentSourceController, 'Document Source', Icons.document_scanner_outlined, true),
            _buildNavigationButtons(1),
          ],
        ),
      ),
    );
  }

  Widget _buildCarPage() {
    return SingleChildScrollView(
      child: Form(
        key: _carFormKey,
        child: Column(
          children: [
            SizedBox(height: 50.0),
            _buildTitle('Car Info'),
            _buildTextField(_carTypeController, 'Car Type', Icons.electric_car_rounded, true),
            _buildTextField(_carModelController, 'Car Model', Icons.local_car_wash_rounded, true),
            _buildTextField(_carLettersController, 'Car letters', Icons.sort_by_alpha_rounded, true),
            _buildTextField(_carNumbersController, 'Car numbers', Icons.numbers_rounded, true),
            _buildTextField(_carChassisController, 'Car Chassis', Icons.directions_car_rounded, true),
            _buildNavigationButtons(2),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFF033f58), size: 100.0),
          SizedBox(height: 20.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfba321),
            ),
            onPressed: () async {
              await _signup(); // Calls the function to validate and send the data
              // Navigate to the homepage
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text('Great! Lets get started.', style: TextStyle(fontSize: 20.0)),
          ),
          SizedBox(height: 20.0),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Color(0xFFfba321),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Color(0xFF033f58)),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFF033f58),
                    borderRadius: BorderRadius.circular(75),
                    border: Border.all(width: 3, color: Color(0xFFfba321)),
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(75),
                    child: Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover),
                  )
                      : const Icon(Icons.camera_alt, size: 50, color: Color(0xFFfba321)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, bool isRequired,
      {bool isPassword = false, String? Function(String?)? validator})
  {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hintText, style: TextStyle(fontSize: 10.0, color: Color(0xFF033f58))),
          SizedBox(height: 8.0),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon, color: Color(0xFF033f58)),
              border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF033f58)),),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF033f58), width: 2.0),
              ),

            ),
            style: TextStyle(fontSize: 10.0),
            obscureText: isPassword,
            validator: validator ??
                (isRequired
                    ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter $hintText';
                  }
                  return null;
                }
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hintText, IconData icon, bool isRequired,
      {bool isPassword = false, String? Function(String?)? validator})
  {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hintText, style: TextStyle(fontSize: 10.0, color: Color(0xFF033f58))),
          SizedBox(height: 8.0),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon, color: Color(0xFF033f58)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF033f58),
                ),
                onPressed: _togglePasswordVisibility,
              ),
              border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF033f58)),),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF033f58), width: 2.0),
              ),

            ),
            style: TextStyle(fontSize: 10.0),
            obscureText: _obscureText,
            validator: validator ??
                (isRequired
                    ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter $hintText';
                  }
                  return null;
                }
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String hintText, IconData icon, bool isRequired,
      {bool isPassword = false, String? Function(String?)? validator})
  {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hintText, style: TextStyle(fontSize: 10.0, color: Color(0xFF033f58))),
          SizedBox(height: 8.0),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon, color: Color(0xFF033f58)),
              border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF033f58)),),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF033f58), width: 2.0),
              ),
            ),
            style: TextStyle(fontSize: 10.0),
            keyboardType: TextInputType.phone,
            obscureText: isPassword,
            validator: validator ??
                (isRequired
                    ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter $hintText';
                  }
                  return null;
                }
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBackButton(currentPage),
        SizedBox(width: 10),
        _buildNextButton(currentPage),
      ],
    );
  }

  Widget _buildBackButton(int currentPage) {
    if (currentPage == 0) {
      return SizedBox.shrink();
    }
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: Color(0xFF033f58),
      ),
      onPressed: () {
        if (currentPage > 0) {
          setState(() {
          });
          _pageController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      },
      iconSize: 40.0,
    );
  }

  Widget _buildNextButton(int currentPage) {
    return IconButton(
      icon: Icon(
        Icons.arrow_forward_ios,
        color: Color(0xFF033f58),
      ),
      onPressed: () {
        if (_validateCurrentPage(currentPage)) {
          if (_pageController.hasClients && _pageController.page! < 3) {
            setState(() {
            });
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        }
      },
      iconSize: 40.0,
    );
  }

  bool _validateCurrentPage(int currentPage) {
    switch (currentPage) {
      case 0:
        return _profileFormKey.currentState?.validate() ?? false;
      case 1:
        return _detailsFormKey.currentState?.validate() ?? false;
      case 2:
        return _carFormKey.currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Phone Number';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'Phone Number must be 11 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    List<String> errors = [];

    if (value == null || value.isEmpty) {
      errors.add('Please enter Password');
    } else {
      if (value.length < 8) {
        errors.add('Password must be at least 8 characters long');
      }
      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
        errors.add('Password must contain at least one capital letter');
      }
      if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
        errors.add('Password must contain at least one lowercase letter');
      }
      if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
        errors.add('Password must contain at least one digit');
      }
      if (!RegExp(r'(?=.*[@$!%?&])').hasMatch(value)) {
        errors.add('Password must contain at least one valid special character');
      }
    }

    if (errors.isEmpty) {
      return null;
    } else {
      return errors.join('\n');
    }
  }



  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Email Address';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Invalid Email Address';
    }
    return null;
  }
}

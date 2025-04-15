import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'otp_verification_page.dart';
import 'services/auth_service.dart';
import 'location_selection_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showEmailPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Checking if mobile number is registered...');
      final checkResponse = await http.post(
        Uri.parse('http://test.shoppazing.com/api/shop/registeruser'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'Email': '',
          'Firstname': '',
          'Lastname': '',
          'MobileNo': _mobileController.text,
          'Password': '',
          'RoleName': 'User',
        }),
      );

      print('Mobile check response status code: ${checkResponse.statusCode}');
      print('Mobile check response body: ${checkResponse.body}');

      // Parse the response body to check the status_code
      final checkData = jsonDecode(checkResponse.body);
      final statusCode = checkData['status_code'];
      final message = checkData['message'];

      // Send OTP regardless of registration status
      print('Sending OTP...');
      final response = await http.post(
        Uri.parse('http://test.shoppazing.com/api/shop/sendotp'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'UserId': '',
          'MobileNo': _mobileController.text,
          'AppHash': 'h234shsw',
        }),
      );

      print('OTP response status code: ${response.statusCode}');
      print('OTP response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        // Show appropriate message based on registration status
        if (statusCode == 1 && message == "Mobile No exist") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mobile number not registered. Please complete registration after OTP verification.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }

        // Navigate to OTP verification page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OTPVerificationPage(mobileNumber: _mobileController.text),
          ),
        );
      } else {
        throw Exception('Failed to send OTP');
      }
    } on SocketException catch (e) {
      print('Network error: $e');
      setState(() {
        _errorMessage = 'Network error. Please check your internet connection.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Network error. Please check your internet connection and try again.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error sending OTP: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('Attempting to login...');
      final loginResponse = await http.post(
        Uri.parse('http://test.shoppazing.com/api/shop/registeruser'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'Email': _emailController.text,
          'Firstname': '', // Empty for login
          'Lastname': '', // Empty for login
          'MobileNo': '', // Empty for login
          'Password': _passwordController.text,
          'RoleName': 'User',
        }),
      );

      print('Login response status code: ${loginResponse.statusCode}');
      print('Login response body: ${loginResponse.body}');

      // Parse the response body to check the status_code
      final loginData = jsonDecode(loginResponse.body);
      final statusCode = loginData['status_code'];
      final message = loginData['message'];

      if (statusCode == 1 && message == "User already exist") {
        // Login successful
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to location selection page after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LocationSelectionPage(),
          ),
        );
      } else {
        // Login failed
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please sign in to continue',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (!_showEmailPassword) ...[
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        hintText: 'Enter your mobile number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showEmailPassword = true;
                        });
                      },
                      child: const Text('Login using email and password'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendOTP,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showEmailPassword = false;
                        });
                      },
                      child: const Text('Login using mobile number'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _loginWithEmailPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

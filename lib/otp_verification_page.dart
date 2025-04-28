import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'services/auth_service.dart';
import 'registration_page.dart';
import 'home_page.dart';
import 'dart:async';

class OTPVerificationPage extends StatefulWidget {
  final String mobileNumber;

  const OTPVerificationPage({super.key, required this.mobileNumber});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;
  bool _canResendOTP = false;
  int _resendTimer = 30; // 30 seconds timer
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResendOTP = false;
      _resendTimer = 30;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        setState(() {
          _canResendOTP = true;
        });
        timer.cancel();
      }
    });
  }

  void _onOTPChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    } else if (value.isEmpty && index > 0) {
      // Handle backspace
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index - 1].text.length),
      );
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Starting OTP verification process...');
      print('Mobile number: ${widget.mobileNumber}');
      print('OTP entered: $otp');

      final requestBody = {
        'UserId': '',
        'MobileNo': widget.mobileNumber,
        'OTP': otp,
      };
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('http://test.shoppazing.com/api/shop/verifyotplogin'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode(requestBody),
      );

      print('OTP verification response status code: ${response.statusCode}');
      print('OTP verification response body: ${response.body}');

      // Parse the response body to check the status
      final responseData = jsonDecode(response.body);
      print('Parsed response data: $responseData');
      final statusCode = responseData['status_code'];
      final message = responseData['message'];
      print('Status code: $statusCode');
      print('Message: $message');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('HTTP request was successful');
        if (statusCode == 1 ||
            (statusCode == 3 &&
                message == "No user found with this mobile no.")) {
          print('OTP verification successful');
          // Check if user is already registered
          print('Checking if user is already registered...');
          final checkResponse = await http.post(
            Uri.parse('http://test.shoppazing.com/api/shop/registeruser'),
            headers: AuthService.getAuthHeaders(),
            body: jsonEncode({
              'Email': '',
              'Firstname': '',
              'Lastname': '',
              'MobileNo': widget.mobileNumber,
              'Password': '',
              'RoleName': 'User',
            }),
          );

          print('User check response status code: ${checkResponse.statusCode}');
          print('User check response body: ${checkResponse.body}');

          // Parse the response body to check the status_code
          final checkData = jsonDecode(checkResponse.body);
          final userStatusCode = checkData['status_code'];
          final userMessage = checkData['message'];

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          if (userStatusCode == 1 && userMessage == "Mobile No exist") {
            // User is already registered, navigate to home page
            print('User is already registered, navigating to home page...');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            // User is not registered, navigate to registration page
            print('User is not registered, navigating to registration page...');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RegistrationPage(mobileNumber: widget.mobileNumber),
              ),
            );
          }
        } else {
          throw Exception('Invalid OTP. Please try again.');
        }
      } else {
        throw Exception('Failed to verify OTP. Please try again.');
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
      print('Error verifying OTP: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
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

  Future<void> _resendOTP() async {
    if (!_canResendOTP) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Resending OTP...');
      print('Mobile number: ${widget.mobileNumber}');

      final response = await http.post(
        Uri.parse('http://test.shoppazing.com/api/shop/sendotplogin'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'MobileNo': widget.mobileNumber,
        }),
      );

      print('Resend OTP response status code: ${response.statusCode}');
      print('Resend OTP response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['status_code'] == 1) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP has been resent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _startResendTimer();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to resend OTP');
        }
      } else {
        throw Exception('Failed to resend OTP');
      }
    } catch (e) {
      print('Error resending OTP: $e');
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
      appBar: AppBar(title: const Text('OTP Verification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter the OTP sent to',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.mobileNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => _onOTPChanged(index, value),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Resend OTP button
              TextButton(
                onPressed: _canResendOTP ? _resendOTP : null,
                child: Text(
                  _canResendOTP
                      ? 'Resend OTP'
                      : 'Resend OTP in $_resendTimer seconds',
                  style: TextStyle(
                    color: _canResendOTP ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
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
                        'Verify OTP',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

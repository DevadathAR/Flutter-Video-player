import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_video_player/auth/signup.dart';
import 'package:my_video_player/screens/video_player.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? _verificationId;
  bool _isOtpSent = false;

  Future<void> _sendOtp() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically sign in the user if verification is completed
          await _auth.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VideoPlayerPage()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message ?? 'Verification failed')));
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('OTP sent')));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _verifyOtp() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VideoPlayerPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 197),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 197),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)))),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              if (_isOtpSent) ...[
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                      labelText: 'OTP',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  child: const Text('Verify OTP', style: TextStyle(fontSize: 22)),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _sendOtp,
                  child: const Text('Send OTP', style: TextStyle(fontSize: 22)),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_video_player/auth/login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  XFile? _userImage;
  String? _verificationId;
  bool _otpSent = false;

  Future<void> _signUp() async {
    if (_otpSent) {
      // Verify OTP
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _otpController.text.trim(),
        );
        await _auth.signInWithCredential(credential);
        // Optionally store additional user information
        // await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        //   'name': _nameController.text,
        //   'email': _emailController.text,
        //   'dob': _dobController.text,
        // });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign Up Successful')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error verifying OTP: $e')));
      }
    } else {
      // Send OTP
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: _phoneController.text.trim(),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign Up Successful')));
            Navigator.pop(context);
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _verificationId = verificationId;
              _otpSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent')));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending OTP: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _userImage = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
              // User Image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _userImage != null
                      ? FileImage(File(_userImage!.path)) // Convert String path to File
                      : null,
                  child: _userImage == null
                      ? Icon(Icons.add_a_photo, color: Colors.grey[600], size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              if (!_otpSent) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                      labelText: 'Date Of Birth (DD/MM/YY)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _signUp,
                  child: const Text(
                    'Send OTP',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                      labelText: 'OTP',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _signUp,
                  child: const Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pop(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    ),
                    child: const Text(
                      'Login',
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

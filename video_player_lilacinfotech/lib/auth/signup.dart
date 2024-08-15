import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player_lilacinfotech/auth/otp_screen.dart';
import 'package:video_player_lilacinfotech/screens/video_player.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  XFile? _imageFile;

  Future<void> _verifyPhoneNumber() async {
    final phoneNumber = phoneController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final dob = dobController.text.trim();

    if (phoneNumber.isEmpty || name.isEmpty || email.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return VideoPlayerPage(); 
            },
          ));
        } catch (e) {
          print('Error during auto sign-in: ${e.toString()}');
        }
      },
      verificationFailed: (FirebaseAuthException ex) {
        print('Verification failed: ${ex.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${ex.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return OtpScreen(verificationId: verificationId);
          },
        ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Code auto retrieval timeout: $verificationId');
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100, 
              backgroundColor: Colors.grey[300],
              backgroundImage: _imageFile == null
                ? null
                : FileImage(File(_imageFile!.path)),
              child: _imageFile == null
                ? TextButton.icon(
                    icon: const Icon(Icons.upload, size: 40),
                    label: const Text('Upload', style: TextStyle(fontSize: 16)),
                    onPressed: _pickImage,
                  )
                : null,
            ),
                SizedBox(height: 10,),
                TextFormField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Full Name"),
            ),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(hintText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(hintText: "Email Address"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: dobController,
              decoration: const InputDecoration(hintText: "Date of Birth"),
            ),
            
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: const Text("Verify Number"),
            ),
          ],
        ),
      ),
    );
  }
}

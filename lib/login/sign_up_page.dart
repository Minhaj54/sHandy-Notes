import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';// Update with your correct import
import 'dart:io';

import '../navigation_page.dart';
import 'login_with _phoneNumber.dart';

class SignUpWithPhoneNumber extends StatefulWidget {
  const SignUpWithPhoneNumber({super.key});

  @override
  State<SignUpWithPhoneNumber> createState() => _SignUpWithPhoneNumberState();
}

class _SignUpWithPhoneNumberState extends State<SignUpWithPhoneNumber> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final professionController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final otpController = TextEditingController();
  final auth = FirebaseAuth.instance;
  String verificationId = '';
  File? profileImage;
  PhoneNumber number = PhoneNumber(isoCode: 'IN'); // Default to India

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref().child('profile_pics/${auth.currentUser?.uid}.jpg');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  void sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
    });

    final fullPhoneNumber = number.phoneNumber ?? '';

    await auth.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        saveUserData();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          loading = false;
          this.verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          this.verificationId = verificationId;
        });
      },
    );
  }

  void verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
    });
    final code = otpController.text.trim();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: code);
    try {
      await auth.signInWithCredential(credential);
      saveUserData();
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Verification failed')));
    }
  }

  void saveUserData() async {
    final userId = auth.currentUser?.uid;
    if (userId != null) {
      String? profilePicUrl;
      if (profileImage != null) {
        profilePicUrl = await uploadImage(profileImage!);
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': nameController.text,
        'profession': professionController.text,
        'phoneNumber': number.phoneNumber, // Save full phone number including country code
        'profilePicUrl': profilePicUrl,
      });

      setState(() {
        loading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationBaar()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create an account!!',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text('Welcome! Please enter your details.'),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: pickImage,
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.deepPurpleAccent,
                      radius: 60,
                      backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                      child: profileImage == null
                          ? const Icon(Icons.add_a_photo, size: 70, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: 'Name',
                    hintText: 'E.g - Tony Stalk',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: professionController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.man4),
                    labelText: 'Profession',
                    hintText: 'E.g - Student..',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your profession';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    setState(() {
                      this.number = number;
                    });
                  },
                  onInputValidated: (bool value) {
                    //print(value);
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: const TextStyle(color: Colors.black),
                  initialValue: number,
                  textFieldController: phoneNumberController,
                  formatInput: false,
                  maxLength: 15,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputDecoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: ' E.g - 62060*****',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                if (loading) const CircularProgressIndicator(),
                if (!loading)
                  ElevatedButton(
                    onPressed: sendOTP,
                    child: const Text('Sign Up'),
                  ),
                const SizedBox(height: 20),
                if (verificationId.isNotEmpty)
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '123456',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 20),
                if (verificationId.isNotEmpty && !loading)
                  ElevatedButton(
                    onPressed: verifyOTP,
                    child: const Text('Verify OTP'),
                  ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider()),
                    Text(' OR '),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginWithPhoneNumber()),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

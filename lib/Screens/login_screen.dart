import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Screens/Executive/Auth/executive_verification_screen.dart';
import 'package:elzsi/Utils/button_loader.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/utils/colors.dart';
import 'package:elzsi/utils/verticalspace.dart';
import 'package:flutter/material.dart';
import 'package:elzsi/Screens/Leader/Auth/leader_verification_screen.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //TO SET THE USER TYPE : EXECUTIVE OR LEADER
  int userType = 0;

  //REGEX
  final RegExp numberRegex = RegExp(r'^\d+$');

  //FOR LOADER
  bool isLoading = false;

  //CONTROLLERS
  final _mobileNoController = TextEditingController();

  //FORM_KEY
  final _loginFormKey = GlobalKey<FormState>();

  void _login() async {
    if (_loginFormKey.currentState!.validate()) {
      var data = {
        "user_type": userType == 0 ? "EXECUTIVE" : "LEADER",
        "mobile": _mobileNoController.text
      };
      FocusScope.of(context).unfocus();

      try {
        setState(() {
          isLoading = true;
        });

        final result = await Api().login(data);

        if (result['status'].toString() == '1') {
          setState(() {
            isLoading = false;
          });
          if (!context.mounted) {
            return;
          }
          _mobileNoController.clear();
          userType == 0
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ExecutiveVerificationScreen(data: result)))
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LeaderVerificationScreen(data: result)));
        } else {
          setState(() {
            isLoading = false;
          });
          Common().showToast(result['message']);
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something Went Wrong')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/login-banner.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'LOGIN',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      const VerticalSpace(height: 10),
                      Text(
                        'Please enter your mobile number',
                        style: TextStyle(color: fontGrey),
                      ),
                      const VerticalSpace(height: 20),
                      const Text(
                        'I am a',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: isLoading
                                ? () {}
                                : () {
                                    setState(() {
                                      userType = 0;
                                    });
                                  },
                            child: Container(
                              height: 40,
                              width: screenWidth * 0.40,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                    color:
                                        userType == 0 ? darkBlue : inputBorder),
                              ),
                              child: const Text(
                                'Executive',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: isLoading
                                ? () {}
                                : () {
                                    setState(() {
                                      userType = 1;
                                    });
                                  },
                            child: Container(
                              height: 40,
                              width: screenWidth * 0.40,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                    color:
                                        userType == 1 ? darkBlue : inputBorder),
                              ),
                              child: const Text(
                                'Leader',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const VerticalSpace(height: 30),
                      TextFormField(
                        controller: _mobileNoController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                          counterText: '',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.5, vertical: 14),
                            child: Image.asset(
                              'assets/images/mobile.png',
                              height: 15,
                            ),
                          ),
                          hintText: 'Mobile number',
                          hintStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        validator: (value) {
                          if (value.toString().trim().isEmpty ||
                              value == null) {
                            return 'Enter mobile number';
                          } else if (!numberRegex
                                  .hasMatch(value.toString().trim()) ||
                              value.toString().trim().length < 10) {
                            return 'Invalid mobile number';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const VerticalSpace(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? () {} : _login,
                          child: isLoading
                              ? const ButtonLoader()
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

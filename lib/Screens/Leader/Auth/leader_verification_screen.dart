import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Models/user_model.dart';
import 'package:elzsi/Screens/Leader/Dashboard/leader_home_screen.dart';
import 'package:elzsi/Utils/button_loader.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/utils/colors.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/utils/verticalspace.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:elzsi/Screens/Leader/Auth/leader_update_profile_screen.dart';

class LeaderVerificationScreen extends StatefulWidget {
  const LeaderVerificationScreen({super.key, required this.data});

  final Map data;

  @override
  State<LeaderVerificationScreen> createState() =>
      _LeaderVerificationScreenState();
}

class _LeaderVerificationScreenState extends State<LeaderVerificationScreen> {
  //DEVICE INFO
  String thisDeviceId = '';
  //KEY
  final _otpFormKey = GlobalKey<FormState>();
  //FOR OTP TIMER
  late Timer timer;
  int _remainingSeconds = 60;

  //CONTROLLERS
  final _otpController = TextEditingController();

  //FOR LOADER
  bool isLoading = false;
  bool resendOtpLoading = false;

  void _otpTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _resendOTP() async {
    _otpController.clear();
    var data = {"user_type": "LEADER", "mobile": widget.data['data']};

    try {
      setState(() {
        resendOtpLoading = true;
      });
      final result = await Api().resendOtp(data);

      if (result['status'].toString() == '1') {
        setState(() {
          resendOtpLoading = false;
          _remainingSeconds = 60;
        });

        _otpTimer();
        Common().showToast(result['message']);
      } else {
        setState(() {
          resendOtpLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        resendOtpLoading = false;
      });
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Something Went Wrong')));
    }
  }

  void _verifyOTP() async {
    FocusScope.of(context).unfocus();
    if (_otpFormKey.currentState!.validate()) {
      var fcm = FirebaseMessaging.instance;
      await fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      var fcmToken = await fcm.getToken();
      var data = {
        "user_id": widget.data['user_id'],
        "otp": _otpController.text,
        "user_type": "LEADER",
        "mobile": widget.data['data'],
        "device_type": Platform.isAndroid ? "ANDROID" : "IOS",
        "device_id": thisDeviceId,
        "fcm_token": fcmToken
      };

      try {
        setState(() {
          isLoading = true;
        });
        final result = await Api().verifyOtp(data);

        if (result['status'].toString() == '1') {
          DatabaseHelper().insertDb(UserModel(
              userId: result['data']['id'],
              deviceId: thisDeviceId,
              token: result['data']['api_token'],
              fcmToken: fcmToken ?? ''));
          await pref.setBool('loggedIn', true);
          await pref.setBool('leaderLogin', true);
          setState(() {
            isLoading = false;
          });
          if (!context.mounted) {
            return;
          }

          Nav().replace(context, const LeaderHomeScreen());
        } else if (result['status'].toString() == '2') {
          setState(() {
            isLoading = false;
          });
          if (!context.mounted) {
            return;
          }
          Nav().replace(
              context,
              LeaderUpdateProfileScreen(
                data: result['data'],
                deviceId: thisDeviceId,
                fcmToken: fcmToken ?? '',
              ));
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
  void initState() {
    _otpTimer();
    _getDeviceInfo();
    super.initState();
  }

  Future _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    var androidInfo = await deviceInfoPlugin.androidInfo;
    var androidId = androidInfo.id;
    setState(() {
      thisDeviceId = androidId.toString();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        body: SingleChildScrollView(
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
                      'VERIFICATION',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const VerticalSpace(height: 10),
                    Text(
                      'You will get a OTP via SMS',
                      style: TextStyle(color: fontGrey),
                    ),
                    const VerticalSpace(height: 20),
                    Center(
                      child: Form(
                        key: _otpFormKey,
                        child: Pinput(
                          length: 4,
                          controller: _otpController,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          defaultPinTheme: PinTheme(
                            width: 64,
                            height: 62,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: inputBg,
                              border: Border.all(color: inputBorder),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                                fontSize: 20,
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 64,
                            height: 62,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: inputBg,
                              border: Border.all(color: primaryColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                                fontSize: 20,
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                          errorPinTheme: PinTheme(
                            width: 64,
                            height: 62,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: inputBg,
                              border: Border.all(color: Colors.red.shade900),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold),
                          ),
                          onChanged: (value) {},
                          validator: (value) {
                            if (value.toString().trim().isEmpty ||
                                value == null ||
                                value.length < 4) {
                              return 'Enter four digit OTP';
                            } else {
                              return null;
                            }
                          },
                          onCompleted: (value) {
                            _verifyOTP();
                          },
                        ),
                      ),
                    ),
                    const VerticalSpace(height: 30),
                    Center(
                      child: _remainingSeconds == 0
                          ? resendOtpLoading
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                )
                              : TextButton(
                                  onPressed: isLoading ? () {} : _resendOTP,
                                  child: const Text(
                                    'Resend code',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Resend code in ',
                                      style: TextStyle(color: fontGrey),
                                    ),
                                    TextSpan(
                                      text: ' $_remainingSeconds secs',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Change mobile number',
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verifyOTP,
                        child: isLoading
                            ? const ButtonLoader()
                            : const Text(
                                'VERIFY',
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
    );
  }
}

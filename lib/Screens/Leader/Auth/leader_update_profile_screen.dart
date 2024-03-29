import 'dart:convert';
import 'dart:io';
import 'package:elzsi/Api/urls.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Models/user_model.dart';
import 'package:elzsi/Screens/Leader/Dashboard/leader_home_screen.dart';
import 'package:elzsi/Utils/button_loader.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Widgets/common_modal.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/regex.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:http/http.dart' as http;

class LeaderUpdateProfileScreen extends StatefulWidget {
  const LeaderUpdateProfileScreen(
      {super.key,
      required this.data,
      required this.deviceId,
      required this.fcmToken});

  final Map data;
  final String deviceId;
  final String fcmToken;
  @override
  State<LeaderUpdateProfileScreen> createState() =>
      _LeaderUpdateProfileScreenState();
}

class _LeaderUpdateProfileScreenState extends State<LeaderUpdateProfileScreen> {
  @override
  void initState() {
    setState(() {
      _nameController.text = widget.data['agent_name'] ?? '';
      _emailController.text = widget.data['agent_email']?.toString() ?? '';
      _addressController.text = widget.data['address'] ?? '';
      _projectsCountController.text =
          widget.data['no_of_projects']?.toString() ?? '';
      if (widget.data['created_seller'] != null &&
          widget.data['created_seller'] != "") {
        existingControllers[0][0].text =
            widget.data['created_seller']?['business_name'] ?? '';
        existingControllers[0][1].text =
            widget.data['created_seller']?['name'] ?? '';
        existingControllers[0][2].text =
            widget.data['created_seller']?['mobile']?.toString() ?? '';
      }
    });
    super.initState();
  }

  //KEY
  final _formKey = GlobalKey<FormState>();

  //FOR LOADER
  bool isLoading = false;

//CONTROLLERS
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  // final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _projectsCountController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _areaController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();

  DateTime? selectedDOB(String date) {
    try {
      DateTime givenDate = DateFormat('dd-MM-yyyy').parse(date);
      String formatChangedDate = DateFormat('yyyy-MM-dd').format(givenDate);
      DateTime dob = DateTime.parse(formatChangedDate);
      return dob;
    } catch (e) {
      return null;
    }
  }

  //FOCUS NODES
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  // final _mobileFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _projectsCountFocus = FocusNode();
  final _dobFocus = FocusNode();
  final _genderFocus = FocusNode();
  final _areaFocus = FocusNode();
  final _pincodeFocus = FocusNode();
  final _yearsOfExperienceFocus = FocusNode();

  //FUNCTION FOR SCROLLING INTO ERROR TEXT FIELD
  void _scrollToErrorField(FocusNode focusField) {
    FocusScope.of(context).unfocus();
    final RenderObject renderObject = focusField.context!.findRenderObject()!;
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(renderObject);
    final double offset = viewport.getOffsetToReveal(renderObject, 0.0).offset;

    _scrollController.animateTo(
      offset - 75,
      duration: const Duration(milliseconds: 400),
      curve: Curves.linear,
    );
  }

  //EXECUTIVE TYPE
  int workingType = 5;

  //GENDERS
  List genders = ['Male', 'Female', 'Others'];

  //ADDRESS INFOs
  Map? selectedPincode;
  Map? selectedArea;

  //FOR SELECTED DOCUMENTS
  File? _photo;
  String? _photoName;
  File? _aadhaar;
  String? _aadhaarName;
  File? _pan;
  String? _panName;
  File? _sellerLetter;
  String? _sellerLetterName;

  List<List<TextEditingController>> existingControllers = [
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ]
  ];

  DateTime _startingYear(String date) {
    DateTime dateTime = DateTime.parse("$date-01");
    return dateTime;
  }

  void chooseDocumentAlert(String type) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        clipBehavior: Clip.hardEdge,
        children: [
          ListTile(
            onTap: () {
              if (type == 'photo') {
                Nav().pop(context);
                _choosePhoto('gallery');
              } else if (type == 'aadhaar') {
                Nav().pop(context);
                _chooseAadhaar('gallery');
              } else if (type == 'pan') {
                Nav().pop(context);
                _choosePan('gallery');
              } else if (type == 'sellerletter') {
                Nav().pop(context);
                _chooseSellerLetter('gallery');
              }
            },
            leading: const Icon(
              Icons.image,
              color: Colors.black,
            ),
            title: const Text(
              'Choose Image',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
          ListTile(
            onTap: () {
              if (type == 'photo') {
                Nav().pop(context);
                _choosePhoto('filemanager');
              } else if (type == 'aadhaar') {
                Nav().pop(context);
                _chooseAadhaar('filemanager');
              } else if (type == 'pan') {
                Nav().pop(context);
                _choosePan('filemanager');
              } else if (type == 'sellerletter') {
                Nav().pop(context);
                _chooseSellerLetter('filemanager');
              }
            },
            leading: const Icon(
              Icons.sim_card_rounded,
              color: Colors.black,
            ),
            title: const Text(
              'Choose PDF',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  //CHOOSE PHOTO
  void _choosePhoto(String source) async {
    try {
      if (source == 'gallery') {
        final pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          // if (!pickedImage.name.endsWith('jpg') ||
          //     !pickedImage.name.endsWith('jpeg') ||
          //     !pickedImage.name.endsWith('png')) {
          //   Common().showToast('Unsupported Format');
          //   return;
          // }
          setState(() {
            _photo = File(pickedImage.path);
            _photoName = pickedImage.name;
          });
        }
      } else {
        FilePickerResult? pickedPdf = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (pickedPdf != null) {
          setState(() {
            _photo = File(pickedPdf.files.single.path!);
            _photoName = pickedPdf.names[0].toString();
          });
        }
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Permission Denied')));
    }
  }

  //CHOOSE AADHAAR
  void _chooseAadhaar(String source) async {
    try {
      if (source == 'gallery') {
        final pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          // if (!pickedImage.name.endsWith('jpg') ||
          //     !pickedImage.name.endsWith('jpeg') ||
          //     !pickedImage.name.endsWith('png')) {
          //   Common().showToast('Unsupported Format');
          //   return;
          // }
          setState(() {
            _aadhaar = File(pickedImage.path);
            _aadhaarName = pickedImage.name;
          });
        }
      } else {
        FilePickerResult? pickedPdf = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (pickedPdf != null) {
          setState(() {
            _aadhaar = File(pickedPdf.files.single.path!);
            _aadhaarName = pickedPdf.names[0].toString();
          });
        }
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Permission Denied')));
    }
  }

  //CHOOSE PAN
  void _choosePan(String source) async {
    try {
      if (source == 'gallery') {
        final pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          // if (!pickedImage.name.endsWith('jpg') ||
          //     !pickedImage.name.endsWith('jpeg') ||
          //     !pickedImage.name.endsWith('png')) {
          //   Common().showToast('Unsupported Format');
          //   return;
          // }
          setState(() {
            _pan = File(pickedImage.path);
            _panName = pickedImage.name;
          });
        }
      } else {
        FilePickerResult? pickedPdf = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (pickedPdf != null) {
          setState(() {
            _pan = File(pickedPdf.files.single.path!);
            _panName = pickedPdf.names[0].toString();
          });
        }
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Permission Denied')));
    }
  }

  //CHOOSE SELLER LETTER
  void _chooseSellerLetter(String source) async {
    try {
      if (source == 'gallery') {
        final pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          // if (!pickedImage.name.endsWith('jpg') ||
          //     !pickedImage.name.endsWith('jpeg') ||
          //     !pickedImage.name.endsWith('png')) {
          //   Common().showToast('Unsupported Format');
          //   return;
          // }
          setState(() {
            _sellerLetter = File(pickedImage.path);
            _sellerLetterName = pickedImage.name;
          });
        }
      } else {
        FilePickerResult? pickedPdf = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (pickedPdf != null) {
          setState(() {
            _sellerLetter = File(pickedPdf.files.single.path!);
            _sellerLetterName = pickedPdf.names[0].toString();
          });
        }
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Permission Denied')));
    }
  }

  void _addExistingSellerDetails() {
    setState(() {
      existingControllers.add([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    });
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
  }

  //CHOOSE DOB
  void _chooseDOB() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: selectedDOB(_dobController.text),
      lastDate: DateTime(
          DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  // String _formatDate(String date) {
  //   if (date.isEmpty || date == '') {
  //     return '';
  //   }
  //   DateTime inputDate = DateTime.parse(date);
  //   String formattedDate = DateFormat('dd-MM-yyyy').format(inputDate);
  //   return formattedDate;
  // }

  String _formatDate1(String date) {
    if (date.isEmpty || date == '') {
      return '';
    }
    DateTime inputDate = DateFormat("dd-MM-yyyy").parse(date);
    String formattedDate = DateFormat('yyyy-MM-dd').format(inputDate);
    return formattedDate;
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // if (_photo == null) {
      //   Common().showToast('Upload Photo');
      // } else if (_aadhaar == null) {
      //   Common().showToast('Upload Aadhaar');
      // } else if (_pan == null) {
      //   Common().showToast('Upload PAN or Driving License');
      // } else if (_sellerLetter == null) {
      //   Common().showToast('Upload Seller Letter');
      // } else {
      try {
        FocusScope.of(context).unfocus();
        setState(() {
          isLoading = true;
        });
        var request = http.MultipartRequest(
            'POST', Uri.parse(liveURL + updateProfileUrl));

        //HEADERS
        request.headers['x-api-key'] = widget.data['api_token'].toString();

        //DATA - BODY FIELD
        request.fields['user_id'] = widget.data['id'].toString();
        request.fields['work_position'] = workingType.toString();
        request.fields['name'] = _nameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['dob'] = _formatDate1(_dobController.text);
        request.fields['gender'] = _genderController.text;
        request.fields['address'] = _addressController.text;
        request.fields['mobile'] = widget.data['mobile'];
        request.fields['area_id'] = selectedArea!['id'].toString();
        request.fields['pincode_id'] = selectedPincode!['id'].toString();
        request.fields['years_of_exp'] =
            _yearsOfExperienceController.text.toString();
        request.fields['no_of_projects'] = _projectsCountController.text;
        for (int info = 0; info < existingControllers.length; info++) {
          if (existingControllers[info][0].text.isNotEmpty ||
              existingControllers[info][1].text.isNotEmpty ||
              existingControllers[info][2].text.isNotEmpty ||
              existingControllers[info][3].text.isNotEmpty ||
              existingControllers[info][4].text.isNotEmpty ||
              existingControllers[info][5].text.isNotEmpty ||
              existingControllers[info][6].text.isNotEmpty) {
            request.fields['existing_sellers[$info]'] = json.encode({
              "id": 0,
              "business_name": existingControllers[info][0].text,
              "person_name": existingControllers[info][1].text,
              "contact_number": existingControllers[info][2].text,
              "since_yrmonth":
                  existingControllers[info][3].text.replaceAll('/', '-'),
              "till_yrmonth":
                  existingControllers[info][4].text.replaceAll('/', '-'),
              "handled_projects": existingControllers[info][5].text,
              "position_held": existingControllers[info][6].text,
            });
          }
        }

        //ADD FILES
        if (_photo != null) {
          request.files.add(
              await http.MultipartFile.fromPath('agent_image', _photo!.path));
        }

        if (_aadhaar != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'aadhar_image', _aadhaar!.path));
        }

        if (_pan != null) {
          request.files.add(
              await http.MultipartFile.fromPath('pan_dlicense', _pan!.path));
        }

        if (_sellerLetter != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'seller_letter', _sellerLetter!.path));
        }

        var response = await request.send();
        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();

          var result = json.decode(responseBody);

          if (result['status'].toString() == '1') {
            DatabaseHelper().insertDb(UserModel(
                userId: result['data']['id'],
                deviceId: widget.deviceId,
                token: result['data']['api_token'],
                fcmToken: widget.fcmToken));
            await pref.setBool('loggedIn', true);
            await pref.setBool('executiveLogin', true);
            if (!context.mounted) {
              return;
            }
            setState(() {
              isLoading = false;
            });
            Common().showToast(result['message']);
            Nav().replace(context, const LeaderHomeScreen());
          } else {
            setState(() {
              isLoading = false;
            });
            Common().showToast(result['message']);
          }
        } else {
          throw Exception('Something went wrong');
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
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        body: SingleChildScrollView(
          controller: _scrollController,
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
                padding:
                    EdgeInsets.symmetric(horizontal: Platform.isIOS ? 20 : 15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'UPDATE PROFILE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const VerticalSpace(height: 15),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio(
                                  value: 5,
                                  groupValue: workingType,
                                  activeColor: primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      workingType = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  'Agent',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const HorizontalSpace(width: 25),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio(
                                  value: 6,
                                  groupValue: workingType,
                                  activeColor: primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      workingType = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  'Employee',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const VerticalSpace(height: 15),
                      const Text(
                        'Name',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        style: const TextStyle(fontSize: 14),
                        controller: _nameController,
                        focusNode: _nameFocus,
                        decoration: const InputDecoration(
                          hintText: 'Enter Name',
                        ),
                        validator: (value) {
                          if (value.toString().trim().isEmpty ||
                              value == null) {
                            _scrollToErrorField(_nameFocus);
                            return 'Enter name';
                          } else if (!nameRegex
                              .hasMatch(value.toString().trim())) {
                            _scrollToErrorField(_nameFocus);
                            return 'Invalid name';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const VerticalSpace(height: 17.5),
                      const Text(
                        'Mail ID',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        style: const TextStyle(fontSize: 14),
                        controller: _emailController,
                        focusNode: _emailFocus,
                        decoration:
                            const InputDecoration(hintText: 'Enter Mail ID'),
                        validator: (value) {
                          if (value.toString().trim().isEmpty ||
                              value == null) {
                            _scrollToErrorField(_emailFocus);
                            return 'Enter mail address';
                          } else if (!emailRegex
                              .hasMatch(value.toString().trim())) {
                            _scrollToErrorField(_emailFocus);
                            return 'Invalid mail address';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const VerticalSpace(height: 17.5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DOB',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                const VerticalSpace(height: 6),
                                TextFormField(
                                  readOnly: true,
                                  onTap: _chooseDOB,
                                  style: const TextStyle(fontSize: 14),
                                  controller: _dobController,
                                  focusNode: _dobFocus,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your DOB',
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Image.asset(
                                        'assets/images/calendar.png',
                                        height: 5,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value.toString().trim().isEmpty ||
                                        value == null) {
                                      _scrollToErrorField(_dobFocus);
                                      return 'Enter Date of Birth';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const HorizontalSpace(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gender',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                const VerticalSpace(height: 6),
                                TextFormField(
                                  style: const TextStyle(fontSize: 14),
                                  controller: _genderController,
                                  focusNode: _genderFocus,
                                  readOnly: true,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                        backgroundColor: Colors.white,
                                        surfaceTintColor: Colors.white,
                                        clipBehavior: Clip.hardEdge,
                                        children: [
                                          for (final gender in genders)
                                            ListTile(
                                              onTap: () {
                                                setState(() {
                                                  _genderController.text =
                                                      gender;
                                                });
                                                Nav().pop(context);
                                              },
                                              title: Text(
                                                gender,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Enter your gender'),
                                  validator: (value) {
                                    if (value.toString().trim().isEmpty ||
                                        value == null) {
                                      _scrollToErrorField(_genderFocus);
                                      return 'Enter your gender';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const VerticalSpace(height: 17.5),
                      const Text(
                        'Address',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        style: const TextStyle(fontSize: 14),
                        controller: _addressController,
                        focusNode: _addressFocus,
                        decoration:
                            const InputDecoration(hintText: 'Enter Address'),
                        validator: (value) {
                          if (value.toString().trim().isEmpty ||
                              value == null) {
                            _scrollToErrorField(_addressFocus);
                            return 'Enter address';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const VerticalSpace(height: 17.5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pincode',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                const VerticalSpace(height: 6),
                                TextFormField(
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 14),
                                  controller: _pincodeController,
                                  focusNode: _pincodeFocus,
                                  decoration: InputDecoration(
                                    hintText: 'Select pincode',
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Image.asset(
                                        'assets/images/down.png',
                                        height: 5,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) =>
                                            CommonModal.pincode(
                                                userId: widget.data['id']
                                                    .toString(),
                                                token: widget.data['api_token']
                                                    .toString(),
                                                chosenPincode: selectedPincode,
                                                onSelect: (pincode) {
                                                  setState(() {
                                                    selectedPincode = pincode;
                                                    _pincodeController.text =
                                                        pincode['pincode']
                                                            .toString();
                                                    _areaController.clear();
                                                    selectedArea = null;
                                                  });
                                                }));
                                  },
                                  validator: (value) {
                                    if (value.toString().trim().isEmpty ||
                                        value == null) {
                                      _scrollToErrorField(_pincodeFocus);
                                      return 'Select pincode';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const HorizontalSpace(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Area',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                const VerticalSpace(height: 6),
                                TextFormField(
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 14),
                                  controller: _areaController,
                                  focusNode: _areaFocus,
                                  onTap: () {
                                    if (selectedPincode != null) {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) =>
                                              CommonModal.area(
                                                  userId: widget.data['id']
                                                      .toString(),
                                                  token: widget
                                                      .data['api_token']
                                                      .toString(),
                                                  chosenPincode:
                                                      selectedPincode,
                                                  chosenArea: selectedArea,
                                                  onSelect: (area) {
                                                    setState(() {
                                                      selectedArea = area;
                                                      _areaController.text =
                                                          area['area_name'];
                                                    });
                                                  }));
                                    } else {
                                      Common()
                                          .showToast('Please select pincode');
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Select area',
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Image.asset(
                                        'assets/images/down.png',
                                        height: 5,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value.toString().trim().isEmpty ||
                                        value == null) {
                                      _scrollToErrorField(_areaFocus);
                                      return 'Select area';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const VerticalSpace(height: 17.5),
                      const Text(
                        'Years of Experience',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        maxLength: 3,
                        style: const TextStyle(fontSize: 14),
                        controller: _yearsOfExperienceController,
                        focusNode: _yearsOfExperienceFocus,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            counterText: '',
                            hintText: 'Enter years of experience'),
                        validator: (value) {
                          if (value.toString().trim().isEmpty ||
                              value == null) {
                            _scrollToErrorField(_yearsOfExperienceFocus);
                            return 'Enter years of experience';
                          } else if (!numberRegex
                              .hasMatch(value.toString().trim())) {
                            _scrollToErrorField(_yearsOfExperienceFocus);
                            return 'Enter in numbers';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const VerticalSpace(height: 17.5),
                      const Text(
                        'No. of Projects Handled',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        maxLength: 6,
                        focusNode: _projectsCountFocus,
                        style: const TextStyle(fontSize: 14),
                        controller: _projectsCountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            counterText: '',
                            hintText: 'No. of Projects Handled'),
                        validator: (value) {
                          if (value.toString().trim().isEmpty ||
                              value == null) {
                            _scrollToErrorField(_projectsCountFocus);
                            return 'Enter no. of projects handled';
                          } else if (!numberRegex
                              .hasMatch(value.toString().trim())) {
                            _scrollToErrorField(_projectsCountFocus);
                            return 'Enter in numbers';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const VerticalSpace(height: 17.5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Uploads',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          const HorizontalSpace(width: 7.5),
                          Text(
                            '(.jpg & .pdf)',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 10),
                          ),
                        ],
                      ),
                      const VerticalSpace(height: 13),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.2,
                            child: InkWell(
                              onTap: () {
                                chooseDocumentAlert('photo');
                              },
                              child: Column(
                                children: [
                                  _photo != null && _photoName != null
                                      ? !_photoName!.endsWith('.pdf')
                                          ? Stack(
                                              children: [
                                                Image.file(
                                                  _photo!,
                                                  height: 70,
                                                  width: 70,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      const SizedBox(
                                                    height: 70,
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                                  ),
                                                ),
                                                const Positioned(
                                                  right: 2,
                                                  bottom: 2,
                                                  child: Icon(
                                                    Icons.image_rounded,
                                                    color: Colors.red,
                                                    size: 15,
                                                  ),
                                                )
                                              ],
                                            )
                                          : Image.asset(
                                              'assets/images/pdf.png',
                                              height: 70,
                                            )
                                      : Image.asset(
                                          'assets/images/upload.png',
                                          height: 70,
                                        ),
                                  const VerticalSpace(height: 7),
                                  _photoName != null
                                      ? Text(
                                          _photoName!,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: fontLightGrey,
                                              fontSize: 10),
                                        )
                                      : Text(
                                          '(Photo)',
                                          style: TextStyle(
                                              color: fontLightGrey,
                                              fontSize: 10),
                                        )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.2,
                            child: InkWell(
                              onTap: () {
                                chooseDocumentAlert('aadhaar');
                              },
                              child: Column(
                                children: [
                                  _aadhaar != null && _aadhaarName != null
                                      ? !_aadhaarName!.endsWith('.pdf')
                                          ? Stack(
                                              children: [
                                                Image.file(
                                                  _aadhaar!,
                                                  height: 70,
                                                  width: 70,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      const SizedBox(
                                                    height: 70,
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                                  ),
                                                ),
                                                const Positioned(
                                                  right: 2,
                                                  bottom: 2,
                                                  child: Icon(
                                                    Icons.image_rounded,
                                                    color: Colors.red,
                                                    size: 15,
                                                  ),
                                                )
                                              ],
                                            )
                                          : Image.asset(
                                              'assets/images/pdf.png',
                                              height: 70,
                                            )
                                      : Image.asset(
                                          'assets/images/upload.png',
                                          height: 70,
                                        ),
                                  const VerticalSpace(height: 7),
                                  _aadhaarName != null
                                      ? Text(
                                          _aadhaarName!,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: fontLightGrey,
                                              fontSize: 10),
                                        )
                                      : Text(
                                          '(Aadhaar)',
                                          style: TextStyle(
                                              color: fontLightGrey,
                                              fontSize: 10),
                                        )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.2,
                            child: InkWell(
                              onTap: () {
                                chooseDocumentAlert('pan');
                              },
                              child: Column(
                                children: [
                                  _pan != null && _panName != null
                                      ? !_panName!.endsWith('.pdf')
                                          ? Stack(
                                              children: [
                                                Image.file(
                                                  _pan!,
                                                  height: 70,
                                                  width: 70,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      const SizedBox(
                                                    height: 70,
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                                  ),
                                                ),
                                                const Positioned(
                                                  right: 2,
                                                  bottom: 2,
                                                  child: Icon(
                                                    Icons.image_rounded,
                                                    color: Colors.red,
                                                    size: 15,
                                                  ),
                                                )
                                              ],
                                            )
                                          : Image.asset(
                                              'assets/images/pdf.png',
                                              height: 70,
                                            )
                                      : Image.asset(
                                          'assets/images/upload.png',
                                          height: 70,
                                        ),
                                  const VerticalSpace(height: 7),
                                  _panName != null
                                      ? Text(
                                          _panName!,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: fontLightGrey,
                                              fontSize: 10),
                                        )
                                      : Text(
                                          '(Pan/DL)',
                                          style: TextStyle(
                                              color: fontLightGrey,
                                              fontSize: 10),
                                        )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.2,
                            child: InkWell(
                              onTap: () {
                                chooseDocumentAlert('sellerletter');
                              },
                              child: Column(
                                children: [
                                  _sellerLetter != null &&
                                          _sellerLetterName != null
                                      ? !_sellerLetterName!.endsWith('.pdf')
                                          ? Stack(
                                              children: [
                                                Image.file(
                                                  _sellerLetter!,
                                                  height: 70,
                                                  width: 70,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      const SizedBox(
                                                    height: 70,
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                                  ),
                                                ),
                                                const Positioned(
                                                  right: 2,
                                                  bottom: 2,
                                                  child: Icon(
                                                    Icons.image_rounded,
                                                    color: Colors.red,
                                                    size: 15,
                                                  ),
                                                )
                                              ],
                                            )
                                          : Image.asset(
                                              'assets/images/pdf.png',
                                              height: 70,
                                            )
                                      : Image.asset(
                                          'assets/images/upload.png',
                                          height: 70,
                                        ),
                                  const VerticalSpace(height: 7),
                                  _sellerLetterName != null
                                      ? Text(
                                          _sellerLetterName!,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: fontLightGrey,
                                              fontSize: 10),
                                        )
                                      : Text(
                                          '(Seller Letter)',
                                          style: TextStyle(
                                              color: fontLightGrey,
                                              fontSize: 10),
                                        )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 17.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Existing Seller Details',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: _addExistingSellerDetails,
                            icon: Image.asset(
                              'assets/images/plus-btn.png',
                              height: 23,
                            ),
                          )
                        ],
                      ),
                      for (int i = 0; i < existingControllers.length; i++)
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Business Name',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                style: const TextStyle(fontSize: 14),
                                controller: existingControllers[i][0],
                                decoration: const InputDecoration(
                                  hintText: 'Enter Business Name',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) {
                                  if (value!.isNotEmpty) {
                                    if (!nameRegex
                                        .hasMatch(value.toString().trim())) {
                                      return 'Invalid business name';
                                    } else {
                                      return null;
                                    }
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const VerticalSpace(height: 17.5),
                              const Text(
                                'Person Name',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                controller: existingControllers[i][1],
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Enter Person Name',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) {
                                  if (value!.isNotEmpty) {
                                    if (!nameRegex
                                        .hasMatch(value.toString().trim())) {
                                      return 'Invalid person name';
                                    } else {
                                      return null;
                                    }
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const VerticalSpace(height: 17.5),
                              const Text(
                                'Contact No',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                controller: existingControllers[i][2],
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                    hintText: 'Enter Contact No',
                                    filled: true,
                                    fillColor: Colors.white,
                                    counterText: ''),
                                validator: (value) {
                                  if (value!.isNotEmpty) {
                                    if (!numberRegex
                                        .hasMatch(value.toString().trim())) {
                                      return 'Invalid business name';
                                    } else {
                                      return null;
                                    }
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const VerticalSpace(height: 17.5),
                              const Text(
                                'Since YY/MM',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                readOnly: true,
                                controller: existingControllers[i][3],
                                style: const TextStyle(fontSize: 14),
                                onTap: () async {
                                  var date = await showMonthPicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      existingControllers[i][3].text =
                                          date.month.toString().length == 2
                                              ? '${date.year}/${date.month}'
                                              : '${date.year}/0${date.month}';
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter Since YY/MM',
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Image.asset(
                                      'assets/images/calendar.png',
                                      height: 5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: Colors.red.shade800, width: 1),
                                  ),
                                ),
                                validator: (value) {
                                  if (existingControllers[i][4]
                                      .text
                                      .isNotEmpty) {
                                    if (value.toString().isEmpty ||
                                        value == null) {
                                      return 'Please select year and month';
                                    } else {
                                      return null;
                                    }
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const VerticalSpace(height: 17.5),
                              const Text(
                                'Till  YY/MM',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                readOnly: true,
                                controller: existingControllers[i][4],
                                style: const TextStyle(fontSize: 14),
                                onTap: existingControllers[i][3].text.isEmpty
                                    ? () {
                                        Common().showToast(
                                            'Select starting year and month');
                                      }
                                    : () async {
                                        var date = await showMonthPicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: _startingYear(
                                              existingControllers[i][3]
                                                  .text
                                                  .toString()
                                                  .replaceAll('/', '-')),
                                          lastDate: DateTime.now(),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            existingControllers[i][4]
                                                .text = date.month
                                                        .toString()
                                                        .length ==
                                                    2
                                                ? '${date.year}/${date.month}'
                                                : '${date.year}/0${date.month}';
                                          });
                                        }
                                      },
                                decoration: InputDecoration(
                                  hintText: 'Enter Till  YY/MM',
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Image.asset(
                                      'assets/images/calendar.png',
                                      height: 5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: Colors.red.shade800, width: 1),
                                  ),
                                ),
                                // validator: (value) {
                                //   if (value.toString().isEmpty ||
                                //       value == null) {
                                //     return 'Please select year and month';
                                //   } else {
                                //     return null;
                                //   }
                                // },
                              ),
                              const VerticalSpace(height: 17.5),
                              const Text(
                                'Handled Projects',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                controller: existingControllers[i][5],
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Enter Handled Projects',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                // validator: (value) {
                                //   if (value.toString().isEmpty ||
                                //       value == null) {
                                //     return 'Enter handled projects';
                                //   } else {
                                //     return null;
                                //   }
                                // },
                              ),
                              const VerticalSpace(height: 17.5),
                              const Text(
                                'Position Held',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                controller: existingControllers[i][6],
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Enter Position Held',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                // validator: (value) {
                                //   if (value.toString().isEmpty ||
                                //       value == null) {
                                //     return 'Enter position held';
                                //   } else {
                                //     return null;
                                //   }
                                // },
                              ),
                              const VerticalSpace(height: 17.5),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? () {}
                              : workingType != 5 && workingType != 6
                                  ? () {
                                      Common().showToast(
                                          'Please select work position');
                                    }
                                  : _updateProfile,
                          icon: isLoading
                              ? const ButtonLoader()
                              : const VerticalSpace(height: 0),
                          label: const Text(
                            'UPDATE PROFILE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      VerticalSpace(height: Platform.isIOS ? 32 : 20),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

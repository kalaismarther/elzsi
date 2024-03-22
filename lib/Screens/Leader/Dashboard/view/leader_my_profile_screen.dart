import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Api/urls.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/PDF/pdf.dart';
import 'package:elzsi/Screens/view_pdf_screen.dart';
import 'package:elzsi/Utils/button_loader.dart';
import 'package:elzsi/Utils/circleshimmer.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Widgets/common_modal.dart';
import 'package:flutter/material.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/regex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class LeaderMyProfileScreen extends StatefulWidget {
  const LeaderMyProfileScreen({super.key, required this.reloadHomeContent});

  final Function() reloadHomeContent;
  @override
  State<LeaderMyProfileScreen> createState() => _LeaderMyProfileScreenState();
}

class _LeaderMyProfileScreenState extends State<LeaderMyProfileScreen> {
  @override
  void initState() {
    _getProfile = _getProfileInfo();
    super.initState();
  }

  //FUTURE
  late Future _getProfile;

  //KEY
  final _formKey = GlobalKey<FormState>();

  //FOR LOADER
  bool isLoading = false;
  bool dpLoading = false;
  bool centerLoading = false;

  //TO STORE THE INITIALIZED PROFILE DATA
  Map? profileInfo;

  //CONTROLLERS
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _projectsCountController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _areaController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();

  //EXECUTIVE TYPE
  int workingType = 5;

  //ADDRESS INFO
  Map? selectedPincode;
  Map? selectedArea;

  //FOR PROFILE PICTURE
  String? displayPicture;

  //RETRIEVED DOCUMENTS INFO
  String? _uploadedPhotoLink;
  String? _uploadedAadhaarLink;
  String? _uploadedPanLink;
  String? _uploadedSellerLetterLink;

  //FOR SELECTED DOCUMENTS
  File? _photo;
  String? _photoName;
  String photoSource = 'online';

  File? _aadhaar;
  String? _aadhaarName;
  String aadhaarSource = 'online';

  File? _pan;
  String? _panName;
  String panSource = 'online';

  File? _sellerLetter;
  String? _sellerLetterName;
  String sellerLetterSource = 'online';

  List existingControllers = [];

  DateTime _startingYear(String date) {
    DateTime dateTime = DateTime.parse("$date-01");
    print(dateTime);
    return dateTime;
  }

  //CHOOSE PHOTO
  void _choosePhoto() async {
    try {
      FilePickerResult? pickedPhoto = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf'],
      );

      if (pickedPhoto != null) {
        setState(() {
          _photo = File(pickedPhoto.files.single.path!);
          _photoName = pickedPhoto.names[0].toString();
          photoSource = 'offline';
        });
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
  void _chooseAadhaar() async {
    try {
      FilePickerResult? pickedAadhaar = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf'],
      );

      if (pickedAadhaar != null) {
        setState(() {
          _aadhaar = File(pickedAadhaar.files.single.path!);
          _aadhaarName = pickedAadhaar.names[0].toString();
          aadhaarSource = 'offline';
        });
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
  void _choosePan() async {
    try {
      FilePickerResult? pickedPan = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf'],
      );

      if (pickedPan != null) {
        setState(() {
          _pan = File(pickedPan.files.single.path!);
          _panName = pickedPan.names[0].toString();
          panSource = 'offline';
        });
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
  void _chooseSellerLetter() async {
    try {
      FilePickerResult? pickedSellerLetter =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf'],
      );

      if (pickedSellerLetter != null) {
        setState(() {
          _sellerLetter = File(pickedSellerLetter.files.single.path!);
          _sellerLetterName = pickedSellerLetter.names[0].toString();
          sellerLetterSource = 'offline';
        });
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Permission Denied')));
    }
  }

  //CHOOSE DOB
  void _chooseDOB() async {
    final pickedDate = await showDatePicker(
        context: context, firstDate: DateTime(1900), lastDate: DateTime.now());

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty || date == '') {
      return '';
    }
    DateTime inputDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd-MM-yyyy').format(inputDate);
    return formattedDate;
  }

  String _formatDate1(String date) {
    if (date.isEmpty || date == '') {
      return '';
    }
    DateTime inputDate = DateFormat("dd-MM-yyyy").parse(date);
    String formattedDate = DateFormat('yyyy-MM-dd').format(inputDate);
    return formattedDate;
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
        0
      ]);
    });
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
  }

  void _updateProfile() async {
    final userInfo = await DatabaseHelper().initDb();
    if (_formKey.currentState!.validate()) {
      // if (_photoName == null || _photoName!.trim().isEmpty) {
      //   Common().showToast('Upload Photo');
      // } else if (_aadhaarName == null || _aadhaarName!.trim().isEmpty) {
      //   Common().showToast('Upload Aadhaar');
      // } else if (_panName == null || _panName!.trim().isEmpty) {
      //   Common().showToast('Upload PAN or Driving License');
      // } else if (_sellerLetterName == null ||
      //     _sellerLetterName!.trim().isEmpty) {
      //   Common().showToast('Upload Seller Letter');
      // } else {
      try {
        if (!context.mounted) {
          return;
        }
        FocusScope.of(context).unfocus();
        setState(() {
          isLoading = true;
        });
        var request = http.MultipartRequest(
            'POST', Uri.parse(liveURL + updateProfileUrl));

        //HEADERS
        request.headers['x-api-key'] = userInfo.token.toString();

        //DATA - BODY FIELD
        request.fields['user_id'] = userInfo.userId.toString();
        request.fields['work_position'] = workingType.toString();
        request.fields['name'] = _nameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['dob'] = _formatDate1(_dobController.text);
        request.fields['gender'] = _genderController.text;
        request.fields['address'] = _addressController.text;
        request.fields['mobile'] = profileInfo!['mobile'].toString();
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
              "id": existingControllers[info][7],
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

        var responseBody = await response.stream.bytesToString();

        var result = json.decode(responseBody);

        if (result['status'].toString() == '1') {
          setState(() {
            isLoading = false;
          });
          Common().showToast(result['message']);
          if (!context.mounted) {
            return;
          }
          Nav().pop(context);
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
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something Went Wrong')));
      }
    }
    // }
  }

  Future<void> _getProfileInfo() async {
    final userInfo = await DatabaseHelper().initDb();
    if (!context.mounted) {
      return;
    }

    var data = {"user_id": userInfo.userId};
    print(data);
    print(userInfo.token);

    final result = await Api().getAgentProfile(data, userInfo.token, context);

    if (result['status'].toString() == '1') {
      setState(() {
        profileInfo = result['data'];
        workingType = profileInfo?['work_position'] ?? 5;
        _nameController.text = profileInfo?['name'] ?? '';
        _emailController.text = profileInfo?['email'] ?? '';
        _mobileController.text = profileInfo?['mobile']?.toString() ?? '';
        _dobController.text = _formatDate(profileInfo?['dob'] ?? '');
        _genderController.text = profileInfo?['gender'] ?? '';
        _addressController.text = profileInfo?['address'] ?? '';
        selectedPincode = {
          "id": profileInfo?['pincode_id'] ?? 0,
          "pincode": profileInfo?['is_pincode']?.toString() ?? ''
        };
        _pincodeController.text = profileInfo?['is_pincode']?.toString() ?? '';
        selectedArea = profileInfo?['is_agent_area_name'] ?? {};
        _areaController.text = profileInfo?['is_area_name']?.toString() ?? '';
        _yearsOfExperienceController.text =
            profileInfo?['years_of_exp']?.toString() ?? '';
        _projectsCountController.text =
            profileInfo?['no_of_projects']?.toString() ?? '';

        _uploadedPhotoLink = profileInfo!['is_agent_image'] ?? '';
        _photoName = profileInfo!['agent_image']?.toString() ?? '';
        photoSource = profileInfo!['agent_image'] != null &&
                profileInfo!['agent_image'] != ''
            ? 'online'
            : 'offline';

        _uploadedAadhaarLink = profileInfo!['is_aadhar_image'] ?? '';
        _aadhaarName = profileInfo!['aadhar_image']?.toString() ?? '';
        aadhaarSource = profileInfo!['aadhar_image'] != null &&
                profileInfo!['aadhar_image'] != ''
            ? 'online'
            : 'offline';

        _uploadedPanLink = profileInfo!['is_pan_dlicense'] ?? '';
        _panName = profileInfo!['pan_dlicense']?.toString() ?? '';
        panSource = profileInfo!['pan_dlicense'] != null &&
                profileInfo!['pan_dlicense'] != ''
            ? 'online'
            : 'offline';

        _uploadedSellerLetterLink = profileInfo!['is_seller_letter'] ?? '';
        _sellerLetterName = profileInfo!['seller_letter']?.toString() ?? '';
        sellerLetterSource = profileInfo!['seller_letter'] != null &&
                profileInfo!['seller_letter'] != ''
            ? 'online'
            : 'offline';

        for (int i = 0; i < result['data']['existing_sellers']?.length; i++) {
          existingControllers.add([
            TextEditingController(),
            TextEditingController(),
            TextEditingController(),
            TextEditingController(),
            TextEditingController(),
            TextEditingController(),
            TextEditingController(),
            result['data']['existing_sellers'][i]['id'].toString()
          ]);
          existingControllers[i][0].text =
              profileInfo!['existing_sellers']?[i]?['business_name'] ?? '';
          existingControllers[i][1].text =
              profileInfo!['existing_sellers']?[i]?['person_name'] ?? '';
          existingControllers[i][2].text = profileInfo!['existing_sellers']?[i]
                      ?['contact_number']
                  ?.toString() ??
              '';
          existingControllers[i][3].text = profileInfo!['existing_sellers']?[i]
                      ?['since_yrmonth']
                  ?.toString()
                  .replaceAll('-', '/') ??
              '';
          existingControllers[i][4].text = profileInfo!['existing_sellers']?[i]
                      ?['till_yrmonth']
                  ?.toString()
                  .replaceAll('-', '/') ??
              '';
          existingControllers[i][5].text = profileInfo!['existing_sellers']?[i]
                      ?['handled_projects']
                  ?.toString() ??
              '';
          existingControllers[i][6].text = profileInfo!['existing_sellers']?[i]
                      ?['position_held']
                  ?.toString() ??
              '';
        }
        centerLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _openCamera() async {
    XFile? capturedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 25);

    if (capturedImage != null) {
      setState(() {
        displayPicture = capturedImage.path;
      });
      _updateProfileImage();
    }
  }

  void _openGallery() async {
    XFile? selectedImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 25);

    if (selectedImage != null) {
      setState(() {
        displayPicture = selectedImage.path;
      });
      _updateProfileImage();
    }
  }

  void _updateProfileImage() async {
    final userInfo = await DatabaseHelper().initDb();
    try {
      setState(() {
        dpLoading = true;
      });
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(liveURL + updateProfileImageUrl),
      );

      //HEADERS
      request.headers['x-api-key'] = userInfo.token.toString();

      //BODY - DATA
      request.fields['user_id'] = userInfo.userId.toString();
      request.files.add(
          await http.MultipartFile.fromPath('profile_image', displayPicture!));
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var result = json.decode(responseBody);
      if (result['status'].toString() == '1') {
        setState(() {
          dpLoading = false;
          centerLoading = true;
        });
        Common().showToast(result['message']);
        _getProfileInfo();
      } else {
        setState(() {
          isLoading = false;
        });
        Common().showToast(result['message']);
      }
    } catch (e) {
      print(e);
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Something Went Wrong')));
    }
  }

  //FUNCTION FOR DELETING PROFILE IMAGE
  void _deleteProfileImage() async {
    try {
      setState(() {
        dpLoading = true;
      });
      final userInfo = await DatabaseHelper().initDb();
      if (!context.mounted) {
        return;
      }

      var data = {"user_id": userInfo.userId};

      final result =
          await Api().deleteProfileImage(data, userInfo.token, context);
      if (result['status'].toString() == '1') {
        setState(() {
          dpLoading = false;
          centerLoading = true;
        });
        Common().showToast(result['message']);
        _getProfileInfo();
      } else {
        setState(() {
          isLoading = false;
        });
        Common().showToast(result['message']);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Something Went Wrong')));
    }
  }

  void _loadAndOpenPDF(String title, String url) async {
    showDialog(
      barrierColor: Colors.black54,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: const SpinKitCircle(
            color: Colors.white,
          ),
        ),
      ),
    );
    _openPDF(title, await PDF().loadNetwork(url));
  }

  void _openPDF(String title, File pdf) {
    Nav().pop(context);
    Nav().push(context, ViewPdfScreen(appTitle: title, file: pdf));
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.network(url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: isLoading ? false : true,
      onPopInvoked: (didPop) {
        if (didPop) {
          widget.reloadHomeContent();
          return;
        }
        Common().showToast('Please wait. Profile is updating');
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Nav().pop(context);
              widget.reloadHomeContent();
            },
            child: Row(
              children: [
                const HorizontalSpace(width: 9),
                Image.asset(
                  'assets/images/prev.png',
                  height: 17,
                ),
                const HorizontalSpace(width: 15),
                const Text(
                  'My Profile',
                  style: TextStyle(color: Colors.white, fontSize: 17.5),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          height: screenHeight,
          width: screenWidth,
          padding: EdgeInsets.symmetric(horizontal: Platform.isIOS ? 20 : 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
          ),
          child: FutureBuilder(
            future: _getProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SpinKitCircle(
                  color: primaryColor,
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to fetch data'));
              } else {
                return centerLoading
                    ? SpinKitCircle(
                        color: primaryColor,
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const VerticalSpace(height: 15),
                              const Text(
                                'LEADER',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return SizedBox(
                                          height: 180,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 30),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _openCamera();
                                                      },
                                                      icon: const Icon(
                                                        Icons.camera_alt,
                                                        color: Colors.black,
                                                        size: 40,
                                                      ),
                                                    ),
                                                    const VerticalSpace(
                                                        height: 8),
                                                    const Text(
                                                      'Camera',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _openGallery();
                                                      },
                                                      icon: const Icon(
                                                        Icons.image,
                                                        color: Colors.black,
                                                        size: 40,
                                                      ),
                                                    ),
                                                    const VerticalSpace(
                                                        height: 8),
                                                    const Text(
                                                      'Gallery',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: profileInfo![
                                                                      'profile_image']
                                                                  .toString()
                                                                  .isEmpty ||
                                                              profileInfo![
                                                                      'is_profile_image'] ==
                                                                  null
                                                          ? () {
                                                              Navigator.pop(
                                                                  context);
                                                              Common().showToast(
                                                                  'No user image found');
                                                            }
                                                          : () {
                                                              Navigator.pop(
                                                                  context);
                                                              _deleteProfileImage();
                                                            },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.black,
                                                        size: 40,
                                                      ),
                                                    ),
                                                    const VerticalSpace(
                                                        height: 8),
                                                    const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: dpLoading
                                      ? const CircleShimmer(
                                          height: 110, width: 110)
                                      : Stack(
                                          children: [
                                            // CircleAvatar(
                                            //   radius: 53,
                                            //   foregroundImage: NetworkImage(
                                            //     profileInfo!['is_profile_image'],
                                            //   ),
                                            // ),
                                            CachedNetworkImage(
                                              imageUrl: profileInfo![
                                                  'is_profile_image'],
                                              placeholder: (context, url) =>
                                                  const CircleShimmer(
                                                      height: 110, width: 110),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                height: 110,
                                                width: 110,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 4,
                                              bottom: 7,
                                              child: Image.asset(
                                                'assets/images/edit.png',
                                                height: 32,
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                              ),
                              const VerticalSpace(height: 8.5),
                              Center(
                                child: Text(
                                  profileInfo!['name'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const VerticalSpace(height: 8.5),
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
                              const VerticalSpace(height: 25),
                              const Text(
                                'Name',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                style: const TextStyle(fontSize: 14),
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Name',
                                ),
                                validator: (value) {
                                  if (value.toString().trim().isEmpty ||
                                      value == null) {
                                    return 'Enter name';
                                  } else if (!nameRegex
                                      .hasMatch(value.toString().trim())) {
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
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                style: const TextStyle(fontSize: 14),
                                controller: _emailController,
                                decoration: const InputDecoration(
                                    hintText: 'Enter Mail ID'),
                                validator: (value) {
                                  if (value.toString().trim().isEmpty ||
                                      value == null) {
                                    return 'Enter mail address';
                                  } else if (!emailRegex
                                      .hasMatch(value.toString().trim())) {
                                    return 'Invalid mail address';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const VerticalSpace(height: 17.5),
                              const Text(
                                'Mobile',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                readOnly: true,
                                style: const TextStyle(fontSize: 14),
                                controller: _mobileController,
                                decoration: const InputDecoration(
                                    hintText: 'Enter Mobile'),
                                validator: (value) {
                                  if (value.toString().trim().isEmpty ||
                                      value == null) {
                                    return 'Enter mobile number';
                                  } else if (!numberRegex
                                      .hasMatch(value.toString().trim())) {
                                    return 'Invalid mobile number';
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          decoration: InputDecoration(
                                            hintText: 'Enter your DOB',
                                            suffixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Image.asset(
                                                'assets/images/calendar.png',
                                                height: 5,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value
                                                    .toString()
                                                    .trim()
                                                    .isEmpty ||
                                                value == null) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          decoration: const InputDecoration(
                                              hintText: 'Enter your gender'),
                                          validator: (value) {
                                            if (value
                                                    .toString()
                                                    .trim()
                                                    .isEmpty ||
                                                value == null) {
                                              return 'Enter your gender';
                                            } else if (!nameRegex.hasMatch(
                                                value.toString().trim())) {
                                              return 'Invalid gender';
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
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                style: const TextStyle(fontSize: 14),
                                controller: _addressController,
                                decoration: const InputDecoration(
                                    hintText: 'Enter Address'),
                                validator: (value) {
                                  if (value.toString().trim().isEmpty ||
                                      value == null) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          decoration: InputDecoration(
                                            hintText: 'Select pincode',
                                            suffixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
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
                                                        chosenPincode:
                                                            selectedPincode,
                                                        onSelect: (pincode) {
                                                          setState(() {
                                                            selectedPincode =
                                                                pincode;
                                                            _pincodeController
                                                                .text = pincode[
                                                                    'pincode']
                                                                .toString();
                                                            _areaController
                                                                .clear();
                                                            selectedArea = null;
                                                          });
                                                        }));
                                          },
                                          validator: (value) {
                                            if (value
                                                    .toString()
                                                    .trim()
                                                    .isEmpty ||
                                                value == null) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          onTap: () {
                                            if (selectedPincode != null) {
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) =>
                                                      CommonModal.area(
                                                          chosenPincode:
                                                              selectedPincode,
                                                          chosenArea:
                                                              selectedArea,
                                                          onSelect: (area) {
                                                            setState(() {
                                                              selectedArea =
                                                                  area;
                                                              _areaController
                                                                      .text =
                                                                  area[
                                                                      'area_name'];
                                                            });
                                                          }));
                                            } else {
                                              Common().showToast(
                                                  'Please select pincode');
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Select area',
                                            suffixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Image.asset(
                                                'assets/images/down.png',
                                                height: 5,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value
                                                    .toString()
                                                    .trim()
                                                    .isEmpty ||
                                                value == null) {
                                              return 'Select area';
                                            } else if (!nameRegex.hasMatch(
                                                value.toString().trim())) {
                                              return 'Invalid area';
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
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                style: const TextStyle(fontSize: 14),
                                controller: _yearsOfExperienceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    hintText: 'Enter years of experience'),
                                validator: (value) {
                                  if (value.toString().trim().isEmpty ||
                                      value == null) {
                                    return 'Enter years of experience';
                                  } else if (!numberRegex
                                      .hasMatch(value.toString().trim())) {
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
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const VerticalSpace(height: 6),
                              TextFormField(
                                style: const TextStyle(fontSize: 14),
                                controller: _projectsCountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    hintText: 'No. of Projects Handled'),
                                validator: (value) {
                                  if (value.toString().trim().isEmpty ||
                                      value == null) {
                                    return 'Enter no. of projects handled';
                                  } else if (!numberRegex
                                      .hasMatch(value.toString().trim())) {
                                    return 'Invalid mail address';
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //PHOTO
                                  SizedBox(
                                    width: screenWidth * 0.2,
                                    child: _photoName == null ||
                                            _photoName!.isEmpty
                                        ? InkWell(
                                            onTap: _choosePhoto,
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/images/upload.png',
                                                  height: 70,
                                                ),
                                                const VerticalSpace(height: 7),
                                                Text(
                                                  '(Photo)',
                                                  style: TextStyle(
                                                      color: fontLightGrey,
                                                      fontSize: 10),
                                                )
                                              ],
                                            ),
                                          )
                                        : photoSource == 'offline'
                                            ? _photoName!.endsWith('.jpg') ||
                                                    _photoName!
                                                        .endsWith('.jpeg')
                                                ? Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          InkWell(
                                                            onTap: _choosePhoto,
                                                            child: Image.file(
                                                              _photo!,
                                                              height: 70,
                                                              width: 70,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          const Positioned(
                                                            right: 2,
                                                            bottom: 2,
                                                            child: Icon(
                                                              Icons
                                                                  .image_rounded,
                                                              color: Colors.red,
                                                              size: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      const VerticalSpace(
                                                          height: 7),
                                                      Text(
                                                        '(Photo)',
                                                        style: TextStyle(
                                                            color:
                                                                fontLightGrey,
                                                            fontSize: 10),
                                                      ),
                                                      VerticalSpace(
                                                          height:
                                                              _photoName != null
                                                                  ? 7
                                                                  : 0),
                                                      Text(
                                                        _photoName!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue.shade600,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10),
                                                      )
                                                    ],
                                                  )
                                                : Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: _choosePhoto,
                                                        child: Image.asset(
                                                          'assets/images/pdf.png',
                                                          height: 70,
                                                        ),
                                                      ),
                                                      const VerticalSpace(
                                                          height: 7),
                                                      Text(
                                                        '(Photo)',
                                                        style: TextStyle(
                                                            color:
                                                                fontLightGrey,
                                                            fontSize: 10),
                                                      ),
                                                      VerticalSpace(
                                                          height:
                                                              _photoName != null
                                                                  ? 7
                                                                  : 0),
                                                      Text(
                                                        _photoName!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue.shade600,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10),
                                                      )
                                                    ],
                                                  )
                                            : Column(
                                                children: [
                                                  _photoName!.endsWith(
                                                              '.jpg') ||
                                                          _photoName!.endsWith(
                                                              '.jpeg') ||
                                                          _photoName!
                                                              .endsWith('.png')
                                                      ? InkWell(
                                                          onTap: () {
                                                            _showImagePreview(
                                                                _uploadedPhotoLink!);
                                                          },
                                                          child: Stack(
                                                            children: [
                                                              Image.network(
                                                                _uploadedPhotoLink!,
                                                                height: 70,
                                                                width: 70,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              const Positioned(
                                                                right: 2,
                                                                bottom: 2,
                                                                child: Icon(
                                                                  Icons
                                                                      .image_rounded,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 15,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            _loadAndOpenPDF(
                                                                'Photo',
                                                                _uploadedPhotoLink!);
                                                          },
                                                          child: Image.asset(
                                                            'assets/images/pdf.png',
                                                            height: 70,
                                                          ),
                                                        ),
                                                  const VerticalSpace(
                                                      height: 7),
                                                  Text(
                                                    '(Photo)',
                                                    style: TextStyle(
                                                        color: fontLightGrey,
                                                        fontSize: 10),
                                                  ),
                                                  VerticalSpace(
                                                      height: _panName != null
                                                          ? 7
                                                          : 0),
                                                  photoSource == 'online'
                                                      ? InkWell(
                                                          onTap: _choosePhoto,
                                                          child: Text(
                                                            'Upload',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue
                                                                    .shade600,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 10),
                                                          ),
                                                        )
                                                      : Text(
                                                          _photoName!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Colors.blue
                                                                  .shade600,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 10),
                                                        )
                                                ],
                                              ),
                                  ),

                                  //AADHAAR
                                  SizedBox(
                                    width: screenWidth * 0.2,
                                    child: _aadhaarName == null ||
                                            _aadhaarName!.isEmpty
                                        ? InkWell(
                                            onTap: _chooseAadhaar,
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/images/upload.png',
                                                  height: 70,
                                                ),
                                                const VerticalSpace(height: 7),
                                                Text(
                                                  '(Aadhaar)',
                                                  style: TextStyle(
                                                      color: fontLightGrey,
                                                      fontSize: 10),
                                                )
                                              ],
                                            ),
                                          )
                                        : aadhaarSource == 'offline'
                                            ? _aadhaarName!.endsWith('.jpg') ||
                                                    _aadhaarName!
                                                        .endsWith('.jpeg')
                                                ? Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          InkWell(
                                                            onTap:
                                                                _chooseAadhaar,
                                                            child: Image.file(
                                                              _aadhaar!,
                                                              height: 70,
                                                              width: 70,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          const Positioned(
                                                            right: 2,
                                                            bottom: 2,
                                                            child: Icon(
                                                              Icons
                                                                  .image_rounded,
                                                              color: Colors.red,
                                                              size: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      const VerticalSpace(
                                                          height: 7),
                                                      Text(
                                                        '(Aadhaar)',
                                                        style: TextStyle(
                                                            color:
                                                                fontLightGrey,
                                                            fontSize: 10),
                                                      ),
                                                      VerticalSpace(
                                                          height:
                                                              _aadhaarName !=
                                                                      null
                                                                  ? 7
                                                                  : 0),
                                                      Text(
                                                        _aadhaarName!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue.shade600,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10),
                                                      )
                                                    ],
                                                  )
                                                : Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: _choosePhoto,
                                                        child: Image.asset(
                                                          'assets/images/pdf.png',
                                                          height: 70,
                                                        ),
                                                      ),
                                                      const VerticalSpace(
                                                          height: 7),
                                                      Text(
                                                        '(Aadhaar)',
                                                        style: TextStyle(
                                                            color:
                                                                fontLightGrey,
                                                            fontSize: 10),
                                                      ),
                                                      VerticalSpace(
                                                          height:
                                                              _aadhaarName !=
                                                                      null
                                                                  ? 7
                                                                  : 0),
                                                      Text(
                                                        _aadhaarName!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue.shade600,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10),
                                                      )
                                                    ],
                                                  )
                                            : Column(
                                                children: [
                                                  _aadhaarName!.endsWith(
                                                              '.jpg') ||
                                                          _aadhaarName!
                                                              .endsWith('.jpeg')
                                                      ? InkWell(
                                                          onTap: () {
                                                            _showImagePreview(
                                                                _uploadedAadhaarLink!);
                                                          },
                                                          child: Stack(
                                                            children: [
                                                              Image.network(
                                                                _uploadedAadhaarLink!,
                                                                height: 70,
                                                                width: 70,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              const Positioned(
                                                                right: 2,
                                                                bottom: 2,
                                                                child: Icon(
                                                                  Icons
                                                                      .image_rounded,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 15,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            _loadAndOpenPDF(
                                                                'Aadhaar',
                                                                _uploadedAadhaarLink!);
                                                          },
                                                          child: Image.asset(
                                                            'assets/images/pdf.png',
                                                            height: 70,
                                                          ),
                                                        ),
                                                  const VerticalSpace(
                                                      height: 7),
                                                  Text(
                                                    '(Aadhaar)',
                                                    style: TextStyle(
                                                        color: fontLightGrey,
                                                        fontSize: 10),
                                                  ),
                                                  VerticalSpace(
                                                      height:
                                                          _aadhaarName != null
                                                              ? 7
                                                              : 0),
                                                  aadhaarSource == 'online'
                                                      ? InkWell(
                                                          onTap: _chooseAadhaar,
                                                          child: Text(
                                                            'Upload',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue
                                                                    .shade600,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 10),
                                                          ),
                                                        )
                                                      : Text(
                                                          _aadhaarName!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Colors.blue
                                                                  .shade600,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 10),
                                                        )
                                                ],
                                              ),
                                  ),

                                  //PAN/DL
                                  SizedBox(
                                    width: screenWidth * 0.2,
                                    child: _panName == null || _panName!.isEmpty
                                        ? InkWell(
                                            onTap: _choosePan,
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/images/upload.png',
                                                  height: 70,
                                                ),
                                                const VerticalSpace(height: 7),
                                                Text(
                                                  '(Pan/DL)',
                                                  style: TextStyle(
                                                      color: fontLightGrey,
                                                      fontSize: 10),
                                                )
                                              ],
                                            ),
                                          )
                                        : panSource == 'offline'
                                            ? _panName!.endsWith('.jpg') ||
                                                    _panName!.endsWith('.jpeg')
                                                ? Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          InkWell(
                                                            onTap: _choosePan,
                                                            child: Image.file(
                                                              _pan!,
                                                              height: 70,
                                                              width: 70,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          const Positioned(
                                                            right: 2,
                                                            bottom: 2,
                                                            child: Icon(
                                                              Icons
                                                                  .image_rounded,
                                                              color: Colors.red,
                                                              size: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      const VerticalSpace(
                                                          height: 7),
                                                      Text(
                                                        '(Pan/DL)',
                                                        style: TextStyle(
                                                            color:
                                                                fontLightGrey,
                                                            fontSize: 10),
                                                      ),
                                                      VerticalSpace(
                                                          height:
                                                              _panName != null
                                                                  ? 7
                                                                  : 0),
                                                      Text(
                                                        _panName!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue.shade600,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10),
                                                      )
                                                    ],
                                                  )
                                                : Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: _choosePan,
                                                        child: Image.asset(
                                                          'assets/images/pdf.png',
                                                          height: 70,
                                                        ),
                                                      ),
                                                      const VerticalSpace(
                                                          height: 7),
                                                      Text(
                                                        '(Pan/DL)',
                                                        style: TextStyle(
                                                            color:
                                                                fontLightGrey,
                                                            fontSize: 10),
                                                      ),
                                                      VerticalSpace(
                                                          height:
                                                              _panName != null
                                                                  ? 7
                                                                  : 0),
                                                      Text(
                                                        _panName!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue.shade600,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10),
                                                      )
                                                    ],
                                                  )
                                            : Column(
                                                children: [
                                                  _panName!.endsWith('.jpg') ||
                                                          _panName!
                                                              .endsWith('.jpeg')
                                                      ? InkWell(
                                                          onTap: () {
                                                            _showImagePreview(
                                                                _uploadedPanLink!);
                                                          },
                                                          child: Stack(
                                                            children: [
                                                              Image.network(
                                                                _uploadedPanLink!,
                                                                height: 70,
                                                                width: 70,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              const Positioned(
                                                                right: 2,
                                                                bottom: 2,
                                                                child: Icon(
                                                                  Icons
                                                                      .image_rounded,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 15,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            _loadAndOpenPDF(
                                                                'Pan/DL',
                                                                _uploadedPanLink!);
                                                          },
                                                          child: Image.asset(
                                                            'assets/images/pdf.png',
                                                            height: 70,
                                                          ),
                                                        ),
                                                  const VerticalSpace(
                                                      height: 7),
                                                  Text(
                                                    '(Pan/DL)',
                                                    style: TextStyle(
                                                        color: fontLightGrey,
                                                        fontSize: 10),
                                                  ),
                                                  VerticalSpace(
                                                      height: _panName != null
                                                          ? 7
                                                          : 0),
                                                  panSource == 'online'
                                                      ? InkWell(
                                                          onTap: _choosePan,
                                                          child: Text(
                                                            'Upload',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue
                                                                    .shade600,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 10),
                                                          ),
                                                        )
                                                      : Text(
                                                          _panName!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Colors.blue
                                                                  .shade600,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 10),
                                                        )
                                                ],
                                              ),
                                  ),

                                  //SELLERLETTER
                                  SizedBox(
                                    width: screenWidth * 0.2,
                                    child: _sellerLetterName == null ||
                                            _sellerLetterName!.isEmpty
                                        ? InkWell(
                                            onTap: _chooseSellerLetter,
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/images/upload.png',
                                                  height: 70,
                                                ),
                                                const VerticalSpace(height: 7),
                                                Text(
                                                  '(Seller Letter)',
                                                  style: TextStyle(
                                                      color: fontLightGrey,
                                                      fontSize: 10),
                                                )
                                              ],
                                            ),
                                          )
                                        : sellerLetterSource == 'offline'
                                            ? _sellerLetterName!
                                                        .endsWith('.jpg') ||
                                                    _sellerLetterName!
                                                        .endsWith('.jpeg')
                                                ? Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          InkWell(
                                                            onTap:
                                                                _chooseSellerLetter,
                                                            child: Image.file(
                                                              _sellerLetter!,
                                                              height: 70,
                                                              width: 70,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          const Positioned(
                                                            right: 2,
                                                            bottom: 2,
                                                            child: Icon(
                                                              Icons
                                                                  .image_rounded,
                                                              color: Colors.red,
                                                              size: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      const VerticalSpace(
                                                          height: 7),
                                                      Text(
                                                        '(Seller Letter)',
                                                        style: TextStyle(
                                                            color:
                                                                fontLightGrey,
                                                            fontSize: 10),
                                                      ),
                                                      VerticalSpace(
                                                          height:
                                                              _sellerLetterName !=
                                                                      null
                                                                  ? 7
                                                                  : 0),
                                                      Text(
                                                        _sellerLetterName!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue.shade600,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10),
                                                      )
                                                    ],
                                                  )
                                                : Column(
                                                    children: [
                                                      InkWell(
                                                        onTap:
                                                            _chooseSellerLetter,
                                                        child: Image.asset(
                                                          'assets/images/pdf.png',
                                                          height: 70,
                                                        ),
                                                      ),
                                                      const VerticalSpace(
                                                          height: 7),
                                                      Text(
                                                        '(Seller Letter)',
                                                        style: TextStyle(
                                                            color:
                                                                fontLightGrey,
                                                            fontSize: 10),
                                                      ),
                                                      VerticalSpace(
                                                          height:
                                                              _sellerLetterName !=
                                                                      null
                                                                  ? 7
                                                                  : 0),
                                                      Text(
                                                        _sellerLetterName!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue.shade600,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10),
                                                      )
                                                    ],
                                                  )
                                            : Column(
                                                children: [
                                                  _sellerLetterName!.endsWith(
                                                              '.jpg') ||
                                                          _sellerLetterName!
                                                              .endsWith('.jpeg')
                                                      ? InkWell(
                                                          onTap: () {
                                                            _showImagePreview(
                                                                _uploadedSellerLetterLink!);
                                                          },
                                                          child: Stack(
                                                            children: [
                                                              Image.network(
                                                                _uploadedSellerLetterLink!,
                                                                height: 70,
                                                                width: 70,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              const Positioned(
                                                                right: 2,
                                                                bottom: 2,
                                                                child: Icon(
                                                                  Icons
                                                                      .image_rounded,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 15,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            _loadAndOpenPDF(
                                                                'Seller Letter',
                                                                _uploadedSellerLetterLink!);
                                                          },
                                                          child: Image.asset(
                                                            'assets/images/pdf.png',
                                                            height: 70,
                                                          ),
                                                        ),
                                                  const VerticalSpace(
                                                      height: 7),
                                                  Text(
                                                    '(Seller Letter)',
                                                    style: TextStyle(
                                                        color: fontLightGrey,
                                                        fontSize: 10),
                                                  ),
                                                  VerticalSpace(
                                                      height:
                                                          _sellerLetterName !=
                                                                  null
                                                              ? 7
                                                              : 0),
                                                  sellerLetterSource == 'online'
                                                      ? InkWell(
                                                          onTap:
                                                              _chooseSellerLetter,
                                                          child: Text(
                                                            'Upload',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue
                                                                    .shade600,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 10),
                                                          ),
                                                        )
                                                      : Text(
                                                          _sellerLetterName!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Colors.blue
                                                                  .shade600,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 10),
                                                        )
                                                ],
                                              ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 17.5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              for (int i = 0;
                                  i < existingControllers.length;
                                  i++)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        // validator: (value) {
                                        //   if (value.toString().trim().isEmpty ||
                                        //       value == null) {
                                        //     return 'Enter business name';
                                        //   } else if (!nameRegex.hasMatch(
                                        //       value.toString().trim())) {
                                        //     return 'Invalid business name';
                                        //   } else {
                                        //     return null;
                                        //   }
                                        // },
                                        validator: (value) {
                                          if (value!.isNotEmpty) {
                                            if (!nameRegex.hasMatch(
                                                value.toString().trim())) {
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
                                        // validator: (value) {
                                        //   if (value.toString().trim().isEmpty ||
                                        //       value == null) {
                                        //     return 'Enter person name';
                                        //   } else if (!nameRegex.hasMatch(
                                        //       value.toString().trim())) {
                                        //     return 'Invalid person name';
                                        //   } else {
                                        //     return null;
                                        //   }
                                        // },

                                        validator: (value) {
                                          if (value!.isNotEmpty) {
                                            if (!nameRegex.hasMatch(
                                                value.toString().trim())) {
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
                                            if (!numberRegex.hasMatch(
                                                value.toString().trim())) {
                                              return 'Invalid contact no';
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
                                          print(date);
                                          if (date != null) {
                                            setState(() {
                                              existingControllers[i][3]
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
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            borderSide: BorderSide(
                                                color: Colors.red.shade800,
                                                width: 1),
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
                                        onTap: existingControllers[i][3]
                                                .text
                                                .isEmpty
                                            ? () {
                                                Common().showToast(
                                                    'Select starting year and month');
                                              }
                                            : () async {
                                                var date =
                                                    await showMonthPicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: _startingYear(
                                                      existingControllers[i][3]
                                                          .text
                                                          .toString()
                                                          .replaceAll(
                                                              '/', '-')),
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
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            borderSide: BorderSide(
                                                color: Colors.red.shade800,
                                                width: 1),
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
                              const VerticalSpace(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? () {} : _updateProfile,
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
                              const VerticalSpace(height: 20)
                            ],
                          ),
                        ),
                      );
              }
            },
          ),
        ),
      ),
    );
  }
}

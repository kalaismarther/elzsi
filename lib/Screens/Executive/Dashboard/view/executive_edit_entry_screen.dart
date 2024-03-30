import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Utils/button_loader.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/regex.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Widgets/units.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class ExecutiveEditEntryScreen extends StatefulWidget {
  const ExecutiveEditEntryScreen(
      {super.key,
      required this.propertyDetail,
      required this.onBack,
      required this.previousEntryDetail});

  final Map propertyDetail;
  final Function() onBack;
  final Map previousEntryDetail;

  @override
  State<ExecutiveEditEntryScreen> createState() =>
      _ExecutiveEditEntryScreenState();
}

class _ExecutiveEditEntryScreenState extends State<ExecutiveEditEntryScreen> {
  //KEY
  final _formKey = GlobalKey<FormState>();

  //CONTROLLERS
  final _customerNameController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _commentsController = TextEditingController();
  final _reminderController = TextEditingController();
  final _unitController = TextEditingController();
  DateTime? pickedDate;

  int visitType = 1;

  Map? selectedUnit;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    setState(() {
      _customerNameController.text = widget.previousEntryDetail['name'] ?? '';
      _contactNoController.text = widget.previousEntryDetail['mobile'] ?? '';
      visitType = widget.previousEntryDetail['sourceby_id'] ?? 0;
      _commentsController.text =
          widget.previousEntryDetail['agent_remind_comments'] ?? '';
      _reminderController.text =
          _formatDate(widget.previousEntryDetail['agent_remind_date'] ?? '');
      _unitController.text =
          widget.previousEntryDetail['unit_no']?.toString() ?? '';
      selectedUnit = {
        'id': widget.previousEntryDetail['unit_id']?.toString() ?? '',
        "unit_no": widget.previousEntryDetail['unit_no']?.toString() ?? '',
      };
      isLoading = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _contactNoController.dispose();
    _commentsController.dispose();
    _reminderController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  String _formatDate(String date) {
    if (date.isEmpty || date == '') {
      return '';
    }
    try {
      DateTime inputDate = DateTime.parse(date);
      String formattedDate = DateFormat('dd-MM-yyyy').format(inputDate);
      return formattedDate;
    } catch (e) {
      return '';
    }
  }

  String _formatDate1(String date) {
    if (date.isEmpty || date == '') {
      return '';
    }
    try {
      DateTime inputDate = DateFormat("dd-MM-yyyy").parse(date);
      String formattedDate = DateFormat('yyyy-MM-dd').format(inputDate);
      return formattedDate;
    } catch (e) {
      return '';
    }
  }

  void _showDate() async {
    var today = DateTime.now();
    final date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: today,
        //.add(const Duration(days: 1))
        lastDate: DateTime(2101));

    if (date != null) {
      setState(() {
        pickedDate = date;
        _reminderController.text = DateFormat('dd-MM-yyyy').format(date);
      });
    }
  }

  void _saveUnitEntry() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isSaving = true;
        });
        final userInfo = await DatabaseHelper().initDb();

        var data = {
          "user_id": userInfo.userId,
          "project_id": widget.propertyDetail['id'],
          "unit_id": selectedUnit == null ? 0 : selectedUnit!['id'],
          "customer_name": _customerNameController.text,
          "contact_number": _contactNoController.text,
          "call_visit": visitType,
          "comments": _commentsController.text,
          "reminder_date": _formatDate1(_reminderController.text)
        };
        print(data);
        if (!context.mounted) {
          return;
        }
        final result =
            await Api().projectUnitEntry(data, userInfo.token, context);

        if (result['status'].toString() == '1') {
          setState(() {
            isSaving = false;
          });
          Common().showToast(result['message']);
          Nav().pop(context);
          widget.onBack();
        } else {
          setState(() {
            isSaving = false;
          });
          Common().showToast(result['message']);
        }
      } catch (e) {
        if (!context.mounted) {
          return;
        }
        setState(() {
          isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something Went Wrong')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Nav().pop(context);
            // widget.reloadHomeContent();
          },
          icon: Image.asset(
            'assets/images/prev.png',
            height: 17,
          ),
        ),
        title: const Text(
          'Edit Entry',
          style: TextStyle(color: Colors.white, fontSize: 17.5),
        ),
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
          ),
        ),
        child: isLoading
            ? SpinKitCircle(
                color: primaryColor,
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const VerticalSpace(height: 14),
                      const Text(
                        'Customer Name',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        readOnly: true,
                        enabled: false,
                        controller: _customerNameController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Enter Customer Name',
                        ),
                        validator: (value) {
                          if (value.toString().trim().isEmpty ||
                              value == null) {
                            return 'Enter name';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const VerticalSpace(height: 17.5),
                      const Text(
                        'Contact Number',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        readOnly: true,
                        enabled: false,
                        controller: _contactNoController,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Enter Customer Number',
                          counterText: '',
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
                      const VerticalSpace(height: 17.5),
                      const Text(
                        'Call / Visit',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      Row(
                        children: [
                          Radio(
                            activeColor: primaryColor,
                            value: 1,
                            groupValue: visitType,
                            onChanged: (value) {
                              setState(() {
                                visitType = value!;
                              });
                            },
                          ),
                          const Text(
                            'Call',
                            style: TextStyle(fontSize: 13),
                          ),
                          const HorizontalSpace(width: 15),
                          Radio(
                            activeColor: primaryColor,
                            value: 2,
                            groupValue: visitType,
                            onChanged: (value) {
                              setState(() {
                                visitType = value!;
                              });
                            },
                          ),
                          const Text(
                            'Visit',
                            style: TextStyle(fontSize: 13),
                          ),
                          const HorizontalSpace(width: 15),
                          Radio(
                              activeColor: primaryColor,
                              value: 3,
                              groupValue: visitType,
                              onChanged: (value) {
                                setState(() {
                                  visitType = value!;
                                });
                              }),
                          const Flexible(
                            child: Text(
                              'Campaign',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const VerticalSpace(height: 5),
                      const Text(
                        'Comments',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        // readOnly: true,
                        // enabled: false,
                        controller: _commentsController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Enter Comments',
                        ),
                        validator: (value) {
                          if (value.toString().isEmpty || value == null) {
                            return 'Enter Comments';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const VerticalSpace(height: 17.5),
                      const Text(
                        'Set Reminder',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        readOnly: true,
                        // enabled: false,
                        controller: _reminderController,
                        onTap: _showDate,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Set Reminder',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              'assets/images/calendar.png',
                              height: 20,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value.toString().isEmpty || value == null) {
                            return 'Set Reminder';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const VerticalSpace(height: 17.5),
                      const Text(
                        'Select Unit',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const VerticalSpace(height: 6),
                      TextFormField(
                        readOnly: true,
                        controller: _unitController,
                        // onTap: _showDate,
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: Colors.white,
                            context: context,
                            builder: (context) => Units(
                              projectUnits:
                                  widget.propertyDetail['projectunits'] ?? [],
                              onSelect: (unit) {
                                setState(() {
                                  selectedUnit = unit;
                                  _unitController.text =
                                      unit['unit_no'] == null ||
                                              unit['unit_no'].toString().isEmpty
                                          ? ''
                                          : unit['unit_no'].toString();
                                });
                              },
                            ),
                          );
                        },
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Select Unit',
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/images/down.png',
                              height: 8.5,
                            ),
                          ),
                        ),
                      ),
                      const VerticalSpace(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveUnitEntry,
                          child: isSaving
                              ? const ButtonLoader()
                              : const Text(
                                  'SUBMIT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8),
                                ),
                        ),
                      ),
                      const VerticalSpace(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

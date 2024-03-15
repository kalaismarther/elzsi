import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:flutter/material.dart';

class Units extends StatefulWidget {
  const Units({super.key, required this.projectUnits, required this.onSelect});

  final List projectUnits;
  final Function(Map unit) onSelect;

  @override
  State<Units> createState() => _UnitsState();
}

class _UnitsState extends State<Units> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VerticalSpace(height: 20),
        const Text(
          'Choose Unit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const VerticalSpace(height: 10),
        Expanded(
          child: widget.projectUnits.isEmpty
              ? const SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text('No units found'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shrinkWrap: true,
                  itemCount: widget.projectUnits.length,
                  itemBuilder: (context, index) => InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: widget.projectUnits[index]['unit_status']
                                .toString()
                                .trim() !=
                            'AVAILABLE'
                        ? () {
                            Common().showToast('Unit not available');
                          }
                        : () {
                            widget.onSelect(widget.projectUnits[index]);
                            Navigator.pop(context);
                          },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        color: inputBg,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Unit No'),
                                  VerticalSpace(height: 5),
                                  Text('Block Name'),
                                  VerticalSpace(height: 5),
                                  Text('Phase Name'),
                                  VerticalSpace(height: 5),
                                  Text('Unit Status'),
                                ],
                              ),
                              const HorizontalSpace(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(":"),
                                  VerticalSpace(height: 5),
                                  Text(":"),
                                  VerticalSpace(height: 5),
                                  Text(":"),
                                  VerticalSpace(height: 5),
                                  Text(":"),
                                ],
                              ),
                              const HorizontalSpace(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.projectUnits[index]?['unit_no'] ??
                                      ''),
                                  const VerticalSpace(height: 5),
                                  Text(widget.projectUnits[index]
                                          ?['block_name'] ??
                                      ''),
                                  const VerticalSpace(height: 5),
                                  Text(widget.projectUnits[index]
                                          ?['phase_name'] ??
                                      ''),
                                  const VerticalSpace(height: 5),
                                  Text(widget.projectUnits[index]
                                          ?['unit_status'] ??
                                      ''),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

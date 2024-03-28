import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Utils/loader.dart';
import 'package:elzsi/Utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Utils/waiting_shimmer.dart';
import 'package:flutter/material.dart';

class CommonModal extends StatefulWidget {
  const CommonModal.pincode(
      {super.key,
      this.userId,
      this.token,
      this.chosenPincode,
      required this.onSelect})
      : type = 'pincodes',
        chosenArea = null;

  const CommonModal.area(
      {super.key,
      this.userId,
      this.token,
      required this.chosenPincode,
      this.chosenArea,
      required this.onSelect})
      : type = 'areas';

  final String? userId;
  final String? token;
  final String type;
  final Map? chosenPincode;
  final Map? chosenArea;
  final Function(Map pincode) onSelect;

  @override
  State<CommonModal> createState() => _CommonModalState();
}

class _CommonModalState extends State<CommonModal> {
  late Future _getData;

  //CONTROLLERS
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool isLoading = true;
  bool paginationLoader = false;

  List list = [];

  Map? selectedItem;

  int? pageNo;

  String? message;

  @override
  void initState() {
    _getData = widget.type == 'pincodes' ? _getPincodes() : _getAreas();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != list.length) {
          setState(() {
            paginationLoader = true;
          });
          if (widget.type == 'pincodes') {
            _getPincodes();
          } else {
            _getAreas();
          }
        }
      }
    });
    super.initState();
  }

  Future<void> _getAreas() async {
    try {
      setState(() {
        pageNo = list.length;
      });
      final userInfo = await DatabaseHelper().initDb();

      var data = {
        "user_id": widget.userId ?? userInfo.userId,
        "pincode_id": widget.chosenPincode!['id'],
        "search": _searchController.text,
        "page_no": list.length
      };

      if (!context.mounted) {
        return;
      }
      final result =
          await Api().getAreas(data, widget.token ?? userInfo.token, context);
      print(result);

      if (result['status'].toString() == '1') {
        setState(() {
          list.addAll(result?['data'] ?? []);
          isLoading = false;
          paginationLoader = false;
        });
      } else if (result['status'].toString() == '3') {
        throw Exception('Device changed');
      } else if (result['data'] == null || result['data'].isEmpty) {
        setState(() {
          list.addAll(result?['data'] ?? []);
          isLoading = false;
          paginationLoader = false;
        });
      } else {
        setState(() {
          isLoading = false;
          message = result?['messge'] ?? '';
        });
      }
    } catch (e) {
      //
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getPincodes() async {
    try {
      setState(() {
        pageNo = list.length;
      });
      final userInfo = await DatabaseHelper().initDb();

      var data = {
        "user_id": widget.userId ?? userInfo.userId,
        "search": _searchController.text,
        "page_no": list.length
      };
      print(data);
      if (!context.mounted) {
        return;
      }
      final result = await Api()
          .getPincodes(data, widget.token ?? userInfo.token, context);
      print(result);

      if (result['status'].toString() == '1') {
        setState(() {
          list.addAll(result?['data'] ?? []);
          isLoading = false;
          paginationLoader = false;
        });
      } else if (result['status'].toString() == '3') {
        throw Exception('Device changed');
      } else if (result['data'] == null || result['data'].isEmpty) {
        setState(() {
          list.addAll(result?['data'] ?? []);
          isLoading = false;
          paginationLoader = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _search() {
    setState(() {
      isLoading = true;
      list.clear();
    });
    if (widget.type == 'pincodes') {
      _getPincodes();
    } else {
      _getAreas();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VerticalSpace(height: 20),
        // const Text(
        //   'Select Seller',
        //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _searchController,
            keyboardType: widget.type == 'pincodes'
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.grey.shade300,
              hintText:
                  widget.type == 'pincodes' ? 'Search Pincode' : 'Search Area',
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) {
              _search();
            },
          ),
        ),

        const VerticalSpace(height: 10),
        FutureBuilder(
          future: _getData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                title: WaitingShimmer(count: 5, height: 38),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to fetch data'));
            } else {
              return isLoading
                  ? const Loader()
                  : list.isEmpty
                      ? const Text('No data found')
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) => ListTile(
                              onTap: () {
                                widget.onSelect(list[index]);
                                Nav().pop(context);
                              },
                              // leading: list.isEmpty
                              //     ? const Padding(
                              //         padding: EdgeInsets.symmetric(horizontal: 5),
                              //         child: Icon(
                              //           Icons.image_not_supported_rounded,
                              //           size: 35,
                              //         ),
                              //       )
                              //     : CachedNetworkImage(
                              //         imageUrl: sellersList[index]['is_business_logo'],
                              //         imageBuilder: (context, imageProvider) => Container(
                              //           height: 35,
                              //           width: 35,
                              //           margin: const EdgeInsets.only(right: 7),
                              //           decoration: BoxDecoration(
                              //             borderRadius: BorderRadius.circular(8),
                              //             image: DecorationImage(
                              //               image: imageProvider,
                              //               fit: BoxFit.cover,
                              //             ),
                              //           ),
                              //         ),
                              //         placeholder: (context, url) =>
                              //             const CircleShimmer(height: 25, width: 25),
                              //         errorWidget: (context, url, error) =>
                              //             const Icon(Icons.error),
                              //       ),
                              title: widget.type == 'pincodes'
                                  ? Text(
                                      list[index]?['pincode']?.toString() ?? '',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: widget.chosenPincode?['id'] ==
                                                  list[index]['id']
                                              ? Colors.blue
                                              : Colors.black,
                                          overflow: TextOverflow.clip),
                                    )
                                  : Text(
                                      list[index]?['area_name']?.toString() ??
                                          '',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: widget.chosenArea?['id'] ==
                                                  list[index]['id']
                                              ? Colors.blue
                                              : Colors.black,
                                          overflow: TextOverflow.clip),
                                    ),
                            ),
                          ),
                        );
            }
          },
        ),
        paginationLoader
            ? const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Loader(),
              )
            : const VerticalSpace(height: 0)
      ],
    );
  }
}

import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Utils/circleshimmer.dart';
import 'package:elzsi/Utils/loader.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Utils/waiting_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Sellers extends StatefulWidget {
  const Sellers({super.key, required this.onSelect});

  final Function(Map seller) onSelect;

  @override
  State<Sellers> createState() => _SellersState();
}

class _SellersState extends State<Sellers> {
  late Future _getSellers;
  final _scrollController = ScrollController();
  bool isLoading = true;
  bool paginationLoader = false;

  List sellersList = [];

  int? pageNo;

  @override
  void initState() {
    _getSellers = _getSellersList();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != sellersList.length) {
          setState(() {
            paginationLoader = true;
          });
          _getSellersList();
        }
      }
    });
    super.initState();
  }

  Future<void> _getSellersList() async {
    setState(() {
      pageNo = sellersList.length;
    });
    final userInfo = await DatabaseHelper().initDb();

    var data = {"user_id": userInfo.userId, "page_no": sellersList.length};

    if (!context.mounted) {
      return;
    }
    final result = await Api().getSellers(data, userInfo.token, context);

    if (result['status'].toString() == '1') {
      setState(() {
        sellersList.addAll(result['data']);
        isLoading = false;
        paginationLoader = false;
      });
    } else if (result['status'].toString() == '3') {
      throw Exception('Device changed');
    } else if (result['data'] == null || result['data'].isEmpty) {
      setState(() {
        paginationLoader = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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
        const Text(
          'Select Seller',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const VerticalSpace(height: 10),
        FutureBuilder(
          future: _getSellers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                title: WaitingShimmer(count: 5, height: 38),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to fetch data'));
            } else {
              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: sellersList.length,
                  itemBuilder: (context, index) => ListTile(
                    onTap: () {
                      widget.onSelect(sellersList[index]);
                      Nav().pop(context);
                    },
                    leading: sellersList[index]['is_business_logo'] == null ||
                            sellersList[index]['is_business_logo'].isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 35,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: sellersList[index]['is_business_logo'],
                            imageBuilder: (context, imageProvider) => Container(
                              height: 35,
                              width: 35,
                              margin: const EdgeInsets.only(right: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) =>
                                const CircleShimmer(height: 25, width: 25),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                    title: Text(
                      sellersList[index]['business_name'],
                      style: const TextStyle(
                          fontSize: 15, overflow: TextOverflow.clip),
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

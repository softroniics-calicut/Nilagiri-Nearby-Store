import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stores/user/Fruits.dart';
import 'package:stores/user/Grocery.dart';
import 'package:stores/user/Vegitables.dart';
import 'package:url_launcher/url_launcher.dart';

class UserStoreDetails extends StatefulWidget {
  final String storeId;
  final String storeName;
  final String storeImageURL;

  const UserStoreDetails({
    Key? key,
    required this.storeId,
    required this.storeName,
    required this.storeImageURL,
  }) : super(key: key);

  @override
  State<UserStoreDetails> createState() => _UserStoreDetailsState();
}

class _UserStoreDetailsState extends State<UserStoreDetails> {
  TextEditingController searchController = TextEditingController();

  Future<void> _makePhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.storeName),
          actions: [
            IconButton(
              onPressed: () async {
                DocumentSnapshot storeSnapshot = await FirebaseFirestore
                    .instance
                    .collection('add_store')
                    .doc(widget.storeId)
                    .get();
                Map<String, dynamic>? data =
                    storeSnapshot.data() as Map<String, dynamic>?;
                String? phoneNumber = data?['phonenumber'];
                if (phoneNumber != null && phoneNumber.isNotEmpty) {
                  await _makePhoneCall(phoneNumber);
                } else {
                  print('Phone number not available for this store.');
                }
              },
              icon: Icon(Icons.phone),
            ),
          ],
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 140.h,
                  width: 140.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.storeImageURL),
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              ],
            ),
            Text(
              widget.storeName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingBar.builder(
                  initialRating: 3,
                  itemCount: 5,
                  itemSize: 20,
                  direction: Axis.horizontal,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {},
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 330.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                  ),
                  color: const Color(0xffD5F1E9),
                ),
                child: const TabBar(
                  tabs: [
                    Tab(
                      child: Text("Fruits"),
                    ),
                    Tab(
                      child: Text("Vegetables"),
                    ),
                    Tab(
                      child: Text("Grocery"),
                    ),
                  ],
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  indicator: BoxDecoration(color: Color(0xff4D6877)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50.h,
                    width: 330.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xffDDEEE9),
                    ),
                    child: Row(
                      children: [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.search),
                          ),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: TextFormField(
                            controller: searchController,
                            onChanged: (value) {},
                            decoration: const InputDecoration(
                              hintText: "   Search product",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Fruits(
                    storeName: widget.storeName,
                    storeId: widget.storeId,
                    productId: searchController.text,
                  ),
                  Vegitables(
                    storeName: widget.storeName,
                    storeId: widget.storeId,
                    productId: searchController.text,
                  ),
                  Grocery(
                    storeName: widget.storeName,
                    storeId: widget.storeId,
                    productId: searchController.text,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

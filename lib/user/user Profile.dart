import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stores/screens/landingpage.dart';
import 'package:stores/user/user%20Edit%20Profile.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User? _user;
  late UserData _userData;

  late Future<DocumentSnapshot> _userDataFuture;

  @override
  void initState() {
    super.initState();

    _user = _auth.currentUser;
    _userData = UserData(
      name: "",
      email: _user?.email ?? "",
      pincode: "",
      address: "",
      phonenumber: "",
    );
    _userDataFuture = fetchUserData();
  }

  Future<DocumentSnapshot> fetchUserData() {
    return _firestore.collection('users').doc(_user?.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/Ellipse 4.jpg"),
                ),
                const SizedBox(height: 10),
                FutureBuilder(
                  future: _userDataFuture,
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else {
                      _userData = UserData.fromSnapshot(snapshot.data!);
                      return Text(
                        "Hey, ${_userData.name}",
                        style: const TextStyle(fontSize: 25),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const UserEditProfile();
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xffD5F1E9),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    FutureBuilder(
                      future: _userDataFuture,
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        } else {
                          _userData = UserData.fromSnapshot(snapshot.data!);
                          return Column(
                            children: [
                              buildProfileItem("Name", _userData.name),
                              buildProfileItem("Email id", _userData.email),
                              buildProfileItem(
                                  "Phone Number", _userData.phonenumber),
                              buildProfileItem("Pincode", _userData.pincode),
                              buildProfileItem("Address", _userData.address),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 25),
        child: Container(
          width: 50,
          height: 40.h,
          decoration: BoxDecoration(
            color: const Color(0xff4D6877),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LandingPage(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              "Log out",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(":"),
          ),
          SizedBox(
            width: 200.w,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class UserData {
  final String name;
  final String email;
  final String pincode;
  final String address;
  final String phonenumber;

  UserData({
    required this.name,
    required this.email,
    required this.pincode,
    required this.address,
    required this.phonenumber,
  });

  UserData.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot['name'] ?? '',
        email = snapshot['email'] ?? '',
        phonenumber = snapshot['phonenumber'] ?? '',
        pincode = snapshot['pincode'] ?? '',
        address = snapshot['address'] ?? '';
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stores/store%20keeper/ST%20StoreList.dart';

class StoreKeeperAddStore extends StatefulWidget {
  const StoreKeeperAddStore({Key? key}) : super(key: key);

  @override
  State<StoreKeeperAddStore> createState() => _StoreKeeperAddStoreState();
}

class _StoreKeeperAddStoreState extends State<StoreKeeperAddStore> {
  final ImagePicker _picker = ImagePicker();
  late File _selectedImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedImage = File('');
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        print('Image picking cancelled');
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadImageAndAddStore() async {
    try {
      if (!_selectedImage.existsSync()) {
        throw Exception("No image selected.");
      }

      final String storeImageURL = await _uploadImageToStorage();

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      DocumentReference storeRef =
          await FirebaseFirestore.instance.collection('add_store').add({
        'userId': user.uid,
        'name': _nameController.text,
        'type': _typeController.text,
        'address': _addressController.text,
        'phonenumber': _phonenumberController.text,
        'pincode': _pincodeController.text,
        'storeImageURL': storeImageURL,
      });

      await storeRef.update({'storeId': storeRef.id});

      Fluttertoast.showToast(
        msg: "Store added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StStoreList()),
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to add store. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("Error adding store: $error");
    }
  }

  Future<String> _uploadImageToStorage() async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('store_images')
          .child('store_${DateTime.now().millisecondsSinceEpoch}.png');

      final UploadTask uploadTask = storageReference.putFile(_selectedImage);
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image to storage: $e");
      throw Exception("Failed to upload image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Store")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 700.h,
                  width: 330.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffD5F1E9),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: Container(
                            width: 280.w,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 150.w,
                                    height: 150.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: _selectedImage.existsSync()
                                            ? FileImage(_selectedImage)
                                                as ImageProvider<Object>
                                            : const AssetImage(
                                                "assets/Ellipse 4.jpg"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 30.w, top: 20.h),
                          child: const Row(
                            children: [
                              Text(
                                "Name",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 290.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(20.sp),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "  Enter name",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 30.w, top: 10.h),
                          child: const Row(
                            children: [
                              Text(
                                "Store Type",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 290.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(20.sp),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  controller: _typeController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "  Enter Store Type",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter store type';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 30.w, top: 10.h),
                          child: const Row(
                            children: [
                              Text(
                                "Address",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 290.w,
                                height: 130.h,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(20.sp),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "  Enter address",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an address';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 30.w, top: 10.h),
                          child: const Row(
                            children: [
                              Text(
                                "Phone number",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 290.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(20.sp),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10)
                                  ],
                                  controller: _phonenumberController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "  Enter Phonenumber",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a phone number';
                                    }
                                    if (value.length != 10) {
                                      return 'Phone number must be 10 digits';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 30.w),
                          child: const Row(
                            children: [
                              Text(
                                "Pincode",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 290.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(20.sp),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _pincodeController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "  Enter Pincode",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a pincode';
                                    }
                                    if (value.length != 6) {
                                      return 'Pincode must be 6 digits';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 200.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.sp),
                                  color: const Color(0xff4D6877),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _uploadImageAndAddStore();
                                    }
                                  },
                                  child: const Text(
                                    "SUBMIT",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

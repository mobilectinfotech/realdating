import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:realdating/pages/live/live/database/database.dart';
import 'package:realdating/reel/app_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../chat/models/chat_user.dart';
import '../../consts/app_urls.dart';
import '../../services/base_client01.dart';
import '../a_frist_pages/login_page/login.dart';

class SignUpController extends GetxController {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController usernameController = TextEditingController();
  TextEditingController phonenoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  clearData() {
    return {
      usernameController.clear(),
      phonenoController.clear(),
      emailController.clear(),
      passwordController.clear(),
      confirmpasswordController.clear(),
      firstNameController.clear(),
      lastNameController.clear(),
    };
  }

  RxBool isLoadig = false.obs;
  RxBool seePassword = true.obs;
  RxBool seePassword1 = true.obs;

  final formkey1 = GlobalKey<FormState>();
  var deviceType;

  dynamic getFirebaseMessagingToken = "";
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  getToken() async {
    getFirebaseMessagingToken = await fMessaging.getToken();
  }

  @override
  void onReady() {
    super.onReady();
    getToken();
  }

  signUpfunction() async {
    isLoadig(true);
    final response = await BaseClient01().post(Appurls.signUp, {
      'username': usernameController.value.text,
      'password': passwordController.value.text,
      'phone_number': phonenoController.value.text,
      'email': emailController.value.text,
      'firstname': firstNameController.value.text,
      'lastname': lastNameController.value.text
    });

    print("$response");
    isLoadig(false);
    bool success = response["success"];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userUid = "${prefs.getInt('user_id')}";
    print("user_id ==========================>$userUid");
    if (success) {
      var userId = response["data_1"][0]["id"];
      print("user_id$userId");
      String otpR = response["OTP"];
      // Get.off(()=>OtpPage(number: phonenoController.value.text, otp: otpR));
      Get.off(const LoginScreenPage());
      signUp();
      createUser(
          "$userId", "${firstNameController.value.text} ${lastNameController.value.text}", emailController.value.text, "", "", '$getFirebaseMessagingToken');
    }
    var msg = response["message"];
    print("my validation message --------$msg");
    Fluttertoast.showToast(
      msg: "$msg",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  static Future<void> createUser(String userUid, String displayName, String email, String about, String photoURL, String pushToken) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: userUid, name: displayName, email: email, about: about, image: photoURL, createdAt: time, isOnline: false, lastActive: time, pushToken: pushToken);

    return await firestore.collection('users').doc(userUid).set(chatUser.toJson());
  }

  signUp() async {
    var auth1 = FirebaseAuth.instance;

    final pass = passwordController.text.toString().trim();
    final email = emailController.value.text.toString().trim();
    try {
      await auth1.createUserWithEmailAndPassword(email: email, password: pass);
      User? user = FirebaseAuth.instance.currentUser;
      DatabaseService().regUser(user!, email: email, name: firstNameController.text, uid: user.uid).then((value) {
        //Get.offAll(() => const HomePage());
      });
    } catch (e) {
      if (e.toString().contains('A network error (such as timeout, interrupted connection or unreachable host)')) {
        AppUtil.showToast(message: "No internet connection, try again later", isSuccess: false);
      } else {
        AppUtil.showToast(message: "Error", isSuccess: false);
      }
    }
  }
}

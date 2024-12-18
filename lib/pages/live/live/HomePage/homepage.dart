import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realdating/chat/api/apis.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import '../../../../reel/app_util.dart';
import '../../../../zego_live_stream_chat/live_page.dart';
import '../../../dash_board_page.dart';
import '../constant/liveusercard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<LiveUser> liveUsers = [];

  // User? currentUser ;
  bool isDeviceConnected = false;
  StreamSubscription<ConnectivityResult>? connectivitySubscription;

  var userName = '';
  var userID = '';

  @override
  void initState() {
    super.initState();

    fetchLoggedInUserData(user_uid!);
    setupConnectivityListener();
    fetchLiveUsers();
    removeExistingUserIfNeeded();

    print('login user id------------$user_uid');
  }

  Future<void> fetchLoggedInUserData(String userId) async {
    try {
      final collection = FirebaseFirestore.instance.collection('users');
      final querySnapshot = await collection.where('id', isEqualTo: userId).get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        if (kDebugMode) {
          print('User Data: $userData');
        }

        userName = userData['name'];
        final email = userData['email'];
        userID = userData['id'];
        print('Name: $userName, Email: $email');
        print('User id: $userID, username: $userName');
      } else {
        print('No user found with id: $userId');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void setupConnectivityListener() {
    Connectivity().checkConnectivity().then((result) {
      isDeviceConnected = result != ConnectivityResult.none;
      setState(() {});
    });
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      isDeviceConnected = result != ConnectivityResult.none;
      setState(() {});
    });
  }

  void fetchLiveUsers() {
    FirebaseFirestore.instance.collection("Liveusers").snapshots().listen((snapshot) {
      setState(() {
        liveUsers = snapshot.docs.map((doc) => LiveUser.fromDocument(doc)).toList();
        print('Live users loaded: $liveUsers');
      });
    });
  }

  Future<void> removeExistingUserIfNeeded() async {
    if (user_uid != null) {
      bool exists = (await FirebaseFirestore.instance.collection("Liveusers").doc(user_uid).get()).exists;
      if (exists) {
        await FirebaseFirestore.instance.collection("Liveusers").doc(user_uid).delete();
      }
    }
  }

  Future<void> goLive() async {
    // Permission.microphone.request().then((value) {
    //   print(value);
    // },);Permission.camera.request().then((value) {
    //   print(value);
    // },);
    // return;
    if (!isDeviceConnected) {
      AppUtil.showToast(message: "No internet connection", isSuccess: false);

      return;
    }

    Map<Permission, PermissionStatus> statuses = await [Permission.camera, Permission.microphone].request();
    if (statuses[Permission.camera]!.isGranted && statuses[Permission.microphone]!.isGranted) {
      String channelName = generateRandomString(8);

      /// Add live user to Firestore------


      await FirebaseFirestore.instance.collection("Liveusers").doc(user_uid).set({
        'username': userName,
        'userimage': 'https://www.yiwubazaar.com/resources/assets/images/default-product.jpg',
        'channelname': channelName,
        'userid': userID,
        'joinedUserCount': 0, // Initialize with 0
      });


      // await FirebaseFirestore.instance.collection("Liveusers").doc(user_uid).set({
      //   'username': userName,
      //   'userimage': 'https://www.yiwubazaar.com/resources/assets/images/default-product.jpg',
      //   'channelname': channelName,
      //   'userid': userID,
      // });

      if (ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing) {
        return;
      }

      jumpToLivePage(context, liveID: '12345', isHost: true, userNmae: userName, userId: userID);
    } else {
      AppUtil.showToast(message: "Camera and Microphone permissions are required to go live", isSuccess: false);
    }
  }

  String generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.offAll(() => const DashboardPage()),
          ),
          backgroundColor: Colors.redAccent,
          title: const Text("Live Users", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        body: Center(child: buildLiveUserList()),
        floatingActionButton: buildGoLiveButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget buildGoLiveButton() {
    return InkWell(
      onTap: goLive,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(40),
        ),
        height: 50,
        width: 150,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_call, size: 30),
            Text("Go Live", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget buildLiveUserList() {
    return ListView.builder(
      itemCount: liveUsers.length,
      itemBuilder: (context, index) {
        LiveUser liveUser = liveUsers[index];
        return buildLiveUserTile(liveUser);
      },
    );
  }

  Widget buildLiveUserTile(LiveUser liveUser) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          Get.to(() => LivePage(
            liveID: '12345',
            isHost: false,
            userId: liveUser.userId,
            userName: userName,
          ));
        },
        child: LiveUserCard(
          broadcasterName: liveUser.userName,
          image: liveUser.image,
          joinedUserCount: liveUser.joinedUserCount,
        ),
      ),
    );
  }

}

class LiveUser {
  final String userName;
  final String image;
  final String channelName;
  final String userId;
  final int joinedUserCount;

  LiveUser({
    required this.userName,
    required this.image,
    required this.channelName,
    required this.userId,
    required this.joinedUserCount,
  });

  factory LiveUser.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return LiveUser(
      userName: data['username'] ?? 'Not found',
      image: data['userimage'] ?? "https://www.yiwubazaar.com/resources/assets/images/default-product.jpg",
      channelName: data['channelname'],
      userId: data['userid'],
      joinedUserCount: data['joinedUserCount'] ?? 0,
    );
  }
}


void jumpToLivePage(BuildContext context, {required String liveID, required bool isHost, required String userNmae, required String userId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LivePage(
        liveID: liveID,
        isHost: isHost,
        userId: userId,
        userName: userNmae,
      ),
    ),
  );
}

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realdating/pages/mape/NearBy_businesses.dart';
import 'package:realdating/services/apis_related/api_call_services.dart';
import 'package:realdating/validation/validation.dart';

import '../../button.dart';
import '../../const.dart';
import '../../custom_iteam/coustomtextcommon.dart';
import '../../custom_iteam/customprofile_textfiiled.dart';
import '../../function/function_class.dart';
import '../buisness_home/Bhome_page/buisness_home.dart';
import '../buisness_home/controller/business_home_controller.dart';

class CreateDeal extends StatefulWidget {
  const CreateDeal({super.key});

  @override
  State<CreateDeal> createState() => _CreateDealState();
}

class _CreateDealState extends State<CreateDeal> {
  MyDealController myDealController = Get.put(MyDealController());

  // ConnectivityResult _connectionStatus = ConnectivityResult.none;
  // final Connectivity _connectivity = Connectivity();
  // StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  var firstname, lastname, mobile, email;

  TextEditingController txt_title = TextEditingController();
  TextEditingController txt_price = TextEditingController();
  TextEditingController txt_discount = TextEditingController();

  String? CreateDeal;

  // final _formkey = GlobalKey<FormState>();

  String? user_id = "";
  var status, message, data;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  PickedFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  File? _image;



  _imgFromGallery() async {
    final XFile? image = (await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10));
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image!.path,

      // aspectRatioPresets: [
      //   CropAspectRatioPreset.square,
      //   CropAspectRatioPreset.ratio3x2,
      //   CropAspectRatioPreset.original,
      //   CropAspectRatioPreset.ratio4x3,
      //   CropAspectRatioPreset.ratio16x9,
      // ],
      maxWidth: 600,
      maxHeight: 600,
    );
    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
        print(_image.toString());
        testCompressFile(_image!);
      });
    }
  }

  _imgFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 10);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: photo!.path,
      //
      // aspectRatioPresets: [
      //   CropAspectRatioPreset.square,
      //   CropAspectRatioPreset.ratio3x2,
      //   CropAspectRatioPreset.original,
      //   CropAspectRatioPreset.ratio4x3,
      //   CropAspectRatioPreset.ratio16x9,
      // ],
      maxWidth: 600,
      maxHeight: 600,
    );
    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
        print(_image.toString());
        testCompressFile(_image!);
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<Uint8List> testCompressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 10,
      rotate: 90,
    );
    print('??????????????');
    print(file.lengthSync());
    print(result!.length);
    return result;
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(left: 7), child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void uploadFileToServerInfluencer() async {
    if (!(num.parse(txt_price.text.toString()) > num.parse(txt_discount.text.toString()))) {
      Fluttertoast.showToast(msg: "Discount cannot be greater than or equal to the price.");
      return;
    }
    if (_image == null) {
      Fluttertoast.showToast(msg: "Image can't be empty");
      return;
    }
    showLoaderDialog(context);
    Map<String, dynamic> apiData = await ApiCall.instance.callApi(
      url: "https://forreal.net:4000/create_deals",
      headers: await authHeader(),
      method: HttpMethod.POST,
      body: dio.FormData.fromMap({
        "Title": txt_title.text.toString(),
        'Price': txt_price.text.toString(),
        'Discount': txt_discount.text.toString(),
        'business_id': await getUserId(),
        if (_image != null) 'file': await (dio.MultipartFile.fromFile(_image!.path, filename: ("${DateTime.now().toUtc().toIso8601String()}.jpg")))
      }),
    );
    if (apiData["success"] == true) {
      myDealController.dealText.text = txt_title.text;
      Fluttertoast.showToast(
          msg: "Deal created successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      Get.off(() => const BuisnessHomePage());
    } else {
      Fluttertoast.showToast(
          msg: "Something went wrong....",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xffC83760),
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // floatingActionButton: Container(
      //     margin: EdgeInsets.only(left: 32,bottom: 30),
      //     height: 60,
      //     width: double.infinity,
      //     child: updateBtn(context)),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: SvgPicture.asset('assets/icons/btn.svg')),
        ),
        title: const Text(
          'Create Deal',
          style: CustomTextStyle.black,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: formKey,
          // autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 30,
              ),
              customTextC(text: "Upload Image", fSize: 16, fWeight: FontWeight.w500, lineHeight: 36),
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: _image == null
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 135,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: HexColor('#D9D9D9'),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ))
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: 135,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: HexColor('#D9D9D9'),
                                ),
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(image: FileImage(File(_image!.path)), fit: BoxFit.fill)),
                          ),
                  ),
                  Container(
                    height: 141,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //  SvgPicture.asset('assets/icons/file-plus.svg'),
                        InkWell(
                          onTap: () {
                            _showPicker(context);
                          },
                          child: SvgPicture.asset(
                            'assets/icons/image-add (1).svg',
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Upload Image',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              customTextC(
                text: "Title",
                fSize: 16,
                fWeight: FontWeight.w500,
                lineHeight: 36,
              ),
              SizedBox(
                  height: 70,
                  child: CustumProfileTextField1(
                    maxlenght: 30,
                    keyboardType: TextInputType.emailAddress,
                    controller: txt_title,
                    validator: validateTitle,
                    // Pass the function reference
                    hintText: 'Please Enter Title',
                  )),
              const SizedBox(
                height: 10,
              ),
              customTextC(text: "Price(\$)", fSize: 16, fWeight: FontWeight.w500, lineHeight: 36),
              SizedBox(
                height: 70,
                child: CustumProfileTextField1(
                  keyboardType: TextInputType.phone,
                  controller: txt_price,
                  validator: validatePrice,
                  hintText: 'Please Enter price',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              customTextC(text: "Discount(\$)", fSize: 16, fWeight: FontWeight.w500, lineHeight: 36),
              SizedBox(
                height: 70,
                child: CustumProfileTextField1(
                  keyboardType: TextInputType.phone,
                  controller: txt_discount,
                  validator: validateDiscount,
                  hintText: 'Please Enter Discount price',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              updateBtn(context),
            ]),
          ),
        ),
      ),
    );
  }

  Widget updateBtn(context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 15, right: 15),
      // padding: const EdgeInsets.only(left: 15, right: 15),
      child: Button(
        btnColor: Colors.redAccent,
        buttonName: 'CREATE',
        btnstyle: textstylesubtitle2(context)!.copyWith(color: colorWhite, fontFamily: 'Poppins'),
        borderRadius: BorderRadius.circular(30.00),
        btnWidth: deviceWidth(context),
        btnHeight: 60,
        // btnColor: colorbutton,
        onPressed: () {
          //Get.to(() => Reset_Pass());
          // uploadFileToServerInfluencer();
          if (formKey.currentState!.validate()) {
            uploadFileToServerInfluencer();
          }

          // else{
          //   Fluttertoast.showToast(
          //       msg: "Please Match Password",
          //       toastLength: Toast.LENGTH_SHORT,
          //       gravity: ToastGravity.BOTTOM,
          //       backgroundColor: Colors.black,
          //       textColor: Colors.white,
          //       fontSize: 16.0);
          // }
        },
      ),
    );
  }
}

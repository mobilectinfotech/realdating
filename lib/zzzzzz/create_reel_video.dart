import 'package:camera/camera.dart';
import 'package:realdating/zzzzzz/common_import.dart';
import 'package:realdating/zzzzzz/create_reel_controller.dart';
import 'package:realdating/zzzzzz/select_music.dart';

import 'colors_file.dart';
import 'content_creator_view.dart';

class CreateReelScreen extends StatefulWidget {
  const CreateReelScreen({super.key});

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen> with TickerProviderStateMixin {
  CameraController? controller;
  final CreateReelController _createReelController = Get.find();
  AnimationController? animationController;

  @override
  void initState() {
    _initAnimation();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CreateReelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initAnimation();
  }

  @override
  void dispose() {
    _createReelController.clear();
    super.dispose();
  }



  Future<void> toggleFlashMode() async {
    final cameraService = Get.find<CameraControllerService>();
    final controller = cameraService.controller;

    if (controller == null || !controller.value.isInitialized) {
      debugPrint('Camera controller is not initialized');
      return;
    }

    try {
      final currentFlashMode = controller.value.flashMode;
      final newFlashMode = currentFlashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;

      await controller.setFlashMode(newFlashMode);
      _createReelController.flashSetting.value = newFlashMode == FlashMode.torch;
    } catch (e) {
      debugPrint('Error toggling flash mode: $e');
    }
  }



  _initAnimation() {
    animationController = AnimationController(vsync: this, duration: Duration(seconds: _createReelController.recordingLength.value));
    animationController!.addListener(() {
      setState(() {});
    });
    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        stopRecording();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const CameraView(),
              Positioned(
                left: 15,
                right: 15,
                top: 25,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(color: AppColorConstants.themeColor, child: ThemeIconWidget(ThemeIcon.close).p4).circular.ripple(() {
                          Get.back();
                        }),
                        Obx(() => Container(
                                 height:  45,
                                width: 130,
                                decoration: BoxDecoration(
                                    color: AppColorConstants.themeColor,
                                    borderRadius: BorderRadius.circular(10)),

                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      if (_createReelController.selectedAudio.value != null)
                                        ThemeIconWidget(
                                          ThemeIcon.music,
                                          color: AppColorConstants.mainTextColor,
                                        ),
                                      BodyLargeText(
                                        _createReelController.selectedAudio.value != null
                                            ? _createReelController.selectedAudio.value!.name
                                            : "Select Music",
                                        weight: TextWeight.bold,
                                      ),
                                    ],
                                  ).setPadding(),
                                ))
                            .circular).ripple(() {
                          final cameraService = Get.find<CameraControllerService>();

                          Get.bottomSheet(
                            SelectMusic(selectedAudioCallback: (croppedAudio, music) {
                              _createReelController.setCroppedAudio(croppedAudio);
                              cameraService.initializeCamera(CameraLensDirection.front);
                            }),
                            isScrollControlled: true,
                            ignoreSafeArea: true,
                          );
                        }),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 15,
                top: 150,
                child: Container(
                  color: AppColorConstants.cardColor.withOpacity(0.4),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final cameraService = Get.find<CameraControllerService>();

                          if (cameraService.controller.description.lensDirection == CameraLensDirection.back) {
                            cameraService.initializeCamera(CameraLensDirection.front);
                          } else {
                            cameraService.initializeCamera(CameraLensDirection.back);
                          }
                        },
                        child: Icon(
                          Icons.cameraswitch_outlined,
                          size: 30,
                          color: AppColorConstants.themeColor,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: toggleFlashMode,
                        child: Obx(
                              () => Icon(
                            _createReelController.flashSetting.value ? Icons.flash_on : Icons.flash_off,
                            size: 30,
                            color: AppColorConstants.themeColor,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),
                      Obx(() => GestureDetector(
                            onTap: () {
                              _createReelController.updateRecordingLength(15);
                              _initAnimation();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _createReelController.recordingLength.value == 15 ? AppColorConstants.themeColor : AppColorConstants.backgroundColor),
                              child: const Center(child: BodySmallText('15s')),
                            ),
                          )),
                      const SizedBox(
                        height: 25,
                      ),
                      Obx(() => GestureDetector(
                            onTap: () {
                              _createReelController.updateRecordingLength(30);
                              _initAnimation();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _createReelController.recordingLength.value == 30 ? AppColorConstants.themeColor : AppColorConstants.backgroundColor),
                              child: const Center(child: BodySmallText('30s')),
                            ),
                          ))
                    ],
                  ).setPadding(left: 8, right: 8, top: 12, bottom: 12),
                ).round(20),
              ),
              Positioned(
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () {
                      animationController!.forward();
                      _recordVideo();
                      // _recordVideo();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: CircularProgressIndicator(
                            value: animationController!.value,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColorConstants.themeColor),
                          ),
                        ),
                        Obx(() => Container(
                              height: 50,
                              width: 50,
                              color: AppColorConstants.themeColor,
                              child: ThemeIconWidget(
                                _createReelController.isRecording.value ? ThemeIcon.pause : ThemeIcon.play,
                                size: 30,
                              ),
                            ).circular)
                      ],
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }

  _recordVideo() async {
    if (_createReelController.isRecording.value) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  void stopRecording() async {
    animationController?.reset();
    final cameraService = Get.find<CameraControllerService>();
    final file = await cameraService.controller.stopVideoRecording();
    debugPrint('RecordedFile:: ${file.path}');
    _createReelController.stopRecording();
    if (_createReelController.croppedAudioFile != null) {
      _createReelController.stopPlayingAudio();
    }
    _createReelController.isRecording.value = false;
    _createReelController.createReel(_createReelController.croppedAudioFile, file);
  }

  void startRecording() async {
    final cameraService = Get.find<CameraControllerService>();

    await cameraService.controller.prepareForVideoRecording();
    await cameraService.controller.startVideoRecording();
    _createReelController.startRecording();
    if (_createReelController.croppedAudioFile != null) {
      _createReelController.playAudioFile(_createReelController.croppedAudioFile!);
    }
    // startRecordingTimer();
  }
}

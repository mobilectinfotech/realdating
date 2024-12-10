import 'dart:io';
import 'package:camera/camera.dart'; // Can be removed if not used
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realdating/pages/createPostUser/createUserPost.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class CreatePostController extends GetxController {
  final Rxn<XFile> selectedFile = Rxn<XFile>();
  final Rxn<fileTypeName> selectedFileType = Rxn<fileTypeName>();
  VideoPlayerController? videoPlayerController;

  @override
  void onInit() {
    super.onInit();
    print("CreatePostController initialized.");
  }

  Future<void> onTapGallery() async {
    print("Gallery button tapped.");
    final ImagePicker picker = ImagePicker();
    final value = await picker.pickMedia(imageQuality: 50);
    print("Media picked from gallery: ${value?.path}");

    if (value != null) {
      selectedFile.value = null;
      selectedFileType.value = null;
      print("Selected file and file type reset.");

      var fileType = fileTypeCheckk(value.path);
      print("File type detected: $fileType");

      if (fileType == fileTypeName.video) {
        print("Video file detected. Starting compression...");
        MediaInfo? mediaInfo = await VideoCompress.compressVideo(
          value.path,
          quality: VideoQuality.DefaultQuality,
        );
        print("Video compression complete. Path: ${mediaInfo?.path}");

        if (mediaInfo?.path != null) {
          videoPlayerController = VideoPlayerController.file(File(mediaInfo!.path!));
          print("VideoPlayerController initialized with file: ${mediaInfo.path}");
          selectedFile.value = XFile(mediaInfo.path!);
          print("Selected file set to compressed video: ${mediaInfo.path}");
        }
      } else {
        selectedFile.value = value;
        print("Selected file set to image: ${value.path}");
      }

      selectedFileType.value = fileType;
      print("Selected file type set to: $fileType");
    }
  }

  Future<void> onTapVideo() async {
    print("Video recording button tapped.");
    final ImagePicker picker = ImagePicker();
    final value = await picker.pickVideo(source: ImageSource.camera);
    print("Video recorded: ${value?.path}");

    if (value != null) {
      selectedFile.value = null;
      selectedFileType.value = null;
      print("Selected file and file type reset.");

      print("Starting video compression...");
      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        value.path,
        quality: VideoQuality.DefaultQuality,
      );
      print("Video compression complete. Path: ${mediaInfo?.path}");

      if (mediaInfo?.path != null) {
        videoPlayerController = VideoPlayerController.file(File(mediaInfo!.path!));
        print("VideoPlayerController initialized with file: ${mediaInfo.path}");
        selectedFile.value = XFile(mediaInfo.path!);
        print("Selected file set to compressed video: ${mediaInfo.path}");
      }
      selectedFileType.value = fileTypeCheckk(value.path);
      print("Selected file type set to: ${selectedFileType.value}");
    }
  }

  Future<void> onTapCamera() async {
    print("Camera button tapped.");
    final ImagePicker picker = ImagePicker();
    final value = await picker.pickImage(source: ImageSource.camera);
    print("Image captured: ${value?.path}");

    if (value != null) {
      selectedFile.value = null;
      selectedFileType.value = null;
      print("Selected file and file type reset.");

      selectedFileType.value = fileTypeCheckk(value.path);
      print("File type detected: ${selectedFileType.value}");

      selectedFile.value = value;
      print("Selected file set to image: ${value.path}");
    }
  }
}

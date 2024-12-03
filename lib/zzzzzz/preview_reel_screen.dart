import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:realdating/zzzzzz/common_import.dart';
// import 'package:video_compress_ds/video_compress_ds.dart';
import 'package:video_player/video_player.dart';

import 'colors_file.dart';

class PreviewReelsScreen extends StatefulWidget {
  final File reel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;

  const PreviewReelsScreen({Key? key, required this.reel, this.audioId, this.audioStartTime, this.audioEndTime}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PreviewReelsState();
  }
}

class _PreviewReelsState extends State<PreviewReelsScreen> {
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.file(widget.reel);
    videoPlayerController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      chewieController = ChewieController(
        aspectRatio: videoPlayerController!.value.aspectRatio,
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        showOptions: false,
      );
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    chewieController!.dispose();
    videoPlayerController!.dispose();
    chewieController?.pause();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
            // alignment: Alignment.topCenter,
            children: [
              const SizedBox(
                height: 50,
              ),
              chewieController == null
                  ? Container()
                  : SizedBox(
                      height: (Get.width - 32) / videoPlayerController!.value.aspectRatio,
                      child: Chewie(
                        controller: chewieController!,
                      ),
                    ).round(20),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ThemeIconWidget(
                    ThemeIcon.backArrow,
                    size: 25,
                  ).circular.ripple(() {
                    Get.back();
                  }),
                  Container(
                          color: AppColorConstants.themeColor,
                          child: Text(
                            "Next",
                            style: TextStyle(fontSize: FontSizes.b2),
                          ).setPadding())
                      .circular
                      .ripple(() {
                    submitReel();
                  }),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ]),
      ),
    );
  }

  submitReel() async {
    Loader.show(status: "loading...");
    // final thumbnail = await VideoThumbnail.thumbnailData(
    //   video: widget.reel.path,
    //   imageFormat: ImageFormat.JPEG,
    //   maxWidth: 400,
    //   // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    //   quality: 25,
    // );

    // MediaInfo? mediaInfo = await VideoCompress.compressVideo(
    //   widget.reel.path,
    //   quality: VideoQuality.DefaultQuality,
    //   deleteOrigin: false, // It's false by default
    // );

    // final videoInfo = await FlutterVideoInfo().getVideoInfo(mediaInfo!.path!);
    // print(
    //     'here is video size ${Size(videoInfo!.width!.toDouble(), videoInfo.height!.toDouble())}');
    // Loader.dismiss();
    // Media media = Media();
    // media.id = randomId();
    // media.file = File(mediaInfo!.path!);
    // media.thumbnail = thumbnail;
    // media.size =
    //     Size(videoInfo!.width!.toDouble(), videoInfo.height!.toDouble());
    // media.creationTime = DateTime.now();
    // media.title = null;
    // media.mediaType = GalleryMediaType.video;

    // _selectPostMediaController.mediaSelected([media]);

    chewieController?.pause();

    // Get.to(() => AddPostScreen(
    //       items: [media],
    //       isReel: true,
    //       audioId: widget.audioId,
    //       audioStartTime: widget.audioStartTime,
    //       audioEndTime: widget.audioEndTime,
    //       postType: PostType.reel,
    //       postCompletionHandler: () {
    //         Get.close(2);
    //       },
    //
    //       // postType: PostType.reel,
    //     ));
    //todo sameer
  }
}
import 'package:realdating/reel/post_model.dart';
import 'package:realdating/reel/reels_controller.dart';

import 'common_import.dart';

class ReelAudioDetail extends StatefulWidget {
  final ReelMusicModel audio;

  const ReelAudioDetail({super.key, required this.audio});

  @override
  State<ReelAudioDetail> createState() => _ReelAudioDetailState();
}

class _ReelAudioDetailState extends State<ReelAudioDetail> {
  final ReelsController _reelsController = Get.find();

  @override
  void initState() {
    // _reelsController.getReelsWithAudio(widget.audio.id);
    super.initState();
  }

  // _createReelController.getReelCategories();

  @override
  void dispose() {
    super.dispose();
    _reelsController.clearReelsWithAudio();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          backNavigationBar(title: audioString.tr),
          Row(
            children: [
              CachedNetworkImage(height: 70, width: 70, imageUrl: widget.audio.thumbnail).round(10),
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(widget.audio.name, weight: TextWeight.semiBold),
                  const SizedBox(
                    height: 5,
                  ),
                  BodyLargeText(widget.audio.artists, weight: TextWeight.regular),
                  const SizedBox(
                    height: 5,
                  ),
                  BodyMediumText(
                    '${widget.audio.numberOfReelsMade.formatNumber} ${reelsString.tr}',
                    weight: TextWeight.regular,
                  )
                ],
              )
            ],
          ).p16,
          Expanded(
              child: GetBuilder<ReelsController>(
                  init: _reelsController,
                  builder: (ctx) {
                    return GridView.builder(
                        itemCount: _reelsController.filteredReels.length,
                        padding: const EdgeInsets.only(top: 20, bottom: 50),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 2.0, mainAxisSpacing: 2.0, childAspectRatio: 0.7),
                        itemBuilder: (ctx, index) {
                          PostModel reel = _reelsController.filteredReels[index];
                          return CachedNetworkImage(fit: BoxFit.cover, imageUrl: "reel..first.thumbnail").ripple(() {
                            // Get.to(() => ReelsList(
                            //     audioId: widget.audio.id, index: index)
                            // );
                          });
                        });
                  }))
        ]));
  }
}

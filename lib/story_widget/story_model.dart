import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

enum StoryImageType { Image, Video }

class StoryListModel<A, B> {
  final String id;
  final A? data;
  final List<StoryModel<B>> stories;

  StoryListModel({
    required this.id,
    required this.stories,
    this.data,
  });
}

class StoryModel<A> {
  final A? data;
  final String imageUrl;
  String thumbnailUrl;
  final StoryImageType storyType;

  bool isThumbnailUrl = true;
  final isInitialize = ValueNotifier(false);
  final isInitThumbnail = ValueNotifier(false);
  late VideoPlayerController? videoPlayer = null;

  StoryModel(
      {this.data,
      this.imageUrl = '',
      this.thumbnailUrl = '',
      this.storyType = StoryImageType.Image});

  Future<void> initialize() async {
    if (storyType == StoryImageType.Video) {
      videoPlayer = VideoPlayerController.networkUrl(Uri.parse(imageUrl));
      await videoPlayer!.initialize();
      isInitialize.value = true;
    } else {
      videoPlayer = null;
    }
  }

  void dispose() {
    videoPlayer?.dispose();
    isInitialize.dispose();
  }
}

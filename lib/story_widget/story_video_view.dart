import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:story_widget/story_widget/story_model.dart';
import 'package:video_player/video_player.dart';

class StoryVideoView extends StatelessWidget {
  const StoryVideoView({required this.story, this.defaultImage, super.key});

  final StoryModel story;
  final Widget? defaultImage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: story.isInitialize,
        builder: (context, isInit, child) => isInit
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                      aspectRatio: story.videoPlayer!.value.aspectRatio,
                      child: VideoPlayer(story.videoPlayer!)),
                ],
              )
            : ValueListenableBuilder(
                valueListenable: story.isInitThumbnail,
                builder: (context, isThumbInit, child) {
                  if (isThumbInit) {
                    if (story.thumbnailUrl.isNotEmpty) {
                      if (story.isThumbnailUrl) {
                        return CachedNetworkImage(
                          imageUrl: story.thumbnailUrl,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) =>
                              defaultImage ?? const SizedBox(),
                          placeholder: (context, url) =>
                              defaultImage ?? const SizedBox(),
                        );
                      } else {
                        return Image.file(
                          File(story.thumbnailUrl),
                          width: double.infinity,
                          fit: BoxFit.contain,
                        );
                      }
                    }
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ));
  }
}

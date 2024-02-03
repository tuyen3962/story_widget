import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:story_widget/story_widget/story_model.dart';
import 'package:story_widget/story_widget/story_video_view.dart';

const IMAGE_DURATION = 5000;

const _DURATION_TIME = 50;

class StoryWidget<A, B> extends StatefulWidget {
  const StoryWidget({
    this.listStories = const [],
    this.slideImageDuration,
    this.bottomSlideView,
    this.heightSlider = 2,
    this.topSliderPadding,
    this.onFinishStorySlide,
    this.onPageChanged,
    this.onStoryChanged,
    this.topSlideView,
    this.paddingSlide = 8,
    this.activeSlideColor,
    this.unactiveSliderColor,
    this.backgroundColor,
    this.isStopLongPress = true,
    this.isHideWhenStop = true,
    this.fadeDuration,
    this.bottomView,
    super.key,
  });

  /// the list of stories user want to play
  final List<StoryListModel<A, B>> listStories;

  /// the play duration when slider is image
  final int? slideImageDuration;

  /// the height of slider
  final double heightSlider;

  /// the padding between sliders
  final double paddingSlide;

  /// the custom view in the bottom of slider
  final Widget? bottomSlideView;

  /// the custom view in the top of slider
  final Widget? topSlideView;

  /// the custom view in the bottom of video
  final Widget? bottomView;

  /// the padding of slider
  final EdgeInsets? topSliderPadding;

  /// The color of slider when it is unactive
  final Color? unactiveSliderColor;

  /// The color of slider when it is active
  final Color? activeSlideColor;

  ///Background color of view
  final Color? backgroundColor;

  ///Enable the long press gesture for stopping video
  final bool isStopLongPress;

  ///Allow to hide other view when the video player stop
  final bool isHideWhenStop;

  /// the fade duration when user want to hide other view in long press gesture
  final Duration? fadeDuration;

  /// The event when the story board has finished
  final VoidCallback? onFinishStorySlide;

  /// return the current page for handling another action
  final void Function(int index, {A? page})? onPageChanged;

  final void Function(int index, {B? story})? onStoryChanged;

  @override
  State<StoryWidget> createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  late final List<StoryListModel> listStories;
  final PageController pageController = PageController();

  final _currentPageIndex = ValueNotifier(0);

  final _currentStoryIndex = ValueNotifier(0);

  final _currentSlideValue = ValueNotifier(0.0);

  final _isShowOtherView = ValueNotifier(true);

  late Timer? timer;

  Timer? _longPressTimer = null;

  int get desTimer => widget.slideImageDuration ?? IMAGE_DURATION;

  Color get unactive =>
      widget.unactiveSliderColor ?? Colors.grey.withOpacity(0.5);

  Color get active => widget.activeSlideColor ?? Colors.white;

  List<StoryModel> get stories => listStories[_currentPageIndex.value].stories;

  var currentPageValue;

  @override
  void dispose() {
    pageController.dispose();
    _currentPageIndex.dispose();
    _currentStoryIndex.dispose();
    _currentSlideValue.dispose();
    timer?.cancel();
    _longPressTimer?.cancel();
    for (final list in listStories) {
      for (final story in list.stories) {
        story.dispose();
      }
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currentPageValue = pageController.initialPage.toDouble();
    listStories = widget.listStories;

    pageController.addListener(() => setState(() {
          currentPageValue = pageController.page;
        }));
    startCountTimer();
  }

  void onChangeStoryIndex(int index) async {
    if (stories.length == index) {
      final newPageIndex = _currentPageIndex.value + 1;
      if (newPageIndex >= listStories.length) {
        print('last');
        widget.onFinishStorySlide?.call();
      } else {
        _currentPageIndex.value = newPageIndex;
        await animatedToPage(newPageIndex);
      }

      return;
    }
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
    if (index == -1) {
      final newPageIndex = _currentPageIndex.value - 1;
      if (newPageIndex >= 0) {
        await animatedToPage(newPageIndex);
      } else {
        return;
      }
    }

    _currentSlideValue.value = 0;
    final previousStory = stories[_currentStoryIndex.value];
    if (previousStory.storyType == StoryImageType.Video) {
      previousStory.videoPlayer?.pause();
      previousStory.videoPlayer?.seekTo(Duration.zero);
    }
    final story = stories[index];
    _currentStoryIndex.value = index;
    widget.onStoryChanged?.call(index, story: story);

    onCheckAndInitNextVideo(index + 1);
    if (story.storyType == StoryImageType.Video) {
      if (story.videoPlayer == null) {
        await story.initialize();
      } else {
        story.videoPlayer?.seekTo(Duration.zero);
      }
      story.videoPlayer?.play();
    }

    startCountTimer();
  }

  animatedToPage(int pageIndex) async {
    _currentPageIndex.value = pageIndex;
    widget.onPageChanged?.call(pageIndex, page: listStories[pageIndex].data);
    await pageController.animateToPage(pageIndex,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
    onChangeStoryIndex(0);
  }

  onCheckAndInitNextVideo(int nextIndex) {
    if (nextIndex < stories.length) {
      final story = stories[nextIndex];
      if (story.storyType == StoryImageType.Video &&
          story.videoPlayer == null) {
        story.initialize();
      }
    }
  }

  void startCountTimer() {
    timer =
        Timer.periodic(Duration(milliseconds: _DURATION_TIME), (timing) async {
      final story = stories[_currentStoryIndex.value];
      if (story.storyType == StoryImageType.Image) {
        final currentVal =
            (_currentSlideValue.value * desTimer) + _DURATION_TIME;

        if (currentVal <= desTimer) {
          _currentSlideValue.value = currentVal / desTimer;
        } else {
          _currentSlideValue.value = 100;
          timer?.cancel();
          timer = null;
          timing.cancel();
          onChangeStoryIndex(_currentStoryIndex.value + 1);
          return;
        }
      } else {
        if (story.videoPlayer != null && story.isInitialize.value) {
          final position = (await story.videoPlayer!.position ?? Duration.zero)
              .inMilliseconds;
          final duration = story.videoPlayer!.value.duration.inMilliseconds;

          var percent = position / duration;
          if (percent >= 1 || position == duration - 1) {
            percent = 1;
            _currentSlideValue.value = percent;
            timer?.cancel();
            timer = null;
            timing.cancel();
            onChangeStoryIndex(_currentStoryIndex.value + 1);
            return;
          } else {
            _currentSlideValue.value = percent;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _onLongPressStart,
      onLongPressEnd: (details) => _onLongPressEnd(),
      onLongPressCancel: _onLongPressEnd,
      // onHorizontalDragStart: (details) =>
      //     dev.log('onHorizontalDragStart ${details.toString()}'),
      onHorizontalDragUpdate: (details) {
        // pageController.animateTo(currentPageValue + details.delta.dx / 100,
        //     duration: const Duration(milliseconds: 100), curve: Curves.linear);
        // dev.log('onHorizontalDragUpdate $details');
      },
      behavior: HitTestBehavior.deferToChild,
      child: Container(
        color: widget.backgroundColor ?? Colors.black,
        child: Stack(
          children: [
            Positioned.fill(child: _buildStoryImage()),
            ValueListenableBuilder(
              valueListenable: _isShowOtherView,
              builder: (context, isShow, child) => AnimatedCrossFade(
                alignment: Alignment.center,
                duration:
                    widget.fadeDuration ?? const Duration(milliseconds: 500),
                firstChild: SafeArea(child: _buildSlider()),
                secondChild: const SizedBox(),
                crossFadeState: isShow
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: widget.bottomView ?? const SizedBox()),
          ],
        ),
      ),
    );
  }

  void _onLongPressStart() {
    if (!widget.isStopLongPress) return;

    _longPressTimer = Timer(const Duration(milliseconds: 300), () {
      if (widget.isHideWhenStop) {
        _isShowOtherView.value = false;
      }
      final story = stories[_currentStoryIndex.value];
      if (story.storyType == StoryImageType.Video) {
        story.videoPlayer?.pause();
      }
      timer?.cancel();
      timer = null;
      _longPressTimer?.cancel();
      _longPressTimer = null;
    });
  }

  void _onLongPressEnd() {
    _longPressTimer?.cancel();
    _longPressTimer = null;

    if (_isShowOtherView.value || !widget.isStopLongPress) return;

    if (widget.isHideWhenStop) {
      _isShowOtherView.value = true;
    }
    final story = stories[_currentStoryIndex.value];
    if (story.storyType == StoryImageType.Video) {
      story.videoPlayer?.play();
    }
    startCountTimer();
  }

  Widget _buildSlider() {
    return Padding(
      padding: widget.topSliderPadding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(children: [
        widget.topSlideView ?? const SizedBox(),
        Row(
            children: List.generate(
                stories.length,
                (index) => Expanded(
                      child: LayoutBuilder(
                          builder: (context, constraint) =>
                              ValueListenableBuilder(
                                valueListenable: _currentStoryIndex,
                                builder: (context, page, child) {
                                  if (page == index) {
                                    return Stack(children: [
                                      _buildSlideView(index,
                                          backgroundColor: unactive),
                                      ValueListenableBuilder(
                                          valueListenable: _currentSlideValue,
                                          builder: (context, value, child) {
                                            final currentWidth =
                                                constraint.maxWidth < 0
                                                    ? 0.0
                                                    : (value *
                                                            constraint
                                                                .maxWidth) -
                                                        widget.paddingSlide;
                                            return _buildSlideView(index,
                                                backgroundColor: active,
                                                width: currentWidth > 0
                                                    ? currentWidth
                                                    : 0);
                                          }),
                                    ]);
                                  } else if (page > index) {
                                    return _buildSlideView(index,
                                        backgroundColor: active);
                                  } else {
                                    return _buildSlideView(index,
                                        backgroundColor: unactive);
                                  }
                                },
                              )),
                    ))),
        widget.bottomSlideView ?? const SizedBox(),
      ]),
    );
  }

  Widget _buildSlideView(int currentIndex,
      {required Color backgroundColor, double? width}) {
    return Container(
      width: width,
      height: widget.heightSlider,
      margin:
          EdgeInsets.only(right: currentIndex >= 0 ? widget.paddingSlide : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: backgroundColor,
      ),
    );
  }

  Widget _buildStoryImage() {
    return ValueListenableBuilder(
      valueListenable: _currentPageIndex,
      builder: (context, page, child) => PageView.builder(
        controller: pageController,
        itemCount: listStories.length,
        physics: const AlwaysScrollableScrollPhysics(),
        onPageChanged: (value) {
          _currentPageIndex.value = value;
          onChangeStoryIndex(0);
        },
        itemBuilder: (context, index) {
          final isLeaving = (index - currentPageValue) <= 0;
          final t = (index - currentPageValue);
          final rotationY = lerpDouble(0, 30, t as double)!;
          final maxOpacity = 0.8;
          final num opacity =
              lerpDouble(0, maxOpacity, t.abs())!.clamp(0.0, maxOpacity);
          final isPaging = opacity != maxOpacity;
          final transform = Matrix4.identity();
          transform.setEntry(3, 2, 0.003);
          transform.rotateY(-rotationY * (pi / 180.0));

          final currentStoryList = listStories[index];
          final stories = currentStoryList.stories;
          return Transform(
            alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
            transform: transform,
            child: Stack(children: [
              Positioned.fill(
                child: ValueListenableBuilder(
                  valueListenable: _currentStoryIndex,
                  builder: (context, storyIndex, child) {
                    final story = stories[storyIndex];
                    if (story.storyType == StoryImageType.Image) {
                      return CachedNetworkImage(
                        imageUrl: story.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      );
                    } else {
                      return StoryVideoView(story: story);
                    }
                  },
                ),
              ),
              _buildTouchPage(),
              if (isPaging && !isLeaving)
                Positioned.fill(
                  child: Opacity(
                    opacity: opacity as double,
                    child: const ColoredBox(
                      color: Colors.black87,
                    ),
                  ),
                ),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildTouchPage() {
    return Row(
      children: [
        Expanded(
            child: GestureDetector(
          onTap: () => onChangeStoryIndex(_currentStoryIndex.value - 1),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: double.infinity,
          ),
        )),
        // const SizedBox(width: 30),
        Expanded(
            child: GestureDetector(
          onTap: () => onChangeStoryIndex(_currentStoryIndex.value + 1),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: double.infinity,
          ),
        )),
      ],
    );
  }
}

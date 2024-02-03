## Features

Create a story widget for listing the list of images, and videos for users to view like Instagram and Facebook story

## Usage

In this library, we use two models to implement the display of the item story in the view.

The first model is StoryListModel: this provides a list of stories that can be displayed in the view as personal stories. 

In this model, we can set your custom data inside it as a personal use-case.
```dart
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
```

The second model is StoryModel: this is the data of one story
We will give the optional thumbnail URL for video type if you have one.
storyType will be divided into two types: Image and video. So careful to check your asset
```dart
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
}
```

By using it in your project. Just use StoryWidget widget.

import 'package:flutter/material.dart';
import 'package:story_widget/story_widget.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StoryWidget(
          heightSlider: 2,
          listStories: <StoryListModel>[
            StoryListModel(
              id: '',
              stories: [
                StoryModel(
                    audioUrl:
                        'https://commondatastorage.googleapis.com/codeskulptor-assets/Evillaugh.ogg',
                    imageUrl:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTb5z6MCCSYYRWCiVDmoNaRZ1qEwl6MlQCOzkSBJbdMlg&s',
                    storyType: StoryImageType.Image),
                StoryModel(
                    imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b/web-chat-709ef.appspot.com/o/robin_-_65801%20(540p).mp4?alt=media&token=225ea638-cda1-42a2-b8db-7fcd4d6e5ffd',
                    storyType: StoryImageType.Video),
                StoryModel(
                    audioUrl:
                        'https://codeskulptor-demos.commondatastorage.googleapis.com/GalaxyInvaders/theme_01.mp3',
                    imageUrl:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTb5z6MCCSYYRWCiVDmoNaRZ1qEwl6MlQCOzkSBJbdMlg&s',
                    storyType: StoryImageType.Image),
                StoryModel(
                    imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b/web-chat-709ef.appspot.com/o/189018%20(540p).mp4?alt=media&token=e315974f-739a-4ad2-960e-a5ac8cdd7de7',
                    storyType: StoryImageType.Video),
              ],
            ),
            StoryListModel(id: '', stories: [
              StoryModel(
                  imageUrl:
                      'https://player.vimeo.com/progressive_redirect/playback/906926404/rendition/540p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=cd6774e0dd93f076bbdfddc237e7eff87a8b75b4ea23987cd27445db6275c960',
                  storyType: StoryImageType.Video),
              StoryModel(
                  imageUrl:
                      'https://player.vimeo.com/progressive_redirect/playback/906924247/rendition/360p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=6cbd7b8a638c2f5e476df26f81c6ff59c13bf86e569d4cd155410658fe34c2ef',
                  storyType: StoryImageType.Video),
              StoryModel(
                  imageUrl:
                      'https://player.vimeo.com/progressive_redirect/playback/906908763/rendition/360p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=bace0f199705c841170d91388f6ce4b21ce41a5710b9e697495410aefad65d45',
                  storyType: StoryImageType.Video),
              StoryModel(
                  imageUrl:
                      'https://player.vimeo.com/progressive_redirect/playback/906901121/rendition/360p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=7328c0ea9259aa4b8c958e3e8ad96c75cb2548b99b94e35309adef97d688ae59',
                  storyType: StoryImageType.Video),
            ]),
            StoryListModel(id: '', stories: [
              StoryModel(
                  imageUrl:
                      'https://player.vimeo.com/progressive_redirect/playback/906835820/rendition/360p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=06d7192d857602f155cb3cee1dfce747dc807510f48bbe44d0dcba4b92f05bcd',
                  storyType: StoryImageType.Video),
              StoryModel(
                  imageUrl:
                      'https://player.vimeo.com/progressive_redirect/playback/906815729/rendition/360p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=06c826eaa8b1404ac80f893aeaa8937d3b3e1541ecf5c777441c7411f4d2b7d5',
                  storyType: StoryImageType.Video),
              StoryModel(
                  imageUrl:
                      'https://player.vimeo.com/progressive_redirect/playback/906830335/rendition/360p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=97c650364130a3bd867485ddccf4e421b07a506b6b9e2934938fefce7bf1d488',
                  storyType: StoryImageType.Video),
              StoryModel(
                  imageUrl:
                      'https://player.vimeo.com/progressive_redirect/playback/906752007/rendition/360p/file.mp4?loc=external&oauth2_token_id=1747418641&signature=ce27499781e59f8fa37e5c97622e0de4d84309b725bdd65ff956b56f9d717e45',
                  storyType: StoryImageType.Video),
            ]),
          ],
        ),
      ),
    );
  }
}

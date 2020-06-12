import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mediaframe/media_controller.dart';
import 'package:mediaframe/settings_model.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

class SlideShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: _MediaSlider());
  }
}

class _VideoPlayerScreen extends StatefulWidget {
  _VideoPlayerScreen({
    Key key,
    this.videoFile,
    this.onPlay,
    this.onMute,
    this.onEnd,
  }) : super(key: key);

  final File videoFile;
  final VoidCallback onPlay;
  final VoidCallback onMute;
  final VoidCallback onEnd;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  VideoPlayerController _videoController;
  Future<void> _initializeVideoPlayerFuture;
  bool _muted = true;

  void videoListener() {
    if (!_muted && !_videoController.value.isPlaying) {
      setState(() {
        _muted = true;
      });
      _videoController.setVolume(0.0);
      this.widget.onEnd();
    }
  }

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _videoController = VideoPlayerController.file(this.widget.videoFile);

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _videoController.initialize();

    // Use the controller to loop the video.
    _videoController.setLooping(false);

    // Listen to the controller for state changes to detect when we're done playing
    _videoController.addListener(videoListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // mutes the video
      _videoController.setVolume(0);
      // Plays the video once the widget is built and loaded.
      _videoController.play();
    });

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _videoController.removeListener(videoListener);
    _videoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomPadding: false,

      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Icon(Icons.error_outline, size: 16));
            }
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return Center(
                child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(_videoController),
            ));
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Consumer<SettingsModel>(builder: (BuildContext context, SettingsModel settings, Widget child) {
        return FloatingActionButton(
          onPressed: () {
            // Wrap the play or pause in a call to `setState`. This ensures the
            // correct icon is shown.
            setState(() {
              // If the video is playing, pause it.
              if (_muted) {
                _videoController.setVolume(settings.volume);
                _videoController.seekTo(Duration());
                _muted = false;
                this.widget.onPlay();
              } else {
                _videoController.setVolume(0);
                _muted = true;
                this.widget.onMute();
              }
            });
          },
          // Display the correct icon depending on the state of the player.
          child: Icon(
            _muted ? Icons.volume_off : Icons.volume_mute,
          ),
        );
      }),
    );
  }
}

class _MediaSlider extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MediaSliderState();
}

class _MediaSliderState extends State<_MediaSlider> {
  void videoEnded() {
    Provider.of<MediaPlayerController>(context, listen: false).resume();
  }

  /// If the user un-muted the video then pause the timer so we can let the video finish
  void videoPlaying() {
    Provider.of<MediaPlayerController>(context, listen: false).pause();
  }

  /// If the user muted the video then resume the timer
  void videoMuted() {
    Provider.of<MediaPlayerController>(context, listen: false).start();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPlayerController>(builder: (BuildContext context, MediaPlayerController controller, Widget child) {
      return AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          child: controller.value.isVideo
              ? _VideoPlayerScreen(
                  key: ValueKey<String>(controller.value.currentAsset.file.path),
                  videoFile: controller.value.currentAsset.file,
                  onEnd: videoEnded,
                  onPlay: videoPlaying,
                  onMute: videoMuted,
                )
              : Stack(key: ValueKey<String>(controller.value.currentAsset.file.path), children: [
                  Center(child: Icon(Icons.image, size: 36.0)),
                  Center(
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: FileImage(controller.value.currentAsset.file),
                      fit: BoxFit.cover,
                    ),
                  )
                ]));
    });
  }
}

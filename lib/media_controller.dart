import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mediaframe/media_asset.dart';
import 'package:mediaframe/settings_model.dart';

class MediaPlayerValue {
  MediaPlayerValue({
    @required this.currentAsset,
    this.loading = false,
  });

  final MediaAsset currentAsset;
  final bool loading;

  MediaPlayerValue copyWith({
    MediaAsset currentAsset,
    bool loading,
  }) {
    return MediaPlayerValue(
      currentAsset: currentAsset ?? this.currentAsset,
      loading: loading ?? this.loading,
    );
  }

  get isVideo => currentAsset != null && currentAsset.video;

  get isImage => currentAsset != null && currentAsset.image;
}

class MediaPlayerController extends ValueNotifier<MediaPlayerValue> {
  Timer _timer;
  int _currentIndex = 0;
  int _slideDelaySeconds;
  List<MediaAsset> _assets;
  final _random = new Random();

  MediaPlayerController() : super(MediaPlayerValue(loading: true, currentAsset: null));

  void update(SettingsModel settingsModel) {
    if (settingsModel.assets != this._assets) {
      this._assets = settingsModel.assets;
      this._currentIndex = 0;

      if (this.value.loading) {
        if (this._assets.isNotEmpty) {
          this.value = MediaPlayerValue(
              loading: false, currentAsset: this._assets[this._currentIndex]);
        } else {
          this.value = MediaPlayerValue(loading: false, currentAsset: null);
        }
      }
    }

    if (settingsModel.slideDelaySeconds != this._slideDelaySeconds) {
      this._slideDelaySeconds = settingsModel.slideDelaySeconds;

      // If the slide delay changed and the timer is running then restart it with the new setting
      if (this._timer != null) {
        this.pause();
        this.start();
      }
    }
  }

  void incrementView() {
    final newIndex = (this._currentIndex + 1 < this._assets.length)
        ? this._currentIndex + 1
        : 0;

    this._currentIndex = newIndex;
    this.value = this.value.copyWith(currentAsset: this._assets[this._currentIndex]);
  }

  void start() {
    if (this._timer == null && this._slideDelaySeconds != null) {
      this._timer = Timer.periodic(Duration(seconds: this._slideDelaySeconds), (timer) {
        this.incrementView();
      });
    }
  }

  void pause() {
    this._timer?.cancel();
    this._timer = null;
  }

  void resume() {
    if (this._timer == null) {
      Timer(Duration(seconds: 1), () {
        this.incrementView();
        this.start();
      });
    }
  }
}

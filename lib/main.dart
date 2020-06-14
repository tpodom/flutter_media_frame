import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediaframe/assets.dart';
import 'package:mediaframe/media_controller.dart';
import 'package:mediaframe/clock.dart';
import 'package:mediaframe/settings.dart';
import 'package:mediaframe/settings_model.dart';
import 'package:mediaframe/slideshow.dart';
import 'package:mediaframe/unlock.dart';
import 'package:wakelock/wakelock.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(ChangeNotifierProvider<SettingsModel>(create: (context) => SettingsModel(), child: MediaframeApp()));
}

class MediaframeApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Frame',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProxyProvider<SettingsModel, MediaPlayerController>(
        create: (_) => MediaPlayerController(),
        update: (_, settingsModel, controller) {
          controller.update(settingsModel);
          return controller;
        },
        child: _HomePage(title: 'Media Frame'),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  _HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

enum Screen {
  CLOCK,
  MEDIA,
}

class _HomePageState extends State<_HomePage> {
  Screen _currentScreen = Screen.MEDIA;
  bool _appBarVisible = false;
  bool _loading = true;
  Timer _timer;
  Timer _appBarTimer;

  @override
  void initState() {
    super.initState();
    this._hideSystemUI();
    Wakelock.enable();
    this._load();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  _load() async {
    await Provider.of<SettingsModel>(context, listen: false).load();
    _loading = false;
    this._startDisplay();
  }

  _startDisplay() {
    if (this._isNightMode()) {
      this._currentScreen = Screen.CLOCK;
    }
    this._startTimer();
  }

  _isNightMode() {
    var now = TimeOfDay.now();
    var timeOfDayAsDouble = (TimeOfDay timeOfDay) => timeOfDay.hour + timeOfDay.minute / 60.0;
    var settings = Provider.of<SettingsModel>(context, listen: false);
    if (!settings.enableNightMode) {
      return false;
    }

    if (timeOfDayAsDouble(settings.nightEnd) < timeOfDayAsDouble(settings.nightStart)) {
      return (timeOfDayAsDouble(now) < timeOfDayAsDouble(settings.nightEnd)
          || timeOfDayAsDouble(now) >= timeOfDayAsDouble(settings.nightStart));
    }
    return (timeOfDayAsDouble(now) < timeOfDayAsDouble(settings.nightEnd)
        && timeOfDayAsDouble(now) >= timeOfDayAsDouble(settings.nightStart));

  }

  _hideSystemUI() {
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  _showSystemUI() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  _startTimer() {
    this._stopTimer();
    var settings = Provider.of<SettingsModel>(context, listen: false);
    this._timer = Timer.periodic(Duration(minutes: settings.clockDelayMinutes), (timer) => this._switchDisplays());
  }

  _stopTimer() {
    this._timer?.cancel();
  }

  _switchDisplays() {
    setState(() {
      if (this._isNightMode()) {
        this._currentScreen = Screen.CLOCK;
      } else {
        this._currentScreen = this._currentScreen == Screen.CLOCK ? Screen.MEDIA : Screen.CLOCK;
      }
    });
  }

  _toggleAppBar() {
    setState(() {
      if (this._appBarVisible) {
        this._appBarTimer?.cancel();
        this._hideSystemUI();
        this._appBarVisible = false;
      } else {
        this._showSystemUI();
        this._appBarVisible = true;
        this._appBarTimer = Timer(Duration(seconds: 15), () => this._toggleAppBar());
      }
    });
  }

  Future<bool> _promptUnlock(context) async {
    var settings = Provider.of<SettingsModel>(context, listen: false);
    if (!settings.useUnlockCode) {
      return true;
    }
    var completer = Completer<bool>();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UnlockRoute(onSuccess: () {
                completer.complete(true);
              }, onCancel: () {
                completer.complete(false);
              })),
    );
    return completer.future;
  }

  _openSettings(context, controller) async {
    controller.pause();
    this._stopTimer();
    this._appBarTimer?.cancel();
    var unlocked = await this._promptUnlock(context);
    if (unlocked) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsRoute()),
      );
    }
    this._toggleAppBar();
    this._startDisplay();
    if (this._currentScreen == Screen.MEDIA) {
      controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBar;

    if (this._appBarVisible) {
      appBar = AppBar(title: Text('Media Frame'), actions: [
        Consumer<MediaPlayerController>(builder: (BuildContext context, MediaPlayerController controller, Widget child) {
          return IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                await _openSettings(context, controller);
              });
        })
      ]);
    }

    return Scaffold(
        resizeToAvoidBottomPadding: this._appBarVisible,
        backgroundColor: Colors.black,
        appBar: appBar,
        body: GestureDetector(onTap: () {
          this._toggleAppBar();
        }, child: Center(child: Consumer2<MediaPlayerController, SettingsModel>(
            builder: (BuildContext context, MediaPlayerController controller, SettingsModel settings, Widget child) {
          if (_loading) {
            return CircularProgressIndicator();
          }
          if (settings.assets.isEmpty) {
            return Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('Welcome! Open the Slideshow Media settings to get started.', style: TextStyle(color: Colors.white))),
              OutlineButton(
                  borderSide: BorderSide(width: 2.0, color: Colors.white),
                  textColor: Colors.white,
                  child: Text('Add Slideshow Media'),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AssetsRoute()),
                    );
                  })
            ]));
          }

          if (this._currentScreen == Screen.CLOCK) {
            controller.pause();
            return Dismissible(
                key: Key('clock'),
                confirmDismiss: (direction) async {
                  return this._promptUnlock(context);
                },
                onDismissed: (details) {
                  setState(() {
                    this._stopTimer();
                    this._currentScreen = Screen.MEDIA;
                    this._startTimer();
                  });
                },
                child: Clock());
          } else {
            controller.start();
            return SlideShow();
          }
        }))));
  }
}

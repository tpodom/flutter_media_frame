import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediaframe/settings_model.dart';
import 'package:mediaframe/weather.dart';
import 'package:provider/provider.dart';

class Clock extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  final _maxOffsetDistance = 100;

  Timer _timer;
  DateTime _now;
  double _offset = 0;
  double _offsetStep = -1;
  double _paddingLeft = 0;
  double _paddingRight = 0;

  @override
  void initState() {
    super.initState();
    this._timer = Timer.periodic(Duration(seconds: 1), (timer) => this._tick());
    this._tick();
  }

  @override
  void dispose() {
    this._timer?.cancel();
    super.dispose();
  }

  _tick() {
    setState(() {
      this._now = DateTime.now();

      if (this._now.second % 10 == 0) {
        if ((this._offset + this._offsetStep).abs() > this._maxOffsetDistance) {
          this._offsetStep *= -1;
        }

        this._offset += this._offsetStep;
      }

      if (_offset < 0) {
        _paddingRight = _offset.abs();
        _paddingLeft = 0;
      } else {
        _paddingLeft = _offset.abs();
        _paddingRight = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
        builder: (BuildContext context, SettingsModel settings,
            Widget child) {

          var formatter = settings.use24HourTime
              ? DateFormat.Hm()
              : DateFormat.jm();
          var amPMFormatter = DateFormat('a');
          var amPM = amPMFormatter.format(this._now);

          var time = formatter.format(this._now);
          if (time.contains(amPM)) {
            time = time.replaceAll(amPM, "").trim();
          }
          amPM = settings.use24HourTime ? "" : amPM;

          return SizedBox.expand(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 1, child: Container(child: Text(""))),
                  Expanded(flex: 2,
                      child: Container(
                          padding: EdgeInsets.only(
                              left: this._paddingLeft,
                              right: this._paddingRight),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(time,
                                          style: TextStyle(
                                              fontSize: 220,
                                              fontWeight: FontWeight.w100,
                                              color: Colors.white)),
                                      Container(
                                          padding: EdgeInsets.only(bottom: 30),
                                          child: Text(amPM,
                                              style: TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white)))
                                    ]),
                              ]))),
                  Expanded(flex: 1,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                padding: EdgeInsets.only(
                                    left: this._paddingLeft,
                                    right: this._paddingRight),
                                child: settings.enableWeather ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: [Weather()]) : Container()
                            )
                          ]))
                ]),
          );
        }
      );
  }
}

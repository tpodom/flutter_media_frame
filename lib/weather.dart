import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mediaframe/settings_model.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';

class Weather extends StatefulWidget {
  @override
  State createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Position _position;
  Map<String, dynamic> _weatherData;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    this._loadWeather();
    this._timer = Timer.periodic(Duration(minutes: 30), (timer) => this._loadWeather());
  }

  @override
  void dispose() {
    this._timer?.cancel();
    super.dispose();
  }

  _loadPosition() async {
    if (this._position == null) {
      this._position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
  }

  _loadWeather() async {
    await this._loadPosition();
    var apiKey = Provider.of<SettingsModel>(context, listen: false).weatherAPIKey;
    String url =
        'http://api.openweathermap.org/data/2.5/onecall?lat=${this._position.latitude}&lon=${this._position.longitude}&appid=$apiKey&units=imperial';

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      this._weatherData = json.decode(response.body);
    }
  }

  get currentTemp {
    if (this._weatherData != null) {
      return this._weatherData['current']['temp'];
    }
    return null;
  }

  get dayHigh {
    if (this._weatherData != null) {
      return this._weatherData['daily'][0]['temp']['max'];
    }
    return null;
  }

  get dayLow {
    if (this._weatherData != null) {
      return this._weatherData['daily'][0]['temp']['min'];
    }
    return null;
  }

  get sunrise {
    if (this._weatherData != null) {
      return DateTime.fromMillisecondsSinceEpoch(
              this._weatherData['current']['sunrise'] * 1000,
              isUtc: true)
          .toLocal();
    }
    return null;
  }

  get sunset {
    if (this._weatherData != null) {
      return DateTime.fromMillisecondsSinceEpoch(
              this._weatherData['current']['sunset'] * 1000,
              isUtc: true)
          .toLocal();
    }
    return null;
  }

  get isNight {
    if (this._weatherData != null) {
      var now = DateTime.now();
      return now.isBefore(this.sunrise) || now.isAfter(this.sunset);
    }
    return null;
  }

  get icon {
    if (this._weatherData != null) {
      var weatherId = this._weatherData['current']['weather'][0]['id'];
      var night = this.isNight;

      if (weatherId >= 200 && weatherId < 300) {
        return night
            ? WeatherIcons.night_thunderstorm
            : WeatherIcons.day_thunderstorm;
      } else if (weatherId >= 300 && weatherId < 400) {
        return night ? WeatherIcons.night_sprinkle : WeatherIcons.day_sprinkle;
      } else if (weatherId >= 500 && weatherId < 600) {
        return night ? WeatherIcons.night_rain : WeatherIcons.day_rain;
      } else if (weatherId >= 600 && weatherId < 700) {
        return night ? WeatherIcons.night_snow : WeatherIcons.day_snow;
      } else if (weatherId >= 700 && weatherId < 800) {
        switch (weatherId) {
          case 701:
            return night
                ? WeatherIcons.night_sprinkle
                : WeatherIcons.day_sprinkle;
          case 711:
            return WeatherIcons.smoke;
          case 721:
            return WeatherIcons.day_haze;
          case 731:
            return WeatherIcons.dust;
          case 741:
            return night ? WeatherIcons.night_fog : WeatherIcons.day_fog;
          case 751:
            return WeatherIcons.sandstorm;
          case 761:
            return WeatherIcons.dust;
          case 762:
            return WeatherIcons.volcano;
          case 771:
            return WeatherIcons.strong_wind;
          case 781:
            return WeatherIcons.tornado;
          default:
            return WeatherIcons.fog;
        }
      } else if (weatherId == 800) {
        return night ? WeatherIcons.night_clear : WeatherIcons.day_sunny;
      }
      return night ? WeatherIcons.night_cloudy : WeatherIcons.day_cloudy;
    }
    return null;
  }

  _formatTemp(temp) {
    return temp != null ? "${temp.toStringAsFixed(0)}°" : "--";
  }

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
        fontSize: 50, fontWeight: FontWeight.w100, color: Colors.white);

    if (this._weatherData == null) {
      return Text("--", style: style);
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text("")),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(this._formatTemp(this.currentTemp), style: TextStyle(
                          fontSize: 48, fontWeight: FontWeight.w100, color: Colors.white)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("↑${this._formatTemp(this.dayHigh)}",
                                style: TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w100, color: Colors.white)),
                            Text("↓${this._formatTemp(this.dayLow)}",
                                style: TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w100, color: Colors.white)),
                          ])
                    ]),
                BoxedIcon(this.icon, color: Colors.white, size: 50)
              ])
        ]);
  }
}

import 'package:flutter/material.dart';
import 'package:mediaframe/assets.dart';
import 'package:mediaframe/night_mode_settings.dart';
import 'package:mediaframe/settings_model.dart';
import 'package:mediaframe/unlock_settings.dart';
import 'package:mediaframe/weather_settings.dart';
import 'package:provider/provider.dart';

class SettingsRoute extends StatelessWidget {
  Widget createSectionTitle(context, title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Consumer<SettingsModel>(builder: (BuildContext context, SettingsModel model, Widget child) {
          return ListView(children: [
            createSectionTitle(context, 'Slideshow Settings'),
            ListTile(
                title: Text('Media selection'),
                trailing: IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AssetsRoute()),
                    );
                  },
                )),
            Divider(),
            ListTile(
                title: Text('Unlock settings'),
                subtitle: model.useUnlockCode ? Text('Unlock code enabled.') : Text('Unlock code disabled.'),
                trailing: IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UnlockSettingsRoute()),
                    );
                  },
                )),
            Divider(),
            ListTile(
              title: Text('Media volume'),
              subtitle: Slider(
                  value: model.volume,
                  onChanged: (newValue) {
                    model.volume = newValue;
                  }),
            ),
            Divider(),
            ListTile(
              title: Text('Slide delay'),
              subtitle: Slider(
                  value: model.slideDelaySeconds.toDouble(),
                  min: 5.0,
                  max: 60.0,
                  divisions: 11,
                  label: 'Display each slide for ${model.slideDelaySeconds} seconds',
                  onChanged: (newValue) {
                    model.slideDelaySeconds = newValue.round();
                  }),
            ),
            Divider(),
            ListTile(
              title: Text('Clock transition delay'),
              subtitle: Slider(
                  value: model.clockDelayMinutes.toDouble(),
                  min: 5.0,
                  max: 60.0,
                  divisions: 11,
                  label: 'Display the clock every ${model.clockDelayMinutes} minutes for ${model.clockDelayMinutes} minutes',
                  onChanged: (newValue) {
                    model.clockDelayMinutes = newValue.round();
                  }),
            ),
            Divider(),
            createSectionTitle(context, 'Clock Settings'),
            SwitchListTile(
              title: Text('24 hour mode'),
              subtitle: model.use24HourTime ? Text('Display the time using a 24-hour clock.') : Text('Display the time with a 12 hour clock with AM/PM.'),
              value: model.use24HourTime,
              onChanged: (newValue) {
                model.use24HourTime = newValue;
              },
            ),
            Divider(),
            ListTile(
                title: Text('Weather display'),
                subtitle: model.enableWeather ? Text('Display the current weather for your location.') : Text('Do not display the current weather.'),
                trailing: IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WeatherSettingsRoute()),
                    );
                  },
                )),
            Divider(),
            ListTile(
                title: Text('Night mode'),
                subtitle: model.enableNightMode ? Text('Switch to clock display during the night.') : Text('Continue displaying slides at night.'),
                trailing: IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NightModeSettingsRoute()),
                    );
                  },
                )),
          ]);
        }));
  }
}



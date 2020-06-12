import 'package:flutter/material.dart';
import 'package:mediaframe/settings_model.dart';
import 'package:provider/provider.dart';

class NightModeSettingsRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Night Mode Settings')),
        body: Consumer<SettingsModel>(builder: (BuildContext context, SettingsModel model, Widget child) {
          final MaterialLocalizations localizations = MaterialLocalizations.of(context);
          var formattedNightStart = localizations.formatTimeOfDay(
            model.nightStart,
            alwaysUse24HourFormat: model.use24HourTime,
          );
          var formattedNightEnd = localizations.formatTimeOfDay(
            model.nightEnd,
            alwaysUse24HourFormat: model.use24HourTime,
          );

          return ListView(children: [
            SwitchListTile(
              title: Text('Night mode'),
              subtitle: model.enableNightMode ? Text('Switch to clock display during the night.') : Text('Continue displaying slides at night.'),
              value: model.enableNightMode,
              onChanged: (newValue) {
                model.enableNightMode = newValue;
              },
            ),
            Divider(),
            ListTile(
              title: Text('Night start time'),
              subtitle: Text('Night mode will start at $formattedNightStart'),
              enabled: model.enableNightMode,
              onTap: () async {
                TimeOfDay start = await showTimePicker(
                  context: context,
                  initialTime: model.nightStart,
                  builder: (BuildContext context, Widget child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: model.use24HourTime),
                      child: child,
                    );
                  },
                );

                if (start != null) {
                  model.nightStart = start;
                }
              },
            ),
            Divider(),
            ListTile(
              title: Text('Night end time'),
              subtitle: Text('Night mode will end at $formattedNightEnd'),
              enabled: model.enableNightMode,
              onTap: () async {
                TimeOfDay end = await showTimePicker(
                  context: context,
                  initialTime: model.nightEnd,
                  builder: (BuildContext context, Widget child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: model.use24HourTime),
                      child: child,
                    );
                  },
                );

                if (end != null) {
                  model.nightEnd = end;
                }
              },
            ),
          ]);
        }));
  }
}

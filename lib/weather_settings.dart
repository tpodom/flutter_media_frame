import 'package:flutter/material.dart';
import 'package:mediaframe/settings_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class WeatherSettingsRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Weather Settings')),
        body: Consumer<SettingsModel>(builder: (BuildContext context, SettingsModel model, Widget child) {
          return Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(children: [
                Text(
                    'OpenWeatherMap.org is used to retrieve current and forecast weather data.  Usage of this free weather service requires a registered API key.'),
                Expanded(
                    flex: 1,
                    child: ListView(children: [
                      SwitchListTile(
                        title: Text('Display weather'),
                        subtitle: model.enableWeather
                            ? Text('Display weather for your current location on the clock screen')
                            : Text('Weather will not be displayed on the clock screen.'),
                        value: model.enableWeather,
                        onChanged: (newValue) async {
                          await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                          model.enableWeather = newValue;
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('OpenWeatherMap API Key'),
                        subtitle: model.weatherAPIKey != null && model.weatherAPIKey.isNotEmpty ? Text(model.weatherAPIKey) : Text('API key is not set'),
                        enabled: model.enableWeather,
                        trailing: FlatButton(
                          child: Text('CHANGE'),
                          onPressed: !model.enableWeather
                              ? null
                              : () async {
                            var result = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  return _WeatherAPIKeyInputDialog();
                                });
                            if (result != null) {
                              model.weatherAPIKey = result;
                            }
                          },
                        ),
                      ),
                    ]))
              ]));
        }));
  }
}

class _WeatherAPIKeyInputDialog extends StatefulWidget {
  _WeatherAPIKeyInputState createState() => _WeatherAPIKeyInputState();
}

class _WeatherAPIKeyInputState extends State<_WeatherAPIKeyInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: EdgeInsets.all(8),
        content: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextFormField(
                controller: textController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'OpenWeatherMap API key',
                ),
              ),
            ])),
        actions: [
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('SAVE'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Navigator.pop(context, textController.text);
                }
              })
        ]);
  }
}

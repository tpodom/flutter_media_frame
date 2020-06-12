import 'package:flutter/material.dart';
import 'package:mediaframe/settings_model.dart';
import 'package:provider/provider.dart';

class UnlockSettingsRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Unlock Settings')),
        body: Consumer<SettingsModel>(builder: (BuildContext context, SettingsModel model, Widget child) {
          return ListView(children: [
            SwitchListTile(
              title: Text('Use unlock code'),
              subtitle: model.useUnlockCode
                  ? Text('Unlocking the clock and changing settings requires a code.')
                  : Text('Unlocking the clock and changing settings does not require a code.'),
              value: model.useUnlockCode,
              onChanged: (newValue) async {
                model.useUnlockCode = newValue;
              },
            ),
            Divider(),
            ListTile(
              title: Text('Unlock code'),
              subtitle: model.unlockCode != null && model.unlockCode.isNotEmpty ? Text('Unlock code is set.') : Text('Unlock code is not set'),
              enabled: model.useUnlockCode,
              trailing: FlatButton(
                child: Text('CHANGE'),
                onPressed: !model.useUnlockCode
                    ? null
                    : () async {
                  var result = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return _UnlockCodeInputDialog();
                      });
                  if (result != null) {
                    model.unlockCode = result;
                  }
                },
              ),
            ),
          ]);
        }));
  }
}

class _UnlockCodeInputDialog extends StatefulWidget {
  _UnlockCodeInputState createState() => _UnlockCodeInputState();
}

class _UnlockCodeInputState extends State<_UnlockCodeInputDialog> {
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final unlockController = TextEditingController();

  @override
  void dispose() {
    unlockController.dispose();
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
                maxLength: 6,
                maxLengthEnforced: true,
                controller: unlockController,
                keyboardType: TextInputType.number,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Unlock Code',
                  hintText: 'Enter a new unlock code',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
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
                  Navigator.pop(context, unlockController.text);
                }
              })
        ]);
  }
}

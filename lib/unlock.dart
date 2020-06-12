import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mediaframe/settings_model.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:provider/provider.dart';

class UnlockRoute extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const UnlockRoute({Key key, this.onSuccess, this.onCancel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UnlockState();
}

class _UnlockState extends State<UnlockRoute> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  _UnlockState();

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = Provider.of<SettingsModel>(context, listen: false).unlockCode == enteredPasscode;
    _verificationNotifier.add(isValid);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 450),
            child: PasscodeScreen(
              title: Text(
                'Enter Unlock Code',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 45),
              ),
              cancelButton: Text(
                'Cancel',
                style: const TextStyle(fontSize: 16, color: Colors.white),
                semanticsLabel: 'Cancel',
              ),
              passwordEnteredCallback: _onPasscodeEntered,
              passwordDigits: 4,
              deleteButton: Text(
                'Delete',
                style: const TextStyle(fontSize: 16, color: Colors.white),
                semanticsLabel: 'Delete',
              ),
              shouldTriggerVerification: _verificationNotifier.stream,
              backgroundColor: Colors.black.withOpacity(0.8),
              isValidCallback: () {
                this.widget.onSuccess();
              },
              cancelCallback: () {
                this.widget.onCancel();
                Navigator.maybePop(context);
              },
            )));
  }
}

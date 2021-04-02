import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/providers/firebase_auth_provider.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({@required this.popPage}) : assert(popPage != null);
  final Function popPage;
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void Function() logout;
  @override
  void initState() {
    super.initState();

    logout = context.read(firebaseAuthController).logout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Text(
                  "Settings",
                  textScaleFactor: 2.0,
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      logout();
                      widget.popPage();
                    },
                    child: Text("Logout"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    splashRadius: Material.defaultSplashRadius - 10.0,
                    icon: Icon(Icons.chevron_left_rounded),
                    iconSize: 35,
                    onPressed: () {
                      widget.popPage();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

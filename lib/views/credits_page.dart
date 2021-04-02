import 'package:flutter/material.dart';

class CreditsPage extends StatefulWidget {
  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Hero(
                    tag: "Credits_WAND_logo",
                    child: Image.asset(
                      "assets/credits.png",
                      width: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.width / 2
                          : null,
                      height: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? MediaQuery.of(context).size.height / 6
                          : null,
                      // cacheHeight: 50,
                    ),
                  ),
                  Text(
                    "We Ain't No Designers Team",
                    textScaleFactor: 1.2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Credits",
                    textScaleFactor: 2.0,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'App Creator',
                    textScaleFactor: 1,
                  ),
                  Text(
                    'Tobiasz Pokorniecki',
                    textScaleFactor: 1.5,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Backend and Firebase Maintainer',
                    textScaleFactor: 1,
                  ),
                  Text(
                    'Przemysław Dobrzyński',
                    textScaleFactor: 1.5,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  splashRadius: Material.defaultSplashRadius - 10.0,
                  icon: Icon(Icons.chevron_left_rounded),
                  iconSize: 35,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

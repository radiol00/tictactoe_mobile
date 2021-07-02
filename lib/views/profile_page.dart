import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/services/wand_firebase_connection.dart';
import 'package:wand_tictactoe/widgets/wand_progress_indicator.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({this.userId});
  final String userId;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Stream profile;
  @override
  void initState() {
    super.initState();
    profile = Stream.fromFuture(
      context.read(wandFirebaseConnection).getPlayerDoc(widget.userId),
    );
  }

  List<Widget> _buildHistoryList(List history) {
    List<Widget> widgetList = [];

    for (int i = 0; i < history.length; i++) {
      var h = history[i];
      widgetList.add(
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          userId: h["enemyID"],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: 24.0,
                        ),
                        Text(
                          "${h["enemy"]}",
                          textScaleFactor: 1.2,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(h['result'] == 1
                          ? "Win"
                          : h['result'] == 2
                              ? "Lose"
                              : "Draw"),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      );
      widgetList.add(
        Divider(
          thickness: 1.0,
          color: Colors.grey[400],
          height: 0.0,
        ),
      );
    }

    return widgetList.sublist(0, widgetList.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: StreamBuilder(
          stream: profile,
          builder: (context, snapshot) {
            Widget child = Center(
              child: WANDProgressIndicator(
                type: WANDProgressIndicatorType.fullscreen,
              ),
            );

            if (snapshot.hasError)
              child = Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Column(
                    children: [
                      Icon(
                        Icons.error,
                        size: 40.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "No such player",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      right: 8.0,
                    ),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            splashRadius: 15.0,
                            icon: Icon(Icons.chevron_left_rounded, size: 35.0),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            else if (snapshot.hasData) {
              String displayName = snapshot.data["displayName"];
              int wins = snapshot.data["wins"];
              int draws = snapshot.data["draws"];
              int loses = snapshot.data["loses"];
              int maxWinStreak = snapshot.data["maxWinStreak"];
              int currentWinStreak = snapshot.data["currentWinStreak"];
              List<dynamic> history;
              try {
                history = snapshot.data["history"];
              } catch (e) {
                history = [];
              }
              child = Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Material(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.white,
                        elevation: 10.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$displayName",
                                textScaleFactor: 2.0,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                "$wins - $draws - $loses",
                                textScaleFactor: 2.0,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                wins == 0 && draws == 0 && loses == 0
                                    ? "Win rate: 0.0%"
                                    : "Win rate: ${(((wins + 0.5 * draws) / (wins + draws + loses)) * 100).roundToDouble()}%",
                                textScaleFactor: 1.2,
                              ),
                              Text(
                                "Highest win streak: $maxWinStreak",
                                textScaleFactor: 1.2,
                              ),
                              Text(
                                "Current win streak: $currentWinStreak",
                                textScaleFactor: 1.2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: history.length == 0
                        ? Center(
                            child: Text(
                              "No game history",
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              NotificationListener<
                                  OverscrollIndicatorNotification>(
                                onNotification: (notification) {
                                  notification.disallowGlow();
                                  return false;
                                },
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 32.0,
                                        right: 32.0,
                                        bottom: 32.0,
                                        top: 32.0),
                                    child: Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Column(
                                        children: _buildHistoryList(history),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: 32.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.grey[300],
                                          Colors.grey[300].withOpacity(0.0),
                                        ]),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.grey[300],
                                          Colors.grey[300].withOpacity(0.0),
                                        ]),
                                  ),
                                ),
                              )
                            ],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      right: 8.0,
                    ),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            splashRadius: 15.0,
                            icon: Icon(Icons.chevron_left_rounded, size: 35.0),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return AnimatedSwitcher(
              switchInCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  child: child,
                  opacity: animation,
                );
              },
              duration: Duration(milliseconds: 500),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

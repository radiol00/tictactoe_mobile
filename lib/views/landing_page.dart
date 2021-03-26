import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wand_tictactoe/providers/landing_page_visibility_provider.dart';
import 'package:wand_tictactoe/views/auth_page.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  PageController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: [
          IntroductionScreen(
            pages: [
              PageViewModel(
                title: "",
                body: "",
                image: Image.asset("assets/title_screen.png"),
                decoration: PageDecoration(imageFlex: 10),
              ),
              PageViewModel(
                title: "Dominate your enemies!",
                body: "",
                image: Placeholder(),
                decoration: PageDecoration(imageFlex: 2),
              ),
              PageViewModel(
                title: "Have great fun with your friends!",
                body: "",
                image: Placeholder(),
                decoration: PageDecoration(imageFlex: 2),
              ),
              PageViewModel(
                image: Placeholder(),
                title: "Are you ready?",
                body: "",
                decoration: PageDecoration(imageFlex: 2),
              ),
            ],
            dotsDecorator: DotsDecorator(
              size: Size(15.0, 20.0),
              spacing: EdgeInsets.all(2.0),
              activeColor: Theme.of(context).primaryColor,
              activeSize: Size(15.0, 20.0),
              activeShape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            showSkipButton: false,
            onDone: () {
              context.read(landingPageVisibilityController).seen();
              _controller.animateToPage(1,
                  duration: Duration(seconds: 1), curve: Curves.easeInOut);
            },
            skip: Text("Skip"),
            next: Text("Next"),
            done: Text("Create an account"),
            animationDuration: 1000,
            skipFlex: 0,
            nextFlex: 2,
            dotsFlex: 2,
            curve: Curves.easeInOut,
            freeze: true,
          ),
          AuthPage(
            initialMode: AuthPageMode.signin,
          ),
        ],
      ),
    );
  }
}

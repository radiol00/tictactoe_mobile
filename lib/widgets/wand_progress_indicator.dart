import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum WANDProgressIndicatorType { fullscreen, minimal }

class WANDProgressIndicator extends StatelessWidget {
  WANDProgressIndicator({
    this.size = 70,
    @required this.type,
  }) : assert(type != null);
  final double size;
  final WANDProgressIndicatorType type;
  @override
  Widget build(BuildContext context) {
    switch (type) {
      case WANDProgressIndicatorType.fullscreen:
        return SpinKitCubeGrid(
          duration: Duration(milliseconds: 500),
          size: size,
          itemBuilder: (context, index) {
            Icon icon;
            if ([0, 2, 3, 5, 7].contains(index))
              icon = Icon(
                Icons.panorama_fish_eye,
                size: size / 3,
              );
            else
              icon = Icon(
                Icons.close,
                size: size / 3,
              );
            return Container(
              child: Center(child: icon),
              decoration: BoxDecoration(
                border: (index == 1 || index == 7)
                    ? Border.symmetric(
                        vertical: BorderSide(color: Colors.black),
                      )
                    : (index == 3 || index == 5)
                        ? Border.symmetric(
                            horizontal: BorderSide(color: Colors.black),
                          )
                        : (index == 4)
                            ? Border.all(color: Colors.black)
                            : null,
              ),
            );
          },
        );
      case WANDProgressIndicatorType.minimal:
        return Stack(
          alignment: Alignment.center,
          children: [
            SpinKitRipple(
              duration: Duration(milliseconds: 2000),
              color: Colors.black,
              size: size,
            ),
            SpinKitRotatingPlain(
              duration: Duration(milliseconds: 2000),
              size: size / 2,
              itemBuilder: (context, index) {
                return Container(
                  child: Center(
                    child: Icon(Icons.close),
                  ),
                );
              },
            ),
          ],
        );
      default:
        return Container();
    }
  }
}

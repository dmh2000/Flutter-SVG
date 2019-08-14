import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as flutter_svg;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'flutter_svg Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// because there are a lot of parameters, an object is used
// instead of a long list of arguments to the function
class SvgParams {
  double groupAngle = 0.0;
  double a1 = 0.0;
  double x1 = 17.0;
  double y1 = 18.0;
  double x2 = 17.0;
  double y2 = 21.0;
  double a3 = 0.0;
  double x3 = 20.0;
  double y3 = 21.0;
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  SvgParams svg = SvgParams();
  String rawSvg;
  Animation<double> animation;
  AnimationController controller;

  // use a function to update the 'rawSvg' string that is used to generate the picture
  void setSvg(SvgParams p) {
    rawSvg = '''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" width="200" height="200" version="1.1" viewBox="0 0 50 50">
   <rect width="50" height="50" x="0" y="0" fill="#ffffff"/>
      <g transform="rotate(${p.groupAngle},25,25)">
         <rect width="15" height="4" x="${p.x1}" y="${p.y1}" style="fill:#ff0000;stroke-width:0.2" transform="translate(0,0)"/>
         <rect width="3"  height="9" x="${p.x2}" y="${p.y2}" style="fill:#00ff00;stroke-width:0.2" transform="translate(0,0)"/>
         <rect width="12" height="9" x="${p.x3}" y="${p.y3}" style="fill:#000080;stroke-width:0.2" transform="rotate(${p.a3},${p.x3 + 5},${p.y3 + 5})"/>
      </g>
</svg>
        ''';
  }

  @override
  initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeOut)
      ..addListener(
        () {
          setState(
            () {
              // set all the parameters as needed for the desired affects

              // the group is rotated 360 degrees and back
              svg.groupAngle =
                  animation.value * 360.0; // rotate in a complete circle

              // each rect is moved independently
              svg.x1 = 17.0 + animation.value * 5.0; // move in x direction
              svg.y1 = 18.0 - animation.value * 5.0; // move in y direction

              svg.x2 = 17.0 - animation.value * 8; // move in x direction
              svg.y2 = 21.0 + animation.value * 8; // move in y direction

              // the blue square rotates indpendently within the group
              svg.a3 = animation.value * 180.0; // rotate a half circle
              svg.x3 = 20.0 - animation.value * 4; // move in x direction
              svg.y3 = 21.0 + animation.value * 4; // move in y direction

              // update the SVG document
              setSvg(svg);
            },
          );
        },
      )
      ..addStatusListener((status) {
        // go back and forth
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    // initialize rawSvg with the initial values before the animation is started
    setSvg(svg);
  }

  void _startAnimation() {
    // start the animation running
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    //

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            // expand in horizontal direction
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // expand in vertical direction
              Expanded(
                child: Container(
                  // the container is grey
                  color: Colors.grey,
                  // the picture has a white background with colored rectangles in it
                  child: flutter_svg.SvgPicture.string(rawSvg),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _startAnimation,
          tooltip: 'Start',
          //child: Icon(Icons.add),
          label: Text("Start Animation"),
        ));
  }
}

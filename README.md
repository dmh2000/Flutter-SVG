# svg_example

An example of using a parameterized SVG drawing to create an animation in Flutter.

It is possible to use the flutter_svg package to render an SVG drawing that is parameterized to vary according to an Animation. This may just be a curiosity and it may be more complicated than doing conventional Flutter animations It looks to me that if you need some interrelated shapes that are moving around in a fixed coordinate system, it may be easier than drawing rects and circles and such. It results in a more declarative approach to drawing than using code to draw objects on a canvas.

## SVG

SVG is the abbreviation for Scalable Vector Graphics which is a standard for creating
vector drawings in an XML format. Here is a good place to read about it [SVG](https://developer.mozilla.org/en-US/docs/Web/SVG);
For the purposes of this example, SVG is convenient for specifying a set of shapes that can then be parameterized and animated.

For example, here is the SVG document for a simple drawing with 3 rectangles:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" width="200" height="200" version="1.1" viewBox="0 0 50 50">
   <rect width="50" height="50" x="0" y="0" fill="#cccccc"/>
    <g transform="rotate(10,25,25)">
        <rect width="15" height="4" x="17" y="18" style="fill:#ff0000;stroke-width:0.2" />
        <rect width="3"  height="9" x="17" y="21" style="fill:#00ff00;stroke-width:0.2" />
        <rect width="12" height="9" x="20" y="21" style="fill:#000080;stroke-width:0.2" />
    </g>
</svg>
```

An SVG drawing can get pretty complicated and its a subject all its own. It is beyond the scope of this article
to explain all about it. Here is a brief description of the elements in the above xml:
  - ?xml : doctype spec
  - svg tag : main body of svg description
    - xmlns : required xml namespace specs
    - width/height : the size of the drawing in host dimensions (in this case, the containing Widget). this will create a 200x200 pixel square that will hold the SVG drawing.
    - viewbox : specifies the coordinates used in the drawing itself. Within the drawing, these are the dimensions that are used to specify the objects.
  - rect : a specification of a rectangle
    - width/height : in viewBox coordinates
    - x/y : in viewbox coordinates
  - g : encloses a group so that attributes of the group are applied to all children
    - transform : specifies a coordinate transform. can be a combination of rotation, translation, scale and skew. in addition if you are an expert, you can use matrices for transforms. 

A few other notes:
  - the objects are drawn in the order they appear
  - coordinates are 0,0 is upper left, x is left to right, y is top to bottom
  - a vector drawing doesn't pixelate when zoomed. its valuable when sizing is variable


So the gist is that using an SVG document as a starting point to define coordinate systems and the objects within them
might be easier than doing it programmatically in Flutter. And once the objects are specified, they are basically independent
and can have transforms applied to them individually or as a group to create an animation. 

### Creating an SVG drawing

Once you get the hang of the SVG syntax, it is pretty easy to write it all up by hand. You could also use an SVG editor 
such as SVG-Edit (browser based) or Inkscape (a vector drawing app) to create a drawing using their respective GUI and then
import the document string into the Flutter app.

## flutter_svg

The [flutter_svg](https://pub.dev/packages/flutter_svg) package, created by Dan Field, provides support to use SVG drawing as assets in an app. That
is probably the main usage of this package. However, it also has support for dynamically creating SVG images by creating
a Picture widget from a string containing an SVG document. That is the capability used in the example code. 

```dart
import 'package:flutter_svg/flutter_svg.dart' as flutter_svg;

// ... the string containing an svg document
final String rawSvg = '''<svg viewBox="...">...</svg>''';

// use the flutter_svg function SVgPicture to render it as an image
    ...
    Container(
        child: flutter_svg.SvgPicture.string(rawSvg),
        ...
    }
    ...

```

### Parameterizing the SVG Drawing

With the method above for creating the SVG Picture, it becomes easy to parameterize the SVG document
using Dart string interpolation. For example, the group of rectangles can be rotated together
by updating the angle and origin using string interpolation. Then all that is required is to redraw
the widget;

```dart
double angle = 10.0;
double x = 25.0;
double y = 25.0;
String doc = '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" width="200" height="200" version="1.1" viewBox="0 0 50 50">
   <rect width="50" height="50" x="0" y="0" fill="#cccccc"/>
    <g transform="rotate($angle,$x,$y)">
        <rect width="15" height="4" x="17" y="18" style="fill:#ff0000;stroke-width:0.2" />
        <rect width="3"  height="9" x="17" y="21" style="fill:#00ff00;stroke-width:0.2" />
        <rect width="12" height="9" x="20" y="21" style="fill:#000080;stroke-width:0.2" />
    </g>
</svg>'''
```

In addition, each of the inner rectangles could have individual transforms applied to them as well.


### Animating the SVG Drawing

The parameterized SVG document is animated using the normal Flutter animation techniques. You could do something 
like this for the above SVG text, using a StatefulWidget

```dart

String rawSvg;

// call in initState to update
void updateSvg(angle,x,y) {
    // update the rawSvg Variable
    rawSvg = '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" width="200" height="200" version="1.1" viewBox="0 0 50 50">
        <rect width="50" height="50" x="0" y="0" fill="#cccccc"/>
            <g transform="rotate($angle,$x,$y)">
                <rect width="15" height="4" x="17" y="18" style="fill:#ff0000;stroke-width:0.2" />
                <rect width="3"  height="9" x="17" y="21" style="fill:#00ff00;stroke-width:0.2" />
                <rect width="12" height="9" x="20" y="21" style="fill:#000080;stroke-width:0.2" />
            </g>
        </svg>''';
}

// somewhere in the stateful widget, probably initState but could be anywhere in the program logic
AnimationController controller =  AnimationController(duration: const Duration(seconds: 2), vsync: this);

// use whatever animation is descired
Animation  animation = CurvedAnimation(parent: controller, curve: Curves.easeOut)
      ..addListener(
        () {
          setState(
            () {
              // set all the parameters as needed for the desired affect
              double angle = animation.value * 360.0; // rotate in a complete circle
              double x = 17.0 + animation.value * 5.0; // move in x direction
              double y = 18.0 - animation.value * 5.0; // move in y direction
              updateSvg(angle,x,y)
            },
          );
        },
      );
      // start the animation
      controller.forward();

    // ...

    // use the resulting svg to create a picture,
    // somewhere in the widget tree, which is redrawn due to the setState call in the animation listener
    Container(
        child: flutter_svg.SvgPicture(rawSvg),
        ...
    }
```

## Working Example

Load and run the working example in the svg_example directory.

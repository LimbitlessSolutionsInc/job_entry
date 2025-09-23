import 'package:flutter/material.dart';
import 'dart:math';
import 'package:css/css.dart';
import '../src/time/time.dart';

class Circle{
  Circle({
    required this.paths,
    required this.widget
  });

  List<Path> paths;
  Widget widget;
}

class TimeTracking{
  static double sweepConversion({bool isInMinutes = true, required dynamic times}){
    if(isInMinutes){
      return -0.226*(times)+311;
    }
    else{
      return -0.226*(Time.convertTimeToMinutes(times))+311;
    }
  }
  static Widget labels({
    bool visible = true, 
    required BuildContext context,
    EdgeInsets margin = const EdgeInsets.all(5),
    Function()? onTap,
    required Widget child,
    bool show = true,
    required double height,
    required double width
  }){
    return (show)?Align(  
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(2),
          margin: margin,
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(
              width: 1,
              color: (visible)?Theme.of(context).secondaryHeaderColor:(Theme.of(context).brightness == Brightness.dark)?lightGrey:darkGrey
            ),
            color: (visible)?const Color(0x99000000):Colors.transparent,//Theme.of(context).cardColor,
          ),
          child: child,
        )
      )
    ):Container();
  }

  static Circle hover({
    Color color = lightGrey, 
    required double width, 
    double spacing = 0.1,
    int incriments = 1,
    double percentage = 1, 
    required double deg, 
    required double sweep,
    required double size,
    Alignment alignment = Alignment.topRight,
    Offset? offset,
  }){
    offset = offset ?? Offset(-(size/2.8)/2,(size/2.8)/2);

    OpenPainter cc = OpenPainter(
      color: color,
      innerRadius: width,
      outerRadius: width/(1+spacing),
      total: incriments,
      useStroke: (incriments == 1)?false:true,
      percentage: percentage,
      startAngle: deg,
      sweepAngle: sweep,
      setOffset: offset,
    );

    return Circle(
      paths: cc.paths,
      widget: ClipRect(
        child: Align(
          alignment: alignment,
          child:Container(
            //color: Colors.red,
            width: size,
            height: size,
            alignment: alignment,
            child: CustomPaint(
              painter: cc,
            ),
          )
        )
      )
    );
  }

  static Widget timeCircles({
    Color color = lightGrey, 
    required double width, 
    double spacing = 0.1,
    int incriments = 1,
    double percentage = 1, 
    required double deg, 
    required double sweep,
    required double size,
    Alignment alignment = Alignment.topRight,
    Offset? offset,
  }){
    offset = offset ?? Offset(-(size/2.8)/2,(size/2.8)/2);

    return ClipRect(
      child: Align(
        alignment: alignment,
        child:Container(
          //color: Colors.red,
          width: size,
          height: size,
          alignment: alignment,
          child: CustomPaint(
            painter: OpenPainter(
              color: color,
              innerRadius: width,
              outerRadius: width/(1+spacing),
              total: incriments,
              useStroke: (incriments == 1)?false:true,
              percentage: percentage,
              startAngle: deg,
              sweepAngle: sweep,
              setOffset: offset,
            ),
          ),
        )
      )
    );
  }

  static Widget textLocation({
    required EdgeInsets margin, 
    required String title,
    String fontFamily = 'Klavika',
    Color fontColor = Colors.black,
    double  fontSize = 16
  }){
    
    // if(title){
    //   fontFamily = 'Klavika Bold';
    //   fontColor = darkGrey;
    // }

    return Align(
      alignment: Alignment.topRight,
      child: 
      Container(
        margin: margin,
        child:Text(
          title,
          style: TextStyle(
            color: fontColor,
            fontFamily: fontFamily,
            package: fontFamily.contains('Klavika') || fontFamily.contains('Museo')?'css':null,
            fontSize: fontSize
          ),
        ),
      )
    );
  }
}

class OpenPainter extends CustomPainter {
  OpenPainter({
    this.color = lightBlue, 
    required this.innerRadius, 
    required this.outerRadius, 
    this.total = 1, 
    this.useStroke = false,
    this.percentage = 1,
    this.startAngle = 270,
    this.sweepAngle = 359.9,
    this.setOffset = const Offset(0,0),
    this.clockwise = false
  });
  
  //Color color;
  double innerRadius;
  double outerRadius;
  Color color;
  int total;
  bool useStroke;
  bool clockwise;
  double percentage;
  double startAngle;
  double sweepAngle;
  Offset setOffset;
  List<Path> paths = [];//Path();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < total; i++) {
      paint.color = color;
      if(useStroke){
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 4;
      }
      
      Path path = _getPath(size,i);
      paths.add(path);
      canvas.drawPath(
        path,
        paint
      );
    }
  }
  @override
  bool? hitTest(Offset position){
    bool didHit = false;
    for(int i = 0; i < paths.length;i++){
      bool checkHit = paths[i].contains(position);
      if(checkHit){
        didHit = checkHit;
      }
    }

    print(didHit);

    return didHit;
  }

  _getPath(Size size,int i){
    double rad = pi/180;
    double endSize = outerRadius-innerRadius;
    double angleSize = (sweepAngle/(total))*percentage;  

    double start = startAngle-(angleSize*i);
    double end = startAngle-(angleSize*(i+1));

    Offset offsetSet = setOffset;

    Path path = Path()
      ..arcTo(
        Rect.fromCircle(center: offsetSet, radius: outerRadius),
        (start)*rad,
        (end-start)*rad,
        true
      )
      ..relativeLineTo(-cos((end)*rad) * (outerRadius - innerRadius),
        -sin((end)*rad) * (outerRadius - innerRadius))
      ..arcTo(
        Rect.fromCircle(center: offsetSet, radius: innerRadius),
        (end)*rad,
        (start-end)*rad,
        false
      )
      ..close();
    if(percentage != 1){
      if(!clockwise){
        path.addArc(Rect.fromCircle(center: Offset(cos(start*rad) *(outerRadius-endSize/2),sin(start*rad) *(outerRadius-endSize/2)), radius: endSize/2),start*rad,pi);
        path.addArc(Rect.fromCircle(center: Offset(cos(end*rad) *(outerRadius-endSize/2),sin(end*rad) *(outerRadius-endSize/2)), radius: endSize/2),(end+180)*rad,pi);
      }
      else{
        path.addArc(Rect.fromCircle(center: Offset(cos(start*rad) *(outerRadius-endSize/2),sin(start*rad) *(outerRadius-endSize/2)), radius: endSize/2),-start*rad,pi);
        path.addArc(Rect.fromCircle(center: Offset(cos(end*rad) *(outerRadius-endSize/2),sin(end*rad) *(outerRadius-endSize/2)), radius: endSize/2),(end)*rad,pi);
      }
    }

    return path;
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {return false;}

}

class BarsPainter extends CustomPainter{
  BarsPainter({
    required this.barHeight,
    this.strokeWidth = 5,
    this.colors = const[Colors.red,Colors.grey],
    this.angle = 45
  });

  final double barHeight;
  final double strokeWidth;
  final List<Color> colors;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    List<Paint> paint = [];
    double rad = pi/180;
    int numOfBars = (size.width/strokeWidth).floor();

    double distance = 1/(sin(angle*pi/180));
    for(int i = 0; i < colors.length; i++){
      paint.add(Paint());
      paint[i].color = colors[i];
      paint[i].strokeWidth = strokeWidth;
      paint[i].isAntiAlias = true;
    }

    int k = 0;
    for(int j = 0; j < numOfBars; j++){
      if(j%2 == 0){
        k = 0;
      }
      else{
        k = 1;
      }
    
      Offset seperate = Offset(strokeWidth*j*distance,0);
      Offset newLine = Offset((barHeight+25)*cos(angle*rad),(barHeight+25)*sin(angle*rad)-5)+seperate;

      canvas.drawLine(const Offset(0,-5)+seperate,newLine, paint[k]);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate){
    return true;
  }
}
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:css/css.dart';

class Circle{
  Circle({
    required this.paths,
    required this.widget
  });

  List<Path> paths;
  Widget widget;
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
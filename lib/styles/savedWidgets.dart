import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'globals.dart';
import 'package:css/css.dart' as lsi;
import 'package:printing/printing.dart';
import 'circles.dart';

class FocusedInkWell extends StatefulWidget{
  const FocusedInkWell({
    Key? key,
    required this.child,
    this.debugLabel = 'InkWell',
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.bgColor = Colors.transparent,
    this.mouseCursor,
    this.hoverColor,
  }): super(key: key);

  final Widget child;
  final String debugLabel;
  final Function()? onTap;
  final Function()? onDoubleTap;
  final Function()? onLongPress;
  final Color bgColor;
  final MouseCursor? mouseCursor;
  final Color? hoverColor;

  @override
  State<FocusedInkWell> createState() => _FocusedInkWellState();
}

class _FocusedInkWellState extends State<FocusedInkWell> {
  bool isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState(){
    _focusNode = FocusNode(
      debugLabel: widget.debugLabel
    );
    _focusNode.addListener((){
      if(_focusNode.hasFocus){
        print('${widget.debugLabel} has focus');
        setState(() {
          isFocused = true;
        });
      }
      else{
        print('${widget.debugLabel} does not have focus');
        setState(() {
          isFocused = false;
        });
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusNode: _focusNode,
      mouseCursor: widget.mouseCursor,
      hoverColor: widget.hoverColor,
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isFocused?widget.bgColor: Colors.transparent,
          border: Border.all(
            color: isFocused?lightBlueBG:Colors.transparent,
            width: 2
          ),
          boxShadow: [BoxShadow(
            color: isFocused?lightBlue:Colors.transparent,
            blurRadius: 2,
            offset: const Offset(2,2)
          )]
        ),
        child: widget.child
      )
    );
  }
}

class FocusedDropDown extends StatefulWidget{
  const FocusedDropDown({
    Key? key,
    this.debugLabel = 'DropDown',
    required this.itemVal, 
    this.style = const TextStyle(
      color: lsi.darkGrey,
      fontFamily: 'Klavika',
      package: 'css',
      fontSize: 14
    ),
    required this.value,
    this.onchange,
    this.width = 80,
    this.height = 36,
    this.padding = const EdgeInsets.only(left:10),
    this.margin = const EdgeInsets.fromLTRB(0, 5, 0, 5),
    this.color = Colors.transparent,
    this.radius = 0,
    this.alignment = Alignment.center,
    this.border,
  }): super(key: key);

  final String debugLabel;
  final List<DropdownMenuItem<dynamic>> itemVal; 
  final TextStyle style;
  final dynamic value;
  final Function(dynamic)? onchange;
  final double width;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color color;
  final double radius;
  final Alignment alignment;
  final Border? border;

  @override
  State<FocusedDropDown> createState() => _FocusedDropDownState();
}

class _FocusedDropDownState extends State<FocusedDropDown> {
  bool isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState(){
    _focusNode = FocusNode(
      debugLabel: widget.debugLabel
    );
    _focusNode.addListener((){
      if(_focusNode.hasFocus){
        print('${widget.debugLabel} has focus');
        setState(() {
          isFocused = true;
        });
      }
      else{
        print('${widget.debugLabel} does not have focus');
        setState(() {
          isFocused = false;
        });
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      alignment: widget.alignment,
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
        border: isFocused?Border.all(color: lightBlueBG):widget.border,
        boxShadow: [BoxShadow(
          color: isFocused?lightBlue:Colors.transparent,
          blurRadius: 2,
          offset: const Offset(2,2)
        )]
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton <dynamic>(
          focusNode: _focusNode,
          dropdownColor: widget.color,
          isExpanded: true,
          items: widget.itemVal,
          value: widget.value,//ddInfo[i],
          isDense: true,
          focusColor: lsi.lightBlue,
          style: widget.style,
          onChanged: widget.onchange,
        ),
      ),
    );
  }
}

class FocusedMultiDropDown extends StatefulWidget{
  const FocusedMultiDropDown({
    Key? key,
    this.debugLabel = 'MultiDropDown',
    required this.itemVal,
    required this.selected,
    required this.onSelected,
    required this.controller,
    required this.onRemoved,
    this.selectionType = SelectionType.multi,
    this.style = const TextStyle(
      color: darkGrey,
      fontFamily: 'Klavika',
      package: 'css',
      fontSize: 14
    ),
    this.hint = 'Select ...',
    this.width = 80,
    this.height = 36,
    this.padding = const EdgeInsets.only(left:10),
    this.margin = const EdgeInsets.fromLTRB(0, 5, 0, 5),
    this.alignment = Alignment.center,
    this.border,
    this.color = Colors.transparent,
    this.searchColor,
    this.radius = 10,
    this.searchEnabled = false,
  }): super(key: key);

  final String debugLabel;
  final List<ValueItem<dynamic>> itemVal; 
  final List<ValueItem<dynamic>> selected;
  final Function(List<ValueItem<dynamic>>) onSelected;
  final MultiSelectController<dynamic> controller;
  final Function(int, ValueItem<dynamic>) onRemoved;
  final SelectionType selectionType;
  final TextStyle style;
  final String hint;
  final double width;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Alignment alignment;
  final Border? border;
  final Color color;
  final Color? searchColor;
  final double radius;
  final bool searchEnabled;

  @override
  State<FocusedMultiDropDown> createState() => _FocusedMultiDropDownState();
}

class _FocusedMultiDropDownState extends State<FocusedMultiDropDown> {
  bool isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState(){
    _focusNode = FocusNode(
      debugLabel: widget.debugLabel
    );
    _focusNode.addListener((){
      if(_focusNode.hasFocus){
        print('${widget.debugLabel} has focus');
        setState(() {
          isFocused = true;
        });
      }
      else{
        print('${widget.debugLabel} does not have focus');
        setState(() {
          isFocused = false;
        });
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.alignment,
      padding: widget.padding,
      margin: widget.margin,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
        border: isFocused?Border.all(color: lightBlueBG):widget.border,
        boxShadow: [BoxShadow(
          color: isFocused?lightBlue:Colors.transparent,
          blurRadius: 2,
          offset: const Offset(2,2)
        )]
      ),
      child: MultiSelectDropDown <dynamic>(
        focusNode: _focusNode,
        selectionType: widget.selectionType,
        controller: widget.controller,
        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
        onOptionSelected: widget.onSelected,
        onOptionRemoved: widget.onRemoved,
        options: widget.itemVal,
        selectedOptions: widget.selected,
        hint: widget.hint,
        hintStyle: widget.style,
        optionTextStyle: widget.style,
        selectedOptionBackgroundColor: widget.color,
        optionsBackgroundColor: widget.color,
        searchEnabled: widget.searchEnabled,
        fieldBackgroundColor: widget.color,
        dropdownBackgroundColor: widget.color,
        selectedOptionIcon: Icon(Icons.check, color: widget.style.color,),
        inputDecoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
          border: Border.all(
            width: 0, 
            style: BorderStyle.none,
          )
        )
      )
    );
  }
}

class LSISingleUserIcon extends StatelessWidget{
  const LSISingleUserIcon({
    Key? key,
    required this.uid, 
    required this.color,
    this.iconSize = 40,
    this.remove,
    required this.loc
  }):super(key: key);

  final String uid;
  final Color color;
  final int loc;
  final double iconSize;
  final Function(int loc)? remove;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
        (usersProfile != null && usersProfile[uid] != null)?Container(
          width: iconSize,
          height: iconSize,
          margin: const EdgeInsets.only(left:5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(40/2)),
            border: Border.all(color: color,width: 3),
            image: DecorationImage(
              image: NetworkImage(usersProfile[uid]['imageUrl']),
              //fit: (globals.aspectRatio > 1)?BoxFit.fitWidth:BoxFit.fitHeight,
            )
          )
        ):Container(
        //margin: const EdgeInsets.only(left:3),
        alignment: Alignment.center,
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(40/2)),
          border: Border.all(color: color,width: 5)
        ),
        child: Text(
          usersProfile[uid]['displayName'][0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Klavika Bold',
            package: 'css',
            fontSize: 20
          ),
        ),
      ),
      remove != null? Positioned(
        right: 0,
        top: 0,
        child: FocusedInkWell(
          onTap: () => remove!(loc),
          child: Container(
            width: 15,
            height: 15,
            margin: const EdgeInsets.only(left:5),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(15/2)),
            ),
            child: const Icon(
              Icons.remove_circle,
              size: 12,
            ),
          ),
        )
      ):Container()
    ]);
  }
}

class LSIUserIcon extends StatelessWidget{
  const LSIUserIcon({
    Key? key,
    required this.uids,
    required this.colors,
    this.remove,
    this.iconSize = 40,
    required this.viewidth,
  }):super(key: key);

  final List<String> uids;
  final List<Color> colors;
  final double iconSize;
  final double viewidth;
  final Function(int loc)? remove;

  @override
  Widget build(BuildContext context) {
    List<Widget> char = [];
    for(int i = 0; i < uids.length;i++){
      char.add(
        LSISingleUserIcon(
          uid:uids[i].trim(),
          color: i%2 == 0?colors[0]:colors[1],
          loc:i,
          remove: remove,
          iconSize: iconSize,
        )
      );
    }
    if(char.isEmpty){
      char.add(Container());
    }
    return SizedBox(
      width: viewidth,
      height: iconSize,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: char
      )
    );
  }
}

class LSIFloatingActionButton extends StatelessWidget{
  LSIFloatingActionButton({
    GlobalKey? key,
    required this.allowed,
    this.onTap,
    required this.color,
    required this.icon,
    this.size = 60,
    this.iconSize = 35,
    this.offset = const Offset(20,20),
    this.margin = const EdgeInsets.only(bottom: 50, right: 20),
    this.iconColor = Colors.white,
    this.onHoverEnter,
    this.onHoverExit,
    this.alignment = Alignment.bottomRight,
    this.message
  }):super(key: key){
    if(alignment == Alignment.bottomRight){
      bottom = offset.dy;
      right = offset.dx;
    }
    else if(alignment == Alignment.bottomLeft){
      bottom = offset.dy;
      left = offset.dx;
    }
    else if(alignment == Alignment.topRight){
      top = offset.dy;
      right = offset.dx;
    }
    else if(alignment == Alignment.topLeft){
      top = offset.dy;
      left = offset.dx;
    }
  }

  double? left,top,right,bottom;
  final bool allowed;
  final Function()? onTap;
  final Color color;
  final IconData icon;
  final double size;
  final double iconSize;
  final Offset offset;
  final EdgeInsets margin;
  final Color iconColor;
  final Function(PointerEvent)? onHoverEnter;
  final Function(PointerEvent)? onHoverExit;
  final Alignment alignment;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return (allowed)?Positioned(
      key: key,
      left: left,
      top: top,
      bottom: bottom,
      right: right,
      child: MouseRegion(
        onEnter: onHoverEnter,
        onExit: onHoverExit,
        child: FocusedInkWell(
          debugLabel: 'Floating Action Button',
          onTap: onTap,
          child: message != null?Tooltip(
            message: message,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(size/2)),
                boxShadow: [BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0,2),
                ),]
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
            )
          ):Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(size/2)),
              boxShadow: [BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 10,
                offset: const Offset(0,2),
              ),]
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          )
        )
      )
    ):Container();
  }
}

class CheckBoxForm extends StatelessWidget{
  const CheckBoxForm({
    Key? key,
    this.label, 
    required this.onChanged,
    required this.activeColor,
    required this.deactiveColor,
    this.sideColor,
    required this.value,
    this.margin = const EdgeInsets.fromLTRB(10, 0, 10, 0),
    this.padding = const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
  }):super(key: key);

  final String? label;
  final bool? value;
  final void Function(bool?) onChanged;
  final Color? activeColor;
  final Color? deactiveColor;
  final Color? sideColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  Color getColor(Set<WidgetState> states){
      if(states.contains(WidgetState.selected)){ 
        return activeColor!;
      }
      else{
        return deactiveColor!;
      }
    }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: margin,
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:[
          Flexible(
            child: Text(
              label!,
              style: Theme.of(context).primaryTextTheme.bodyMedium,
            ),
          ),
          Checkbox(
            value: value,
            fillColor: WidgetStateProperty.resolveWith(getColor),
            side: WidgetStateBorderSide.resolveWith(
                (states) => BorderSide(color: sideColor!),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2)), 
            onChanged: onChanged,
          )
        ]
      )
    );
  }
}

class IndicatorBlocks extends StatelessWidget{
  const IndicatorBlocks({
    Key? key,
    required this.colors,
    this.height = 20,
    this.active,
    required this.activeColor,
    this.onTap,
    this.highlights,
    this.isDynamic = false
  }):super(key: key);

  final List<Color> colors;
  final double height;
  final int? active;
  final Color activeColor;
  final Function(int)? onTap;
  final List<bool>? highlights;
  final bool isDynamic;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    for(int i = 0; i < colors.length;i++){
      bool highlight = false;
      if(highlights != null){
        if(i < highlights!.length){
          highlight = highlights![i];
        }
      }
      list.add(
        InkWell(
          onTap: (){
            if(onTap != null){
              onTap!(i);
            }
          },
          focusNode: FocusNode(skipTraversal: (onTap == null)),
          child: isDynamic?Stack(
            alignment: Alignment.center,
            children:[
              SizedBox(
                height: height,
                width: CSS.responsive()/colors.length/3.2,
              ),
              Container(
                height: height/2.5,    
                width:  CSS.responsive()/colors.length/2.6,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: colors[i],
                ),
              ),
            ]
          ):Stack(
            alignment: Alignment.center,
            children:[
            (active == i)?Container(
              height: height,
              width: CSS.responsive()/colors.length,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular((height)/2)),
                border: Border.all(
                  width: 2.0,
                  color: activeColor
                )
              ),
            ):SizedBox(
              height: height,
              width: CSS.responsive()/colors.length,
            ),
            Container(
              height: height-10,
              width: CSS.responsive()/colors.length-10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular((height-10)/2)),
                color: colors[i],
              ),
              child: (highlight)?ClipPath(
                  child: 
                  CustomPaint(
                    size: Size(CSS.responsive()/colors.length-10, height-10),
                    painter: BarsPainter(
                      barHeight: height,
                      strokeWidth: 10,
                      colors: [const Color(0x9906A7E2),const Color(0x99222222)]
                    ),
                  )
              ):Container(),
            )
          ])
        )
      );
    }

    return Container(
      width: isDynamic?320:CSS.responsive(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:list
      )
    );
  }
}

class InfoCard extends StatelessWidget{
  const InfoCard({
    Key? key,
    required this.color, 
    this.title = '', 
    this.subtitle = '', 
    this.infoTitle = '', 
    this.infoData = '', 
    this.image, 
    this.preInfo, 
    this.onTap,
    this.height,
    this.width = 650,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.showIcon = true,
    this.margin = const EdgeInsets.fromLTRB(0,0,0,0),
    this.padding,
    this.showBottomInfo = true,
    this.mouseCursor
  }):super(key: key);

  final Color color;
  final String title;
  final String subtitle; 
  final String infoTitle; 
  final String infoData;
  final String? image; 
  final Widget? preInfo;
  final Function()? onTap;
  final double? height;
  final double width;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showIcon;
  final EdgeInsets margin;
  final EdgeInsets? padding;
  final bool showBottomInfo;
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context){
    return FocusedInkWell(
      mouseCursor: mouseCursor,
      onTap: onTap,
      hoverColor: Colors.transparent,
      child: Container(
        margin: margin,
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            offset: const Offset(0,2),
          ),]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Padding(padding: const EdgeInsets.only(top:10, left: 10),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontFamily: 'MuseoSans',
                  package: 'css',
                  decoration: TextDecoration.none
                )
              ),
            ),
            Container(
              //height: height-40,
              width: width,
              //alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom:10),
              padding: padding,
              color: Theme.of(context).splashColor,
              child:
              Column(
                mainAxisAlignment: mainAxisAlignment,
                crossAxisAlignment: crossAxisAlignment,
                children: [
                (preInfo!=null)?preInfo!:Container(),
                (showBottomInfo)?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                  (image != null)?
                  Padding(
                  padding: const EdgeInsets.only(left:30),
                  child: Row(
                    children:[
                      SizedBox(
                        width: 50,
                        height: 40,
                        child: SvgPicture.asset(
                          image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        ' $subtitle',
                        style: TextStyle(
                          color: color,
                          fontSize: 24,
                          fontFamily: 'Klavika Bold',
                          package: 'css',
                          decoration: TextDecoration.none
                        )
                      )
                    ])
                  )
                  :Padding(
                    padding: const EdgeInsets.only(left:30),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontFamily: 'Klavika Bold',
                        package: 'css',
                        decoration: TextDecoration.none
                      )
                    )
                  ),
                  Row(
                    children:[
                    (infoData != '')?Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(
                        infoTitle,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontFamily: 'Klavika',
                          package: 'css',
                          decoration: TextDecoration.none
                        )
                      ),
                      Text(
                        infoData,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontFamily: 'Klavika',
                          package: 'css',
                          decoration: TextDecoration.none
                        )
                      ),
                    ],):const SizedBox(height: 0,),
                    (showIcon)?const Icon(
                      Icons.keyboard_arrow_right,
                      color: Color(0xffbbbbbb),
                      size: 36,
                    ):const SizedBox(height: 0,)
                  ])
                ]):const SizedBox(height: 0,)
            ],)
            )
        ]),
      )
    );
  }
}

class Tabs extends StatelessWidget{
  const Tabs({
    Key? key,
    required this.selectedTab,
    this.onTap,
    required this.tabs,
    this.height = 40,
    this.width,
  }):super(key: key);

  //int currentTab;
  final int selectedTab;
  final double height;
  final double? width;
  //String text;
  final List<String> tabs;
  final void Function(int)? onTap;

  Widget tabContainer(BuildContext context,int i){
    Color color = CSS.lighten(Theme.of(context).canvasColor,0.2);
    if(Theme.of(context).brightness == Brightness.light){
      color = CSS.darken(Theme.of(context).canvasColor,0.2);
    }
    return FocusedInkWell(
      onTap: () {
        if(onTap != null){
          onTap!(i);
        }
      },
      child:Row(
        children: [
        Container(
          height: height,
          width: 10,
          decoration: BoxDecoration(
            color: (selectedTab == i)?
              Theme.of(context).canvasColor:
              color,
          ),
          child: Container(
            decoration: BoxDecoration(
            color: Theme.of(context).indicatorColor,
              borderRadius: const BorderRadius.only(bottomRight:Radius.circular(10))
            ),
          ),
        ),
        Container(
          height: height,
          width: deviceWidth < 500?deviceWidth/tabs.length-20:500/tabs.length-20,
          decoration: BoxDecoration(
            color: (selectedTab == i)?
              Theme.of(context).canvasColor:
              color,
            //borderRadius: br,
            borderRadius: const BorderRadius.only(topRight:Radius.circular(10),topLeft:Radius.circular(10))
          ),
          alignment: Alignment.center,
          child: Text(
            tabs[i].toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CSS.responsiveColor((selectedTab != i)?Theme.of(context).secondaryHeaderColor:Theme.of(context).canvasColor,0.5),
              fontFamily: 'Klavika Bold',
              package: 'css',
              fontSize: 16,
              decoration: TextDecoration.none
            ),
          ),
        ),
        Container(
          height: height,
          width: 10,
          decoration: BoxDecoration(
            color: (selectedTab == i)?
              Theme.of(context).canvasColor:
              color,
          ),
          child: Container(
            decoration: BoxDecoration(
            color: Theme.of(context).indicatorColor,
              borderRadius: const BorderRadius.only(bottomLeft:Radius.circular(10))
            ),
          ),
        ),
      ],)
    );
  }

  @override
  Widget build(BuildContext context){
    List<Widget> allTabs = [];
    for(int i = 0; i < tabs.length; i++){
      allTabs.add(
        tabContainer(context,i)
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: allTabs
      )
    );
  }
}

class EnterTextFormField extends StatelessWidget{
  const EnterTextFormField({
    Key? key,
    this.maxLines,
    this.minLines,
    this.label, 
    required this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.width,
    this.height,
    this.color,
    this.textStyle,
    this.margin = const EdgeInsets.fromLTRB(10, 0, 10, 0),
    this.readOnly = false,
    this.keyboardType = TextInputType.multiline,
    this.padding = const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
    this.inputFormatters,
    this.radius = 10.0
  }):super(key: key);
  
  final int? minLines;
  final int? maxLines;
  final String? label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Function()? onEditingComplete;
  final double? width;
  final double? height;
  final Color? color;
  final bool readOnly;
  final EdgeInsets margin;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final List<TextInputFormatter>? inputFormatters;
  final double radius;

  @override
  Widget build(BuildContext context){
    return Container(
      margin: margin,
      width: width,
      height: height,
      alignment: Alignment.topCenter,
      child: TextField(
        //textAlign: TextAlign.,
        readOnly: readOnly,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        autofocus: false,
        focusNode: focusNode,
        //textAlignVertical: TextAlignVertical.center,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete:onEditingComplete,
        inputFormatters: inputFormatters,
        controller: controller,
        style: (textStyle == null)?Theme.of(context).primaryTextTheme.bodyMedium:textStyle,
        decoration: InputDecoration(
          isDense: true,
          //labelText: label,
          filled: true,
          fillColor: (color == null)?Theme.of(context).splashColor:color,
          contentPadding: padding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
            borderSide: const BorderSide(
                width: 0, 
                style: BorderStyle.none,
            ),
          ),
          hintStyle: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(color: Colors.grey),
          hintText: label
        ),
      )
    );
  }
}

class LSILoadingWheel extends StatelessWidget{
  LSILoadingWheel({
    Key? key,
    this.color,
    this.indicatorColor
  }):super(key: key);
  final double size = (deviceWidth<deviceHeight)?deviceWidth/4:deviceHeight/4;
  Color? color;
  Color? indicatorColor;

  @override
  Widget build(BuildContext context){
    return Container(
      width: deviceWidth,
      height: deviceHeight,
      color: color ?? Theme.of(context).canvasColor,
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: indicatorColor)
    );
  }
}

class LSIWidgets{
  static Widget dropDown({
    Key? key,
    required List<DropdownMenuItem<dynamic>> itemVal, 
    TextStyle style = const TextStyle(
      color: lsi.darkGrey,
      fontFamily: 'Klavika',
      package: 'css',
      fontSize: 14
    ),
    required dynamic value,
    Function(dynamic)? onchange,
    double width = 80,
    double height = 36,
    EdgeInsets padding = const EdgeInsets.only(left:10),
    EdgeInsets margin = const EdgeInsets.fromLTRB(0, 5, 0, 5),
    Color color = Colors.transparent,
    double radius = 0,
    Alignment alignment = Alignment.center,
    Border? border,
  }){
    return Container(
      key: key,
      margin: margin,
      alignment: alignment,
      width: width,
      height:height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: border
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton <dynamic>(
          dropdownColor: color,
          isExpanded: true,
          items: itemVal,
          value: value,//ddInfo[i],
          isDense: true,
          focusColor: lsi.lightBlue,
          style: style,
          onChanged: onchange,
        ),
      ),
    );
  }
  
  static Widget multiSelectDropDown({
    Key? key,
    required List<ValueItem<dynamic>> itemVal, 
    required List<ValueItem<dynamic>> selected,
    required Function(List<ValueItem<dynamic>>) onSelected,
    required MultiSelectController<dynamic> controller,
    required Function(int, ValueItem<dynamic>) onRemoved,
    SelectionType selectionType = SelectionType.multi,
    TextStyle style = const TextStyle(
      color: darkGrey,
      fontFamily: 'Klavika',
      package: 'css',
      fontSize: 14
    ),
    String hint = 'Select ...',
    double width = 80,
    double height = 36,
    EdgeInsets padding = const EdgeInsets.only(left:10),
    EdgeInsets margin = const EdgeInsets.fromLTRB(0, 5, 0, 5),
    Alignment alignment = Alignment.center,
    Border? border,
    Color color = Colors.transparent,
    Color? searchColor,
    double radius = 10,
    bool searchEnabled = false,
  }){
    return Container(
      key: key,
      alignment: alignment,
      padding: padding,
      margin: margin,
      width: width,
      //height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: border
      ),
      child: MultiSelectDropDown <dynamic>(
        selectionType: selectionType,
        controller: controller,
        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
        onOptionSelected: onSelected,
        onOptionRemoved: onRemoved,
        options: itemVal,
        selectedOptions: selected,
        hint: hint,
        hintStyle: style,
        optionTextStyle: style,
        selectedOptionBackgroundColor: color,
        optionsBackgroundColor: color,
        searchEnabled: searchEnabled,
        fieldBackgroundColor: color,
        dropdownBackgroundColor: color,
        selectedOptionIcon: Icon(Icons.check, color: style.color,),
        inputDecoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          border: Border.all(
            width: 0, 
            style: BorderStyle.none,
          )
        )
      )
    );
  }
  static Widget submitButton(String text, function){
    return Align(
      alignment: Alignment.bottomCenter,
      child: FocusedInkWell(
        onTap:function,
        child:Container(
          padding: const EdgeInsets.only(top:10),
          //margin: EdgeInsets.only(bottom:10),
          alignment: Alignment.topCenter,
          color: lsi.lightGreen,
          width: deviceWidth,
          height: 90,
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Klavika',
              package: 'css',
              fontSize: 20,
              decoration: TextDecoration.none
            ),
          ),
        )
      )
    );
  }
  static Widget saveButton({
    required String text, 
    Function()? onTap,
    double width = 100,
    double? maxWidth
  }){
    if(maxWidth != null){
      if(width > maxWidth){
        width = maxWidth;
      }
    }

    return FocusedInkWell(
      onTap:onTap,
      child: Container(
        height: 60,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (text == 'cancel')?Colors.transparent:lsi.lightGrey,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          border: Border.all(width:5,color: (text == 'cancel')?Colors.white:lsi.lightGrey)
        ),
        child:Text(
          text.toUpperCase(),
          style: TextStyle(
            color: (text == 'cancel')?Colors.white:lsi.chartGrey,
            fontFamily: 'Klavika Bold',
            package: 'css',
            fontSize: 20,
            decoration: TextDecoration.none
          ),
        ),
      )
    );
  }

  static Widget saveModal({
    required String text, 
    Function()? onTapButton1, 
    Function()? onTapButton2
  }){
    return Container(
      alignment: Alignment.center,
      height: deviceHeight+navSize.height,
      width: (useSideNav)?deviceWidth+navSize.width:deviceWidth,
      color: lsi.blur,
      child: Container(
        height: deviceHeight/2,
        width: deviceWidth-80,
        //alignment: Alignment.center,
        decoration: BoxDecoration(
          color: lsi.chartGrey,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(width:1)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
          Padding(
            padding: const EdgeInsets.fromLTRB(30,0,30,60),
            child:Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Klavika',
                package: 'css',
                fontSize: 20,
                decoration: TextDecoration.none
              ),
            ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:[
            (onTapButton1 != null)?
              saveButton(
                text: 'confirm',
                onTap: onTapButton1,
                width: (deviceWidth-80)/2-20,
                maxWidth: 260
              )
              :Container(),
            saveButton(
              text:'cancel',
              onTap:onTapButton2,
              width: (deviceWidth-80)/2-20,
              maxWidth: 260
            )
          ])
        ]),
      )
    );
  }

  static Widget squareButton({
    Key? key,
    bool iconFront = false,
    Widget? icon,
    required Color buttonColor,
    Color textColor = lsi.darkGrey,
    required String text,
    Function()? onTap,
    String fontFamily = 'Klavika Bold',
    double fontSize = 18.0,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    double height = 75,
    double width = 100,
    double radius = 5,
    Alignment? alignment,
    EdgeInsets? margin,
    EdgeInsets? padding,
    List<BoxShadow>? boxShadow,
    Color? borderColor,
    bool loading = false,
    String? message,
    Function(PointerEnterEvent)? onHoverEnter,
    Function(PointerExitEvent)? onHoverExit,
  }){
    Widget totalIcon = (icon != null)?icon:Container();
    Widget cont = Container(
      alignment: alignment,//Alignment.center,
      height: height,//75,
      width: width,//deviceWidth,
      margin: margin,//EdgeInsets.fromLTRB(10,5,10,5),
      padding: padding,//EdgeInsets.fromLTRB(25,0,10,0),
      decoration: BoxDecoration(
        color: buttonColor,
        border: Border.all(
          color: (borderColor == null)?buttonColor:borderColor,
          width: 2
        ),
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        boxShadow: boxShadow
      ),
      child:loading?LSILoadingWheel(color: buttonColor,indicatorColor: textColor,):Row(
        key: key,
        mainAxisAlignment: mainAxisAlignment,//MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (iconFront)?totalIcon:Container(),
          Text(
            text.toUpperCase(),
            
            textAlign: TextAlign.start,
            style:TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontFamily: fontFamily,
              decoration: TextDecoration.none,
              package: 'css'
            )
          ),
          (!iconFront)?totalIcon:Container(),
      ],)
    );
    return MouseRegion(
      onEnter: onHoverEnter,
      onExit: onHoverExit,
      child: FocusedInkWell(
        onTap: onTap,
        child: message !=null?Tooltip(message: message,child: cont):cont
      )
    );
  }
  
  static Widget iconName({
    required IconData icon,
    Function()? onTap,
    required Color color
  }){
    return 
    FocusedInkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left:10,right:10),
        child:Stack(
          children:[
            Icon(
              icon,
              color: color,
              size: 36,
            ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              //color: (hasNewNot && name == "NOTIFICATIONS")?Color(0xffe85454):Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(12/2)),
            ),
          ),
        ])
      )
    );
  }

  static Widget dropDownItems({
    Function()? onTap, 
    Function(PointerHoverEvent event)? onHover,
    required BoxDecoration decoration, 
    required Text text, 
    EdgeInsets? margin,
  }){
    return FocusedInkWell(
      onTap: onTap,
      child: MouseRegion(
        onHover: onHover,
        child:Container(
          alignment: Alignment.center,
          height: 40,
          margin: margin,
          decoration: decoration,
          child: text,
        )
      )
    );
  }
  static Widget iconNote(IconData icon, String text, TextStyle style, double size){
    return SizedBox(
      child: Row(children: [
        Icon(
          icon,
          size:size,
          color: style.color
        ),
        Text(
          ' $text',
          style: style,
        )
      ],),
    );
  }
}

class UploadImage extends StatelessWidget{
  const UploadImage({
    Key? key,
    this.label, 
    this.onTap,
    required this.imageController,
    this.color,
    this.width,
    this.name =  "BROWSE",
    this.icon
  }):super(key: key);

  final String? label;
  final IconData? icon;
  final String name;
  final Function()? onTap;
  final TextEditingController imageController;
  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context){
    return Row(children: [
      Container(
        width: (width??((deviceWidth-200)/2-60))-80,
        height: 35,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        decoration: BoxDecoration(
          color: (color != null)?color:Theme.of(context).indicatorColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(7),
            bottomLeft: Radius.circular(7)
          )
        ),
        child: Text(
          imageController.text != ''?imageController.text:label!,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: Theme.of(context).primaryTextTheme.bodyMedium!.fontFamily,
            fontSize: Theme.of(context).primaryTextTheme.bodyMedium!.fontSize,
            color: imageController.text != ''?Theme.of(context).primaryTextTheme.bodyMedium!.color:Colors.grey,
            decoration: TextDecoration.none
          ),
        ),
      ),
      FocusedInkWell(
        debugLabel: 'Upload Image',
        onTap: onTap,
        child: Container(
          height: 35,
          width: 80,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left:2),
          decoration: BoxDecoration(
            color: (color != null)?color:Theme.of(context).indicatorColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(7),
              bottomRight: Radius.circular(7)
            )
          ),
          child: icon == null?Text(
            name,
            style: TextStyle(
              fontFamily: Theme.of(context).primaryTextTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              color: Theme.of(context).primaryTextTheme.bodyMedium!.color!,
              decoration: TextDecoration.none
            ),
          ):Icon(icon,color: Theme.of(context).primaryTextTheme.bodyMedium!.color!,size: 20,),
        ),
      ),
    ],);
  }
}

class TopInfo extends StatelessWidget{
  const TopInfo({
    Key? key,
    required this.title,
    this.info = '',
    this.titleWidget,
    this.width,
    this.height,
    this.onTap,
    this.wrap = true,
    this.backButton = false,
    this.useShaddow = true
  }):super(key: key);
  final Function()? onTap;
  final bool backButton;
  final String title;
  final String info;
  final Widget? titleWidget;
  final double? width;
  final bool useShaddow;
  final bool wrap;
  final double? height;

  @override
  Widget build(BuildContext context){
    List<Widget> children = [
      (backButton)?FocusedInkWell(
          onTap: onTap,
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ):Container(),
        Text(
          title+':  ',
          style: Theme.of(context).primaryTextTheme.headlineMedium
        ),
        (titleWidget != null)?titleWidget!:Container()
      ];
      return Container(
      width: (width == null)?deviceWidth:width,
      height: height,
      //margin: EdgeInsets.only(bottom:20),
      padding: const EdgeInsets.fromLTRB(20,10,10,0),
      decoration: (useShaddow)?BoxDecoration(
        color: Theme.of(context).indicatorColor,
        boxShadow: [BoxShadow(
          color: Theme.of(context).shadowColor,
          blurRadius: 10,
          offset: const Offset(0,-5),
        ),]
      ):BoxDecoration(
        color: Theme.of(context).indicatorColor,
      ),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisSize: MainAxisSize.max,
        children: [
          wrap?Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children
          ):Row(
            children: children,
          ),
          (info != '')?Column(children:[
            const SizedBox(height: 10),
            SizedBox(
              width: CSS.responsive2(),
              child: Text(
                info,
                textAlign: TextAlign.justify,
                style: Theme.of(context).primaryTextTheme.bodyMedium
              ),
            ),
            const SizedBox(height: 10)
          ]):Container(),
        ],
      )
    );
  }
}
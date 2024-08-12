// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  List<Widget> items = [];
  double height;
  double width;
  bool autoScroll;
  Duration autoScrollDuration;
  Duration animationPageDuration;
  Curve animationPageCurve;
  bool stopAtEnd;
  int initialPage = 0;
  Axis scrollAxis;
  double indicatorBarHeight;
  double indicatorBarWidth;
  double indicatorHeight;
  double indicatorWidth;
  bool isCircle;
  Color activateIndicatorColor;
  Color unActivatedIndicatorColor;
  Color indicatorBarColor;
  double? indicatorBarColorOpacity;
  Carousel(
      {super.key,
      required this.items,
      this.activateIndicatorColor = Colors.black,
      this.animationPageCurve = Curves.easeIn,
      this.animationPageDuration = Duration.zero,
      this.autoScroll = false,
      this.autoScrollDuration = Duration.zero,
      this.height = 0.0,
      this.indicatorBarHeight = 0.0,
      this.indicatorBarWidth = 0.0,
      this.indicatorHeight = 10,
      this.indicatorWidth = 10,
      this.initialPage = 0,
      this.isCircle = true,
      this.scrollAxis = Axis.horizontal,
      this.stopAtEnd = false,
      this.unActivatedIndicatorColor = Colors.grey,
      this.indicatorBarColor = Colors.black,
      this.width = 0.0});

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  PageController? _pageController;
  int? _totalItem;
  int _current = 0;

  @override
  void initState() {
    _totalItem = widget.items.length;
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController!.dispose(); // _pageController'ı dispose et
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: widget.height != 0.0 ? widget.height : size.height * 0.4,
      width: widget.width != 0.0 ? widget.width : size.width,
      child: Stack(
        children: [
          SizedBox(
            height: widget.height != 0.0 ? widget.height : size.height * 0.4,
            width: widget.width != 0.0 ? widget.width : size.width,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: widget.scrollAxis,
              itemCount: _totalItem,
              itemBuilder: (context, index) {
                return SizedBox(
                  height:
                      widget.height != 0.0 ? widget.height : size.height * 0.4,
                  width: widget.width != 0.0 ? widget.width : size.width,
                  child: widget.items[index],
                );
              },
              onPageChanged: (int i) {
                setState(() {
                  _current = i;
                });
              },
            ),
          ),
          Circle(
            activateIndicatorColor: widget.activateIndicatorColor,
            activeIndex: _current,
            count: _totalItem,
            height: widget.indicatorBarHeight == 0.0
                ? 30
                : widget.indicatorBarHeight,
            width: widget.indicatorBarWidth != 0.0
                ? widget.indicatorBarWidth
                : widget.width == 0.0
                    ? size.width
                    : widget.width,
            indicatorHeight: widget.indicatorHeight,
            indicatorWidth: widget.indicatorWidth,
            unActivatedIndicatorColor: widget.unActivatedIndicatorColor,
            isCircle: widget.isCircle,
            indicatorBarColor: widget.indicatorBarColor,
          ),
        ],
      ),
    );
  }
}

class Circle extends StatefulWidget {
  double width;
  double height;
  int activeIndex;
  int? count;
  double indicatorHeight;
  double indicatorWidth;
  bool? isCircle;
  Color activateIndicatorColor;
  Color unActivatedIndicatorColor;
  Color indicatorBarColor;
  Circle(
      {super.key,
      required this.width,
      required this.height,
      required this.activeIndex,
      required this.count,
      required this.activateIndicatorColor,
      required this.indicatorHeight,
      required this.indicatorWidth,
      required this.indicatorBarColor,
      this.isCircle,
      required this.unActivatedIndicatorColor});

  @override
  _CircleState createState() => _CircleState();
}

class _CircleState extends State<Circle> {
  List<Widget> widgets = [];
  Widget mywidget(index) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        width: widget.indicatorWidth,
        height: widget.indicatorHeight,
        decoration: BoxDecoration(
            color: index == widget.activeIndex
                ? widget.activateIndicatorColor
                : widget.unActivatedIndicatorColor,
            shape: widget.isCircle! ? BoxShape.circle : BoxShape.rectangle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    widgets.clear();
    for (var i = 0; i < widget.count!; i++) {
      widgets.add(mywidget(i));
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: widget.height,
        width: widget.width,
        color: widget.indicatorBarColor,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widgets.isNotEmpty ? widgets : []),
      ),
    );
  }
}

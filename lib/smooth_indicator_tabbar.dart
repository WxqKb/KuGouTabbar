import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///
/// 圆角矩形TabBar，请确保tabs和pageViews长度一致且一一对应
/// [tabs]
///
class SmoothIndicatorTabBar extends StatefulWidget {
  final double _tabBarHeight; // TabBar高度
  final int _initPage; // 初始页码
  final List<String> _tabs; // TabBar
  final List<Widget> _pageViews; // TabBar对应的views
  final bool isScrollable;

  // 样式定制
  final double indicatorHeight;
  final double indicatorWidth;
  final EdgeInsetsGeometry? indicatorPadding;
  final BoxDecoration? indicatorDecoration; // 指示器修饰器
  final TextStyle? activeLabelTextStyle;
  final TextStyle? normalLabelTextStyle;
  final EdgeInsetsGeometry? padding;

  const SmoothIndicatorTabBar({
    Key? key,
    int initPage = 0,
    double tabBarHeight = 35,
    required List<String> tabs,
    required List<Widget> pageViews,
    this.isScrollable = false,
    this.activeLabelTextStyle,
    required this.indicatorHeight,
    required this.indicatorWidth,
    this.indicatorDecoration,
    this.normalLabelTextStyle,
    this.indicatorPadding,
    this.padding,
  })  : assert(tabs.length == pageViews.length, "tab和page的长度必须保持一致"),
        _tabs = tabs,
        _pageViews = pageViews,
        _initPage = initPage,
        _tabBarHeight = tabBarHeight,
        super(key: key);

  @override
  _SmoothIndicatorTabBarState createState() => _SmoothIndicatorTabBarState();
}

class _SmoothIndicatorTabBarState extends State<SmoothIndicatorTabBar>
    with TickerProviderStateMixin {
  late Alignment _dragAlignment;
  late AnimationController _controller;
  late AnimationController _indicatorWidthController;
  late Animation<Alignment> _animation;
  late Animation<double> _indicatorWidthAnimation;

  // stream
  final StreamController<int> _currentPageController =
      StreamController<int>.broadcast();

  Stream<int> get currentPageStream => _currentPageController.stream;

  Sink<int> get currentPageSink => _currentPageController.sink;

  int currPage = 0;
  late PageController _pageController;

  AnimationStatus? _lastStatus;

  final List<double> _itemsWidthProportion = [];
  late double _itemsWidth;

  @override
  void initState() {
    super.initState();
    currPage = widget._initPage;
    _pageController = PageController(initialPage: currPage);

    _pageController.addListener(() {});

    Future.delayed(Duration.zero, () {
      _dragAlignment = Alignment(ourMap(currPage), 0);

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      )..addListener(() {
          _dragAlignment = _animation.value;
        });

      _indicatorWidthController = AnimationController(
        vsync: this,
        duration: kThemeAnimationDuration,
      )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (_lastStatus != null && _lastStatus == AnimationStatus.forward) {
              _indicatorWidthController.reverse();
            }
          } else {
            _lastStatus = status;
          }
        });
      //
      currentPageStream.listen((int page) {
        _runAnimation(
          _dragAlignment,
          Alignment(ourMap(page), 0),
        );
        _runWidthAnimation();
      });

      currentPageSink.add(currPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: widget._tabBarHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _TabLabelBar(
                onPerformLayout: _saveTabOffsets,
                children: widget._tabs.map((t) {
                  int index = widget._tabs.indexOf(t);
                  Widget item = InkWell(
                    child: Center(
                      heightFactor: 1.0,
                      child: StreamBuilder(
                        stream: currentPageStream,
                        builder: (context, AsyncSnapshot<int> snapshot) {
                          return AnimatedDefaultTextStyle(
                            duration: kThemeAnimationDuration,
                            style: index == snapshot.data
                                ? widget.activeLabelTextStyle!
                                : (widget.normalLabelTextStyle ??
                                    Theme.of(context).textTheme.headline3!),
                            textAlign: TextAlign.center,
                            child: Text(t),
                          );
                        },
                      ),
                    ),
                    onTap: () {
                      currPage = index;
                      _pageController.jumpToPage(index);
                    },
                  );
                  if (!widget.isScrollable) item = Expanded(child: item);
                  return item;
                }).toList(),
              ),
              Container(
                width: _itemsWidth,
                padding: widget.indicatorPadding ?? EdgeInsets.zero,
                child: StreamBuilder(
                  stream: currentPageStream,
                  builder: (context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      return AnimatedBuilder(
                        animation: _indicatorWidthAnimation,
                        builder: (context, _) => AnimatedBuilder(
                          animation: _animation,
                          builder: (context, _) => Align(
                            alignment: _animation.value,
                            child: Container(
                              height: widget.indicatorHeight,
                              width: _indicatorWidthAnimation.value,
                              decoration: widget.indicatorDecoration,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) => currentPageSink.add(page),
            children: widget._pageViews,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _currentPageController.close();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  double ourMap(currIndex) {
    // double preWidth = 0;
    // for (int i = 1; i < currIndex; i++) {
    //   preWidth += _itemsWidthProportion[i];
    // }
    // return _itemsWidthProportion[0] -
    //     1 +
    //     preWidth +
    //     _itemsWidthProportion[currIndex] * 0.5;
    return -0.75 + currIndex  * 0.5;
  }

  void _saveTabOffsets(
      List<double> tabOffsets, TextDirection textDirection, double width) {
    _itemsWidthProportion.clear();
    for (int i = 0; i < tabOffsets.length - 1; i++) {
      _itemsWidthProportion.add((tabOffsets[i + 1] - tabOffsets[i]) / width);
    }
    _itemsWidth = width;
  }

  void _runAnimation(Alignment oldA, Alignment newA) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: oldA,
        end: newA,
      ),
    );
    _controller.reset();
    _controller.forward();
  }

  void _runWidthAnimation() {
    _indicatorWidthAnimation = Tween(
      begin: widget.indicatorWidth,
      end: 94.85,
    ).animate(_indicatorWidthController);
    _indicatorWidthController.reset();
    _indicatorWidthController.forward();
  }
}

typedef _LayoutCallback = void Function(
    List<double> xOffsets, TextDirection textDirection, double width);

class _TabLabelBarRenderer extends RenderFlex {
  _TabLabelBarRenderer({
    List<RenderBox>? children,
    required Axis direction,
    required MainAxisSize mainAxisSize,
    required MainAxisAlignment mainAxisAlignment,
    required CrossAxisAlignment crossAxisAlignment,
    required TextDirection textDirection,
    required VerticalDirection verticalDirection,
    required this.onPerformLayout,
  }) : super(
          children: children,
          direction: direction,
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
        );

  _LayoutCallback onPerformLayout;

  @override
  void performLayout() {
    super.performLayout();
    // xOffsets will contain childCount+1 values, giving the offsets of the
    // leading edge of the first tab as the first value, of the leading edge of
    // the each subsequent tab as each subsequent value, and of the trailing
    // edge of the last tab as the last value.
    RenderBox? child = firstChild;
    final List<double> xOffsets = <double>[];
    while (child != null) {
      final FlexParentData childParentData =
          child.parentData! as FlexParentData;
      xOffsets.add(childParentData.offset.dx);
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    assert(textDirection != null);
    switch (textDirection!) {
      case TextDirection.rtl:
        xOffsets.insert(0, size.width);
        break;
      case TextDirection.ltr:
        xOffsets.add(size.width);
        break;
    }
    onPerformLayout(xOffsets, textDirection!, size.width);
  }
}

// This class and its renderer class only exist to report the widths of the tabs
// upon layout. The tab widths are only used at paint time (see _IndicatorPainter)
// or in response to input.
class _TabLabelBar extends Flex {
  _TabLabelBar({
    Key? key,
    List<Widget> children = const <Widget>[],
    required this.onPerformLayout,
  }) : super(
          key: key,
          children: children,
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
        );

  final _LayoutCallback onPerformLayout;

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return _TabLabelBarRenderer(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context)!,
      verticalDirection: verticalDirection,
      onPerformLayout: onPerformLayout,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _TabLabelBarRenderer renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject.onPerformLayout = onPerformLayout;
  }
}

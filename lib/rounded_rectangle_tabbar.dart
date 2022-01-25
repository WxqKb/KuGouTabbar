import 'dart:async';

import 'package:flutter/material.dart';

///
/// 圆角矩形TabBar，请确保tabs和pageViews长度一致且一一对应
/// [tabs]
///
class RoundedRectangleTabBar extends StatefulWidget {
  final double _tabBarHeight; // TabBar高度
  final int _initPage; // 初始页码
  final List<String> _tabs; // TabBar
  final List<Widget> _pageViews; // TabBar对应的views

  // 样式定制
  final BoxDecoration? backgroundDecoration;
  final BoxDecoration? activeItemDecoration;
  final BoxDecoration? normalItemDecoration;
  final TextStyle? activeLabelTextStyle;
  final TextStyle? normalLabelTextStyle;

  const RoundedRectangleTabBar(
      {Key? key,
      required List<String> tabs,
      required List<Widget> pageViews,
      int initPage = 0,
      double tabBarHeight = 35,
      this.backgroundDecoration,
      this.activeItemDecoration,
      this.normalItemDecoration,
      this.activeLabelTextStyle,
      this.normalLabelTextStyle})
      : assert(tabs.length == pageViews.length, "tab和page的长度必须保持一致"),
        _tabs = tabs,
        _pageViews = pageViews,
        _initPage = initPage,
        _tabBarHeight = tabBarHeight,
        super(key: key);

  @override
  _RoundedRectangleTabBarState createState() => _RoundedRectangleTabBarState();
}

class _RoundedRectangleTabBarState extends State<RoundedRectangleTabBar>
    with SingleTickerProviderStateMixin {
  late Alignment _dragAlignment;
  late AnimationController _controller;
  late Animation<Alignment> _animation;

  // stream
  late StreamController<int> _currentPageController;

  Stream<int> get currentPageStream => _currentPageController.stream;

  Sink<int> get currentPageSink => _currentPageController.sink;

  int initPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    initPage = widget._initPage;
    currentPageSink.add(initPage);
    _pageController = PageController(initialPage: initPage);

    Future.delayed(Duration.zero, () {
      _dragAlignment =
          Alignment(ourMap(initPage, 0, widget._tabs.length - 1, -1, 1), 0);

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..addListener(() {
          setState(() {
            _dragAlignment = _animation.value;
          });
        });

      currentPageStream.listen((int page) {
        _runAnimation(
          _dragAlignment,
          Alignment(ourMap(page, 0, widget._tabs.length - 1, -1, 1), 0),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            height: widget._tabBarHeight,
            decoration: widget.backgroundDecoration ??
                BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular((widget._tabBarHeight / 2)),
                  ),
                ),
            child: Stack(
              children: <Widget>[
                // use animated widget
                StreamBuilder(
                  stream: currentPageStream,
                  builder: (context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      return AnimatedAlign(
                        duration: kThemeAnimationDuration,
                        alignment: Alignment(
                            ourMap(snapshot.data, 0, widget._tabs.length - 1,
                                -1, 1),
                            0),
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            double width = constraints.maxWidth;
                            return Container(
                              height: widget._tabBarHeight - 8,
                              width: width / widget._tabs.length - 8,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              decoration: widget.activeItemDecoration ??
                                  BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFF48BDFF),
                                      Color(0xFF1D80BC)
                                    ]),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        ((widget._tabBarHeight - 8) / 2),
                                      ),
                                    ),
                                  ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                Row(
                  children: widget._tabs.map((t) {
                    int index = widget._tabs.indexOf(t);
                    return Expanded(
                      child: GestureDetector(
                        child: Container(
                          alignment: Alignment.center,
                          height: double.infinity,
                          width: double.infinity,
                          decoration: widget.normalItemDecoration ??
                              BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(widget._tabBarHeight / 2),
                                ),
                              ),
                          child: StreamBuilder(
                              stream: currentPageStream,
                              builder: (context, AsyncSnapshot<int> snapshot) {
                                return AnimatedDefaultTextStyle(
                                  duration: kThemeAnimationDuration,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                        inherit: true,
                                        height: 1.2,
                                      ),
                                  child: Text(t),
                                );
                              }),
                        ),
                        onTap: () {
                          currentPageSink.add(index);
                          _pageController.jumpToPage(index);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => currentPageSink.add(page),
              children: widget._pageViews,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPageController.close();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  double ourMap(v, start1, stop1, start2, stop2) {
    return (v - start1) / (stop1 - start1) * (stop2 - start2) + start2;
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
}

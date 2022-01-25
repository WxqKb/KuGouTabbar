import 'package:custom_tabbar/custom_tabbar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        bottom: KuGouTabBar(
          tabs: const [Tab(text: "音乐"), Tab(text: "动态"), Tab(text: "语文")],
          // labelPadding: EdgeInsets.symmetric(horizontal: 8),
          controller: _tabController,
          // indicatorSize: TabBarIndicatorSize.label,
          // isScrollable: true,
          padding: EdgeInsets.zero,
          indicator: const RRecTabIndicator(
              radius: 4, insets: EdgeInsets.only(bottom: 5)),
          indicatorMinWidth: 6,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(
            child: Text("音乐"),
          ),
          Center(
            child: Text("动态"),
          ),
          Center(
            child: Text("语文"),
          ),
        ],
      ),
      // Container(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height,
      //   padding: const EdgeInsets.only(top: 16),
      //   // child: SmoothIndicatorTabBar(
      //   //   tabs: const ["音乐", "动态", "艺人", "消息"],
      //   //   pageViews: [
      //   //     buildPageView("音乐"),
      //   //     buildPageView("动态"),
      //   //     buildPageView("艺人"),
      //   //     buildPageView("消息"),
      //   //   ],
      //   //   normalLabelTextStyle:
      //   //       const TextStyle(fontSize: 12, color: Colors.grey),
      //   //   activeLabelTextStyle:
      //   //       const TextStyle(fontSize: 14, color: Colors.blue),
      //   //   indicatorWidth: 5,
      //   //   indicatorHeight: 5,
      //   //   indicatorDecoration: const BoxDecoration(
      //   //       color: Colors.lightBlueAccent,
      //   //       borderRadius: BorderRadius.all(
      //   //         Radius.circular(2),
      //   //       )),
      //   //   padding: const EdgeInsets.only(left: 8, right: 8),
      //   //   isScrollable: false,
      //   // ),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  buildPageView(String content) {
    return Center(
      child: Text(
        content,
        style: const TextStyle(color: Colors.blue, fontSize: 24),
      ),
    );
  }
}

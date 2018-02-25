import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/travel.dart' show Travel, getTravels, TravelDay, getTravelDay, TravelOption, getTravelOption;
import 'travel_page.dart' as travel_page;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Discover Switzerland',
      theme: new ThemeData(
        primarySwatch: Colors.red,
        platform: Theme.of(context).platform == TargetPlatform.iOS ? TargetPlatform.iOS : TargetPlatform.android
      ),
      home: new MyHomePage(title: 'Discover Switzerland'),
      routes: <String, WidgetBuilder> {
        "/TravelPage": (BuildContext context) => new TravelPage(null),
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class TravelPage extends StatefulWidget {
  TravelPage(this.travel);

  final Travel travel;

  @override
  _TravelPageState createState() => new _TravelPageState(travel);
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;

  /*void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }*/
  var travels = <Travel>[];

  @override
  initState() {
    super.initState();
    listenForTravels();
  }

  listenForTravels() async {
    var stream = await getTravels();
    stream.listen((travel) => setState(() => travels.add(travel)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new ListView(
          children: travels.map((travel) => new TravelWidget(travel)).toList(),
        ),
      )
      /*floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _TravelPageState extends State<TravelPage> with SingleTickerProviderStateMixin {
  Travel travel;
  _TravelPageState(Travel travel) {
    this.travel = travel;
  }
  //int _counter = 0;

  /*void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }*/

  TabController controller;
  var travelDays = <TravelDay>[];
  @override
  initState() {
    super.initState();
    controller = new TabController(length: 3, vsync: this);
    super.initState();
    listenForTravelDays();
  }

  listenForTravelDays() async {
    if (travel != null) {
      var stream = await getTravelDay(travel);
      stream.listen((travelDay) => setState(() => travelDays.add(travelDay)));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(travel.title),
          bottom: new TabBar(
            controller: controller,
            tabs: <Tab>[
              new Tab(icon: new Icon(Icons.access_time)),
              new Tab(icon: new Icon(Icons.calendar_today)),
              new Tab(icon: new Icon(Icons.account_balance_wallet)),
            ]
          )
        ),
        body: new TabBarView(
          controller: controller,
          children: <Widget>[
            new travel_page.TravelTabCurrent(travel, (travelDays != null && travelDays.length > 0 ? travelDays.first : null)),
            new travel_page.TravelTabFull(travel, travelDays),
            new travel_page.TravelTabTickets(travel, travelDays),
          ],
        )
      /*floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TravelWidget extends StatelessWidget {
  TravelWidget(this.travel);
  final Travel travel;

  @override
  Widget build(BuildContext context) {
    var listTile = new ListTile(
      leading: new CircleAvatar(
        child: new Text(travel.key.toString()),
        backgroundColor: Colors.red,
      ),
      title: new Text(travel.title),
      subtitle: new Text(travel.getFromTo() + ' (' + travel.days.toString() + ' days)'),
      onTap: () {
        Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new TravelPage(travel),
        ));
      },
    );

    return listTile;
  }
}

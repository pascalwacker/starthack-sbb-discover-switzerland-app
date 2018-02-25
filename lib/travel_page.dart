import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'models/travel.dart' show Travel, getTravels, TravelDay, getTravelDay, TravelOption, getTravelOption;

class TravelTabCurrent extends StatelessWidget {
  Travel travel;
  TravelDay day;

  TravelTabCurrent(Travel travel, TravelDay day) {
    this.travel = travel;
    this.day = day;
  }

  void _showTicket(context, value, date) {
    AlertDialog dialog = new AlertDialog(
      content: new Column(
        children: <Widget>[
          new Text(
            value['title'],
            style: new TextStyle(fontSize: 30.0)
          ),
          new Text(
            date.day.toString() + '.' + date.month.toString() + '.' + date.year.toString(),
            style: new TextStyle(color: Colors.grey),
          ),
          new Divider(),
          new Image.asset('assets/qr.png'),
          new Text('1 Adult - ' + value['price'].toString() + ' CHF'),
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: new Text('OK')),
      ],
    );

    showDialog(context: context, child: dialog);
  }

  void _buyTicket(context, value, date) {
    AlertDialog dialog = new AlertDialog(
      content: new Column(
        children: <Widget>[
          new Text(
            value['title'],
            style: new TextStyle(fontSize: 30.0)
          ),
          new Text(
            date.day.toString() + '.' + date.month.toString() + '.' + date.year.toString(),
            style: new TextStyle(color: Colors.grey),
          ),
          new Divider(),
          new Text(
              '1 Adult - ' + value['price'].toString() + ' CHF',
              style: new TextStyle(fontSize: 20.0),
          ),
          new TextField(
            autocorrect: false,
            maxLines: 1,
            decoration: new InputDecoration(
              hintText: 'XXXX-XXXX-XXXX-XXXX',
              labelText: 'Credit Card',
            ),
          ),
          new TextField(
            autocorrect: false,
            maxLines: 1,
            decoration: new InputDecoration(
              hintText: 'XX-XX',
              labelText: 'Valid until',
            ),
          ),
          new TextField(
            autocorrect: false,
            maxLines: 1,
            decoration: new InputDecoration(
              hintText: 'XXX',
              labelText: 'CSV',
            ),
          ),
          new Text(' '),
          new Row(
            children: <Widget>[
              new RaisedButton(
                child: new Text('Buy'),
                onPressed: (){Navigator.pop(context);},
                color: Colors.redAccent,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: new Text('Cancel')),
      ],
    );

    showDialog(context: context, child: dialog);
  }

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CupertinoActivityIndicator(),
          new Text("Loading ..."),
        ],
      );
    } else {
      List<Widget> viewWidgets = <Widget>[
        new ListTile(
          title: new Text(
            day.city,
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0
            ),
          ),
          subtitle: new Text(day.date.day.toString() + '.' + day.date.month.toString() + '.' + day.date.year.toString()),
        ),
      ];

      void iterateMapEntry(value) {
        viewWidgets.add(new Divider());
        Icon icon;
        if (value['type'] == 'acitivity') {
          switch (value['category']) {
            case 'church':
              icon = new Icon(Icons.account_balance);
              break;
            case 'zoo':
              icon = new Icon(Icons.landscape);
              break;
            case 'viewpoint':
              icon = new Icon(Icons.monochrome_photos);
              break;
            default:
              icon = new Icon(Icons.mood);
              break;
          }
        } else {
          icon = new Icon(Icons.adb);
        }
        viewWidgets.add(new ListTile(
          leading: new CircleAvatar(
            child: icon,
            backgroundColor: Colors.red,
          ),
          title: new Text(value['title']),
          subtitle: new Text('Rating: ' + value['rating'].toString() + '/5'),
        ));
        if (value['vr'] != null) {
          viewWidgets.add(new ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('SHOW IN VR'),
                  onPressed: () { _launchUrl(value['vr'], ); },
                ),
              ],
            ),
          ));
        }
        if (value['needs_ticket']) {
          if (value['paid']) {
            viewWidgets.add(new ButtonTheme.bar( // make buttons use the appropriate styles for cards
              child: new ButtonBar(
                children: <Widget>[
                  new Text('Price: ' + value['price'].toString() + 'CHF'),
                  new FlatButton(
                    child: const Text('SHOW TICKETS'),
                    onPressed: () { _showTicket(context, value, day.date); },
                  ),
                ],
              ),
            ));
          } else {
            viewWidgets.add(new ButtonTheme.bar( // make buttons use the appropriate styles for cards
              child: new ButtonBar(
                children: <Widget>[
                  new Text('Price: ' + value['price'].toString() + 'CHF'),
                  new FlatButton(
                    child: const Text('BUY TICKETS'),
                    onPressed: () { _buyTicket(context, value, day.date); },
                  ),
                ],
              ),
            ));
          }
        }
      }

      day.tours.forEach(iterateMapEntry);
      List<TourWidget> views = day.tours.map((tour) => new TourWidget(tour)).toList();
      TourWidget getTourWidgets(TourWidget widget) {
        return widget;
      }

      return new ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0.0),
        children: viewWidgets,
      );
    }
  }
}

class TravelTabFull extends StatelessWidget {
  Travel travel;
  List<TravelDay> travelDays;

  TravelTabFull(Travel travel, List<TravelDay> travelDays) {
    this.travel = travel;
    this.travelDays = travelDays;
  }

  void _showTicket(context, value, date) {
    AlertDialog dialog = new AlertDialog(
      content: new Column(
        children: <Widget>[
          new Text(
              value['title'],
              style: new TextStyle(fontSize: 30.0)
          ),
          new Text(
            date.day.toString() + '.' + date.month.toString() + '.' + date.year.toString(),
            style: new TextStyle(color: Colors.grey),
          ),
          new Divider(),
          new Image.asset('assets/qr.png'),
          new Text('1 Adult - ' + value['price'].toString() + ' CHF'),
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: new Text('OK')),
      ],
    );

    showDialog(context: context, child: dialog);
  }

  void _buyTicket(context, value, date) {
    AlertDialog dialog = new AlertDialog(
      content: new Column(
        children: <Widget>[
          new Text(
              value['title'],
              style: new TextStyle(fontSize: 30.0)
          ),
          new Text(
            date.day.toString() + '.' + date.month.toString() + '.' + date.year.toString(),
            style: new TextStyle(color: Colors.grey),
          ),
          new Divider(),
          new Text(
            '1 Adult - ' + value['price'].toString() + ' CHF',
            style: new TextStyle(fontSize: 20.0),
          ),
          new TextField(
            autocorrect: false,
            maxLines: 1,
            decoration: new InputDecoration(
              hintText: 'XXXX-XXXX-XXXX-XXXX',
              labelText: 'Credit Card',
            ),
          ),
          new TextField(
            autocorrect: false,
            maxLines: 1,
            decoration: new InputDecoration(
              hintText: 'XX-XX',
              labelText: 'Valid until',
            ),
          ),
          new TextField(
            autocorrect: false,
            maxLines: 1,
            decoration: new InputDecoration(
              hintText: 'XXX',
              labelText: 'CSV',
            ),
          ),
          new Text(' '),
          new Row(
            children: <Widget>[
              new RaisedButton(
                child: new Text('Buy'),
                onPressed: (){Navigator.pop(context);},
                color: Colors.redAccent,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: new Text('Cancel')),
      ],
    );

    showDialog(context: context, child: dialog);
  }

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (travelDays == null) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CupertinoActivityIndicator(),
          new Text("Loading ..."),
        ],
      );
    } else {
      List<Widget> viewWidgets = <Widget>[];
      var curDay;

      void iterateMapEntry(value) {
        viewWidgets.add(new Divider());
        Icon icon;
        if (value['type'] == 'acitivity') {
          switch (value['category']) {
            case 'church':
              icon = new Icon(Icons.account_balance);
              break;
            case 'zoo':
              icon = new Icon(Icons.landscape);
              break;
            case 'viewpoint':
              icon = new Icon(Icons.monochrome_photos);
              break;
            case 'park':
              icon = new Icon(Icons.nature_people);
              break;
            case 'shopping_mall':
              icon = new Icon(Icons.shopping_cart);
              break;
            case 'museum':
              icon = new Icon(Icons.format_paint);
              break;
            default:
              icon = new Icon(Icons.mood);
              break;
          }
        } else if (value['type'] == 'transportation') {
          value['title'] = 'Train: ' + value['origin'] + ' to ' + value['destination'];
          icon = new Icon(Icons.train);
        } else {
          icon = new Icon(Icons.adb);
        }
        Widget title = new Text(value['title'] != null ? value['title'] : 'adu plox! 376');
        Widget subtitle = new Text('Rating: ' + value['rating'].toString() + '/5');
        if (value['type'] == 'transportation') {
          title = new Text(
            'Train: ' + value['origin'] + ' to ' + value['destination'],
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
            ),
          );
          subtitle = new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Expanded( child: new Text('Departure')),
                  new Expanded( child: new Text('Arrival')),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Expanded( child: new Text(value['departure'])),
                  new Expanded( child: new Text(value['arrival'])),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Expanded( child: new Text('Track ' + value['departure_platform'].toString())),
                  new Expanded( child: new Text('Track ' + value['arrival_platform'].toString())),
                ],
              ),
              new ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: new ButtonBar(
                  children: <Widget>[
                    new Text('Price: ' + value['price'].toString() + 'CHF'),
                    new FlatButton(
                      child: new Text(value['paid'] ? 'SHOW TICKETS' : 'BUY TICKETS'),
                      onPressed: () { if (value['paid']) {
                        _showTicket(context, value, curDay.date);
                      } else {
                        _buyTicket(context, value, curDay.date);
                      } },
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        viewWidgets.add(new ListTile(
          leading: new CircleAvatar(
            child: icon,
            backgroundColor: Colors.red,
          ),
          title: title,
          subtitle: subtitle,
        ));
        if (value['vr'] != null) {
          viewWidgets.add(new ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('SHOW IN VR'),
                  onPressed: () { _launchUrl(value['vr'], ); },
                ),
              ],
            ),
          ));
        }
        if (value['needs_ticket'] != null && value['needs_ticket']) {
          if (value['paid']) {
            viewWidgets.add(new ButtonTheme.bar( // make buttons use the appropriate styles for cards
              child: new ButtonBar(
                children: <Widget>[
                  new Text('Price: ' + value['price'].toString() + 'CHF'),
                  new FlatButton(
                    child: const Text('SHOW TICKETS'),
                    onPressed: () { _showTicket(context, value, curDay.date); },
                  ),
                ],
              ),
            ));
          } else {
            viewWidgets.add(new ButtonTheme.bar( // make buttons use the appropriate styles for cards
              child: new ButtonBar(
                children: <Widget>[
                  new Text('Price: ' + value['price'].toString() + 'CHF'),
                  new FlatButton(
                    child: const Text('BUY TICKETS'),
                    onPressed: () { _buyTicket(context, value, curDay.date); },
                  ),
                ],
              ),
            ));
          }
        }
      }

      void iterateDayEntry(day) {
        curDay = day;
        viewWidgets.add(
          new Divider()
        );
        viewWidgets.add(
          new ListTile(
            title: new Text(
              day.city,
              style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0
              ),
            ),
            subtitle: new Text(
              day.date.day.toString() + '.' + day.date.month.toString() + '.' + day.date.year.toString(),
              style: new TextStyle(fontSize: 25.0),
            ),
          ),
        );

        if (day.tours.length > 0) {
          day.tours.forEach(iterateMapEntry);
        } else {
          viewWidgets.add(
            new Row(
              children: <Widget>[
                new Expanded(child: new Padding(
                padding: new EdgeInsets.all(3.0),
                  child: new RaisedButton(
                      child: new Text('Church'),
                      onPressed: (){
                        Navigator.push(context, new MaterialPageRoute(
                          builder: (BuildContext context) => new TravelSelectionPage(day.toString(), 'church'),
                        ));
                      },
                      color: Colors.redAccent,
                  )
                )),
                new Expanded(child: new Padding(
                padding: new EdgeInsets.all(3.0),
                child: new RaisedButton(
                  child: new Text('Zoo'),
                    onPressed: (){
                      Navigator.push(context, new MaterialPageRoute(
                        builder: (BuildContext context) => new TravelSelectionPage(day.toString(), 'zoo'),
                      ));
                    },
                    color: Colors.redAccent,
                  )
                )),
                new Expanded(child: new Padding(
                  padding: new EdgeInsets.all(3.0),
                  child: new RaisedButton(
                    child: new Text('Viewpoint'),
                    onPressed: (){
                      Navigator.push(context, new MaterialPageRoute(
                        builder: (BuildContext context) => new TravelSelectionPage(day.toString(), 'viewpoint'),
                      ));
                    },
                    color: Colors.redAccent,
                  )
                )),
              ],
            )
          );
          viewWidgets.add(new Row(
              children: <Widget>[
                new Expanded(child: new Padding(
                  padding: new EdgeInsets.all(3.0),
                  child: new RaisedButton(
                      child: new Text('Park'),
                      onPressed: (){
                        Navigator.push(context, new MaterialPageRoute(
                          builder: (BuildContext context) => new TravelSelectionPage(day.toString(), 'park'),
                        ));
                      },
                      color: Colors.redAccent,
                  )
                )),
                new Expanded(child: new Padding(
                  padding: new EdgeInsets.all(3.0),
                  child: new RaisedButton(
                            child: new Text('Shopping'),
                            onPressed: (){
                              Navigator.push(context, new MaterialPageRoute(
                                builder: (BuildContext context) => new TravelSelectionPage(day.toString(), 'shopping_mall'),
                              ));
                            },
                            color: Colors.redAccent,
                  )
                )),
                new Expanded(child: new Padding(
                  padding: new EdgeInsets.all(3.0),
                  child: new RaisedButton(
                    child: new Text('Museum'),
                    onPressed: (){
                      Navigator.push(context, new MaterialPageRoute(
                        builder: (BuildContext context) => new TravelSelectionPage(day.toString(), 'museum'),
                      ));
                    },
                    color: Colors.redAccent,
                  )
                ),
                )
              ],
            )
          );
        }
        List<TourWidget> views = day.tours.map((tour) => new TourWidget(tour)).toList();
      }

      travelDays.forEach(iterateDayEntry);

      TourWidget getTourWidgets(TourWidget widget) {
        return widget;
      }

      return new ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0.0),
        children: viewWidgets,
      );
    }
  }
}

class TravelTabTickets extends StatelessWidget {
  Travel travel;
  List<TravelDay> travelDays;

  TravelTabTickets(Travel travel, List<TravelDay> travelDays) {
    this.travel = travel;
    this.travelDays = travelDays;
  }

  void _showTicket(context, value, date) {
    AlertDialog dialog = new AlertDialog(
      content: new Column(
        children: <Widget>[
          new Text(
              value['title'],
              style: new TextStyle(fontSize: 30.0)
          ),
          new Text(
            date.day.toString() + '.' + date.month.toString() + '.' + date.year.toString(),
            style: new TextStyle(color: Colors.grey),
          ),
          new Divider(),
          new Image.asset('assets/qr.png'),
          new Text('1 Adult - ' + value['price'].toString() + ' CHF'),
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: new Text('OK')),
      ],
    );

    showDialog(context: context, child: dialog);
  }

  void _buyTicket(context, value, date) {
    AlertDialog dialog = new AlertDialog(
      content: new Column(
        children: <Widget>[
          new Text(
              value['title'],
              style: new TextStyle(fontSize: 30.0)
          ),
          new Text(
            date.day.toString() + '.' + date.month.toString() + '.' + date.year.toString(),
            style: new TextStyle(color: Colors.grey),
          ),
          new Divider(),
          new Text(
            '1 Adult - ' + value['price'].toString() + ' CHF',
            style: new TextStyle(fontSize: 20.0),
          ),
          new TextField(
            autocorrect: false,
            maxLines: 1,
            decoration: new InputDecoration(
              hintText: 'XXXX-XXXX-XXXX-XXXX',
              labelText: 'Credit Card',
            ),
          ),
          new TextField(
            autocorrect: false,
            maxLines: 1,
            decoration: new InputDecoration(
              hintText: 'XX-XX',
              labelText: 'Valid until',
            ),
          ),
          new TextField(
            autocorrect: false,
            maxLines: 1,
            decoration: new InputDecoration(
              hintText: 'XXX',
              labelText: 'CSV',
            ),
          ),
          new Text(' '),
          new Row(
            children: <Widget>[
              new RaisedButton(
                child: new Text('Buy'),
                onPressed: (){Navigator.pop(context);},
                color: Colors.redAccent,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(onPressed: (){
          Navigator.pop(context);
        }, child: new Text('Cancel')),
      ],
    );

    showDialog(context: context, child: dialog);
  }

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (travelDays == null) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CupertinoActivityIndicator(),
          new Text("Loading ..."),
        ],
      );
    } else {
      List<Widget> viewWidgets = <Widget>[];
      var curDay;

      void iterateMapEntry(value) {
        if (value['paid'] != null && value['paid']) {
          viewWidgets.add(new Divider());
          Icon icon;
          if (value['type'] == 'acitivity') {
            switch (value['category']) {
              case 'church':
                icon = new Icon(Icons.account_balance);
                break;
              case 'zoo':
                icon = new Icon(Icons.landscape);
                break;
              case 'viewpoint':
                icon = new Icon(Icons.monochrome_photos);
                break;
              default:
                icon = new Icon(Icons.mood);
                break;
            }
          } else if (value['type'] == 'transportation') {
            value['title'] =
                'Train: ' + value['origin'] + ' to ' + value['destination'];
            icon = new Icon(Icons.train);
          } else {
            icon = new Icon(Icons.adb);
          }
          Widget title = new Text(
              value['title'] != null ? value['title'] : 'adu plox! 376');
          Widget subtitle = new Text(
              'Rating: ' + value['rating'].toString() + '/5');
          if (value['type'] == 'transportation') {
            title = new Text(
              'Train: ' + value['origin'] + ' to ' + value['destination'],
              style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0
              ),
            );
            subtitle = new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Expanded(child: new Text('Departure')),
                    new Expanded(child: new Text('Arrival')),
                  ],
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(child: new Text(value['departure'])),
                    new Expanded(child: new Text(value['arrival'])),
                  ],
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(child: new Text(
                        'Track ' + value['departure_platform'].toString())),
                    new Expanded(child: new Text(
                        'Track ' + value['arrival_platform'].toString())),
                  ],
                ),
                new ButtonTheme
                    .bar( // make buttons use the appropriate styles for cards
                  child: new ButtonBar(
                    children: <Widget>[
                      new Text('Price: ' + value['price'].toString() + 'CHF'),
                      new FlatButton(
                        child: new Text(
                            value['paid'] ? 'SHOW TICKETS' : 'BUY TICKETS'),
                        onPressed: () {
                          if (value['paid']) {
                            _showTicket(context, value, curDay.date);
                          } else {
                            _buyTicket(context, value, curDay.date);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          viewWidgets.add(new ListTile(
            leading: new CircleAvatar(
              child: icon,
              backgroundColor: Colors.red,
            ),
            title: title,
            subtitle: subtitle,
          ));
          if (value['vr'] != null) {
            viewWidgets.add(new ButtonTheme
                .bar( // make buttons use the appropriate styles for cards
              child: new ButtonBar(
                children: <Widget>[
                  new FlatButton(
                    child: const Text('SHOW IN VR'),
                    onPressed: () {
                      _launchUrl(value['vr'],);
                    },
                  ),
                ],
              ),
            ));
          }
          if (value['needs_ticket'] != null && value['needs_ticket']) {
            if (value['paid']) {
              viewWidgets.add(new ButtonTheme
                  .bar( // make buttons use the appropriate styles for cards
                child: new ButtonBar(
                  children: <Widget>[
                    new Text('Price: ' + value['price'].toString() + 'CHF'),
                    new FlatButton(
                      child: const Text('SHOW TICKETS'),
                      onPressed: () {
                        _showTicket(context, value, curDay.date);
                      },
                    ),
                  ],
                ),
              ));
            } else {
              viewWidgets.add(new ButtonTheme
                  .bar( // make buttons use the appropriate styles for cards
                child: new ButtonBar(
                  children: <Widget>[
                    new Text('Price: ' + value['price'].toString() + 'CHF'),
                    new FlatButton(
                      child: const Text('BUY TICKETS'),
                      onPressed: () {
                        _buyTicket(context, value, curDay.date);
                      },
                    ),
                  ],
                ),
              ));
            }
          }
        }
      }

      void iterateDayEntry(day) {
        curDay = day;
        viewWidgets.add(
          new ListTile(
            title: new Text(
              day.city,
              style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0
              ),
            ),
            subtitle: new Text(day.date.day.toString() + '.' + day.date.month.toString() + '.' + day.date.year.toString()),
          ),
        );

        day.tours.forEach(iterateMapEntry);
        List<TourWidget> views = day.tours.map((tour) => new TourWidget(tour)).toList();
      }

      travelDays.forEach(iterateDayEntry);

      TourWidget getTourWidgets(TourWidget widget) {
        return widget;
      }

      return new ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0.0),
        children: viewWidgets,
      );
    }
  }
}

class TravelSelectionPage extends StatefulWidget {
  TravelSelectionPage(city, target) {
    this.city = city;
    this.target = target;
  }

  var city;
  String target;

  @override
  _TravelSelectionPageState createState() => new _TravelSelectionPageState(city, target);
}

class _TravelSelectionPageState extends State<TravelSelectionPage> {
  var travelOptions = <TravelOption>[];
  var city;
  var target;

  final GlobalKey<ScaffoldState> _scaffoldstate = new GlobalKey<ScaffoldState>();

  _TravelSelectionPageState(city, target) {
    this.city = city;
    this.target = target;
  }

  @override
  initState() {
    super.initState();
    listenForTravels();
  }

  listenForTravels() async {
    var stream = await getTravelOption(city, target);
    stream.listen((travelOption) => setState(() => travelOptions.add(travelOption)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldstate,
        appBar: new AppBar(
          title: new Text('Plan your day'),
        ),
        body: new Center(
          child: new ListView(
            children: travelOptions.map((travelOption) => new TravelOptionWidget(travelOption, _scaffoldstate)).toList(),
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

class TravelOptionWidget extends StatelessWidget {
  TravelOptionWidget(this.travelOption, this._scaffoldstate);
  final TravelOption travelOption;
  final GlobalKey<ScaffoldState> _scaffoldstate;

  void _showSnackBar(String value) {
    if(value.isEmpty) return;
    _scaffoldstate.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
    ),);
  }

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    var listTile = new ListTile(
      leading: new CircleAvatar(
        child: travelOption.icon,
        backgroundColor: Colors.red,
      ),
      title: new Text(travelOption.title),
      subtitle: new Text(travelOption.address + ' - Rating: ' + travelOption.rating.toString() + '/5'),
      onLongPress: () {
        _launchUrl('https://www.google.com/maps/?q='+ travelOption.title + ' ' + travelOption.address + ' ' + travelOption.city + ', ' + travelOption.lat.toString() + ',' + travelOption.lng.toString());
      },
    );

    return new Dismissible(
      key: new Key(travelOption.title),
      background: new Container(color: Colors.green),
      secondaryBackground: new Container(color: Colors.red),
      onDismissed: (dir) {
        if (dir == DismissDirection.startToEnd) {
          _showSnackBar('${travelOption.title} has been added to your trip');
        } else {
          _showSnackBar('${travelOption.title} was removed from your trip');
        }
      },
      child: listTile,
    );
  }
}

class TourWidget extends StatelessWidget {
  TourWidget(this.tour);
  final tour;

  @override
  Widget build(BuildContext context) {
    var listTile = new ListTile(
      leading: new CircleAvatar(
        child: new Text('Foo'),
        backgroundColor: Colors.red,
      ),
      title: new Text('Title'),
      subtitle: new Text('Subtitle'),
      /*onTap: () {
        Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new TravelPage(travel),
        ));
      },*/
    );

    return listTile;
  }
}
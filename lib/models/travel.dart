// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;

main() {
  getTravels();
}

class Travel {
  final int key;
  final String title;
  final DateTime start;
  final DateTime end;
  final int days;

  Travel.fromJson(Map jsonTravel) :
        key = jsonTravel['key'],
        title = jsonTravel['title'],
        start = DateTime.parse(jsonTravel['start']),
        end = DateTime.parse(jsonTravel['end']),
        days = jsonTravel['days'];

  String toString() => 'Travel: $title';
  String getFromTo() => start.day.toString() + '.' + start.month.toString() + (start.day != end.day || start.month != end.month ? '-' + end.day.toString() + '.' : '') + end.month.toString() + '.' + end.year.toString();
}

Future<Stream<Travel>> getTravels() async {
  //var url = 'https://hackpreview.hirt.one/api/trips';
  var url = 'https://pascalwacker.github.io/starthack-sbb-discover-switzerland-app/mock/trips.json';

  var client = new http.Client();
  var streamedRes = await client.send(new http.Request('get', Uri.parse(url)));

  return streamedRes.stream
      .transform(UTF8.decoder)
      .transform(JSON.decoder)
      .expand((jsonBody) => (jsonBody as Map)['travels'] )
      .map((jsonTravel) => new Travel.fromJson(jsonTravel));
}

class TravelDay {
  final DateTime date;
  final String city;
  final List tours;

  TravelDay.fromJson(Map jsonTravelDay) :
      date = DateTime.parse(jsonTravelDay == null ? 'now' : jsonTravelDay['date']),
      city = jsonTravelDay == null ? 'Test Stadt' : jsonTravelDay['city'],
      tours = jsonTravelDay['tour']/*jsonTravelDay['tour'].map((tourData) => new Tour.fromJson(tourData))*/;

  String toString() => '$city';
}

Future<Stream<TravelDay>> getTravelDay(Travel travel) async {
  //var url = 'https://hackpreview.hirt.one/api/trips/' + travel.key.toString();
  var url = 'https://pascalwacker.github.io/starthack-sbb-discover-switzerland-app/mock/trips-' + travel.key.toString() + '.json';

  var client = new http.Client();
  var streamedRes = await client.send(new http.Request('get', Uri.parse(url)));

  return streamedRes.stream
      .transform(UTF8.decoder)
      .transform(JSON.decoder)
      .expand((jsonBody) => (jsonBody == null ? null : (jsonBody as Map)['days']) )
      .map((jsonTravelDay) => new TravelDay.fromJson(jsonTravelDay));
}

class TravelOption {
  final String title;
  final String address;
  final String city;
  final double rating;
  final double lat;
  final double lng;
  final Icon icon;

  TravelOption.fromJson(Map jsonTravelOption, String category, String city) :
        title = jsonTravelOption['name'],
        address = jsonTravelOption['address'],
        rating = jsonTravelOption['rating'] != null ? jsonTravelOption['rating'] : 3.5,
        lat = jsonTravelOption['lat'],
        lng = jsonTravelOption['lng'],
        this.city = city,
        icon = (category == 'church' ? new Icon(Icons.account_balance) :
               (category == 'zoo' ? new Icon(Icons.landscape) :
               (category == 'viewpoint' ? new Icon(Icons.monochrome_photos) :
               (category == 'park' ? new Icon(Icons.nature_people) :
               (category == 'shopping_mall' ? new Icon(Icons.shopping_cart) :
               (category == 'museum' ? new Icon(Icons.format_paint) : new Icon(Icons.mood)))))));

  String toString() => '$title';
}

Future<Stream<TravelOption>> getTravelOption(city, category) async {
  //var url = 'https://hackpreview.hirt.one/api/points/' + city + '/' + category + '/';
  var url = 'https://pascalwacker.github.io/starthack-sbb-discover-switzerland-app/mock/' + city + '-' + category + '.json';

  var client = new http.Client();
  var streamedRes = await client.send(new http.Request('get', Uri.parse(url)));

  return streamedRes.stream
      .transform(UTF8.decoder)
      .transform(JSON.decoder)
      .expand((jsonBody) => (jsonBody as Map)['data'] )
      .map((jsonTravelOption) => new TravelOption.fromJson(jsonTravelOption, category, city));
}

class Tour {
  final String type;
  final String title;
  final double rating;
  final String category;
  final bool need_ticket;

  final String origin;
  final String destination;
  final String departure;
  final String arrival;
  final int departure_platform;
  final int arrival_platform;
  final double price;
  final bool paid;

  Tour.fromJson(Map jsonData):
      type = jsonData['type'],
      title = jsonData['title'],
      rating = jsonData['rating'] != null && jsonData['rating'] > 0 ? jsonData['rating'] : 3.5,
      category = jsonData['category'],
      need_ticket = jsonData['need_ticket'],

      origin = jsonData['origin'] != null ? jsonData['origin'] : '',
      destination = jsonData['destination'] != null ? jsonData['destination'] : '',
      departure = jsonData['departure'] != null ? jsonData['departure'] : '',
      arrival = jsonData['arrival'] != null ? jsonData['arrival'] : '',
      departure_platform = jsonData['departure_platform'] != null ? jsonData['departure_platform'] : 5,
      arrival_platform = jsonData['arrival_platform'] != null ? jsonData['arrival_platform'] : 3,
      price = jsonData['price'] != null ? jsonData['price'] : 21.5,
      paid = jsonData['paid'] != null ? jsonData['paid'] : false
      ;
}
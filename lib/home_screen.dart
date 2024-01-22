import 'package:flutter/material.dart';
import 'dart:convert';

import 'article_screen.dart';
import 'news_data.dart';

import 'package:flutter/material.dart';
// New: Add this import
import 'package:home_widget/home_widget.dart';

import 'article_screen.dart';
import 'news_data.dart';

// New: Add these constants
// TO DO: Replace with your App Group ID
const String appGroupId = 'group.widgetshome';
const String iOSWidgetName = 'widgets2';
const String androidWidgetName = 'widgets2';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Item {
  Item({required this.name, required this.status, required this.color});

  late String name;
  late String color;
  late int status;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'color': color,
        'status': status,
      };
  String toJsonString() {
    return jsonEncode(toJson());
  }
}

// New: add this function
void updateHeadline(NewsArticle newHeadline) {
  // Save the headline data to the widget
  List<Item> list = [
    Item(color: '235,85,70,1', name: '111', status: 1),
    Item(color: '235,85,70,1', name: '222', status: 0),
  ];
  String value = jsonEncode(list.map((item) => item.toJson()).toList());
  HomeWidget.saveWidgetData('value', value);
  HomeWidget.updateWidget(
    iOSName: iOSWidgetName,
    androidName: androidWidgetName,
  );
}

class _MyHomePageState extends State<MyHomePage> {
  // New: Add initState
  @override
  void initState() {
    super.initState();

    // Set the group ID
    HomeWidget.setAppGroupId(appGroupId);

    // Mock read in some data and update the headline
    final newHeadline = getNewsStories()[0];
    print('newHeadline$newHeadline');
    updateHeadline(newHeadline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Top Stories'),
            centerTitle: false,
            titleTextStyle: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        body: ListView.separated(
          separatorBuilder: (context, idx) {
            return const Divider();
          },
          itemCount: getNewsStories().length,
          itemBuilder: (context, idx) {
            final article = getNewsStories()[idx];
            return ListTile(
              key: Key('$idx ${article.hashCode}'),
              title: Text(article.title!),
              subtitle: Text(article.description!),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ArticleScreen(article: article);
                    },
                  ),
                );
              },
            );
          },
        ));
  }
}

class MyHomePage2 extends StatefulWidget {
  const MyHomePage2({super.key});
  @override
  State<MyHomePage2> createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Top Stories'),
            centerTitle: false,
            titleTextStyle: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        body: ListView.separated(
          separatorBuilder: (context, idx) {
            return const Divider();
          },
          itemCount: getNewsStories().length,
          itemBuilder: (context, idx) {
            final article = getNewsStories()[idx];
            return ListTile(
              key: Key('$idx ${article.hashCode}'),
              title: Text(article.title),
              subtitle: Text(article.description),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<ArticleScreen>(
                    builder: (context) {
                      return ArticleScreen(article: article);
                    },
                  ),
                );
              },
            );
          },
        ));
  }
}

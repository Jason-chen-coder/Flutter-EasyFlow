// ignore_for_file: public_member_api_docs

import 'package:flutter_easy_flow/pages/custom_flow_chart.dart';
import 'package:flutter_easy_flow/pages/default_flow_chart.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Flow',
      theme: ThemeData(
        hintColor: Colors.orange,
        chipTheme: ChipThemeData(
          backgroundColor: Colors.blueAccent, // 设置ActionChip的背景色
          labelStyle: TextStyle(color: Colors.white), // 设置ActionChip的文本样式
        ),
        listTileTheme: ListTileThemeData(
          selectedTileColor: Colors.blue[50],
          selectedColor: Colors.blue,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      home: const MyHomePage(),
    );
  }
}

///
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _pages = [
    DefaultFlowChart(),
    CustomFlowChart(),
  ];
  final List<String> _titles = ['Default Flow', 'Custom Flow'];
  int _currentIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 80, // 自定义高度
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(_titles[0]),
              selected: _currentIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(_titles[1]),
              selected: _currentIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
      body: _pages[_currentIndex],
    );
  }
}

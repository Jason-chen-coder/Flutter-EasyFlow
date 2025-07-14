// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_easy_flow/pages/custom_flow_chart.dart';
import 'package:flutter_easy_flow/pages/default_flow_chart.dart';
import 'package:flutter_easy_flow/services/theme_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Flow',
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: themeService.themeMode,
          home: const MyHomePage(),
        );
      },
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
  final List<String> _titles = ['Default Flow', 'Flutter-EasyFlow'];
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
        actions: [
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return IconButton(
                icon: Icon(
                  themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeService.toggleTheme(),
                tooltip: themeService.isDarkMode ? '切换到浅色主题' : '切换到深色主题',
              );
            },
          ),
        ],
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       Container(
      //         height: 80, // 自定义高度
      //         color: Colors.blue,
      //         child: Padding(
      //           padding: const EdgeInsets.all(16.0),
      //           child: Text(
      //             'Menu',
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontSize: 24,
      //             ),
      //           ),
      //         ),
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.home),
      //         title: Text(_titles[0]),
      //         selected: _currentIndex == 0,
      //         onTap: () {
      //           _onItemTapped(0);
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.settings),
      //         title: Text(_titles[1]),
      //         selected: _currentIndex == 1,
      //         onTap: () {
      //           _onItemTapped(1);
      //           Navigator.pop(context);
      //         },
      //       )
      //     ],
      //   ),
      // ),
      body: _pages[_currentIndex],
    );
  }
}

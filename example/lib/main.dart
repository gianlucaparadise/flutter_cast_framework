import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast/CastContext.dart';
import 'package:flutter_cast_framework/cast/widgets/CastButton.dart';
import 'package:flutter_cast_framework/flutter_cast_framework.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CastState _castState;

  @override
  void initState() {
    super.initState();
    FlutterCastFramework.castContext.state.addListener(_onCastStateChanged);
  }

  void _onCastStateChanged() {
    debugPrint("Cast state changed from example");
    setState(() {
      _castState = FlutterCastFramework.castContext.state.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cast plugin example app'),
        ),
        body: Center(
            child: Column(
          children: [Text('Cast State: $_castState'), CastButton()],
        )),
      ),
    );
  }
}

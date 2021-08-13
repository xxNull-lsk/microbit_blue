import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:microbit_blue/gamepad.dart';
import 'microbit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mico:Bit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Mico:Bit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  Map<String, ScanResult> scanResults = {};
  List<String> allBlueNameAry = [];
  bool isScanning = false;

  void _stopScan() {
    flutterBlue.stopScan();
    isScanning = false;
  }

  void _startScan() {
    try {
      flutterBlue.startScan();
      isScanning = true;
    } catch (e) {
      print('startScan failed!');
      return;
    }
    flutterBlue.scanResults.listen((results) {
      // 扫描结果 可扫描到的所有蓝牙设备
      allBlueNameAry.clear();
      setState(() {});
      for (ScanResult r in results) {
        if (r.device.name.indexOf("micro:bit") <= 0) {
          continue;
        }
        scanResults[r.device.name] = r;
        if (r.device.name.length > 0) {
          print('${r.device.name} found! rssi: ${r.rssi}');
          if (allBlueNameAry.indexOf(r.device.name) > 0) {
            continue;
          }
          allBlueNameAry.add(r.device.name);
          setState(() {});
        }
      }
    });
  }

  Future<void> _onPressed(var deviceName) async {
    _stopScan();
    var result = scanResults[deviceName];
    if (result == null) {
      return;
    }
    result.device.connect().then((value) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return GamepadPage(
              device: result.device,
            );
          },
        ),
      ).then((value) => result.device.disconnect());
    });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index >= allBlueNameAry.length) {
      return Container(
        child: Text("没有更多"),
      );
    }

    return Container(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
            onPressed: () {
              _onPressed(allBlueNameAry[index]);
            },
            icon: Icon(Icons.bluetooth),
            label: Text(allBlueNameAry[index])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.bluetooth,
          color: Colors.white,
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            disabledColor: Colors.grey,
            onPressed: isScanning ? null : _startScan,
            icon: Icon(Icons.scanner),
          ),
          IconButton(
            disabledColor: Colors.grey,
            onPressed: isScanning ? _stopScan : null,
            icon: Icon(Icons.stop),
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemBuilder: _itemBuilder,
          itemCount: allBlueNameAry.length,
        ),
      ),
    );
  }
}

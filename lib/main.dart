import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:microbit_blue/gamepad.dart';
import 'package:microbit_blue/myIcons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micro:Bit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Micro:Bit'),
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
  List<String> microbitBlueNameAry = [];
  bool isScanning = false;
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      _startScan();
    });
  }

  void _stopScan() {
    Fluttertoast.showToast(msg: "停止搜索蓝牙设备");
    flutterBlue.stopScan();
    isScanning = false;
    setState(() {});
  }

  void _startScan() {
    Fluttertoast.showToast(msg: "开始搜索蓝牙设备");
    try {
      flutterBlue.startScan();
      isScanning = true;
    } catch (e) {
      Fluttertoast.showToast(msg: "启动scan失败!$e");
      isScanning = false;
      return;
    }
    microbitBlueNameAry.clear();
    setState(() {});
    flutterBlue.scanResults.listen((results) {
      // 扫描结果 可扫描到的所有蓝牙设备
      for (ScanResult r in results) {
        if (r.device.name.length <= 0) {
          continue;
        }
        var name = "${r.device.name} - ${r.device.id.toString()}";
        if (microbitBlueNameAry.contains(name)) {
          continue;
        }
        Fluttertoast.showToast(msg: "发现$name");
        scanResults[name] = r;
        microbitBlueNameAry.add(name);
      }
      setState(() {});
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
    if (index >= microbitBlueNameAry.length) {
      return Container(
        child: Text("没有更多"),
      );
    }

    return Container(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
            onPressed: () {
              _onPressed(microbitBlueNameAry[index]);
            },
            icon: Icon(Icons.bluetooth),
            label: Text(microbitBlueNameAry[index])));
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
            icon:
                Icon(MyIcons.bluetooth_searching, color: Colors.blue, size: 32),
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
          itemCount: microbitBlueNameAry.length,
        ),
      ),
    );
  }
}

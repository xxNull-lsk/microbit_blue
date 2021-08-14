import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:orientation/orientation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'microbit.dart';

class GamepadPage extends StatefulWidget {
  GamepadPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _GamepadPageState createState() => _GamepadPageState();
}

class _GamepadPageState extends State<GamepadPage> {
  void initState() {
    super.initState();
    //隐藏状态栏和导航栏
    SystemChrome.setEnabledSystemUIOverlays([]);

    //隐藏底部导航栏
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

    //隐藏状态栏
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
  }

  void deactivate() {
    super.deactivate();
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    //恢复默认
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  Future<void> _onPressed(String txt) async {
    var services = await widget.device.discoverServices();
    Fluttertoast.showToast(msg: txt);

    await uartSend(services, txt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("游戏手柄"),
        actions: [
          IconButton(
            disabledColor: Colors.grey,
            onPressed: null,
            icon: Icon(Icons.home),
          ),
          IconButton(
            disabledColor: Colors.grey,
            onPressed: null,
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: _renderArrow()),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderRowItem(List<String> _items) {
    var btnIcons = {
      "up": Icons.arrow_upward,
      "down": Icons.arrow_downward,
      "left": Icons.arrow_back,
      "right": Icons.arrow_forward,
      "1": Icons.looks_one,
      "2": Icons.looks_two,
      "3": Icons.looks_3,
      "4": Icons.looks_4,
      "start": Icons.play_arrow,
      "stop": Icons.stop,
    };
    var btnColors = {
      "1": Colors.deepOrange,
      "2": Colors.deepOrange,
      "3": Colors.deepPurple,
      "4": Colors.deepPurple,
      "start": Colors.green,
      "stop": Colors.red,
    };
    List<Widget> items = [];
    for (var item in _items) {
      if (item == "") {
        items.add(Text(""));
      } else if (item == "-") {
        items.add(Text(""));
      } else {
        items.add(IconButton(
          onPressed: () => _onPressed(item),
          icon: Icon(btnIcons[item]),
          color: btnColors[item],
          iconSize: 48,
        ));
      }
    }
    return items;
  }

  List<TableRow> _renderArrow() {
    List<TableRow> items = [];
    var rowItems = [
      ["", "", "", "-", "-", "", "", ""],
      ["", "up", "", "-", "-", "", "1", ""],
      ["left", "", "right", "-", "-", "2", "", "3"],
      ["", "down", "", "-", "-", "", "4", ""],
      ["", "", "", "start", "stop", "", "", ""],
    ];
    for (var row in rowItems) {
      items.add(TableRow(children: _renderRowItem(row)));
    }
    return items;
  }
}

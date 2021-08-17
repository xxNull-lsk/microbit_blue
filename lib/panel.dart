import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:orientation/orientation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'gamepad.dart';
import 'microbit.dart';

class PanelPage extends StatefulWidget {
  PanelPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _PanelPageState createState() => _PanelPageState();
}

class _PanelPageState extends State<PanelPage> {
  void initState() {
    super.initState();
    //隐藏状态栏和导航栏
    SystemChrome.setEnabledSystemUIOverlays([]);

    //隐藏底部导航栏
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

    //隐藏状态栏
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
    Timer.periodic(Duration(seconds: 1), onTimer);
  }

  var buttonsColor = {
    "logo": Colors.grey,
    "A": Colors.grey,
    "B": Colors.grey,
    "T": Colors.grey,
  };

  var labelValues = {
    "logo": "",
    "A": "",
    "B": "",
    "T": "",
  };

  Future<void> onTimer(var timer) async {
    var services = await widget.device.discoverServices();
    int state = await getButtonA(services);
    if (state != 0) {
      labelValues["A"] = "已按下";
      buttonsColor["A"] = Colors.green;
    } else {
      labelValues["A"] = "";
      buttonsColor["A"] = Colors.grey;
    }

    state = await getButtonB(services);
    if (state != 0) {
      labelValues["B"] = "已按下";
      buttonsColor["B"] = Colors.green;
    } else {
      labelValues["B"] = "";
      buttonsColor["B"] = Colors.grey;
    }
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

    switch (txt) {
      case 'A':
        await clickButtonA(services);
        break;
      case 'B':
        await clickButtonB(services);
        break;
      default:
        Fluttertoast.showToast(msg: "未知按钮： $txt");
    }
  }

  void switchToGamepad() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return GamepadPage(
            device: widget.device,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("面板"),
        actions: [
          IconButton(
            disabledColor: Colors.grey,
            onPressed: switchToGamepad,
            icon: Icon(Icons.gamepad),
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
      "logo": Icons.radio,
      "A": Icons.ac_unit,
      "B": Icons.backpack,
      "T": Icons.tab,
    };
    List<Widget> items = [];
    String name = _items.elementAt(0);
    for (var item in _items) {
      if (item == "LABEL") {
        String? val = labelValues[name];
        val ??= "";
        items.add(Text(val));
      } else if (item == "-") {
        items.add(Text(""));
      } else {
        items.add(IconButton(
          onPressed: () => _onPressed(item),
          icon: Icon(btnIcons[item]),
          color: buttonsColor[name],
          iconSize: 48,
        ));
      }
    }
    return items;
  }

  List<TableRow> _renderArrow() {
    List<TableRow> items = [];
    var rowItems = [
      ["logo", "LABEL"],
      ["A", "LABEL"],
      ["B", "LABEL"],
      ["T", "LABEL"],
    ];
    for (var row in rowItems) {
      items.add(TableRow(children: _renderRowItem(row)));
    }
    return items;
  }
}

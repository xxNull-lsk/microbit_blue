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

class ListItem {
  ListItem(
    this.icon,
    this.label,
    this.color,
  );
  IconData icon;
  final String label;
  Color color;
  String value = "";
}

class _PanelPageState extends State<PanelPage> {
  late var services;

  List<String> itemNames = ['A', 'B', 'T'];

  var items = {
    "A": ListItem(Icons.radio_button_off, "按钮A", Colors.grey),
    "B": ListItem(Icons.radio_button_off, "按钮B", Colors.grey),
    "T": ListItem(Icons.water, "温度", Colors.grey),
  };

  void initState() {
    super.initState();
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    widget.device.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        Fluttertoast.showToast(msg: "${widget.device.name} 失去连接");
        Navigator.pop(context);
      }
    });
    widget.device.discoverServices().then((value) async {
      services = value;
      List<List<dynamic>> buttonState = [
        ["", Colors.grey, Icons.radio_button_off],
        ["已按下", Colors.green, Icons.radio_button_on],
        ["长按", Colors.red, Icons.radio_button_on_outlined],
      ];
      await listenButtonA(services, (state) {
        items["A"]!.value = buttonState[state][0];
        items["A"]!.color = buttonState[state][1];
        items["A"]!.icon = buttonState[state][2];
        setState(() {});
      });
      await listenButtonB(services, (state) {
        items["B"]!.value = buttonState[state][0];
        items["B"]!.color = buttonState[state][1];
        items["B"]!.icon = buttonState[state][2];
        setState(() {});
      });
      await listenTemperature(services, (value) {
        items["T"]!.value = "$value ℃";
        setState(() {});
      });
    });
  }

  void deactivate() {
    super.deactivate();
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
        child: ListView.builder(
          itemBuilder: itemBuilder,
          itemCount: itemNames.length,
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    if (index >= itemNames.length) {
      return Text("没有更多数据了");
    }
    String name = itemNames[index];
    String val = items[name]!.value;
    return ListTile(
      leading: Icon(
        items[name]!.icon,
        color: items[name]!.color,
      ),
      title: Text(val),
    );
  }
}

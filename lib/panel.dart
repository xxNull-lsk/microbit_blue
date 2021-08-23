import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:microbit_blue/IconFont.dart';
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
  ListItem(this.icon, this.label, this.color, {this.value = ""});
  IconData icon;
  final String label;
  Color color;
  String value;
}

class _PanelPageState extends State<PanelPage> {
  late var services;

  var items = {
    "A": ListItem(IconFont.icon_rec_button_fill, "按钮A", Colors.grey),
    "B": ListItem(IconFont.icon_rec_button_fill, "按钮B", Colors.grey),
    "Temperature": ListItem(IconFont.icon_wenduji, "温度", Colors.grey),
    "Gyroscope": ListItem(IconFont.icon_navigation, "陀螺仪", Colors.grey),
    "MicrobitEvent": ListItem(IconFont.icon_mianban, "Microbit事件", Colors.grey),
    "MicrobitRequirements":
        ListItem(IconFont.icon_mianban, "Microbit需求", Colors.grey),
    "name": ListItem(IconFont.icon_rec_button_fill, "name", Colors.grey),
    "modelNumber":
        ListItem(IconFont.icon_rec_button_fill, "model", Colors.grey),
    "serialNumber": ListItem(IconFont.icon_rec_button_fill, "SN", Colors.grey),
    "firmwareRevision":
        ListItem(IconFont.icon_rec_button_fill, "firmwareRev", Colors.grey),
    "hardwareRevision":
        ListItem(IconFont.icon_rec_button_fill, "hardwareRev", Colors.grey),
    "manufacturer":
        ListItem(IconFont.icon_rec_button_fill, "manufacturer", Colors.grey),
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
        ["", Colors.grey, IconFont.icon_rec_button_fill],
        ["已按下", Colors.green, IconFont.icon_rec_button_fill],
        ["长按", Colors.red, IconFont.icon_rec_button_fill],
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
        items["Temperature"]!.value = "$value ℃";
        setState(() {});
      });
      await listenGyroscope(services, (x, y, z) {
        items["Gyroscope"]!.value = "$x, $y, $z";
        setState(() {});
      });
      await listenMicrobitEvent(services, (a, b) {
        items["MicrobitEvent"]!.value = "$a, $b";
        setState(() {});
      });
      await listenMicrobitRequirements(services, (a, b) {
        items["MicrobitRequirements"]!.value = "$a, $b";
        setState(() {});
      });
      var di = await getDeviceInfomation(services);
      items["firmwareRevision"]!.value = di.firmwareRevision;
      items["hardwareRevision"]!.value = di.hardwareRevision;
      items["manufacturer"]!.value = di.manufacturer;
      items["modelNumber"]!.value = di.modelNumber;
      items["serialNumber"]!.value = di.serialNumber;
      items["name"]!.value = di.name;
      for (var e in await getMicrobitRequirements(services)) {
        items.putIfAbsent(
            "event: ${e.type.toString()}",
            () => ListItem(IconFont.icon_rec_button_fill,
                "event_${e.type.toString()}", Colors.grey,
                value: e.value.toString()));
      }
      setState(() {});
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
        title: Text("信息面板"),
        actions: [
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
            itemCount: items.length,
            padding: EdgeInsets.all(0)),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    if (index >= items.length) {
      return Text("没有更多数据了");
    }
    String name = items.keys.elementAt(index);
    return ListTile(
      minLeadingWidth: 24,
      leading: Icon(
        items[name]!.icon,
        size: 32,
        color: items[name]!.color,
      ),
      title: Text(items[name]!.label),
      trailing: Text(items[name]!.value),
    );
  }
}

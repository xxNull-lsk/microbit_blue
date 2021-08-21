import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:microbit_blue/IconFont.dart';
import 'package:orientation/orientation.dart';

import 'microbit.dart';

class NumberPage extends StatefulWidget {
  NumberPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _NumberPageState createState() => _NumberPageState();
}

class _NumberPageState extends State<NumberPage> {
  void initState() {
    super.initState();
    widget.device.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        Fluttertoast.showToast(msg: "${widget.device.name} 失去连接");
        Navigator.pop(context);
      }
    });
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("数字面板"),
      ),
      body: Container(
        margin: EdgeInsets.all(40),
        child: Align(
          alignment: Alignment.topCenter,
          child: Table(
            children: tableBuilder(),
          ),
        ),
      ),
    );
  }

  Map<String, IconData> icons = {
    "0": IconFont.icon_0_round_solid,
    "1": IconFont.icon_1_round_solid,
    "2": IconFont.icon_2_round_solid,
    "3": IconFont.icon_3_round_solid,
    "4": IconFont.icon_4_round_solid,
    "5": IconFont.icon_5_round_solid,
    "6": IconFont.icon_6_round_solid,
    "7": IconFont.icon_7_round_solid,
    "8": IconFont.icon_8_round_solid,
    "9": IconFont.icon_9_round_solid,
    "start": Icons.play_arrow,
    "stop": Icons.stop,
    "up": IconFont.icon_jiantou_shang,
    "down": IconFont.icon_jiantou_xia,
    "left": IconFont.icon_jiantou_zuo,
    "right": IconFont.icon_jiantou_you,
  };

  Future<void> onPressed(String txt) async {
    var services = await widget.device.discoverServices();
    Fluttertoast.showToast(msg: txt);

    await uartSend(services, txt);
  }

  List<TableRow> tableBuilder() {
    List<TableRow> rows = [];
    List<List<String>> items = [
      ["1", "2", "3"],
      ["-", "-", "-"],
      ["4", "5", "6"],
      ["-", "-", "-"],
      ["7", "8", "9"],
      ["-", "-", "-"],
      ["start", "0", "stop"],
      ["-", "-", "-"],
      ["-", "up", "-"],
      ["-", "-", "-"],
      ["left", "-", "right"],
      ["-", "-", "-"],
      ["-", "down", "-"]
    ];
    for (var r in items) {
      List<Widget> rowWidgets = [];
      for (var c in r) {
        if (c == '-') {
          rowWidgets.add(Container(
            height: 32,
            width: 32,
          ));
        } else {
          rowWidgets.add(IconButton(
              onPressed: () => onPressed(c),
              icon: Icon(
                icons[c],
                color: Colors.grey,
                size: 56,
              )));
        }
      }
      rows.add(TableRow(children: rowWidgets));
    }
    return rows;
  }
}

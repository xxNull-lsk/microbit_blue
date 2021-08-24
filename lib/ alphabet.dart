import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:microbit_blue/IconFont.dart';
import 'package:orientation/orientation.dart';

import 'microbit.dart';

class AlphabetPage extends StatefulWidget {
  AlphabetPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _AlphabetPageState createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
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
        title: Text("字母面板"),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
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
    "A": IconFont.icon_A_round_solid,
    "B": IconFont.icon_B_round_solid,
    "C": IconFont.icon_C_round_solid,
    "D": IconFont.icon_D_round_solid,
    "E": IconFont.icon_E_round_solid,
    "F": IconFont.icon_F_round_solid,
    "G": IconFont.icon_G_round_solid,
    "H": IconFont.icon_H_round_solid,
    "I": IconFont.icon_I_round_solid,
    "J": IconFont.icon_J_round_solid,
    "K": IconFont.icon_K_round_solid,
    "L": IconFont.icon_L_round_solid,
    "M": IconFont.icon_M_round_solid,
    "N": IconFont.icon_N_round_solid,
    "O": IconFont.icon_O_round_solid,
    "P": IconFont.icon_P_round_solid,
    "Q": IconFont.icon_Q_round_solid,
    "R": IconFont.icon_R_round_solid,
    "S": IconFont.icon_S_round_solid,
    "T": IconFont.icon_T_round_solid,
    "U": IconFont.icon_U_round_solid,
    "V": IconFont.icon_V_round_solid,
    "W": IconFont.icon_W_round_solid,
    "X": IconFont.icon_X_round_solid,
    "Y": IconFont.icon_Y_round_solid,
    "Z": IconFont.icon_Z_round_solid,
  };

  Future<void> onPressed(String txt) async {
    var services = await widget.device.discoverServices();
    Fluttertoast.showToast(msg: txt);

    uartSend(services, txt);
  }

  List<TableRow> tableBuilder() {
    List<TableRow> rows = [];
    List<List<String>> items = [
      ["A", "B", "C", "D"],
      ["-", "-", "-", "-"],
      ["E", "F", "G", "H"],
      ["-", "-", "-", "-"],
      ["I", "J", "K", "L"],
      ["-", "-", "-", "-"],
      ["M", "N", "O", "P"],
      ["-", "-", "-", "-"],
      ["Q", "R", "S", "T"],
      ["-", "-", "-", "-"],
      ["U", "V", "W", "X"],
      ["-", "-", "-", "-"],
      ["Y", "Z", "-", "-"],
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

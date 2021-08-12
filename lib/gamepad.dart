import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:orientation/orientation.dart';

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
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
  }

  void deactivate() {
    super.deactivate();
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
  }

  Future<void> _onPressed(String txt) async {
    var services = await widget.device.discoverServices();
    await ledPixels(services, LED_ERROR);
    sleep(Duration(seconds: 1));
    await ledPixels(services, LED_CLAER);
    sleep(Duration(seconds: 1));
    await uartSend(services, txt);
    sleep(Duration(seconds: 3));
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
      body: Column(
        children: [
          Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: _renderTable())
        ],
      ),
    );
  }

  Widget _renderTableItem(int row, int col) {
    switch (col) {
      case 0:
        switch (row) {
          case 0:
            return Text("$col$row");
          case 1:
            return IconButton(
              onPressed: () => _onPressed("UP"),
              icon: Icon(Icons.arrow_upward),
              iconSize: 64,
            );
          case 2:
            return Text("$col$row");
          default:
        }
        break;
      case 1:
        switch (row) {
          case 0:
            return IconButton(
              onPressed: () => _onPressed("LEFT"),
              icon: Icon(Icons.arrow_left),
              iconSize: 64,
            );
          case 1:
            return Text("$col$row");
          case 2:
            return IconButton(
              onPressed: () => _onPressed("RIGHT"),
              icon: Icon(Icons.arrow_right),
              iconSize: 64,
            );
          default:
        }
        break;
      case 2:
        switch (row) {
          case 0:
            return Text("$col$row");
          case 1:
            return IconButton(
              onPressed: () => _onPressed("DOWN"),
              icon: Icon(Icons.arrow_downward),
              iconSize: 64,
            );
          case 2:
            return Text("$col$row");
          default:
        }
    }
    return Text("");
  }

  List<TableRow> _renderTable() {
    List<TableRow> items = [];
    for (var col = 0; col < 3; col++) {
      items.add(TableRow(children: [
        _renderTableItem(0, col),
        _renderTableItem(1, col),
        _renderTableItem(2, col),
      ]));
    }
    return items;
  }
}

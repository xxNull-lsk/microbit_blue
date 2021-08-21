import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:microbit_blue/%20alphabet.dart';
import 'package:microbit_blue/IconFont.dart';
import 'package:microbit_blue/number.dart';
import 'package:orientation/orientation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'microbit.dart';
import 'panel.dart';

class GamepadPage extends StatefulWidget {
  GamepadPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _GamepadPageState createState() => _GamepadPageState();
}

class _GamepadPageState extends State<GamepadPage> {
  void initState() {
    super.initState();
    widget.device.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        Fluttertoast.showToast(msg: "${widget.device.name} 失去连接");
        Navigator.pop(context);
      }
    });

    initLandScape();
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

  void initLandScape() {
    //隐藏状态栏和导航栏
    SystemChrome.setEnabledSystemUIOverlays([]);

    //隐藏底部导航栏
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

    //隐藏状态栏
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
  }

  void switchToPanel() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PanelPage(
            device: widget.device,
          );
        },
      ),
    ).then((value) {
      initLandScape();
    });
  }

  void switchToNumberPanel() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return NumberPage(
            device: widget.device,
          );
        },
      ),
    ).then((value) {
      initLandScape();
    });
  }

  void switchToAlphabetPanel() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AlphabetPage(
            device: widget.device,
          );
        },
      ),
    ).then((value) {
      initLandScape();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("游戏手柄"),
        actions: [
          IconButton(
            disabledColor: Colors.grey,
            onPressed: switchToPanel,
            icon: Icon(IconFont.icon_mianban),
          ),
          IconButton(
            disabledColor: Colors.grey,
            onPressed: switchToNumberPanel,
            icon: Icon(IconFont.icon_shuzi),
          ),
          IconButton(
            disabledColor: Colors.grey,
            onPressed: switchToAlphabetPanel,
            icon: Icon(IconFont.icon_zimu),
          ),
          IconButton(
            disabledColor: Colors.grey,
            onPressed: null,
            icon: Icon(IconFont.icon_liaotian_04),
          ),
          IconButton(
            disabledColor: Colors.grey,
            onPressed: null,
            icon: Icon(IconFont.icon_shezhi),
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
      "up": IconFont.icon_jiantou_shang_1,
      "down": IconFont.icon_jiantou_xia_1,
      "left": IconFont.icon_jiantou_zuo_1,
      "right": IconFont.icon_jiantou_you_1,
      "1": IconFont.icon_1_round_solid,
      "2": IconFont.icon_2_round_solid,
      "3": IconFont.icon_3_round_solid,
      "4": IconFont.icon_4_round_solid,
      "start": IconFont.icon_start,
      "stop": IconFont.icon_stop,
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

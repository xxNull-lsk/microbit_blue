import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_blue/flutter_blue.dart';

const String ACCEL_SRV = 'E95D0753-251D-470A-A062-FA1922DFA9A8';
const String ACCEL_DATA = 'E95DCA4B-251D-470A-A062-FA1922DFA9A8';
const String ACCEL_PERIOD = 'E95DFB24-251D-470A-A062-FA1922DFA9A8';
const String BTN_SRV = 'E95D9882-251D-470A-A062-FA1922DFA9A8';
const String BTN_A_STATE = 'E95DDA90-251D-470A-A062-FA1922DFA9A8';
const String BTN_B_STATE = 'E95DDA91-251D-470A-A062-FA1922DFA9A8';
const String LED_SRV = 'E95DD91D-251D-470A-A062-FA1922DFA9A8';
const String LED_STATE = 'E95D7B77-251D-470A-A062-FA1922DFA9A8';
const String LED_TEXT = 'E95D93EE-251D-470A-A062-FA1922DFA9A8';
const String LED_SCROLL = 'E95D0D2D-251D-470A-A062-FA1922DFA9A8';
const String MAGNETO_SRV = 'E95DF2D8-251D-470A-A062-FA1922DFA9A8';
const String MAGNETO_DATA = 'E95DFB11-251D-470A-A062-FA1922DFA9A8';
const String MAGNETO_PERIOD = 'E95D386C-251D-470A-A062-FA1922DFA9A8';
const String MAGNETO_BEARING = 'E95D9715-251D-470A-A062-FA1922DFA9A8';
const String MAGNETO_CALIBRATE = 'E95DB358-251D-470A-A062-FA1922DFA9A8';
const String IO_PIN_SRV = 'E95D127B-251D-470A-A062-FA1922DFA9A8';
const String IO_PIN_DATA = 'E95D8D00-251D-470A-A062-FA1922DFA9A8';
const String IO_AD_CONFIG = 'E95D5899-251D-470A-A062-FA1922DFA9A8';
const String IO_PIN_CONFIG = 'E95DB9FE-251D-470A-A062-FA1922DFA9A8';
const String IO_PIN_PWM = 'E95DD822-251D-470A-A062-FA1922DFA9A8';
const String TEMP_SRV = 'E95D6100-251D-470A-A062-FA1922DFA9A8';
const String TEMP_DATA = 'E95D9250-251D-470A-A062-FA1922DFA9A8';
const String TEMP_PERIOD = 'E95D1B25-251D-470A-A062-FA1922DFA9A8';
const String UART_SRV = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
const String UART_TX = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
const String UART_RX = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';

Future<void> ledText(List<BluetoothService> services, String text) async {
  for (var service in services) {
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var serviceUuid = c.serviceUuid.toString().toUpperCase();
      var uuid = c.uuid.toString().toUpperCase();
      if (LED_SRV != serviceUuid || LED_TEXT != uuid) {
        continue;
      }

      await c.write(utf8.encode(text));
      return;
    }
  }
}

const List<int> LED_CLAER = [0x00, 0x00, 0x00, 0x00, 0x00];
const List<int> LED_ARROW_LEFT = [0, 8, 31, 8, 0];
const List<int> LED_ARROW_RIGHT = [0, 2, 31, 2, 0];
const List<int> LED_HEART = [10, 255, 255, 14, 4];
const List<int> LED_LITTLE_HEART = [0, 10, 14, 4, 0];
const List<int> LED_RIGHT = [0, 1, 2, 20, 8];
const List<int> LED_ERROR = [17, 10, 4, 10, 17];
Future<void> ledPixels(List<BluetoothService> services, List<int> data) async {
  for (var service in services) {
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var serviceUuid = c.serviceUuid.toString().toUpperCase();
      var uuid = c.uuid.toString().toUpperCase();
      if (LED_SRV != serviceUuid || LED_STATE != uuid) {
        continue;
      }

      await c.write(data);
      return;
    }
  }
}

Future<void> uartSend(List<BluetoothService> services, String text) async {
  for (var service in services) {
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var serviceUuid = c.serviceUuid.toString().toUpperCase();
      var uuid = c.uuid.toString().toUpperCase();
      if (UART_SRV != serviceUuid || UART_RX != uuid) {
        continue;
      }

      await c.write(utf8.encode(text + "\n"));
      return;
    }
  }
}

Future<bool> listenValue(List<BluetoothService> services, String _serviceUuid,
    String _uuid, void onChanged(List<int> value)) async {
  for (var service in services) {
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var serviceUuid = c.serviceUuid.toString().toUpperCase();
      var uuid = c.uuid.toString().toUpperCase();
      if (_serviceUuid != serviceUuid || _uuid != uuid) {
        continue;
      }
      try {
        bool ret = await c.setNotifyValue(true);
        if (!ret) {
          print("listenValue: setNotifyValue $_serviceUuid $_uuid failed!");
          return ret;
        }
        c.value.listen((value) {
          onChanged(value);
        });
        return true;
      } catch (e) {
        print("listenValue exception: $e");
        return false;
      }
    }
  }
  print(
      "listenValue failed! not found!_serviceUuid=$_serviceUuid _uuid=$_uuid");
  return false;
}

Future<List<int>> getValue(
    List<BluetoothService> services, String _serviceUuid, String _uuid) async {
  for (var service in services) {
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var serviceUuid = c.serviceUuid.toString().toUpperCase();
      var uuid = c.uuid.toString().toUpperCase();
      if (_serviceUuid != serviceUuid || _uuid != uuid) {
        continue;
      }
      try {
        return c.read();
      } catch (e) {
        print("getTemperature: $e");
        return [];
      }
    }
  }
  return [];
}

Future<void> setButtonState(
    List<BluetoothService> services, String button, int value) async {
  for (var service in services) {
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var serviceUuid = c.serviceUuid.toString().toUpperCase();
      var uuid = c.uuid.toString().toUpperCase();
      if (BTN_SRV != serviceUuid || button != uuid) {
        continue;
      }

      await c.write([value]);
      return;
    }
  }
}

Future<bool> listenButtonA(
    List<BluetoothService> services, void onChanged(int val)) {
  return listenValue(services, BTN_SRV, BTN_A_STATE, (val) {
    onChanged(val[0]);
  });
}

Future<bool> listenButtonB(
    List<BluetoothService> services, void onChanged(int val)) {
  return listenValue(services, BTN_SRV, BTN_B_STATE, (val) {
    onChanged(val[0]);
  });
}

Future<bool> listenTemperature(
    List<BluetoothService> services, void onChanged(int val)) {
  return listenValue(services, TEMP_SRV, TEMP_DATA, (val) {
    int temp = 0;
    for (var v in val) {
      temp = (temp << 8) | v;
    }
    onChanged(temp);
  });
}

Future<int> getTemperature(List<BluetoothService> services) async {
  List<int> val = await getValue(services, TEMP_SRV, TEMP_DATA);
  int temp = 0;
  for (var v in val) {
    temp = (temp << 8) | v;
  }
  return temp;
}

Future<bool> listenGyroscope(List<BluetoothService> services,
    void onChanged(double x, double y, double z)) {
  return listenValue(services, ACCEL_SRV, ACCEL_DATA, (val) {
    double x = 0, y = 0, z = 0;
    x = (val[0] << 8 | val[1]) / 1000.0;
    y = (val[2] << 8 | val[3]) / 1000.0;
    z = (val[4] << 8 | val[5]) / 1000.0;
    onChanged(x, y, z);
  });
}

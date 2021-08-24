import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter_blue/flutter_blue.dart';

const String GENERIC_ACCESS_SRV = '00001800-0000-1000-8000-00805F9B34FB';
const String GA_Device_Name = '00002A00-0000-1000-8000-00805F9B34FB';
const String GA_Appearance = '00002A01-0000-1000-8000-00805F9B34FB';
const String GA_Parameters = '00002A04-0000-1000-8000-00805F9B34FB';
const String GENERIC_ATTRIBUTE_SRV = '00001801-0000-1000-8000-00805F9B34FB';
const String DEVICE_INFO_SRV = '0000180A-0000-1000-8000-00805F9B34FB';
const String DI_Model_Number_String = '00002A24-0000-1000-8000-00805F9B34FB';
const String DI_Serial_Number_String = '00002A25-0000-1000-8000-00805F9B34FB';
const String DI_Hardware_Revision_String =
    '00002A27-0000-1000-8000-00805F9B34FB';
const String DI_Firmware_Revision_String =
    '00002A26-0000-1000-8000-00805F9B34FB';
const String DI_Manufacturer_Name_String =
    '00002A29-0000-1000-8000-00805F9B34FB';
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
// https://lancaster-university.github.io/microbit-docs/ble/event-service/
const String EVENT_SRV = 'E95D93AF-251D-470A-A062-FA1922DFA9A8';
const String EVENT_MICROBIT_REQUIREMENTS =
    "E95DB84C-251D-470A-A062-FA1922DFA9A8";
const String EVENT_MICROBITEVENT = "E95D9775-251D-470A-A062-FA1922DFA9A8";
const String EVENT_CLIENTREQUIREMENTS = "E95D23C4-251D-470A-A062-FA1922DFA9A8";
const String EVENT_CLIENTEVENT = "E95D5404-251D-470A-A062-FA1922DFA9A8";

const String PARTIAL_FLASH_SRV = 'E97DD91D-251D-470A-A062-FA1922DFA9A8';

class DeviceInformation {
  String name = '';
  String modelNumber = '';
  String serialNumber = '';
  String firmwareRevision = '';
  String hardwareRevision = '';
  String manufacturer = '';
}

Future<DeviceInformation> getDeviceInfomation(
    List<BluetoothService> services) async {
  DeviceInformation di = DeviceInformation();
  for (var service in services) {
    var serviceUuid = service.uuid.toString().toUpperCase();
    if (serviceUuid != DEVICE_INFO_SRV && serviceUuid != GENERIC_ACCESS_SRV) {
      continue;
    }
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var uuid = c.uuid.toString().toUpperCase();
      if (DEVICE_INFO_SRV == serviceUuid) {
        switch (uuid) {
          case DI_Firmware_Revision_String:
            di.firmwareRevision = utf8.decode(await c.read());
            break;
          case DI_Hardware_Revision_String:
            di.hardwareRevision = utf8.decode(await c.read());
            break;
          case DI_Manufacturer_Name_String:
            di.manufacturer = utf8.decode(await c.read());
            break;
          case DI_Model_Number_String:
            di.modelNumber = utf8.decode(await c.read());
            break;
          case DI_Serial_Number_String:
            di.serialNumber = utf8.decode(await c.read());
            break;
        }
      } else if (GENERIC_ACCESS_SRV == serviceUuid) {
        if (uuid == GA_Device_Name) {
          di.name = utf8.decode(await c.read());
        }
      }
    }
  }
  return di;
}

Future<void> _write(List<BluetoothService> services, String serviceUuid,
    String characteristicsUuid, List<int> data) async {
  for (var service in services) {
    var serviceUuid = service.uuid.toString().toUpperCase();
    if (serviceUuid != LED_SRV) {
      continue;
    }
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var uuid = c.uuid.toString().toUpperCase();
      if (LED_TEXT != uuid) {
        continue;
      }

      await c.write(data);
      return;
    }
  }
}

Future<bool> listenValue(List<BluetoothService> services, String _serviceUuid,
    String _uuid, void onChanged(List<int> value)) async {
  for (var service in services) {
    var serviceUuid = service.uuid.toString().toUpperCase();
    if (serviceUuid != _serviceUuid) {
      continue;
    }
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var uuid = c.uuid.toString().toUpperCase();
      if (_uuid != uuid) {
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
    var serviceUuid = service.uuid.toString().toUpperCase();
    if (serviceUuid != _serviceUuid) {
      continue;
    }
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      var uuid = c.uuid.toString().toUpperCase();
      if (_uuid != uuid) {
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

void ledText(List<BluetoothService> services, String text) {
  _write(services, LED_SRV, LED_TEXT, utf8.encode(text));
}

const List<int> LED_CLAER = [0, 0, 0, 0, 0];
const List<int> LED_ARROW_LEFT = [0, 8, 31, 8, 0];
const List<int> LED_ARROW_RIGHT = [0, 2, 31, 2, 0];
const List<int> LED_HEART = [10, 255, 255, 14, 4];
const List<int> LED_LITTLE_HEART = [0, 10, 14, 4, 0];
const List<int> LED_RIGHT = [0, 1, 2, 20, 8];
const List<int> LED_ERROR = [17, 10, 4, 10, 17];
const List<int> LED_HAPPY = [0, 10, 0, 17, 14];
const List<int> LED_UNHAPPY = [0, 10, 0, 14, 17];
const List<int> LED_LOSS = [0, 10, 0, 10, 21];
const List<int> LED_ANGRY = [17, 10, 0, 31, 21];
const List<int> LED_SLEEP = [0, 27, 0, 14, 0];
const List<int> LED_SURPRISE = [14, 0, 4, 10, 4];
void ledPixels(List<BluetoothService> services, List<int> data) {
  _write(services, LED_SRV, LED_STATE, data);
}

void uartSend(List<BluetoothService> services, String text) {
  _write(services, UART_SRV, UART_RX, utf8.encode(text + "\n"));
}

Future<bool> listenUart(
    List<BluetoothService> services, void onRecv(String val)) {
  return listenValue(services, BTN_SRV, UART_TX, (val) {
    onRecv(utf8.decode(val));
  });
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

class MicrobitEvent {
  int type = 0;
  int value = 0;
}

Future<bool> listenMicrobitRequirements(List<BluetoothService> services,
    void onChanged(int eventType, int eventValue)) {
  return listenValue(services, EVENT_SRV, EVENT_MICROBIT_REQUIREMENTS, (val) {
    for (int i = 0; i < val.length / 4; i++) {
      int index = i * 4;
      var ev = MicrobitEvent();
      ev.type = val[index] << 8 | val[index + 1];
      ev.value = val[index + 2] << 8 | val[index + 3];
      onChanged(ev.type, ev.value);
    }
  });
}

Future<List<MicrobitEvent>> getMicrobitRequirements(
    List<BluetoothService> services) async {
  List val = await getValue(services, EVENT_SRV, EVENT_MICROBIT_REQUIREMENTS);
  List<MicrobitEvent> events = [];
  for (int i = 0; i < val.length / 4; i++) {
    int index = i * 4;
    var ev = MicrobitEvent();
    ev.type = val[index] << 8 | val[index + 1];
    ev.value = val[index + 2] << 8 | val[index + 3];
    events.add(ev);
  }
  return events;
}

Future<bool> listenMicrobitEvent(List<BluetoothService> services,
    void onChanged(int eventType, int eventValue)) {
  return listenValue(services, EVENT_SRV, EVENT_MICROBITEVENT, (val) {
    for (int i = 0; i < val.length / 4; i++) {
      int index = i * 4;
      var ev = MicrobitEvent();
      ev.type = val[index] << 8 | val[index + 1];
      ev.value = val[index + 2] << 8 | val[index + 3];
      onChanged(ev.type, ev.value);
    }
  });
}

void writeClientRequirements(
    List<BluetoothService> services, List<MicrobitEvent> events) {
  List<int> data = [];
  var index = 0;
  for (var item in events) {
    data[index] = item.type >> 8;
    data[index + 1] = item.type & 0xF0;
    data[index + 2] = item.value >> 8;
    data[index + 3] = item.value & 0xF0;
  }
  _write(services, EVENT_SRV, EVENT_CLIENTREQUIREMENTS, data);
}

void writeClientEvent(
    List<BluetoothService> services, List<MicrobitEvent> events) {
  List<int> data = [];
  var index = 0;
  for (var item in events) {
    data[index] = item.type >> 8;
    data[index + 1] = item.type & 0xF0;
    data[index + 2] = item.value >> 8;
    data[index + 3] = item.value & 0xF0;
  }
  _write(services, EVENT_SRV, EVENT_CLIENTEVENT, data);
}

void dumpService(BluetoothService service) {
  print("================= ${service.uuid}\n");
  if (service.uuid.toString().toUpperCase() == '$EVENT_SRV') {
    for (var item in service.characteristics) {
      print(
          "    characteristics uuid: ${item.uuid} ${item.properties.toString()}\n");
    }
  }
}

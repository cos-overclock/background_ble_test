// The callback function should always be a top-level function.
import 'dart:async';
import 'dart:isolate';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(BleTaskHandler());
}

class BleTaskHandler extends TaskHandler {
  final device = BluetoothDevice.fromId('00:3C:84:16:A6:58');
  late StreamSubscription<BluetoothDeviceState> _subscription;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _subscription = device.state.listen((state) {
      sendPort?.send(state.toString());
      if (state == BluetoothDeviceState.disconnected) {
        device.connect(); // 切断したら再接続
      }
    });
    device.connect(autoConnect: true);
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _subscription.cancel();
    device.disconnect();
  }
}

void registerReceivePort(ReceivePort newReceivePort) {
  newReceivePort.listen((message) {
    if (message is int) {
      print('eventCount: $message');
    } else if (message is String) {
      if (message == 'connected') {
      } else if (message == 'disconnected') {}
    } else if (message is DateTime) {
      print('timestamp: ${message.toString()}');
    }
  });
}

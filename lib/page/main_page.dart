import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:background_ble_test/model/foreground_task.dart';

final connectionStateProvider = StateProvider<String>((ref) => 'disconnected');

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Background Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(ref.watch(connectionStateProvider)),
            FilledButton(
              onPressed: () async {
                print('on Press');
                try {
                  if (!await FlutterForegroundTask.canDrawOverlays) {
                    final isGranted = await FlutterForegroundTask
                        .openSystemAlertWindowSettings();
                    if (!isGranted) {
                      print('SYSTEM_ALERT_WINDOW permission denied!');
                      return;
                    }
                  }

                  FlutterForegroundTask.receivePort?.listen((message) {
                    if (message is String) {
                      ref.watch(connectionStateProvider.notifier).state =
                          message;
                    }
                  });

                  if (await FlutterForegroundTask.isRunningService) {
                    FlutterForegroundTask.restartService();
                  } else {
                    FlutterForegroundTask.startService(
                      notificationTitle: 'Foreground Service is running',
                      notificationText: 'Tap to return to the app',
                      callback: startCallback,
                    );
                  }
                  print('Start Foreground');
                } catch (e) {
                  print(e.toString());
                }
              },
              child: const Text('Start Background Connect'),
            ),
            FilledButton(
              onPressed: () => FlutterForegroundTask.stopService(),
              child: const Text('Stop Background Connect'),
            ),
          ],
        ),
      ),
    );
  }
}

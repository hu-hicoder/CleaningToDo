import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// One global instance is enough
final FlutterLocalNotificationsPlugin notifications =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android settings
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS settings
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

  // Combine & initialize
  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit, iOS: iosInit);

  await notifications.initialize(initSettings);

  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(title: 'Clean ToDo'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _counter = 0;

  Future<void> _incrementCounter() async {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            FilledButton(
              onPressed: _onPressed,
              child: const Text('Notify'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment & Notify',
        child: const Icon(Icons.add),
      ),
    );
  }
  void _onPressed() {
    showLocalNotification('Counter value', 'You have tapped $_counter times.');
  }
  void showLocalNotification(String title, String message) {
    const androidNotificationDetail = AndroidNotificationDetails(
        'channel_id', // channel Id
        'channel_name' // channel Name
    );
    const iosNotificationDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificationDetail,
      android: androidNotificationDetail,
    );
    FlutterLocalNotificationsPlugin()
        .show(0, title, message, notificationDetails);
  }
}

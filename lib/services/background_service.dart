import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackgroundService {
  static const String syncDataTask = 'syncDataTask';
  static const String notificationTask = 'notificationTask';

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize background service
  static Future<void> initBackgroundService() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    // Initialize notifications
    await _initializeNotifications();
  }

  // Initialize local notifications
  static Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  // Register periodic background tasks
  static Future<void> registerBackgroundTasks() async {
    // Sync data setiap 15 menit
    await Workmanager().registerPeriodicTask(
      syncDataTask,
      syncDataTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      initialDelay: const Duration(minutes: 1),
    );

    // Check notifications setiap 30 menit
    await Workmanager().registerPeriodicTask(
      notificationTask,
      notificationTask,
      frequency: const Duration(minutes: 30),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  // Cancel all background tasks
  static Future<void> cancelBackgroundTasks() async {
    await Workmanager().cancelAll();
  }

  // Show notification
  static Future<void> showNotification({
    required String title,
    required String body,
    required int id,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'peta_randusari_channel',
          'Peta Randusari',
          channelDescription: 'Notifikasi dari Aplikasi Peta Randusari',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, platformChannelSpecifics);
  }
}

// Callback dispatcher untuk background tasks
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == BackgroundService.syncDataTask) {
        // Sync data dari Supabase
        await _syncDataFromSupabase();
      } else if (task == BackgroundService.notificationTask) {
        // Check dan send notifications
        await _checkNotifications();
      }
      return true;
    } catch (e) {
      return false;
    }
  });
}

// Sync data dari Supabase
Future<void> _syncDataFromSupabase() async {
  try {
    final supabase = Supabase.instance.client;

    // Fetch data penduduk terbaru
    final response = await supabase
        .from('data_penduduk')
        .select()
        .order('tahun', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      // Data berhasil disync
      await BackgroundService.showNotification(
        id: 1,
        title: 'Data Tersync',
        body: 'Data penduduk telah berhasil disinkronisasi',
      );
    }
  } catch (e) {
    print('Error syncing data: $e');
  }
}

// Check notifications
Future<void> _checkNotifications() async {
  try {
    final supabase = Supabase.instance.client;

    // Fetch notifications dari database
    final response = await supabase
        .from('notifications')
        .select()
        .eq('is_read', false)
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      final notification = response[0];
      await BackgroundService.showNotification(
        id: 2,
        title: notification['title'] ?? 'Notifikasi Baru',
        body: notification['message'] ?? 'Anda memiliki notifikasi baru',
      );
    }
  } catch (e) {
    print('Error checking notifications: $e');
  }
}

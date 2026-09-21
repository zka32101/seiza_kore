import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/timecapsule_event.dart';

/// 天文イベント（流星群・月食等）の開始時刻にローカル通知を送るサービス。
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      // タイムゾーン取得に失敗した場合はデフォルト（UTC）のまま続行する
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (!_initialized) await initialize();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidGranted =
        await androidPlugin?.requestNotificationsPermission();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  /// 未来の天文イベント開始時刻にまとめて通知を予約する。
  /// 呼び出しごとに既存の予約をすべて解除してから再登録する（重複防止）。
  Future<void> scheduleEventNotifications(
    List<TimecapsuleEvent> events, {
    required String languageCode,
  }) async {
    if (!_initialized) await initialize();
    await _plugin.cancelAll();

    const androidDetails = AndroidNotificationDetails(
      'astro_events',
      'astro_events_channel',
      channelDescription:
          '流星群・月食などの天文イベント開始時刻をお知らせします',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    var id = 0;
    final now = DateTime.now();
    for (final event in events) {
      if (event.openTime.isBefore(now)) continue;
      final scheduled = tz.TZDateTime.from(event.openTime, tz.local);
      await _plugin.zonedSchedule(
        id++,
        event.localizedName(languageCode),
        event.localizedDescription(languageCode),
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }
}

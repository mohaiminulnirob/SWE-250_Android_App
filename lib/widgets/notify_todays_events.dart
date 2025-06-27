import 'package:project/repositories/notifications_repo.dart';
import 'package:project/services/device_notifications.dart';
import 'package:project/models/event_model.dart';

Future<void> notifyTodaysEvents() async {
  final notificationsRepo = NotificationsRepository();
  final todayEvents = await notificationsRepo.getTodaysNotifications();

  for (int i = 0; i < todayEvents.length; i++) {
    Event event = todayEvents[i];
    await DeviceNotifications.showNotification(
      id: i,
      title: 'Today\'s Event: ${event.title}',
      body: '${event.organizationName} | ${event.spotName} | ${event.session}',
    );
  }
}

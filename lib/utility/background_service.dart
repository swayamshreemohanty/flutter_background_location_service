// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_location_service/notification/notification.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

const String notificationChannelId = "foreground_service";
const int foregroundServiceNotificationId = 888;
const String initialNotificationTitle = "TRACK YOUR LOCATION";
const String initialNotificationContent = "Initializing";

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) async {
      await service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) async {
      await service.setAsBackgroundService();
    });
  }

  service.on("stop_service").listen((event) async {
    await service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always) {
          Geolocator.getPositionStream().listen((Position position) async {
            service.invoke('on_location_changed', position.toJson());
            // await UpdateLocationOnDbCubit().updateLocation(position: position);

            await NotificationService(FlutterLocalNotificationsPlugin())
                .showNotification(
              showNotificationId: foregroundServiceNotificationId,
              title: "Hii, User",
              body:
                  'Your Latitude: ${position.latitude}, Longitude: ${position.longitude}',
              payload: "service",
              androidNotificationDetails: const AndroidNotificationDetails(
                notificationChannelId,
                notificationChannelId,
                // icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            );
          });
        }
      }
    }
  });
}

class BackgroundService {
  //Get instance for flutter background service plugin
  final FlutterBackgroundService flutterBackgroundService =
      FlutterBackgroundService();

  FlutterBackgroundService get instance => flutterBackgroundService;

  Future<void> initializeService() async {
    await NotificationService(FlutterLocalNotificationsPlugin()).createChannel(
        const AndroidNotificationChannel(
            notificationChannelId, notificationChannelId));
    await flutterBackgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        // auto start service
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        foregroundServiceNotificationId: foregroundServiceNotificationId,
        initialNotificationTitle: initialNotificationTitle,
        initialNotificationContent: initialNotificationContent,
      ),
      //Currently IOS setup is not completed.
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,
        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,
      ),
    );
    await flutterBackgroundService.startService();
  }

  void setServiceAsForeGround() async {
    flutterBackgroundService.invoke("setAsForeground");
  }

  void stopService() {
    flutterBackgroundService.invoke("stop_service");
  }
}

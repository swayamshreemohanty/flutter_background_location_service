import 'package:flutter/material.dart';
import 'package:flutter_background_location_service/home/screens/home_screen.dart';
import 'package:flutter_background_location_service/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:flutter_background_location_service/location_service/repository/location_service_repository.dart';
import 'package:flutter_background_location_service/notification/notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notificationService =
    NotificationService(FlutterLocalNotificationsPlugin());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: notificationService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LocationControllerCubit(
              locationServiceRepository: LocationServiceRepository(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Track Your Location',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}

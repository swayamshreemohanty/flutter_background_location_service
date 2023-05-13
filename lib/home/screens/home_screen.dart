// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_location_service/tools/background_service.dart';
import 'package:flutter_background_location_service/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:flutter_background_location_service/notification/notification.dart';
import 'package:flutter_background_location_service/utility/shared_preference/shared_preference.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userNameTextController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @pragma('vm:entry-point')
  @override
  Future<void> didChangeDependencies() async {
    await context.read<NotificationService>().initialize(context);

    //Start the service automatically if it was activated before closing the application
    if (await BackgroundService().instance.isRunning()) {
      // await BackgroundService().instance.startService();
      await BackgroundService().initializeService();
    }
    BackgroundService()
        .instance
        .on('on_location_changed')
        .listen((event) async {
      if (event != null) {
        final position = Position(
          longitude: double.tryParse(event['longitude'].toString()) ?? 0.0,
          latitude: double.tryParse(event['latitude'].toString()) ?? 0.0,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
              event['timestamp'].toInt(),
              isUtc: true),
          accuracy: double.tryParse(event['accuracy'].toString()) ?? 0.0,
          altitude: double.tryParse(event['altitude'].toString()) ?? 0.0,
          heading: double.tryParse(event['heading'].toString()) ?? 0.0,
          speed: double.tryParse(event['speed'].toString()) ?? 0.0,
          speedAccuracy:
              double.tryParse(event['speed_accuracy'].toString()) ?? 0.0,
        );

        await context
            .read<LocationControllerCubit>()
            .onLocationChanged(location: position);
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Column(
        children: [
          Form(
            key: formkey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ),
              child: TextFormField(
                controller: userNameTextController,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field can't be empty";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  label: const Text("Enter your name"),
                  suffixIcon: IconButton(
                    onPressed: () {
                      userNameTextController.clear();
                    },
                    icon: const Icon(Icons.cancel),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          BlocBuilder<LocationControllerCubit, LocationControllerState>(
            builder: (context, state) {
              if (state is LocationFetched) {
                return Center(
                  child: Column(
                    children: [
                      Text(
                        "Latitude:${state.location.latitude}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        "Longitude:${state.location.longitude}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        "Altitude:${(state.location.altitude).toStringAsFixed(2)} m",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        "Speed:${((state.location.speed) / 1000).toStringAsFixed(2)} KMPH",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          BackgroundService().stopService();
                          await context
                              .read<LocationControllerCubit>()
                              .stopLocationFetch();
                        },
                        child: const Text("Stop sending"),
                      ),
                    ],
                  ),
                );
              } else if (state is LoadingLocation) {
                return const Text(
                  "Loading your service...",
                  style: TextStyle(fontSize: 18),
                );
              } else {
                return ElevatedButton(
                  onPressed: () async {
                    if (formkey.currentState!.validate()) {
                      final permission = await context
                          .read<LocationControllerCubit>()
                          .enableGPSWithPermission();

                      if (permission) {
                        FocusScope.of(context).unfocus();
                        await CustomSharedPreference().storeData(
                          key: SharedPreferenceKeys.userName,
                          data: userNameTextController.text.trim(),
                        );

                        Fluttertoast.showToast(
                          msg: "Wait for a while, Initializing the service...",
                        );

                        await context
                            .read<LocationControllerCubit>()
                            .locationFetchByDeviceGPS();
                        //Configure the service notification channel and start the service
                        await BackgroundService().initializeService();
                        //Set service as foreground.(Notification will available till the service end)
                        BackgroundService().setServiceAsForeGround();
                      }
                    }
                  },
                  child: const Text("Start data sending"),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

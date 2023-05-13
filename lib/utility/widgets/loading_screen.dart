import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_location_service/utility/widgets/theme_spinner.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.white),
      ),
      body: const Center(
        child: ThemeSpinner(size: 50),
      ),
    );
  }
}

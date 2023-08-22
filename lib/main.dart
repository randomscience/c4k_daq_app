import 'package:flutter/material.dart';
import 'Calibration.dart';
import 'Library.dart';
import 'NewRecording.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Obtain a list of the available cameras on the device.

  // Get a specific camera from the list of available cameras.
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  StatefulWidget _getCentralWidget() {
    if (currentPageIndex == 0) return const Calibration();
    if (currentPageIndex == 1) return NewRecording();
    return const Library();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'C4K DAQ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(22, 88, 232, 1)),
        primaryColor: const Color.fromRGBO(22, 88, 232, 1),
        useMaterial3: true,
      ),
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: currentPageIndex,
          height: 60,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.compass_calibration),
              icon: Icon(Icons.compass_calibration_outlined),
              label: 'Calibration',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.video_camera_back),
              icon: Icon(Icons.video_camera_back_outlined),
              label: 'New Recording',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.bookmark),
              icon: Icon(Icons.bookmark_border),
              label: 'Library',
            ),
          ],
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Connect 4 Kids",
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        body: Center(child: _getCentralWidget()),
      ),
    );
  }
}

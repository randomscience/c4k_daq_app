import 'package:flutter/material.dart';
import 'calibration.dart';
import 'library.dart';
import 'new_recording.dart';
import 'information.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
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

  _pageTitle() {
    if (currentPageIndex == 0) return "Instrukcja";
    if (currentPageIndex == 1) return "Kalibracja";
    if (currentPageIndex == 2) return "Nowy Pomiar";
    return "Biblioteka";
  }

  StatefulWidget _getCentralWidget() {
    if (currentPageIndex == 0) return const Information();
    if (currentPageIndex == 1) return const Calibration();
    if (currentPageIndex == 2) return NewRecording();
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
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: currentPageIndex,
          height: 60,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.info),
              icon: Icon(Icons.info_outlined),
              label: 'Instrukcja',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.compass_calibration),
              icon: Icon(Icons.compass_calibration_outlined),
              label: 'Kalibracja',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.add_circle),
              icon: Icon(Icons.add_circle_outline),
              label: 'Nowy Pomiar',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.bookmark),
              icon: Icon(Icons.bookmark_border),
              label: 'Biblioteka',
            ),
          ],
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(_pageTitle(),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        ),
        body: Center(child: _getCentralWidget()),
      ),
    );
  }
}

import 'package:c4k_daq/constants.dart';
import 'package:flutter/material.dart';
import 'calibration_view.dart';
import 'library_view.dart';
import 'new_recording_view.dart';
import 'information.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  // Obtain a list of the available cameras on the device.

  // Get a specific camera from the list of available cameras.
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  // new recording information
  Map<String, String?> userInformation =
      Map<String, String?>.from(emptyUserInformation());

  Map<String, String?> exerciseVideoMapping =
      Map<String, String?>.from(emptyExerciseVideoMapping);

  clearData() {
    userInformation = Map<String, String?>.from(emptyUserInformation());
    exerciseVideoMapping = Map<String, String?>.from(emptyExerciseVideoMapping);
  }

  bool isRecording() {
    if (userInformation != emptyUserInformation()) return true;
    if (exerciseVideoMapping != emptyExerciseVideoMapping) return true;
    return false;
  }

  MyHomePage({super.key});

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
    if (currentPageIndex == 2) {
      return NewRecording(
        userInformation: () => widget.userInformation,
        exerciseVideoMapping: () => widget.exerciseVideoMapping,
        clearData: widget.clearData,
      );
    }
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
              label: 'Instrukcja',
              selectedIcon: Icon(Icons.info),
              icon: Icon(Icons.info_outlined),
            ),
            NavigationDestination(
              label: 'Kalibracja',
              selectedIcon: Icon(Icons.compass_calibration),
              icon: Icon(Icons.compass_calibration_outlined),
            ),
            NavigationDestination(
              label: 'Nowy Pomiar',
              selectedIcon: Badge(
                backgroundColor: Colors.blueAccent,
                label: Icon(Icons.edit, size: 12.0, color: Colors.white),
                child: Icon(Icons.add_circle),
              ),
              icon: Badge(
                backgroundColor: Colors.blueAccent,
                label: Icon(Icons.edit, size: 12.0, color: Colors.white),
                child: Icon(Icons.add_circle_outline_outlined),
              ),
            ),
            NavigationDestination(
                label: 'Biblioteka',
                selectedIcon: Badge(
                  backgroundColor: Colors.blueAccent,
                  label: Text('3'),
                  child: Icon(Icons.bookmark),
                ),
                icon: Badge(
                  backgroundColor: Colors.blueAccent,
                  label: Text('3'),
                  child: Icon(Icons.bookmark_outline_outlined),
                )),
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

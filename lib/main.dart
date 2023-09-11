import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:c4k_daq/constants.dart';
import 'package:c4k_daq/gateway_url.dart';
import 'package:c4k_daq/version.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'library/library_view.dart';
import 'new_recording/new_recording_view.dart';
import 'information/information_view.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  // Obtain a list of the available cameras on the device.

  // Get a specific camera from the list of available cameras.
  runApp(MaterialApp(
      title: 'C4K DAQ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(57, 165, 221, 1),
            background: Colors.white,
            primary: const Color.fromRGBO(57, 165, 221, 1)),
        // primaryColor: const Color.fromRGBO(22, 88, 232, 1),
        // scaffoldBackgroundColor: Colors.white,
        // secondaryHeaderColor: Colors.white,
        // appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        // backgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: MyHomePage()));
}

class MyHomePage extends StatefulWidget {
  // new recording information
  Map<String, String?> userInformation =
      Map<String, String?>.from(emptyUserInformation());

  Map<String, String?> exerciseVideoMapping =
      Map<String, String?>.from(emptyExerciseVideoMapping);

  bool isRecording() {
    for (var element in userInformation.values) {
      if (element != null && element != "") return true;
    }
    for (var element in exerciseVideoMapping.values) {
      if (element != null) return true;
    }
    return false;
  }

  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  int noDirectoriesInFile = 0;

  clearData() {
    widget.exerciseVideoMapping =
        Map<String, String?>.from(emptyExerciseVideoMapping);
    widget.userInformation = Map<String, String?>.from(emptyUserInformation());
    _noLoadedFiles();
  }

  void copyToSDCard() async {
    String originalDirectory = (await getApplicationDocumentsDirectory()).path;
    List<FileSystemEntity> directoriesInFile = [];
    try {
      directoriesInFile = Directory("$originalDirectory/c4k_daq/").listSync();
    } on PathNotFoundException {
      debugPrint("No directory named c4k_daq");
      return;
    }
    if (directoriesInFile.isEmpty) return;

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    String finalDirectoryPath = '/storage/emulated/0/Download/c4k_daq/';
    Directory(finalDirectoryPath).createSync();
    for (FileSystemEntity file in directoriesInFile) {
      String filename = file.path.toString().split('/').last;
      if (filename.contains(".mp4")) {
        File(file.path).copy("$finalDirectoryPath$filename.encrypted");
      } else {
        File(file.path).copy("$finalDirectoryPath$filename");
      }
    }
  }

  void addMeasurementForDebug() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    Directory("$directory/c4k_daq/").createSync();

    String uid = const Uuid().v4();

    void helper(String from, String to) async {
      ByteData bytes =
          await rootBundle.load("assets/$from.mp4"); //load sound from assets

      Uint8List vidBytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

      XFile.fromData(vidBytes)
          .saveTo("$directory/c4k_daq/${uid}_debug_exercise_$to.mp4");
    }

    helper("123", "1");
    helper("123", "2");
    helper("123", "3");

    helper("456", "4");
    helper("456", "5");
    helper("456", "6");

    helper("789", "7");
    helper("789", "8");
    helper("789", "9");

    File("$directory/c4k_daq/$uid.json").writeAsString(
        json.encode({
          ...{"unique_id": uid},
          ...{
            id: Random().nextInt(20000).toString(),
            height: (Random().nextInt(160) + 100).toString(),
            noseToFloor: (Random().nextInt(130) + 90).toString(),
            collarBoneToFloor: (Random().nextInt(100) + 80).toString(),
            pelvisToFloor: (Random().nextInt(70) + 20).toString(),
          },
          ...{
            "exercise_1": "$directory/c4k_daq/${uid}_debug_exercise_1.mp4",
            "exercise_2": "$directory/c4k_daq/${uid}_debug_exercise_2.mp4",
            "exercise_3": "$directory/c4k_daq/${uid}_debug_exercise_3.mp4",
            "exercise_4": "$directory/c4k_daq/${uid}_debug_exercise_4.mp4",
            "exercise_5": "$directory/c4k_daq/${uid}_debug_exercise_5.mp4",
            "exercise_6": "$directory/c4k_daq/${uid}_debug_exercise_6.mp4",
            "exercise_7": "$directory/c4k_daq/${uid}_debug_exercise_7.mp4",
            "exercise_8": "$directory/c4k_daq/${uid}_debug_exercise_8.mp4",
            "exercise_9": "$directory/c4k_daq/${uid}_debug_exercise_9.mp4",
          },
          ...{"measurement_time": "${DateTime.now()}"},
          ...{"app_version": appVersion}
        }),
        flush: true);
  }

  void addIncompleteMeasurementForDebug() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    Directory("$directory/c4k_daq/").createSync();

    String uid = const Uuid().v4();

    void helper(String from, String to) async {
      ByteData bytes =
          await rootBundle.load("assets/$from.mp4"); //load sound from assets

      Uint8List vidBytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

      XFile.fromData(vidBytes)
          .saveTo("$directory/c4k_daq/${uid}_debug_exercise_$to.mp4");
    }

    helper("123", "1");
    helper("123", "2");
    helper("123", "3");

    helper("456", "4");
    helper("456", "6");

    helper("789", "7");
    helper("789", "8");
    helper("789", "9");

    File("$directory/c4k_daq/$uid.json").writeAsString(
        json.encode({
          ...{"unique_id": uid},
          ...{
            id: Random().nextInt(20000).toString(),
            height: (Random().nextInt(160) + 100).toString(),
            noseToFloor: (Random().nextInt(130) + 90).toString(),
            collarBoneToFloor: (Random().nextInt(100) + 80).toString(),
            pelvisToFloor: (Random().nextInt(70) + 20).toString(),
          },
          ...{
            "exercise_1": "$directory/c4k_daq/${uid}_debug_exercise_1.mp4",
            "exercise_2": "$directory/c4k_daq/${uid}_debug_exercise_2.mp4",
            "exercise_3": "$directory/c4k_daq/${uid}_debug_exercise_3.mp4",
            "exercise_4": "$directory/c4k_daq/${uid}_debug_exercise_4.mp4",
            "exercise_6": "$directory/c4k_daq/${uid}_debug_exercise_6.mp4",
            "exercise_7": "$directory/c4k_daq/${uid}_debug_exercise_7.mp4",
            "exercise_8": "$directory/c4k_daq/${uid}_debug_exercise_8.mp4",
            "exercise_9": "$directory/c4k_daq/${uid}_debug_exercise_9.mp4",
          },
          ...{"measurement_time": "${DateTime.now()}"},
          ...{"app_version": appVersion}
        }),
        flush: true);
  }

  void _updateBadge(int newNoDirectoriesInFile) {
    setState(() => noDirectoriesInFile = newNoDirectoriesInFile);
  }

  void listFilesInDirectory() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    List<FileSystemEntity> directoriesInFile = [];
    try {
      directoriesInFile = Directory("$directory/c4k_daq/").listSync();
    } on PathNotFoundException {
      debugPrint("No directory named c4k_daq");
    }
    debugPrint(directoriesInFile.toString());
  }

  void _noLoadedFiles() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    List<String> directoriesInFile = [];
    try {
      Directory("$directory/c4k_daq/")
          .listSync()
          .forEach((element) => directoriesInFile.add(element.path));
    } on PathNotFoundException {
      debugPrint("No directory named c4k_daq");
    }
    var iter = directoriesInFile.iterator;
    noDirectoriesInFile = directoriesInFile.length;

    while (iter.moveNext()) {
      if (iter.current.contains('.json')) {
        var file = File(iter.current);
        String content = await file.readAsString();

        if (content.isEmpty) {
          noDirectoriesInFile -= 1;
          file.delete();
        }
      } else {
        noDirectoriesInFile -= 1;
      }
    }

    setState(() {});
  }

  _pageTitle() {
    if (currentPageIndex == 0) return "Instrukcja";
    // if (currentPageIndex == 1) return "Kalibracja";
    if (currentPageIndex == 1) return "Nowy Pomiar";
    return "Oczekujące";
  }

  StatefulWidget _getCentralWidget() {
    if (currentPageIndex == 0) return const Information();
    // if (currentPageIndex == 1) return const Calibration();
    if (currentPageIndex == 1) {
      return NewRecording(
        userInformation: () => widget.userInformation,
        exerciseVideoMapping: () => widget.exerciseVideoMapping,
        clearData: clearData,
      );
    }
    return Library(updateBadgeNumber: _updateBadge);
  }

  String deviceID = '';

  _getID() async {
    deviceID = await getId();
  }

  @override
  void initState() {
    super.initState();
    _getID();
    _noLoadedFiles();
  }

  NavigationDestination _newMeasurementIcon() {
    if (widget.isRecording()) {
      return const NavigationDestination(
        label: 'Nowy Pomiar',
        selectedIcon: Badge(
          label: Icon(Icons.edit, size: 12.0, color: Colors.white),
          child: Icon(Icons.add_circle),
        ),
        icon: Badge(
          label: Icon(Icons.edit, size: 12.0, color: Colors.white),
          child: Icon(Icons.add_circle_outline_outlined),
        ),
      );
    } else {
      return const NavigationDestination(
        label: 'Nowy Pomiar',
        selectedIcon: Icon(Icons.add_circle),
        icon: Icon(Icons.add_circle_outline_outlined),
      );
    }
  }

  NavigationDestination _libraryIcon() {
    if (noDirectoriesInFile > 0) {
      return NavigationDestination(
          label: 'Oczekujące',
          selectedIcon: Badge(
            label: Text('$noDirectoriesInFile'),
            child: const Icon(Icons.bookmark),
          ),
          icon: Badge(
            label: Text('$noDirectoriesInFile'),
            child: const Icon(Icons.bookmark_outline_outlined),
          ));
    } else {
      return const NavigationDestination(
        label: 'Oczekujące',
        selectedIcon: Icon(Icons.bookmark),
        icon: Icon(Icons.bookmark_outline_outlined),
      );
    }
  }

  _showDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('C4K DAQ'),
        content: SizedBox(
            height: 200,
            child: Column(children: [
              const Text(
                'Wersja Aplikacji: $appVersion',
              ),
              Text('Wersja urządzenia: $deviceID'),
              const Text('Ścieżka do bramki:\n$gatewayUrl'),
            ])),
        actions: <Widget>[
          FilledButton(
            onPressed: () => {Navigator.pop(context, 'OK')},
            child: const Text('Ok'),
          ),
          if (kDebugMode)
            FilledButton(
              onPressed: () => {addMeasurementForDebug()},
              child: const Text('Add'),
            ),
          if (kDebugMode)
            FilledButton(
              onPressed: () => {addIncompleteMeasurementForDebug()},
              child: const Text('Add Incomplete'),
            ),
          FilledButton(
            onPressed: () =>
                {copyToSDCard(), Navigator.pop(context, 'Wyeksportuj')},
            child: const Text('Wyeksportuj'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: currentPageIndex,
        height: 60,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: <Widget>[
          const NavigationDestination(
            label: 'Instrukcja',
            selectedIcon: Icon(Icons.info),
            icon: Icon(Icons.info_outlined),
          ),
          // const NavigationDestination(
          // label: 'Kalibracja',
          // selectedIcon: Icon(Icons.compass_calibration),
          // icon: Icon(Icons.compass_calibration_outlined),
          // ),
          _newMeasurementIcon(),
          _libraryIcon()
        ],
      ),
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_pageTitle(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 28)),
              IconButton(
                  onPressed: () => _showDialog(),
                  icon: const Image(
                    image: AssetImage('assets/connect4kids_logo_kolor.png'),

                    // width: 100,
                    height: 25,
                  ))
            ],
          )),
      body: Center(child: _getCentralWidget()),
    );
  }
}

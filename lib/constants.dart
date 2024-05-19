import 'dart:convert';
import 'dart:io';

const measurementTime = "measurement_time";

enum MeasurementType { id, number, dropdown, photo, video, save }

enum CameraOrientation { vertical, horizontal, none }

enum MeasurementGroup {
  generalInfo,
  photos,
  poseVideos,
  superPowersVideos,
  save
}

class Measurement {
  late MeasurementType type;
  late String title;
  late String description;
  late MeasurementGroup group;
  late String uniqueKeyword;
  late bool isRequired;
  late CameraOrientation cameraOrientation;
  Measurement(
      {required this.type,
      required this.title,
      required this.description,
      required this.group,
      required this.uniqueKeyword,
      this.cameraOrientation = CameraOrientation.none,
      this.isRequired = false});
}

_generateMeasurementList() async {
  var input = await File("assets/exercises.json").readAsString();
  var map = jsonDecode(input);
  print(map);
  var list = [
    Measurement(
        type: MeasurementType.save,
        title: "",
        description: '',
        group: MeasurementGroup.save,
        uniqueKeyword: "")
  ];
  return list;
}

List<Measurement> measurementList = [
  Measurement(
      type: MeasurementType.id,
      title: 'The Kidly ID',
      description: 'Wpisz Unikatowe ID dziecka',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "theKidlyId",
      isRequired: true),
  Measurement(
      type: MeasurementType.number,
      title: 'Wzrost',
      description: 'Wpisz wzrost [cm]',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "height",
      isRequired: true),
  Measurement(
      type: MeasurementType.number,
      title: 'Wiek',
      description: 'Wpisz wiek [lata]',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "age",
      isRequired: true),
  Measurement(
      type: MeasurementType.dropdown,
      title: 'Płeć',
      description: 'Wybierz biologiczną płeć',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "sex",
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: 'Zdjęcie w pozycji "T"',
      description: 'Zrób zdjęcie w pozycji "T", przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "t_pose_photo_front",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(1) Zdjęcie w pozycji stania na baczność',
      description: 'Zrób zdjęcie w pozycji "na baczność", przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_front",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(2) Zdjęcie w pozycji stania na baczność',
      description:
          'Zrób zdjęcie w pozycji "na baczność", lewym profilem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_left",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(3) Zdjęcie w pozycji stania na baczność',
      description:
          'Zrób zdjęcie w pozycji "na baczność", prawym profilem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_right",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  Measurement(
      type: MeasurementType.video,
      title: "(1) Przejście z punktu D do punktu B",
      description:
          'Nagraj dziecko idące przodem do kamery, z punktu D do punktu B',
      group: MeasurementGroup.poseVideos,
      cameraOrientation: CameraOrientation.vertical,
      uniqueKeyword: "move_from_d_b_1"),
  Measurement(
      type: MeasurementType.video,
      title: "(2) Przejście z punktu D do punktu B",
      description:
          'Nagraj dziecko idące przodem do kamery, z punktu D do punktu B',
      group: MeasurementGroup.poseVideos,
      cameraOrientation: CameraOrientation.vertical,
      uniqueKeyword: "move_from_d_b_2"),
  Measurement(
      type: MeasurementType.video,
      title: "(3) Przejście z punktu D do punktu B",
      description:
          'Nagraj dziecko idące przodem do kamery, z punktu D do punktu B',
      group: MeasurementGroup.poseVideos,
      cameraOrientation: CameraOrientation.vertical,
      uniqueKeyword: "move_from_d_b_3"),
  Measurement(
      type: MeasurementType.video,
      title: "Skok",
      description: 'Nagraj dziecko skaczące 5 razy',
      group: MeasurementGroup.superPowersVideos,
      cameraOrientation: CameraOrientation.vertical,
      uniqueKeyword: "high_jump_5"),
  Measurement(
      type: MeasurementType.video,
      title: "Skip A",
      description: 'Nagraj dziecko wykonujące w miejscu skip A',
      group: MeasurementGroup.superPowersVideos,
      cameraOrientation: CameraOrientation.vertical,
      uniqueKeyword: "skip_a"),
  Measurement(
      type: MeasurementType.video,
      title: "Półprzysiad profilem do kamery",
      description:
          'Nagraj dziecko wykonujące półprzysiad z rękami wyprostowanymi w przód, profilem do kamery',
      group: MeasurementGroup.superPowersVideos,
      cameraOrientation: CameraOrientation.vertical,
      uniqueKeyword: "squat_side"),
  Measurement(
      type: MeasurementType.video,
      title: "Półprzysiad, przodem do kamery",
      description:
          'Nagraj dziecko wykonujące półprzysiad z rękami wyprostowanymi w przód, przodem do kamery',
      group: MeasurementGroup.superPowersVideos,
      cameraOrientation: CameraOrientation.vertical,
      uniqueKeyword: "squat_front"),
  Measurement(
      type: MeasurementType.video,
      title: "Rozkrok, przodem do kamery",
      description:
          'Nagraj dziecko wykonujące rozkrok (szpagat) przodem do kamery',
      group: MeasurementGroup.superPowersVideos,
      cameraOrientation: CameraOrientation.vertical,
      uniqueKeyword: "split_front"),
  Measurement(
      type: MeasurementType.video,
      title: "Podpór przodem",
      description: 'Nagraj dziecko wykonujące podpór przodem',
      group: MeasurementGroup.superPowersVideos,
      cameraOrientation: CameraOrientation.horizontal,
      uniqueKeyword: "plank"),
  Measurement(
      type: MeasurementType.video,
      title: "Ciężarki",
      description:
          'Nagraj dziecko trzymające ciężarki o wadze 1 kg, w pozycji "T"',
      group: MeasurementGroup.superPowersVideos,
      cameraOrientation: CameraOrientation.vertical,
      uniqueKeyword: "strength_doubles"),
  Measurement(
      type: MeasurementType.video,
      title: "(1) Przejście z punktu L do punktu P",
      description:
          'Nagraj dziecko idące profilem do kamery, z punktu L do punktu P',
      group: MeasurementGroup.poseVideos,
      cameraOrientation: CameraOrientation.horizontal,
      uniqueKeyword: "move_from_l_p_1"),
  Measurement(
      type: MeasurementType.video,
      title: "(2) Przejście z punktu L do punktu P",
      description:
          'Nagraj dziecko idące profilem do kamery, z punktu L do punktu P',
      group: MeasurementGroup.poseVideos,
      cameraOrientation: CameraOrientation.horizontal,
      uniqueKeyword: "move_from_l_p_2"),
  Measurement(
      type: MeasurementType.video,
      title: "(3) Przejście z punktu L do punktu P",
      description:
          'Nagraj dziecko idące profilem do kamery, z punktu L do punktu P',
      group: MeasurementGroup.poseVideos,
      cameraOrientation: CameraOrientation.horizontal,
      uniqueKeyword: "move_from_l_p_3"),
  Measurement(
      type: MeasurementType.video,
      title: "Leżenie na brzuchu z kończynami uniesionymi",
      description: 'Nagraj dziecko leżące na brzuchu z kończynami uniesionymi',
      group: MeasurementGroup.superPowersVideos,
      cameraOrientation: CameraOrientation.horizontal,
      uniqueKeyword: "laying_down_banana_style"),
  Measurement(
    type: MeasurementType.video,
    title: "Pompki kobiece, profilem do kamery",
    description: "Nagraj dziecko wykonujące pompki, profilem do kamery",
    group: MeasurementGroup.superPowersVideos,
    uniqueKeyword: "push_ups_easy_side",
    cameraOrientation: CameraOrientation.horizontal,
  ),
  Measurement(
    type: MeasurementType.video,
    title: "Pompki kobiece, przodem do kamery",
    description: "Nagraj dziecko wykonujące pompki, przodem do kamery",
    group: MeasurementGroup.superPowersVideos,
    uniqueKeyword: "push_ups_easy_front",
    cameraOrientation: CameraOrientation.horizontal,
  ),
  Measurement(
    type: MeasurementType.video,
    title: "Bieg wahadłowy 10x5",
    description:
        "Nagraj dziecko wykonujące bieg wahadłowy, 10 razy po 5 metrów",
    group: MeasurementGroup.superPowersVideos,
    uniqueKeyword: "shuttle_run",
    cameraOrientation: CameraOrientation.horizontal,
  ),
  Measurement(
    type: MeasurementType.video,
    title: "Beep test 20 m",
    description: "Nagraj dziecko wykonujące beep test",
    group: MeasurementGroup.superPowersVideos,
    uniqueKeyword: "beep_test_20",
    cameraOrientation: CameraOrientation.horizontal,
  ),
  Measurement(
    type: MeasurementType.video,
    title: "Skok w dal z miejsca",
    description: "Nagraj dziecko wykonujące skok w dal, bokiem do kamery",
    group: MeasurementGroup.superPowersVideos,
    uniqueKeyword: "long_jump",
    cameraOrientation: CameraOrientation.horizontal,
  ),
  Measurement(
      type: MeasurementType.save,
      title: "",
      description: '',
      group: MeasurementGroup.save,
      uniqueKeyword: "")
];


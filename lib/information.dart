import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _Information();
}

class _Information extends State<Information> {
  String version = 'seems empty guy';

  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() => version = packageInfo.version.toString());
  }

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
            "Information view is not yet implemented, but the current version is :$version ",
            style: Theme.of(context).textTheme.headlineMedium));
  }
}

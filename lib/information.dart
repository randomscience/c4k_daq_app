import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _Information();
}

class _Information extends State<Information> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder(
            future: rootBundle.loadString("welcome.md"),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Markdown(
                  data: snapshot.data!,
                  selectable: false,
                  onTapLink: (text, url, title) {
                    launchUrl(Uri.parse(url!),
                        mode: LaunchMode
                            .externalApplication); /*For url_launcher 6.1.0 and higher*/
                    // launch(url);  /*For url_launcher 6.0.20 and lower*/
                  },
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}

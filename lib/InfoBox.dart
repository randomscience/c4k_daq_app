import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoBox extends StatefulWidget {
  const InfoBox({super.key});

  @override
  State<InfoBox> createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> {
  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.grey,
        shadowColor: Colors.black,
        child: Column(children: <Widget>[
          TextField(
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter Unique ID',
              hintText: 'Child ID',
            ),
          ),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              labelText: 'Enter size of the child',
              hintText: 'Height in [cm]',
            ),
          ),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              labelText: 'Enter nose to floor',
              hintText: 'Height in [cm]',
            ),
          ),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              labelText: 'Enter collarbone  to floor',
              hintText: 'Height in [cm]',
            ),
          ),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              labelText: 'Enter d2f of the child',
              hintText: 'Height in [cm]',
            ),
          )
        ]));
  }
}

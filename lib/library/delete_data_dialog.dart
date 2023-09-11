import 'package:flutter/material.dart';

class DeleteDataDialog extends StatefulWidget {
  final String id;
  final String pathToFile;
  final void Function(String) deleteFile;
  final void Function() exitButton;

  const DeleteDataDialog({
    super.key,
    required this.id,
    required this.pathToFile,
    required this.deleteFile,
    required this.exitButton,
  });

  @override
  State<DeleteDataDialog> createState() => _DeleteDataDialogState();
}

class _DeleteDataDialogState extends State<DeleteDataDialog> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: ListBody(
      children: <Widget>[
        Text("Czy na pewno chcesz usunąć: ${widget.id}"),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
                alignment: Alignment.bottomRight,
                child: FilledButton.tonal(
                    onPressed: () => widget.exitButton(),
                    child: const Text('Anuluj'))),
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: FilledButton(
                        onPressed: () => {
                              widget.deleteFile(widget.pathToFile),
                              widget.exitButton()
                            },
                        child: const Text(
                          'Usuń',
                        ))))
          ],
        )
      ],
    ));
  }
}

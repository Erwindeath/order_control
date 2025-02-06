import 'package:flutter/material.dart';

Future<T?> showTextDialog<T>(
  BuildContext context, {
  required String title,
  required String value,
  required TextInputType keyboardType,
}) =>
    showDialog<T>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        value: value,
        keyboardType: keyboardType,
      ),
    );

class TextDialogWidget extends StatefulWidget {
  final String title;
  final String value;
  final TextInputType keyboardType;

  const TextDialogWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.keyboardType,
  }) : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: TextField(
          controller: controller,
          keyboardType: widget.keyboardType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.of(context).pop(controller.text),
          )
        ],
      );
}

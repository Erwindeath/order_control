import 'package:flutter/material.dart';

class EditableDropdown extends StatefulWidget {
  final List<DropdownMenuItem<int>> items;
  final int? value;
  final ValueChanged<int?>? onChanged;

  EditableDropdown({
    Key? key,
    required this.items,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  _EditableDropdownState createState() => _EditableDropdownState();
}

class _EditableDropdownState extends State<EditableDropdown> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return TextField(
        controller: _controller,
        onSubmitted: (value) {
          int? newValue;
          try {
            newValue = int.parse(value);
          } catch (e) {
            // Manejo de errores al convertir el texto a int
          }
          widget.onChanged?.call(newValue);
          setState(() {
            _isEditing = false;
          });
        },
      );
    } else {
      return DropdownButton<int>(
        items: widget.items,
        value: widget.value,
        onChanged: (int? newValue) {
          if (newValue == null) {
            // Un valor nulo indica edición
            setState(() {
              _isEditing = true;
              _controller.text = widget.value?.toString() ?? '';
            });
          } else {
            widget.onChanged?.call(newValue);
          }
        },
        selectedItemBuilder: (BuildContext context) {
          return widget.items.map<Widget>((DropdownMenuItem<int> item) {
            if (item.child is Text) {
              return Text((item.child as Text).data!);
            } else if (item.child is Icon) {
              return item.child as Icon;
            }
            return SizedBox.shrink(); // Devuelve un widget vacío si no es Text o Icon.
          }).toList();
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

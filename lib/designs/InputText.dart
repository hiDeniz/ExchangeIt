import 'package:flutter/material.dart';

class InputText {
  @required
  TextInputType keyboardType;
  @required
  String hint;
  bool obscureText;
  bool enableSuggestions;
  bool autocorrect;

  InputText({
    required this.keyboardType,
    required this.hint,
    this.obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
  });
}

class WidgetInputText extends StatelessWidget {
  final InputText InputText_;
  final Function validator;
  WidgetInputText({required this.InputText_, required this.validator});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: InputText_.keyboardType,
      obscureText: InputText_.obscureText,
      enableSuggestions: InputText_.enableSuggestions,
      autocorrect: InputText_.autocorrect,
      decoration: InputDecoration(
        fillColor: Colors.grey[200],
        filled: true,
        hintText: InputText_.hint,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
      validator: (val) => validator(val),
      onSaved: (val) {
        //func yazılacak
      },
    );
  }
}

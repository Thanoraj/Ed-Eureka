import 'package:ed_eureka/constants.dart';
import 'package:flutter/material.dart';

class LabeledRadioButton extends StatelessWidget {
  const LabeledRadioButton({
    Key key,
    @required this.label,
    @required this.padding,
    @required this.groupValue,
    @required this.value,
    @required this.onChanged,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final groupValue;
  final value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Radio(
              activeColor: kBlueGreen600White,
              toggleable: true,
              groupValue: groupValue,
              value: value,
              onChanged: (newValue) {
                onChanged(newValue);
              },
            ),
            Text(
              label,
              style: TextStyle(color: kBlackGreen600white),
            ),
          ],
        ),
      ),
    );
  }
}

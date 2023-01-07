import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';

class ThVerticalSpacingFormFieldsDefault extends StatelessWidget
    implements IThVerticalSpacingFormFields {
  final double height;

  const ThVerticalSpacingFormFieldsDefault({
    Key? key,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

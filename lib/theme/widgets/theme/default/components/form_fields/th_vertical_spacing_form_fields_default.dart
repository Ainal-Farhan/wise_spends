import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';

class ThVerticalSpacingFormFieldsDefault extends StatelessWidget
    implements IThVerticalSpacingFormFields {
  final double height;

  const ThVerticalSpacingFormFieldsDefault({
    super.key,
    required this.height,
  });

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

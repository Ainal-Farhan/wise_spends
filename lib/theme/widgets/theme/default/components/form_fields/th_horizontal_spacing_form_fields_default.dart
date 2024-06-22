import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_horizontal_spacing_form_fields.dart';

class ThHorizontalSpacingFormFieldsDefault extends StatelessWidget
    implements IThHorizontalSpacingFormFields {
  final double width;

  const ThHorizontalSpacingFormFieldsDefault({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
    );
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

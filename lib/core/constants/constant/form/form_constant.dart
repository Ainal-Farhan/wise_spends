abstract class FormConstant {
  static const FormFieldMode formFieldModeEditable = FormFieldMode.editable;
  static const FormFieldMode formFieldModeReadOnly = FormFieldMode.readOnly;
  static final List<FormFieldMode> formFieldModesList = List.unmodifiable([
    formFieldModeEditable,
    formFieldModeReadOnly,
  ]);
}

enum FormFieldMode {
  editable,
  readOnly,
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Keyboard type options for AppTextField
enum AppTextFieldKeyboardType {
  text,
  number,
  decimal,
  email,
  phone,
  url,
  multiline,
  datetime,
  currency,
}

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String? helperText;
  final String? prefixText;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final String? suffixText;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final AppTextFieldKeyboardType keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCharacterCounter;
  final bool showClearButton;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final FocusNode? focusNode;
  final bool expandable;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final bool enableSuggestions;
  final bool autocorrect;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final AutovalidateMode? autovalidateMode;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.helperText,
    this.prefixText,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixText,
    this.suffixIcon,
    this.suffixWidget,
    this.keyboardType = AppTextFieldKeyboardType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCharacterCounter = false,
    this.showClearButton = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.initialValue,
    this.focusNode,
    this.expandable = false,
    this.contentPadding,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.autovalidateMode,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
    }

    _showClearButton = widget.showClearButton && _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    // Only dispose if we created the controller internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.showClearButton) {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  // Add to _AppTextFieldState
  FormFieldValidator<String>? _buildAutoValidator() {
    FormFieldValidator<String>? autoValidator;

    switch (widget.keyboardType) {
      case AppTextFieldKeyboardType.email:
        autoValidator = (value) {
          if (value != null && value.isNotEmpty) {
            final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$');
            if (!emailRegex.hasMatch(value)) return 'Invalid email address';
          }
          return null;
        };
        break;
      case AppTextFieldKeyboardType.phone:
        autoValidator = (value) {
          if (value != null && value.isNotEmpty) {
            final phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,15}$');
            if (!phoneRegex.hasMatch(value)) return 'Invalid phone number';
          }
          return null;
        };
        break;
      case AppTextFieldKeyboardType.url:
        autoValidator = (value) {
          if (value != null && value.isNotEmpty) {
            final urlRegex = RegExp(r'^https?://[\w\-]+(\.[\w\-]+)+[/#?]?.*$');
            if (!urlRegex.hasMatch(value)) return 'Invalid URL';
          }
          return null;
        };
        break;
      case AppTextFieldKeyboardType.decimal:
      case AppTextFieldKeyboardType.currency:
        autoValidator = (value) {
          if (value != null && value.isNotEmpty) {
            if (double.tryParse(value) == null) return 'Invalid number';
          }
          return null;
        };
        break;
      default:
        break;
    }

    // If a custom validator is provided, chain it after auto-validation
    if (widget.validator != null) {
      final customValidator = widget.validator!;
      if (autoValidator != null) {
        final builtIn = autoValidator;
        return (value) => builtIn(value) ?? customValidator(value);
      }
      return customValidator;
    }

    return autoValidator;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.errorText != null
                  ? AppColors.error
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          decoration: _buildDecoration(),
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          obscureText: _obscureText,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.showCharacterCounter ? widget.maxLength : null,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          textAlign: widget.textAlign,
          textCapitalization: widget.textCapitalization,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          restorationId: widget.restorationId,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          autovalidateMode: widget.autovalidateMode,
          validator: _buildAutoValidator(),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          inputFormatters: _buildInputFormatters(),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTextStyles.captionSmall.copyWith(color: AppColors.error),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(widget.helperText!, style: AppTextStyles.captionSmall),
        ],
      ],
    );
  }

  InputDecoration _buildDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      prefixText: widget.prefixText,
      prefixStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      prefixIcon: _buildPrefixIcon(),
      prefixIconConstraints: const BoxConstraints(
        minWidth: AppTouchTarget.min,
        minHeight: AppTouchTarget.min,
      ),
      suffixText: widget.suffixText,
      suffixStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      suffixIcon: _buildSuffixIcon(),
      suffixIconConstraints: const BoxConstraints(
        minWidth: AppTouchTarget.min,
        minHeight: AppTouchTarget.min,
      ),
      errorText: null, // Handled manually below the field
      errorStyle: AppTextStyles.captionSmall.copyWith(color: AppColors.error),
      errorMaxLines: 2,
      counterText: '', // Hide default counter
      counterStyle: AppTextStyles.captionSmall,
      filled: true,
      fillColor: widget.enabled ? AppColors.surface : AppColors.surfaceVariant,
      contentPadding:
          widget.contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixWidget != null) {
      return widget.prefixWidget;
    }

    if (widget.prefixIcon != null) {
      return Icon(
        widget.prefixIcon,
        color: AppColors.textSecondary,
        size: AppIconSize.md,
      );
    }

    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.showClearButton && _showClearButton) {
      return IconButton(
        icon: const Icon(Icons.clear, size: AppIconSize.sm),
        onPressed: _clearText,
        color: AppColors.textSecondary,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppTouchTarget.min,
          minHeight: AppTouchTarget.min,
        ),
      );
    }

    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          size: AppIconSize.sm,
        ),
        onPressed: _toggleObscureText,
        color: AppColors.textSecondary,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppTouchTarget.min,
          minHeight: AppTouchTarget.min,
        ),
      );
    }

    if (widget.suffixWidget != null) {
      return widget.suffixWidget;
    }

    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: AppColors.textSecondary,
        size: AppIconSize.md,
      );
    }

    return null;
  }

  TextInputType _getKeyboardType() {
    switch (widget.keyboardType) {
      case AppTextFieldKeyboardType.text:
        return TextInputType.text;
      case AppTextFieldKeyboardType.number:
        return TextInputType.number;
      case AppTextFieldKeyboardType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      case AppTextFieldKeyboardType.email:
        return TextInputType.emailAddress;
      case AppTextFieldKeyboardType.phone:
        return TextInputType.phone;
      case AppTextFieldKeyboardType.url:
        return TextInputType.url;
      case AppTextFieldKeyboardType.multiline:
        return TextInputType.multiline;
      case AppTextFieldKeyboardType.datetime:
        return TextInputType.datetime;
      case AppTextFieldKeyboardType.currency:
        return const TextInputType.numberWithOptions(decimal: true);
    }
  }

  List<TextInputFormatter>? _buildInputFormatters() {
    final formatters = <TextInputFormatter>[];

    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }

    if (widget.keyboardType == AppTextFieldKeyboardType.currency) {
      formatters.add(
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      );
    }

    return formatters.isNotEmpty ? formatters : null;
  }
}

/// Currency input field with formatting
class CurrencyTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String currencySymbol;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const CurrencyTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.currencySymbol = 'RM',
    this.enabled = true,
    this.onChanged,
    this.validator,
  });

  @override
  State<CurrencyTextField> createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<CurrencyTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: _controller,
      errorText: widget.errorText,
      prefixText: widget.currencySymbol,
      keyboardType: AppTextFieldKeyboardType.decimal,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      validator: widget.validator,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
    );
  }
}

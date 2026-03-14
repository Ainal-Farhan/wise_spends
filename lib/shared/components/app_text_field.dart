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
  final bool suppressContainer;
  final TextStyle? textStyle;

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
    this.suppressContainer = false,
    this.textStyle,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false;
  bool _isFocused = false;

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();

    _showClearButton = widget.showClearButton && _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.showClearButton) {
      setState(() => _showClearButton = _controller.text.isNotEmpty);
    }
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _toggleObscureText() => setState(() => _obscureText = !_obscureText);

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Border colour logic — single source of truth
  // ─────────────────────────────────────────────────────────────────────────

  Color get _activeBorderColor {
    if (_hasError) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.border;
  }

  Color? get _focusRingColor {
    if (!_isFocused) return null;
    if (_hasError) return AppColors.error.withValues(alpha: 0.12);
    return AppColors.primary.withValues(alpha: 0.12);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _LabelRow(
            label: widget.label!,
            hasError: _hasError,
            enabled: widget.enabled,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],

        // ── Input container ─────────────────────────────────────────────
        if (widget.suppressContainer)
          _buildInputContent()
        else
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.surface
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(
                color: _activeBorderColor,
                width: _isFocused ? 1.5 : 1.0,
              ),
              boxShadow: _focusRingColor != null
                  ? [
                      BoxShadow(
                        color: _focusRingColor!,
                        blurRadius: 0,
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: _buildInputContent(),
          ),

        if (_hasError) ...[
          const SizedBox(height: 5),
          _HelperRow(text: widget.errorText!, isError: true),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 5),
          _HelperRow(text: widget.helperText!),
        ],

        if (widget.showCharacterCounter && widget.maxLength != null)
          _CharacterCounter(
            controller: _controller,
            maxLength: widget.maxLength!,
          ),
      ],
    );
  }

  Widget _buildInputContent() {
    // Multiline gets a slightly different layout with optional footer
    if ((widget.maxLines ?? 1) > 1 || widget.minLines != null) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.prefixWidget != null || widget.prefixIcon != null)
                _PrefixIconContainer(
                  child:
                      widget.prefixWidget ??
                      Icon(
                        widget.prefixIcon,
                        color: _hasError
                            ? AppColors.error
                            : AppColors.textSecondary,
                        size: AppIconSize.md,
                      ),
                ),
              Expanded(child: _buildTextField()),
            ],
          ),
          // Counter footer for multiline
          if (widget.showCharacterCounter && widget.maxLength != null)
            _MultilineCounterFooter(
              controller: _controller,
              maxLength: widget.maxLength!,
            ),
        ],
      );
    }

    // Single-line layout
    return Row(
      children: [
        // Prefix
        if (widget.prefixWidget != null)
          _PrefixIconContainer(child: widget.prefixWidget!)
        else if (widget.prefixIcon != null)
          _PrefixIconContainer(
            child: Icon(
              widget.prefixIcon,
              color: _hasError
                  ? AppColors.error
                  : _isFocused
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: AppIconSize.md,
            ),
          )
        else if (widget.prefixText != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: Text(
              widget.prefixText!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

        // Input
        Expanded(child: _buildTextField()),

        // Suffix
        _buildSuffixArea(),
      ],
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: _buildDecoration(),
      keyboardType: _getKeyboardType(),
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      obscureText: _obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: null, // We handle counter manually
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
      style:
          widget.textStyle ??
          AppTextStyles.bodyMedium.copyWith(
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
    );
  }

  InputDecoration _buildDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      // All border styling is on the AnimatedContainer — keep these invisible
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      // Suppress built-in error/counter rendering — we do it manually
      errorText: null,
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      counterText: '',
      filled: false,
      isDense: true,
      contentPadding:
          widget.contentPadding ??
          EdgeInsets.symmetric(
            horizontal:
                (widget.prefixIcon != null ||
                    widget.prefixWidget != null ||
                    widget.prefixText != null)
                ? AppSpacing.md
                : AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
    );
  }

  Widget _buildSuffixArea() {
    // Clear button
    if (widget.showClearButton && _showClearButton) {
      return _SuffixButton(
        onTap: _clearText,
        child: const Icon(Icons.close_rounded, size: 16),
      );
    }

    // Password visibility toggle
    if (widget.obscureText) {
      return _SuffixButton(
        onTap: _toggleObscureText,
        hasDivider: true,
        child: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: AppIconSize.sm,
        ),
      );
    }

    // Custom suffix widget
    if (widget.suffixWidget != null) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: widget.suffixWidget,
      );
    }

    // Suffix icon
    if (widget.suffixIcon != null) {
      return _PrefixIconContainer(
        child: Icon(
          widget.suffixIcon,
          color: AppColors.textSecondary,
          size: AppIconSize.md,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Auto-validator (unchanged logic, same as before)
  // ─────────────────────────────────────────────────────────────────────────

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

// =============================================================================
// Sub-widgets
// =============================================================================

class _LabelRow extends StatelessWidget {
  final String label;
  final bool hasError;
  final bool enabled;

  const _LabelRow({
    required this.label,
    required this.hasError,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        color: hasError
            ? AppColors.error
            : enabled
            ? AppColors.textPrimary
            : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _HelperRow extends StatelessWidget {
  final String text;
  final bool isError;

  const _HelperRow({required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isError) ...[
          Icon(Icons.error_outline_rounded, size: 13, color: AppColors.error),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.captionSmall.copyWith(
              color: isError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterCounter extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;

  const _CharacterCounter({required this.controller, required this.maxLength});

  @override
  State<_CharacterCounter> createState() => _CharacterCounterState();
}

class _CharacterCounterState extends State<_CharacterCounter> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final count = widget.controller.text.length;
    final isNearLimit = count >= widget.maxLength * 0.85;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$count / ${widget.maxLength}',
          style: AppTextStyles.captionSmall.copyWith(
            color: isNearLimit ? AppColors.error : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

/// Character counter inside the multiline field's footer bar
class _MultilineCounterFooter extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;

  const _MultilineCounterFooter({
    required this.controller,
    required this.maxLength,
  });

  @override
  State<_MultilineCounterFooter> createState() =>
      _MultilineCounterFooterState();
}

class _MultilineCounterFooterState extends State<_MultilineCounterFooter> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final count = widget.controller.text.length;
    final isNearLimit = count >= widget.maxLength * 0.85;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$count / ${widget.maxLength}',
          style: AppTextStyles.captionSmall.copyWith(
            color: isNearLimit ? AppColors.error : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

class _PrefixIconContainer extends StatelessWidget {
  final Widget child;

  const _PrefixIconContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppTouchTarget.min,
      height: AppTouchTarget.min,
      child: Center(child: child),
    );
  }
}

/// Suffix button — used for clear + password toggle
class _SuffixButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool hasDivider;

  const _SuffixButton({
    required this.onTap,
    required this.child,
    this.hasDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppTouchTarget.min,
        height: AppTouchTarget.min,
        decoration: hasDivider
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.divider, width: 0.5),
                ),
              )
            : null,
        child: Center(
          child: IconTheme(
            data: const IconThemeData(color: AppColors.textSecondary),
            child: child,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CurrencyTextField — unchanged API, inherits new AppTextField styling
// =============================================================================

class CurrencyTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String currencySymbol;
  final bool enabled;
  final bool readOnly;
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
    this.readOnly = false,
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
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint ?? '0.00',
      controller: _controller,
      errorText: widget.errorText,
      prefixText: widget.currencySymbol,
      keyboardType: AppTextFieldKeyboardType.decimal,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      textAlign: TextAlign.right,
      onChanged: widget.readOnly ? null : widget.onChanged,
      validator: widget.validator,
      inputFormatters: widget.readOnly
          ? null
          : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
    );
  }
}

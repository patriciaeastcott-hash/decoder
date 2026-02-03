/// Accessibility utilities for WCAG 2.1 AAA compliance

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Minimum touch target size for WCAG 2.1 AAA (48x48 dp)
const double kMinTouchTargetSize = 48.0;

/// Minimum contrast ratio for WCAG 2.1 AAA normal text (7:1)
const double kMinContrastRatioAAA = 7.0;

/// Minimum contrast ratio for WCAG 2.1 AAA large text (4.5:1)
const double kMinContrastRatioLargeAAA = 4.5;

/// Widget that ensures minimum touch target size
class AccessibleTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;

  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kMinTouchTargetSize,
            minHeight: kMinTouchTargetSize,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Accessible icon button with minimum touch target
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final Color? color;
  final double size;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: kMinTouchTargetSize,
          minHeight: kMinTouchTargetSize,
        ),
      ),
    );
  }
}

/// Heading widget with proper semantic level
class AccessibleHeading extends StatelessWidget {
  final String text;
  final int level; // 1-6 for h1-h6
  final TextStyle? style;
  final TextAlign? textAlign;

  const AccessibleHeading({
    super.key,
    required this.text,
    this.level = 1,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final defaultStyle = switch (level) {
      1 => theme.headlineLarge,
      2 => theme.headlineMedium,
      3 => theme.headlineSmall,
      4 => theme.titleLarge,
      5 => theme.titleMedium,
      _ => theme.titleSmall,
    };

    return Semantics(
      header: true,
      child: Text(
        text,
        style: style ?? defaultStyle,
        textAlign: textAlign,
      ),
    );
  }
}

/// Image with required alt text for accessibility
class AccessibleImage extends StatelessWidget {
  final ImageProvider image;
  final String altText;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool decorative;

  const AccessibleImage({
    super.key,
    required this.image,
    required this.altText,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.decorative = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: decorative ? null : altText,
    );

    if (decorative) {
      return ExcludeSemantics(child: imageWidget);
    }

    return Semantics(
      label: altText,
      image: true,
      child: imageWidget,
    );
  }
}

/// List item with proper accessibility
class AccessibleListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final int? index;
  final int? total;

  const AccessibleListItem({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.index,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    String? label = semanticLabel;
    if (index != null && total != null) {
      label = '${label ?? ''} Item ${index! + 1} of $total'.trim();
    }

    return Semantics(
      label: label,
      hint: semanticHint,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Progress indicator with accessible label
class AccessibleProgressIndicator extends StatelessWidget {
  final double? value;
  final String semanticLabel;
  final Color? color;

  const AccessibleProgressIndicator({
    super.key,
    this.value,
    required this.semanticLabel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progressText = value != null
        ? '${(value! * 100).toInt()}% complete'
        : 'Loading';

    return Semantics(
      label: '$semanticLabel, $progressText',
      child: value != null
          ? LinearProgressIndicator(value: value, color: color)
          : LinearProgressIndicator(color: color),
    );
  }
}

/// Form field with proper accessibility
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final int? maxLength;
  final bool required;

  const AccessibleTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.maxLines = 1,
    this.maxLength,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: required ? '$labelText (required)' : labelText,
      hint: hintText,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: required ? '$labelText *' : labelText,
          hintText: hintText,
          errorText: errorText,
          helperText: helperText,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        maxLines: maxLines,
        maxLength: maxLength,
      ),
    );
  }
}

/// Announce message to screen readers
void announceToScreenReader(String message, {TextDirection direction = TextDirection.ltr}) {
  SemanticsService.announce(message, direction);
}

/// Format number for screen reader
String formatNumberForScreenReader(int number) {
  if (number == 0) return 'zero';
  if (number == 1) return 'one';
  return number.toString();
}

/// Format percentage for screen reader
String formatPercentageForScreenReader(double value) {
  final percent = (value * 100).round();
  return '$percent percent';
}

/// Check if animations should be reduced
bool shouldReduceAnimations(BuildContext context) {
  return MediaQuery.of(context).disableAnimations;
}

/// Get appropriate animation duration based on reduce motion setting
Duration getAnimationDuration(BuildContext context, {Duration normal = const Duration(milliseconds: 300)}) {
  if (shouldReduceAnimations(context)) {
    return Duration.zero;
  }
  return normal;
}

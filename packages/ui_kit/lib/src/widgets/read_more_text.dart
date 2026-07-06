// Based on the `readmore` package by jonataslaw.
// Original source: https://github.com/jonataslaw/readmore
// Licensed under the MIT License.

import 'dart:ui' as ui show TextHeightBehavior;

import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// TrimMode defines the method by which the text will be trimmed in the [SaReadMoreText] widget.
enum TrimMode {
  /// Trim by a specified number of characters.
  length,

  /// Trim by a specified number of lines.
  line,
}

const String _kEllipsis = '\u2026';

/// A builder for the expand and collapse buttons.
typedef ReadMoreButtonBuilder = Widget Function(BuildContext context, VoidCallback onTap);

/// Defines a customizable pattern within text, such as hashtags, URLs, or mentions.
///
/// Enables applying custom styles and interactions to matched patterns,
/// enhancing text interactivity. Utilize this class to highlight specific text
/// segments or to add clickable functionality, facilitating navigation or other actions.
@immutable
class Annotation {
  /// Creates an [Annotation] instance.
  const Annotation({
    required this.regExp,
    required this.spanBuilder,
  });

  /// The regular expression pattern used to identify text segments for annotation.
  final RegExp regExp;

  /// A builder function that generates a [TextSpan] for the matched text segment.
  final TextSpan Function(String text, TextStyle textStyle) spanBuilder;
}

/// A widget that displays text with a "read more" functionality, allowing users to expand and collapse long text content.
class SaReadMoreText extends StatefulWidget {
  /// Creates a [SaReadMoreText] widget.
  const SaReadMoreText(
    String this.data, {
    super.key,
    this.expandButtonLabel = 'Read more',
    this.collapseButtonLabel = 'Show less',
    this.actionButtonStyle,
    this.isCollapsed,
    this.preDataText,
    this.postDataText,
    this.preDataTextStyle,
    this.postDataTextStyle,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = TrimMode.length,
    this.delimiter = _kEllipsis,
    this.annotations,
    this.isExpandable = true,
    this.showExpandableGradient = true,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : richData = null,
       richPreData = null,
       richPostData = null;

  /// Creates a [SaReadMoreText] widget with rich text support.
  const SaReadMoreText.rich(
    TextSpan this.richData, {
    super.key,
    this.expandButtonLabel = 'Read more',
    this.collapseButtonLabel = 'Show less',
    this.actionButtonStyle,
    this.richPreData,
    this.richPostData,
    this.isCollapsed,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = TrimMode.length,
    this.delimiter = _kEllipsis,
    this.isExpandable = true,
    this.showExpandableGradient = true,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : data = null,
       annotations = null,
       preDataText = null,
       postDataText = null,
       preDataTextStyle = null,
       postDataTextStyle = null;

  /// Text label for the expand button (e.g., "Show all").
  final String expandButtonLabel;

  /// Text label for the collapse button (e.g., "Hide").
  final String collapseButtonLabel;

  /// Action button text style.
  final TextStyle? actionButtonStyle;

  /// Duration for the expand/collapse animation.
  final Duration animationDuration;

  /// Curve for the expand/collapse animation.
  final Curve animationCurve;

  /// External control of the collapsed state. If null, the widget manages its own state internally.
  final ValueNotifier<bool>? isCollapsed;

  /// Used on TrimMode.Length
  final int trimLength;

  /// Used on TrimMode.Lines
  final int trimLines;

  /// Determines the type of trim. TrimMode.Length takes into account
  /// the number of letters, while TrimMode.Lines takes into account
  /// the number of lines
  final TrimMode trimMode;

  /// Textspan used before the data any heading or something
  final String? preDataText;

  /// Textspan used after the data end or before the more/less
  final String? postDataText;

  /// Textspan used before the data any heading or something
  final TextStyle? preDataTextStyle;

  /// Textspan used after the data end or before the more/less
  final TextStyle? postDataTextStyle;

  /// Rich version of [preDataText]
  final TextSpan? richPreData;

  /// Rich version of [postDataText]
  final TextSpan? richPostData;

  /// A list of [Annotation] objects defining patterns to be annotated within the text.
  final List<Annotation>? annotations;

  /// Expand text on readMore press
  final bool isExpandable;

  /// Whether to show a gradient overlay at the bottom of the text when it is collapsed, indicating that there is more content to read.
  final bool showExpandableGradient;

  /// The delimiter to display between the trimmed text and the "read more" link when the text is collapsed.
  final String delimiter;

  /// The main text content to display, which can be trimmed and expanded based on user interaction.
  final String? data;

  /// The rich text content to display, which can be trimmed and expanded based on user interaction.
  final TextSpan? richData;

  /// The style to use for the text.
  final TextStyle? style;

  /// The strut style to apply to the text.
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can be rendered differently.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  final bool? softWrap;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// The text scaler to apply to the text.
  final TextScaler? textScaler;

  /// The strategy to use when calculating the width of the text.
  final String? semanticsLabel;

  /// The strategy to use when calculating the width of the text.
  final TextWidthBasis? textWidthBasis;

  /// The text height behavior to apply to the text.
  final ui.TextHeightBehavior? textHeightBehavior;

  /// The color to use when painting the selection.
  final Color? selectionColor;

  @override
  State<SaReadMoreText> createState() => _SaReadMoreTextState();
}

class _SaReadMoreTextState extends State<SaReadMoreText> {
  static final _nonCapturingGroupPattern = RegExp(r'\((?!\?:)');

  ValueNotifier<bool>? _isCollapsed;
  ValueNotifier<bool> get _effectiveIsCollapsed =>
      widget.isCollapsed ?? (_isCollapsed ??= ValueNotifier(true));

  void _onTap() {
    if (widget.isExpandable) {
      _effectiveIsCollapsed.value = !_effectiveIsCollapsed.value;
    }
  }

  RegExp? _mergeRegexPatterns(List<Annotation>? annotations) {
    if (annotations == null || annotations.isEmpty) {
      return null;
    } else if (annotations.length == 1) {
      return annotations[0].regExp;
    }

    return RegExp(
      annotations
          .map(
            (a) => '(${a.regExp.pattern.replaceAll(_nonCapturingGroupPattern, '(?:')})',
          )
          .join('|'),
    );
  }

  @override
  void didUpdateWidget(SaReadMoreText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCollapsed == null && oldWidget.isCollapsed != null) {
      final oldValue = oldWidget.isCollapsed!.value;
      (_isCollapsed ??= ValueNotifier(oldValue)).value = oldValue;
    }
  }

  @override
  void dispose() {
    _isCollapsed?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _effectiveIsCollapsed,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, bool isCollapsed, Widget? child) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle;
    if (widget.style == null || widget.style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    } else {
      effectiveTextStyle = widget.style!;
    }
    if (MediaQuery.boldTextOf(context)) {
      effectiveTextStyle = effectiveTextStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    final registrar = SelectionContainer.maybeOf(context);
    final textScaler = widget.textScaler ?? MediaQuery.textScalerOf(context);

    final textAlign = widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);
    final softWrap = widget.softWrap ?? defaultTextStyle.softWrap;
    final overflow = widget.overflow ?? defaultTextStyle.overflow;
    final textWidthBasis = widget.textWidthBasis ?? defaultTextStyle.textWidthBasis;
    final textHeightBehavior =
        widget.textHeightBehavior ??
        defaultTextStyle.textHeightBehavior ??
        DefaultTextHeightBehavior.maybeOf(context);
    final selectionColor =
        widget.selectionColor ??
        DefaultSelectionStyle.of(context).selectionColor ??
        DefaultSelectionStyle.defaultColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        assert(constraints.hasBoundedWidth, 'SaReadMoreText requires a bounded width constraint.');
        final maxWidth = constraints.maxWidth;

        TextSpan? preTextSpan;
        TextSpan? postTextSpan;

        if (widget.richPreData != null) {
          preTextSpan = widget.richPreData;
        } else if (widget.preDataText != null) {
          preTextSpan = TextSpan(
            text: '${widget.preDataText!} ',
            style: widget.preDataTextStyle ?? effectiveTextStyle,
          );
        }

        if (widget.richPostData != null) {
          postTextSpan = widget.richPostData;
        } else if (widget.postDataText != null) {
          postTextSpan = TextSpan(
            text: ' ${widget.postDataText!}',
            style: widget.postDataTextStyle ?? effectiveTextStyle,
          );
        }

        final TextSpan dataTextSpan;
        if (widget.richData != null) {
          dataTextSpan = TextSpan(
            style: effectiveTextStyle,
            children: [widget.richData!],
          );
        } else {
          dataTextSpan = _buildAnnotatedTextSpan(
            data: widget.data!,
            textStyle: effectiveTextStyle,
            regExp: _mergeRegexPatterns(widget.annotations),
            annotations: widget.annotations,
          );
        }

        final text = TextSpan(
          children: [
            ?preTextSpan,
            dataTextSpan,
            ?postTextSpan,
          ],
        );

        final textPainter = TextPainter(
          text: text,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          textScaler: textScaler,
          maxLines: widget.trimLines,
          strutStyle: widget.strutStyle,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          ellipsis: overflow == TextOverflow.ellipsis ? widget.delimiter : null,
        )..layout(minWidth: constraints.minWidth, maxWidth: maxWidth);

        late final TextSpan textSpan;
        var needsExpansion = false;

        switch (widget.trimMode) {
          case TrimMode.length:
            if (widget.richData != null) {
              final trimResult = _trimTextSpan(
                textSpan: dataTextSpan,
                spanStartIndex: 0,
                endIndex: widget.trimLength,
                splitByRunes: true,
              );

              if (trimResult.didTrim) {
                needsExpansion = true;
                textSpan = TextSpan(
                  children: [
                    if (isCollapsed) trimResult.textSpan else dataTextSpan,
                    if (isCollapsed && widget.delimiter.isNotEmpty)
                      TextSpan(text: widget.delimiter),
                  ],
                );
              } else {
                textSpan = dataTextSpan;
              }
            } else {
              if (widget.trimLength < widget.data!.runes.length) {
                needsExpansion = true;
                final effectiveDataTextSpan = isCollapsed
                    ? _trimTextSpan(
                        textSpan: dataTextSpan,
                        spanStartIndex: 0,
                        endIndex: widget.trimLength,
                        splitByRunes: true,
                      ).textSpan
                    : dataTextSpan;

                textSpan = TextSpan(
                  children: <TextSpan>[
                    effectiveDataTextSpan,
                    if (isCollapsed && widget.delimiter.isNotEmpty)
                      TextSpan(text: widget.delimiter),
                  ],
                );
              } else {
                textSpan = dataTextSpan;
              }
            }
          case TrimMode.line:
            if (textPainter.didExceedMaxLines) {
              needsExpansion = true;

              final pos = textPainter.getPositionForOffset(
                textPainter.size.bottomRight(Offset.zero),
              );
              final endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;

              final effectiveDataTextSpan = isCollapsed
                  ? _trimTextSpan(
                      textSpan: dataTextSpan,
                      spanStartIndex: 0,
                      endIndex: endIndex,
                      splitByRunes: false,
                    ).textSpan
                  : dataTextSpan;

              textSpan = TextSpan(
                children: <TextSpan>[
                  effectiveDataTextSpan,
                  if (isCollapsed && widget.delimiter.isNotEmpty) TextSpan(text: widget.delimiter),
                ],
              );
            } else {
              textSpan = dataTextSpan;
            }
        }

        Widget richTextResult = RichText(
          text: TextSpan(
            style: effectiveTextStyle,
            children: [
              ?preTextSpan,
              textSpan,
              ?postTextSpan,
            ],
          ),
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaler: textScaler,
          strutStyle: widget.strutStyle,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionRegistrar: registrar,
          selectionColor: selectionColor,
        );

        if (registrar != null) {
          richTextResult = MouseRegion(
            cursor: DefaultSelectionStyle.of(context).mouseCursor ?? SystemMouseCursors.text,
            child: richTextResult,
          );
        }
        if (widget.semanticsLabel != null) {
          richTextResult = Semantics(
            textDirection: widget.textDirection,
            label: widget.semanticsLabel,
            child: ExcludeSemantics(
              child: richTextResult,
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              alignment: Alignment.topCenter,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  richTextResult,
                  if (needsExpansion &&
                      widget.isExpandable &&
                      isCollapsed &&
                      widget.showExpandableGradient)
                    _buildExpandButton(context),
                ],
              ),
            ),
            if (needsExpansion &&
                widget.isExpandable &&
                (!isCollapsed || !widget.showExpandableGradient))
              _buildActionButton(),
          ],
        );
      },
    );
  }

  Widget _buildActionButton() {
    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _onTap,
          child: SaText(
            _effectiveIsCollapsed.value ? widget.expandButtonLabel : widget.collapseButtonLabel,
            style: widget.actionButtonStyle ?? AppTextStyle.bodyBold,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 28),
      decoration: widget.showExpandableGradient
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor.withValues(alpha: 0),
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            )
          : null,
      child: _buildActionButton(),
    );
  }

  TextSpan _buildAnnotatedTextSpan({
    required String data,
    required TextStyle textStyle,
    required RegExp? regExp,
    required List<Annotation>? annotations,
  }) {
    if (regExp == null || data.isEmpty) {
      return TextSpan(text: data, style: textStyle);
    }

    final contents = <TextSpan>[];

    data.splitMapJoin(
      regExp,
      onMatch: (regexMatch) {
        final matchedText = regexMatch.group(0)!;
        late final Annotation matchedAnnotation;

        if (annotations!.length == 1) {
          matchedAnnotation = annotations[0];
        } else {
          for (var i = 0; i < regexMatch.groupCount; i++) {
            if (matchedText == regexMatch.group(i + 1)) {
              matchedAnnotation = annotations[i];
              break;
            }
          }
        }

        final content = matchedAnnotation.spanBuilder(matchedText, textStyle);
        contents.add(content);

        return '';
      },
      onNonMatch: (unmatchedText) {
        contents.add(TextSpan(text: unmatchedText));
        return '';
      },
    );

    return TextSpan(style: textStyle, children: contents);
  }

  _TextSpanTrimResult _trimTextSpan({
    required TextSpan textSpan,
    required int spanStartIndex,
    required int endIndex,
    required bool splitByRunes,
  }) {
    var spanEndIndex = spanStartIndex;

    final text = textSpan.text;
    if (text != null) {
      final textLen = splitByRunes ? text.runes.length : text.length;
      spanEndIndex += textLen;

      if (spanEndIndex >= endIndex) {
        final newText = splitByRunes
            ? String.fromCharCodes(text.runes, 0, endIndex - spanStartIndex)
            : text.substring(0, endIndex - spanStartIndex);

        final nextSpan = TextSpan(
          text: newText,
          style: textSpan.style,
          recognizer: textSpan.recognizer,
          mouseCursor: textSpan.mouseCursor,
          onEnter: textSpan.onEnter,
          onExit: textSpan.onExit,
          semanticsLabel: textSpan.semanticsLabel,
          locale: textSpan.locale,
          spellOut: textSpan.spellOut,
        );

        return _TextSpanTrimResult(
          textSpan: nextSpan,
          spanEndIndex: spanEndIndex,
          didTrim: true,
        );
      }
    }

    var didTrim = false;
    final newChildren = <InlineSpan>[];

    final children = textSpan.children;
    if (children != null) {
      for (final child in children) {
        if (child is TextSpan) {
          final result = _trimTextSpan(
            textSpan: child,
            spanStartIndex: spanEndIndex,
            endIndex: endIndex,
            splitByRunes: splitByRunes,
          );

          spanEndIndex = result.spanEndIndex;
          newChildren.add(result.textSpan);

          if (result.didTrim) {
            didTrim = true;
            break;
          }
        } else {
          newChildren.add(child);
        }
      }
    }

    final resultTextSpan = didTrim
        ? TextSpan(
            text: textSpan.text,
            children: newChildren, // update children
            style: textSpan.style,
            recognizer: textSpan.recognizer,
            mouseCursor: textSpan.mouseCursor,
            onEnter: textSpan.onEnter,
            onExit: textSpan.onExit,
            semanticsLabel: textSpan.semanticsLabel,
            locale: textSpan.locale,
            spellOut: textSpan.spellOut,
          )
        : textSpan;

    return _TextSpanTrimResult(
      textSpan: resultTextSpan,
      spanEndIndex: spanEndIndex,
      didTrim: didTrim,
    );
  }
}

@immutable
class _TextSpanTrimResult {
  const _TextSpanTrimResult({
    required this.textSpan,
    required this.spanEndIndex,
    required this.didTrim,
  });

  final TextSpan textSpan;
  final int spanEndIndex;
  final bool didTrim;
}

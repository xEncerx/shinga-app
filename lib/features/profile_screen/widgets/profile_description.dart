import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/extensions.dart';
import '../../../utils/utils.dart';

class ProfileDescription extends StatefulWidget {
  const ProfileDescription({
    super.key,
    required this.description,
    this.onSave,
    this.isReadOnly = false,
  });

  final String? description;
  final Future<void> Function(String)? onSave;
  final bool isReadOnly;

  @override
  State<ProfileDescription> createState() => _ProfileDescriptionState();
}

class _ProfileDescriptionState extends State<ProfileDescription> with TickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  bool _isEditing = false;
  bool _isLoading = false;
  String? _originalText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.description ?? '');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    if (widget.description == null) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startEditing() {
    if (widget.isReadOnly) return;

    setState(() {
      _isEditing = true;
      _originalText = _controller.text;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _controller.text = _originalText ?? '';
    });
  }

  Future<void> _saveDescription() async {
    if (widget.onSave == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave!(_controller.text.trim());
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (_controller.text.isNotEmpty) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showSnackBar(context, 'Failed to save description');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = widget.description != null || _isEditing;

    if (!hasContent && !_isEditing && widget.isReadOnly) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: _isEditing ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'About Me',
                  style: theme.textTheme.titleMedium
                      .withColor(theme.colorScheme.onSurface)
                      .semiBold,
                ),
              ),
              if (!widget.isReadOnly && !_isEditing)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: IconButton(
                    key: const ValueKey('edit'),
                    onPressed: _startEditing,
                    icon: Icon(
                      hasContent ? Icons.edit_outlined : Icons.add,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: _isEditing ? _buildEditingMode(theme) : _buildDisplayMode(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingMode(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: _controller,
            maxLines: 5,
            maxLength: 1000,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Write about yourself...',
              hintStyle: theme.textTheme.bodyMedium.withColor(theme.hintColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: theme.textTheme.bodySmall.withColor(theme.hintColor),
            ),
            style: theme.textTheme.bodyMedium,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1000),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isLoading ? null : _cancelEditing,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _isLoading ? null : _saveDescription,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisplayMode(ThemeData theme) {
    if (widget.description == null) {
      return _buildEmptyState(theme);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    if (widget.isReadOnly) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.edit_note_outlined,
            size: 32,
            color: theme.hintColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Add description',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

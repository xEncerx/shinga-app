import 'package:auto_route/auto_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talker/talker.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/utils.dart';

class ChooseImageAlertDialog extends StatelessWidget {
  const ChooseImageAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        t.profile.cropImage.title,
        style: theme.textTheme.titleLarge,
      ),
      content: GestureDetector(
        onTap: () => _pickImage(context),
        behavior: HitTestBehavior.translucent,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: theme.hintColor,
            radius: const Radius.circular(8),
            strokeWidth: 2,
            dashPattern: const [8, 8],
            strokeCap: StrokeCap.round,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image icon
                Icon(
                  Icons.image,
                  size: 28,
                  color: theme.hintColor,
                ),
                Text(
                  t.profile.cropImage.chooseImage,
                  style: theme.textTheme.bodyMedium.withColor(theme.hintColor),
                ),
              ],
            ),
          ),
        ),
      ).clickable,
      actions: [
        OutlinedButton(
          onPressed: () => context.router.pop(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
          ),
          child: Text(t.common.cancel),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final result = await _requestPermission(context);
    if (!result) return;

    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
      );
      if (pickedFile != null) {
        final imageData = await pickedFile.readAsBytes();
        if (context.mounted) {
          context.router.pop();
          context.router.push(
            CropAvatarRoute(imageData: imageData),
          );
        }
      }
    } catch (e) {
      getIt<Talker>().error('Failed to pick image: $e');
      if (context.mounted) {
        showSnackBar(context, t.profile.cropImage.failedToPickImage);
      }
    }
  }

  Future<bool> _requestPermission(BuildContext context) async {
    final result = await getIt<PermissionService>().requestPhotoPermission();

    if (!result && context.mounted) {
      showSnackBar(context, t.errors.permissionDenied);
      return false;
    }
    return true;
  }
}

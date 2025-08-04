import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../i18n/strings.g.dart';
import '../../../utils/show_snack_bar.dart';
import '../../features.dart';

@RoutePage()
class CropAvatarScreen extends StatefulWidget {
  const CropAvatarScreen({
    super.key,
    required this.imageData,
  });

  final Uint8List imageData;

  @override
  State<CropAvatarScreen> createState() => _CropAvatarScreenState();
}

class _CropAvatarScreenState extends State<CropAvatarScreen> {
  final _cropController = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!_isCropping)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                _cropController.crop();
                setState(() => _isCropping = true);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Crop(
          controller: _cropController,
          image: widget.imageData,
          filterQuality: FilterQuality.high,
          initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
            size: 0.5,
            aspectRatio: 1,
          ),
          progressIndicator: Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: theme.colorScheme.primary,
              size: 52,
            ),
          ),
          baseColor: theme.scaffoldBackgroundColor,
          aspectRatio: 1,
          interactive: !_isCropping,
          fixCropRect: _isCropping,
          withCircleUi: true,
          onCropped: (status) {
            switch (status) {
              case CropSuccess(:final croppedImage):
                context.read<ProfileBloc>().add(UploadUserAvatar(croppedImage));
                context.router.pop();
              case CropFailure():
                showSnackBar(context, t.profile.cropImage.failedToCropImage);
            }
            setState(() => _isCropping = false);
          },
        ),
      ),
    );
  }
}

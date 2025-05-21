import 'package:flutter/material.dart';

class ErrorNotifyContainer extends StatelessWidget {
  const ErrorNotifyContainer({
    super.key,
    required this.title,
    this.description,
  });

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // * Widget on future

    return Center(
      child: SingleChildScrollView(
        child: Column(
          spacing: 5,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall,
            ),
            if (description != null)
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Muestra un mensaje flotante personalizado para reemplazar SnackBar.
Future<void> showFloatingNotification(
  BuildContext context, {
  required String message,
  String? title,
  IconData icon = Icons.info_outline,
  Color? color,
  Duration duration = const Duration(seconds: 2),
}) async {
  final theme = Theme.of(context);
  final bg = color ?? theme.colorScheme.surface;
  final fg = theme.colorScheme.onSurface;
  final navigator = Navigator.of(context, rootNavigator: true);

  final dialogFuture = showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'notification',
    barrierColor: Colors.black.withValues(alpha: 0.15),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (dialogContext, animation, secondaryAnimation) => const SizedBox.shrink(),
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, -0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

      final opacityAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );

      return FadeTransition(
        opacity: opacityAnimation,
        child: SlideTransition(
          position: offsetAnimation,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(16),
                color: bg,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: color ?? theme.colorScheme.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            Text(
                              message,
                              style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: fg,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  Future.delayed(duration, () {
    if (navigator.canPop()) {
      navigator.pop();
    }
  });

  await dialogFuture;
}

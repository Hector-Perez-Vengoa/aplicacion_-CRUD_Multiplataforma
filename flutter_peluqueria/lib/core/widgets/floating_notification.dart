import 'package:flutter/material.dart';

enum NotificationType { success, error, warning, info }

extension NotificationTypeExt on NotificationType {
  Color getBackgroundColor(BuildContext context) {
    switch (this) {
      case NotificationType.success:
        return const Color(0xFF0E0E10); // Negro
      case NotificationType.error:
        return const Color(0xFF0E0E10); // Negro
      case NotificationType.warning:
        return const Color(0xFF0E0E10); // Negro
      case NotificationType.info:
        return const Color(0xFF0E0E10); // Negro
    }
  }

  Color getAccentColor(BuildContext context) {
    switch (this) {
      case NotificationType.success:
        return const Color(0xFFD4AF37); // Oro
      case NotificationType.error:
        return const Color(0xFFD4AF37); // Oro
      case NotificationType.warning:
        return const Color(0xFFD4AF37); // Oro
      case NotificationType.info:
        return const Color(0xFFD4AF37); // Oro
    }
  }

  Color getTextColor() {
    switch (this) {
      case NotificationType.success:
        return Colors.white;
      case NotificationType.error:
        return Colors.white;
      case NotificationType.warning:
        return Colors.white;
      case NotificationType.info:
        return Colors.white;
    }
  }

  Color getBorderColor() {
    switch (this) {
      case NotificationType.success:
        return const Color(0xFFD4AF37).withValues(alpha: 0.5); // Oro semi-transparente
      case NotificationType.error:
        return const Color(0xFFD4AF37).withValues(alpha: 0.5); // Oro semi-transparente
      case NotificationType.warning:
        return const Color(0xFFD4AF37).withValues(alpha: 0.5); // Oro semi-transparente
      case NotificationType.info:
        return const Color(0xFFD4AF37).withValues(alpha: 0.5); // Oro semi-transparente
    }
  }

  IconData getDefaultIcon() {
    switch (this) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }
}

/// Muestra un mensaje flotante personalizado con estilos según el tipo.
Future<void> showFloatingNotification(
  BuildContext context, {
  required String message,
  String? title,
  IconData? icon,
  NotificationType type = NotificationType.info,
  Duration duration = const Duration(seconds: 2),
  Color? color,
}) async {
  final backgroundColor = color ?? type.getBackgroundColor(context);
  final accentColor = type.getAccentColor(context);
  final textColor = type.getTextColor();
  final borderColor = type.getBorderColor();
  final displayIcon = icon ?? type.getDefaultIcon();
  final navigator = Navigator.of(context, rootNavigator: true);

  final dialogFuture = showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'notification',
    barrierColor: Colors.black.withValues(alpha: 0.15),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (dialogContext, animation, secondaryAnimation) => const SizedBox.shrink(),
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, -0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

      final scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

      final opacityAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );

      return FadeTransition(
        opacity: opacityAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 320,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          displayIcon,
                          color: accentColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (title != null)
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: 0.3,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (title != null) const SizedBox(height: 8),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            color: textColor,
                            size: 20,
                          ),
                        ),
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

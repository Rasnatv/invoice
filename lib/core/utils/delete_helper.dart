import 'package:flutter/material.dart';
import 'confirmation_dialogue.dart';

/// Pass in your actual delete logic as [onConfirmed].
Future<void> deleteItem(
    BuildContext context, {
      required Future<void> Function() onConfirmed,
      String itemName = 'item',
    }) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'Delete',
    message: 'Are you sure you want to delete this $itemName? This action cannot be undone.',
    confirmText: 'Delete',
  );

  if (!confirmed) return;
  if (!context.mounted) return;

  await onConfirmed();
}
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NewPage {
  const NewPage({
    this.pageBuilder,
    this.name,
  });

  final String? name;
  final Page<T> Function<T>(BuildContext context, GoRouterState state)?
      pageBuilder;
}

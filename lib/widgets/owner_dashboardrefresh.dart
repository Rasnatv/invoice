import 'package:flutter/foundation.dart';

/// Increment this value (ownerDataRefresh.value++) to tell the owner
/// dashboard and estimates list to reload their data.
final ValueNotifier<int> ownerDataRefresh = ValueNotifier<int>(0);
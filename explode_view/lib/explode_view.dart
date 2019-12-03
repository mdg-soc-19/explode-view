library explode_view;

import 'package:flutter/material.dart';

class ExplodeView extends RefreshIndicator{
  const ExplodeView({
    Key key,
    Widget child,
    RefreshCallback onRefresh,
  }) : super(key: key, child: child, onRefresh: onRefresh);
}
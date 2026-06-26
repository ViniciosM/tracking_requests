import 'package:flutter/material.dart';
import 'package:tracking_requests/core/design_system/utils/enum_visuals.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';

class PriorityDot extends StatelessWidget {
  final RequestPriorityEnum priority;
  const PriorityDot(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: priority.color, shape: BoxShape.circle),
    );
  }
}

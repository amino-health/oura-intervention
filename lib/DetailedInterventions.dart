import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'InterventionsList.dart';

class DetailedIntervention extends StatelessWidget {
  const DetailedIntervention({Key? key, required this.data}) : super(key: key);
  final Intervention? data;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (data != null) Icon(data!.icon),
              Text(
                data?.name ?? "Not selected",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Text(data?.toFullDescription() ?? "", style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailedIntervention extends StatelessWidget {
  const DetailedIntervention({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite),
              Text(
                'Caffeine',
                style: new TextStyle(fontSize: 20),
              ),
            ],
          ),
          Text("Caffeine is a stimulant that can worsen sleep",
              style: new TextStyle(fontSize: 20)),
          Text("200mg", style: new TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

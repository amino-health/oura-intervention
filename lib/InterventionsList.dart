import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Intervention {
  final String name;
  final String description;
  final IconData icon;

  Intervention({
    required this.name,
    required this.description,
    required this.icon,
  });
}

class SupplementIntervention extends Intervention {
  final String dose;

  SupplementIntervention(
    this.dose, {
    required String name,
    required String description,
    required IconData icon,
  }) : super(
          name: name,
          description: description,
          icon: icon,
        );
}

class Instance<T extends Intervention> {
  final T intervention;
  final DateTime time;

  Instance(this.intervention, this.time);
}

class InterventionListItem extends StatelessWidget {
  final Intervention item;

  const InterventionListItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(item.icon),
        Text(item.name),
      ],
    );
  }
}

class InterventionList extends StatelessWidget {
  const InterventionList({Key? key, required this.interventions})
      : super(key: key);
  final List<Intervention> interventions;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return InterventionListItem(
          item: interventions[index],
        );
      },
      itemCount: interventions.length,
    );
  }
}
